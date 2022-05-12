
#CUTTING THE WORLDCLIM BIOCLIMATIC VARIABLES

library(raster)
library(rgdal)
library(sf)

#get the world clim files lovation
world_clim_file_location <- '/Users/laurengomezcullen/Documents/Cambridge/Fourth/Project/final/data/worldclim/global/historical/30s'


#MEXICO AND TEXAS BORDER------------------------------------------------------------------------------------------------------
#Get the required outline
texas_mexico_border_outline_file <- '/Users/laurengomezcullen/Documents/Cambridge/Fourth/Project/final/data/chagas_cases/mexico_border_and_texas_cases/mexico_border_and_texas_cases.shp'
texas_mexico_border_outline <- shapefile(texas_mexico_border_outline_file)

#OR CAN USE EXTENTS IF NEEDED
# mexico extent if needed
# ex <- extent(-120, -80, 10,35)
#colombia extent if needed
# #ex <- extent(-80, -65, -5, 15)

#the current bioclim data had each variable as a different file, and so used this code
for(i in 1:19){
  variable <- paste("bio", i, sep = "")
  file <- paste(world_clim_file_location,"/wc2.1_30s_bio_",i,".tif", sep = "")
  temp_raster <- raster(file)
  raster_crop <- crop(temp_raster, extent(texas_mexico_border_outline))
  raster_masked <- mask(raster_crop, texas_mexico_border_outline)
  file_name <- paste("/Users/laurengomezcullen/maxent/mexico_and_texas/current_bioClim_variables_asc/",variable, ".asc", sep = "" )
  writeRaster(raster_masked, file_name, format="ascii")
}

plot(raster("/Users/laurengomezcullen/maxent/mexico_and_texas/current_bioClim_variables_asc/bio1.asc"))


#the projected data had all bioclim data is in one file, with each variable as a band in a raster stack, so used:
world_clim_location <- '/Users/laurengomezcullen/Documents/Cambridge/Fourth/Project/final/data/worldclim/global/2021-2040/'
file_location <- '/Users/laurengomezcullen/maxent/colombia/future_bioClim_variables/'
pathways <- c('245', '585')

for(k in pathways){
  l <- 0
  for(j in list.files('/Users/laurengomezcullen/Documents/Cambridge/Fourth/Project/final/data/worldclim/global/2021-2040/245/2.5')){
    world_clim_file <- paste(world_clim_location,k,'/2.5/',str_sub(j, end = -18),k,'_2021-2040.tif', sep = "")
    print(world_clim_file)
    l <- l+1
    for(i in 1:19){
      variable <- paste("bio", i, sep = "")
      temp_raster <- raster(world_clim_file, band = i)
      raster_crop <- crop(temp_raster, extent(border_outline_file))
      l_string <- toString(l)
      file_name <- paste(file_location,k,'/model',l_string,"/",variable, ".asc", sep = "" )
      print(file_name)
      NAvalue(raster_crop) <- -9999
      writeRaster(raster_crop, file_name, format="ascii", overwrite=TRUE)
    }
  }
}


