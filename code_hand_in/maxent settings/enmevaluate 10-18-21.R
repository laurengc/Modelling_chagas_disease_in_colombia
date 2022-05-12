#Set working directory
setwd('/Users/laurengomezcullen/maxent/colombia/current_bioClim_variables_asc/2.5m')

library(devtools)
library(rgdal)
library(ENMeval)
library(raster)
library(MASS)
library(foster)

#get the data and assign the correct projection that they are in so that I can used matchResolution
for(i in 1:19){
  name <-  paste("bio",i,sep = "")
  file <- paste("bio", i,".asc", sep = "")
  temp_raster <- raster(file)
  projection(temp_raster) <- CRS("+init=epsg:4326")
  assign(name, temp_raster)
}
land_cover <- raster('/Users/laurengomezcullen/maxent/colombia/current_bioClim_variables_asc/2.5m/biocateg1.asc')
projection(land_cover) <- CRS("+init=epsg:4326")#needed for matchResolution
plot(land_cover)

#require same resolution for the stacking so use matchResolution if I havent dont so already, else just assign the variable
#biocateg1 <- matchResolution(land_cover, bio1, method = 'ngb', filename = "/Users/laurengomezcullen/Documents/Cambridge/Fourth/Project/final/data/land_cover/colombia/historical/10m_resolution/biocateg1.asc", overwrite = TRUE)
biocateg1 <- land_cover

#require the biocateg1 to be defined as a categorical variable
biocateg1 <- as.factor(biocateg1)
#note the categories not included in the area and remove them from the list for landcover
print(biocateg1)

#edit this according to the numbers printed, as not all types of land cover are present in colombia
rat <- levels(biocateg1)[[1]]
rat
# rat$landcover <- c("Water",
#                    "Broadlead evergreen tree, tropical",
#                    "Broadleaf evergreen tree, temperate",
#                    "Broadlead deciduous tree, tropical",
#                    "Broadlead deciduous tree, temperate",
#                    "Broadleaf deciduous tree, boreal",
#                    "Needleleaf evergreen tree, temperate",
#                    "Needleleaf evergreen tree, temperate",
#                    "Needleaf evergreen tree, boreal",
#                    "Needleleaf deciduous tree",
#                    "Broadleaf evergreen shrub, temperate",
#                    "Broadleaf deciduous shrub, temperate",
#                    "Broadleaf deciduous shrub, boreal",
#                    "C3 grass arctic",
#                    "C4 grass",
#                    "Mixed C3,C4 grass",
#                    "Barren",
#                    "Cropland",
#                    "Urban",
#                    "Permanent snow and ice", 
#                   "Ocean")

rat$landcover <- c("Water",
                   "Broadlead evergreen tree, tropical",
                   "Broadleaf evergreen tree, temperate",
                   "Broadlead deciduous tree, tropical",
                   "Broadlead deciduous tree, temperate",
                   "Needleaf evergreen tree, boreal",
                   "Needleleaf deciduous tree",
                   "Broadleaf evergreen shrub, temperate",
                   "Broadleaf deciduous shrub, temperate",
                   "Broadleaf deciduous shrub, boreal",
                   "C3 grass arctic",
                   "C4 grass",
                   "Mixed C3,C4 grass",
                   "Barren",
                   "Cropland",
                   "Urban",
                   "Permanent snow and ice", "Ocean")
rat
levels(biocateg1) <- rat
biocateg1


#Do what's called "stacking" the rasters together into a single r object
env <- stack(bio1, bio2, bio3, bio4, bio5, bio6, bio7, bio8, bio9, bio10, bio11, bio12, bio13, bio14, bio15, bio16, bio17, bio18, bio19, biocateg1)

#Display the stacked environment layer. 

env

#load in your occurrence points
setwd('/Users/laurengomezcullen/maxent/colombia/')
occ <- read.csv("occ.csv")[,-1]
print(occ)

#make a bias file
occur.ras <- rasterize(occ, env, 1)
#for mexico border and texas file unhashtag this
# occ_crop <- crop(occur.ras, extent(bio))
# occ_.ras <- mask(occ_crop, bio)
presences <- which(values(occur.ras) == 1)
pres.locs <- coordinates(occur.ras)[presences, ]
dens <- kde2d(pres.locs[,1], pres.locs[,2], n = c(nrow(occur.ras), ncol(occur.ras)), lims = c(extent(env)[1], extent(env)[2], extent(env)[3], extent(env)[4]))
dens.ras <- raster(dens, env)
dens.ras2 <- resample(dens.ras, env)
plot(dens.ras2)
#bias_layer <-reclassify(dens.ras2 , c(-Inf,0, 2.225074e-308))
bias_layer <- crop(dens.ras2,bio1)
#writeRaster(bias_layer, "/Users/laurengomezcullen/maxent/colombia/biasfile.asc", overwrite = TRUE) #save the bias file

#check how many potential background points you have available, and adjust the number in the bg fucntion accordingly, such that the number is far less than the number of potential background points (i.e. such that the number)
length(which(!is.na(values(subset(env, 1)))))

#bg is the background data
bg <- xyFromCell(dens.ras2, sample(which(!is.na(values(subset(env, 1)))), 10000, prob=values(dens.ras2)[!is.na(values(subset(env, 1)))]))
colnames(bg) <- colnames(occ)

#Execute EnMeval
#I used the "randomkfold" method of cross-validation, with a set of background points sampled based on the bias file, and 10 cross-validation folds. 
#I couldn't use the block split as the software I used for Maxent didn't have this as an option, but for future improvements of the project I would explore doing this as recommended by this article: https://www.tandfonline.com/doi/full/10.1080/13658816.2020.1798968

#use if you have not got categorical data
#enmeval_results <- ENMevaluate(occ, env, bg, tune.args = list(fc = c("L","LQ","H", "LQH", "LQHP", "LQHPT"), rm = 1:5), partitions = "randomkfold", partition.settings = list(kfolds = 10), algorithm = "maxnet")

#use if you have got categorical data use this. If you wish to use the block method
enmeval_results <- ENMevaluate(occ, env, bg, tune.args = list(fc = c("L","LQ","H", "LQH", "LQHP", "LQHPT"), rm = 1:5), partitions = "block",  partition.settings = list(orientation = 'lat_lon'), algorithm = "maxnet", categoricals = "biocateg1")

#use if you have got categorical data use this. If you wish to use the random k fold method
#enmeval_results <- ENMevaluate(occ, env, bg, tune.args = list(fc = c("L","LQ","H", "LQH", "LQHP", "LQHPT"), rm = 1:5), partitions = "randomkfold",  partition.settings = list(kfolds = 10), algorithm = "maxnet", categoricals = "biocateg1")

enmeval_results@results

#write.csv(enmeval_results@results, "/Users/laurengomezcullen/maxent/colombia/enmeval_results_random_k_fold.csv")
