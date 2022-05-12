#cutting the land cover data as needed for colombia and mexico

##CURRENT LAND COVER##------------------------------------------------------------------------------------------------------
#colombia
ex <- extent(-80, -65, -5, 15)
file_world <- raster('/Users/laurengomezcullen/Documents/Cambridge/Fourth/Project/final/data/land_cover/global/historical/global_PFT.asc')
world_cropped <- crop(file_world, ex)
writeRaster(world_cropped, "/Users/laurengomezcullen/maxent/colombia/current_bioClim_variables_asc/PFT.asc", format = 'ascii')

#mexico
ex <- extent(-120, -80, 10,35)
file_world <- raster('/Users/laurengomezcullen/Documents/Cambridge/Fourth/Project/final/data/land_cover/global/historical/global_PFT.asc')
world_cropped <- crop(file_world, ex)
writeRaster(world_cropped, "/Users/laurengomezcullen/maxent/mexico/current_bioClim_variables_asc/PFT.asc", format = 'ascii', overwrite = TRUE)

#mexico border and texas
file_world <- raster('/Users/laurengomezcullen/Documents/Cambridge/Fourth/Project/final/data/land_cover/global/historical/global_PFT.asc')
texas_mexico_border_outline <- raster("/Users/laurengomezcullen/maxent/mexico_and_texas/current_bioClim_variables_asc/bio1.asc")
world_cropped <- crop(file_world,extent(texas_mexico_border_outline))
crs(texas_mexico_border_outline) <- "+init=epsg:4326"
world_resolution <- projectRaster(world_cropped, texas_mexico_border_outline) #need to have the same resolution for masking
world_masked <- mask(world_resolution, texas_mexico_border_outline)
writeRaster(world_masked, "/Users/laurengomezcullen/maxent/mexico_and_texas/current_bioClim_variables_asc/PFT.asc", format = 'ascii', overwrite = TRUE)



##FUTURE LAND COVER ##------------------------------------------------------------------------------------------------------
#change colombia for mexico_and_texas for future land cover projections
pathways <- c('245', '585')
outputs <- c("SSP1_RCP26", "SSP4_RCP60" )

j = 1
for(i in outputs){
  pathway_world_location <- paste("/Volumes/TOSHIBA EXT/vegetation_cover/zenobo/Global PFT-based land projection dataset under SSPs-RCPs/", i, "/global_PFT_",i,"_2040.tif", sep = "")
  file_world <- raster(pathway_world_location)
  crs(file_world) <-"+init=epsg:6933"
  border_outline <- raster('/Users/laurengomezcullen/maxent/colombia/future_bioClim_variables/245/model1/bio1.asc')
  crs(border_outline) <-"+init=epsg:4326"
  file_world <- projectRaster(file_world,border_outline, method = 'ngb')
  file_world <- resample(file_world, border_outline)
  world_cropped <- crop(file_world,extent(border_outline))
  # world_masked <- mask(world_resolution, border_outline, )
  for(k in 1:3){
    location <- paste("/Users/laurengomezcullen/maxent/colombia/future_bioClim_variables/", pathways[[j]], '/model',k,"/biocateg1.asc", sep = "")
    print(location)
    writeRaster(world_cropped, location, format = 'ascii', overwrite = TRUE)
  }
    j <- j +1
}
