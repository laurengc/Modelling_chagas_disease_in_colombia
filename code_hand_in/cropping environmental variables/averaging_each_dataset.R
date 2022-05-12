
# GOAL: to find the average of any of the following variables: 'precpitation', 'maximum temperature', and 'minimum temperature', at 
# every longitude and latitude for a given country, period of 20 years, SSP and model, when I was intending to use data other than 
#worldclim as the server was down 

library(ncdf4)
library(dismo)

average_over_period <- function(file, variable){
    
    #opening one model
    variable = 'precipitation'
    file = '/Users/laurengomezcullen/Documents/Cambridge/Fourth/Project/final/data/bioClimData/monthly/Colombia/_2040/ssp1_2_6/precipitation/awi_cm_1_1_mr.nc'
    print(file)
    nc_data <- nc_open(file)
    print(nc_data)
    
    #assigning the correct string to 'var' depending on the variable of interest
    vars <- list('tasmax', 'tasmin', 'pr')
    names(vars) <-  c('daily_maximum_near_surface_air_temperature', 'daily_minimum_near_surface_air_temperature', 'precipitation')
    
    # set the lat, long and time data
    lon <- ncvar_get(nc_data, "lon")
    lat <- ncvar_get(nc_data, "lat")
    t <- ncvar_get(nc_data, "time")
    
    #getting the variable data from one model and assigning it to an array
    var <- vars[variable]
    variable.array <- ncvar_get(nc_data, var[[1]])
    
    #find the values used for missing data
    fillvalue <- ncatt_get(nc_data, var[[1]], "_FillValue")
    fillvalue
    
    #close the data
    nc_close(nc_data)
    
    #replace all the fill values with the R-standard NA
    variable.array[variable.array == fillvalue$value] <- NA
    dim(variable.array)
    r <- raster(t(variable.array[,,1]), xmn=min(lon), xmx=max(lon), ymn=min(lat), ymx=max(lat), crs=CRS("+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs+ towgs84=0,0,0"))
    r <- flip(r, direction='y')
    plot(r)
    dim(r)
    
    #find the mean value at every longitude and latitude across the twenty years 
    avg_variable <- rowMeans( variable.array , dims = 2 )
return (avg_variable)
}

#
# countries = c('colombia', 'mexico')
# periods = c('_2040', "2060", '_2080', '2100')
# pathways = c('ssp1_2_6', 'ssp2_4_5', 'ssp5_8_5')
# variables = c('daily_maximum_near_surface_air_temperature', 'daily_minimum_near_surface_air_temperature', 'precipitation')

countries = c('colombia', 'mexico')
periods = c('_2040')
pathways = c('ssp1_2_6')
variables = c('daily_maximum_near_surface_air_temperature')

for (country in countries){
  for (period in periods){
    for (SSP in pathways){
      for (variable in variables){
        file_list = get_files(country, period, SSP, variable)
        for (file in file_list){
          avg_variable <- average_over_period(file, variable)
        }
      }
    }
  }
}

