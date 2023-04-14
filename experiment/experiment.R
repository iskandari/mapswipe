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