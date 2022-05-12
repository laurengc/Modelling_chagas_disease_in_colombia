#!/bin/bash
cd '/Users/laurengomezcullen/Documents/Cambridge/Fourth/Project/final/data/bioClimData/nasa_daily'

##list of models, variables, years and pathways needed
# models=( "ACCESS-ESM1-5" "AWI-CM-1-1-MR" "BCC-CSM2-MR" "CMCC-CM2-SR5" "FGOALS-g3" "GISS-E2-1-G" "MIROC-ES2L" "MIROC6" "MPI-ESM1-2-HR" "MPI-ESM1-2-LR" "MRI-ESM2-0" "NorESM2-LM" "NorESM2-MM" )
# pathways=(  "ssp1_2_6"   "ssp2_4_5" "ssp5_8_5" )
# variables=( "daily_maximum_near_surface_air_temperature"  "daily_minimum_near_surface_air_temperature" "precipitation" )
# years=( "2040" "2060" "2080" "2100" )

#dummy data
models=( "ACCESS-ESM1-5" )
pathways=(  "ssp1_2_6"   )
variables=( "daily_maximum_near_surface_air_temperature"  )
years=( "2040" "2060" )

# #making files to place data
# for SSP in "${pathways[@]}" 
# do
#     for variable in "${variables[@]}" 
#     do
#         for year in "${years[@]}"
#         do
#         mkdir -p "colombia/${year}/${SSP}/${variable}"
#         done
#     done
# done

#getting data
for model in "${models}"
do 
    for SSP in "${pathways[@]}" 
    do
        for variable in "${variables[@]}" 
        do
            for year in "${years[@]}"
            do
            cd "/Users/laurengomezcullen/Documents/Cambridge/Fourth/Project/final/data/bioClimData/nasa_daily/colombia/${year}/${SSP}/${variable}"
            wget -o "${model}.nc" "https://ds.nccs.nasa.gov/thredds/ncss/AMES/NEX/GDDP-CMIP6/${model}/${ssp}/r1i1p1f1/${variable}/${variable}_day_${model}_${SSP}_r1i1p1f1_gn_${year}.nc?var=pr&north=15&west=-80&east=-65&south=-5.7&disableProjSubset=on&horizStride=1&time_start=${year}-01-01T12%3A00%3A00Z&time_end=${year}-12-31T12%3A00%3A00Z&timeStride=1&addLatLon=true"
            done
        done
    done
done


    
