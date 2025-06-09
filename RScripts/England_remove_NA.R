library(raster)
# rast = raster("F:/Big Data/DSM_England_2m.tif")
# rast = reclassify(rast, cbind(NA, 0), right = FALSE)
# newproj <- "+proj=lcc +lat_1=48 +lat_2=33 +lon_0=-100 +datum=WGS84"
# rast = projectRaster(rast, crs = raster::crs("EPSG:3857"))
# writeRaster(rast, "C:/tiles/DSM_England_2m_noNA_3857.tif", format = "GTiff",
#             options = c("COMPRESS=DEFLATE","PREDICTOR=3","ZLEVEL=9","BIGTIFF=YES"))


rast = raster("C:/tiles/DSM_England_2M_NA1000_4326.tif")
summary(rast)

rast = reclassify(rast, cbind(NA, 0), right = FALSE)
rast = round(rast, 3)
summary(rast)
writeRaster(rast, "F:/Big Data/DSM_England_2M_round_4326.tif", format = "GTiff",
            options = c("COMPRESS=DEFLATE","PREDICTOR=3","ZLEVEL=9","BIGTIFF=YES"))
