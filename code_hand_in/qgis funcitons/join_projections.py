for i in ['2030', '2050', '2080', '2100']:
    year = i
    for j in ['26','45','60','85']:
        rcp = j
        for k in ['tasmax', 'pr']:
            vrble = k
            if vrble == 'tasmax':
                result = processing.run("qgis:joinbylocationsummary", {'INPUT':'/Users/laurengomezcullen/Documents/Cambridge/Fourth year/Project/data/dana/chagas_vulnerability_final.shp','JOIN':'delimitedtext://file:///Users/laurengomezcullen/Documents/Cambridge/Fourth year/Project/data/dana/projected_texas_climate_data/' + year+ '/bcsd5/' + year + '_' + rcp +'_'+ vrble+ '.csv?delimiter=,&xField=longitude&yField=latitude','PREDICATE':[0,1,2,3,4,5,6],'JOIN_FIELDS':[vrble],'SUMMARIES':[6],'DISCARD_NONMATCHING':False,'OUTPUT':'/Users/laurengomezcullen/Documents/Cambridge/Fourth year/Project/data/dana/projected_texas_climate_data/' + year + '/bcsd5/'+ year + '_' + rcp +'_'+ vrble + '.shp'})
            else:
                result = processing.run("qgis:joinbylocationsummary", {'INPUT':'/Users/laurengomezcullen/Documents/Cambridge/Fourth year/Project/data/dana/projected_texas_climate_data/' + year + '/bcsd5/'+ year + '_' + rcp +'_tasmax.shp','JOIN':'delimitedtext://file:///Users/laurengomezcullen/Documents/Cambridge/Fourth year/Project/data/dana/projected_texas_climate_data/' + year+ '/bcsd5/' + year + '_' + rcp +'_'+ vrble+ '.csv?delimiter=,&xField=longitude&yField=latitude','PREDICATE':[0,1,2,3,4,5,6],'JOIN_FIELDS':[vrble],'SUMMARIES':[6],'DISCARD_NONMATCHING':False,'OUTPUT':'/Users/laurengomezcullen/Documents/Cambridge/Fourth year/Project/data/dana/projected_texas_climate_data/' + year + '/bcsd5/'+ year + '_' + rcp +'_'+ vrble + '.shp'})
                result_layer = QgsVectorLayer(result['OUTPUT'], year + '_' + rcp, 'ogr')
                QgsProject.instance().addMapLayer(result_layer)
            
            
            