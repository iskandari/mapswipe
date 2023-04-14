library(sf)
library(st)
library(ggplot2)
library(tidyverse)
library(geojsonsf)
library(irr)
library(reshape2)
library(dplyr)
library(leaflet)

#Download and place all ARC aggregated results (with geometry)
#in current working directory

#> files
#[1] "agg_results_-Mx0_479a3w9FD9oMv5o_geom.geojson" "agg_results_-Mx1EYoYRWMpdXez_lwY_geom.geojson"
#[3] "agg_results_-MxuKEABaIRO1bvsDGpM_geom.geojson" "agg_results_-MxuOcF64p72sywz07h6_geom.geojson"
#[5] "agg_results_-MyHuIPUp1dUGxL624Iw_geom.geojson" "agg_results_-MyHxnqRUnxW71eGLs1t_geom.geojson"
#[7] "agg_results_-Myiz41plx7m5ya_JlCf_geom.geojson" "agg_results_-Myj30YKB4H3uUKBkzbq_geom.geojson"
#[9] "agg_results_-MyqhHsmKI4yslxt35hn_geom.geojson" "agg_results_-MzMQbpl8xF-cT0yE0H5_geom.geojson"
#[11] "agg_results_-MzQC3aU6HEP6r-oNRbG_geom.geojson" "agg_results_-MzQE0f5HRdwAheBxqNR_geom.geojson"
#[13] "agg_results_-MzQGLRXHkiPtemstALI_geom.geojson" "agg_results_-N-VL-_6Tm_H9AkAv94I_geom.geojson"
#[15] "agg_results_-N01y8krH7ewqrEBdiOI_geom.geojson" "agg_results_-N0b49yCX4V8MBVktKtQ_geom.geojson"
#[17] "agg_results_-N0b64nUkoZYJW1heMXz_geom.geojson" "agg_results_-N2RucZu1TjB5uo3iJoW_geom.geojson"
#[19] "agg_results_-N2RwLr1-QWoirplWaRS_geom.geojson" "agg_results_-N2Rz0puWSnCOMQPEh_v_geom.geojson"

files = list.files(path='.')

for (x in 1:length(files)){ 
  
  if(grepl('_geom.geojson', files[x], fixed=TRUE)){
    
    data = read_sf(files[x])
    print(nrow(data))
    #data = as.data.frame(d)
    data = data[,c('geometry', 'agreement', "0_count" , "0_share", "1_count", "1_share", "2_count", "2_share", "3_count", "3_share", 'total_count', 'username')]
    data$project = files[x]
    data$sum_0 = sum(data$`0_count`)
    data$sum_1 = sum(data$`1_count`)
    data$sum_2 = sum(data$`2_count`)
    data$sum_3 = sum(data$`3_count`)
    
    if(exists('my_obj')) {
      
      
      my_obj = rbind(my_obj, data)  
      
    } else{
      
      my_obj = data
      
    }
    
    if(x==length(files)){ 
      return(my_obj)
    }
  }
}


set.seed(42)

yes_obj = my_obj[(my_obj$`1_share` == 1),]
yes_obj = yes_obj[sample(nrow(yes_obj), 5000),]

no_obj = my_obj[(my_obj$`0_share` == 1),]
no_obj = no_obj[sample(nrow(no_obj), 5000),]

new_obj = rbind(yes_obj, no_obj)
rows <- sample(nrow(new_obj))
new_obj <- new_obj[rows, ]
new_obj = new_obj[!(colnames(new_obj) %in% c( "2_count", "2_share", "3_count" , "3_share", "sum_0", "sum_1", "sum_2", "sum_3" ))]

st_write(new_obj, "experiment.geojson")