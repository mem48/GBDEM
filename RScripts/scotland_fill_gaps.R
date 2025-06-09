library(terra)
library(sf)
library(tmap)
tmap_mode("view")

r_os = rast("D:/OneDrive - University of Leeds/Data/opentripplanner2/graphs/UK_DEM_4326_new.tif")
r_os = project(r_os, "EPSG:27700")

path_in = "F:/Big Data/Scotland_DTM_2m_large"
path_out = "F:/Big Data/Scotland_DTM_2m_infil"

fls = list.files(path_in)

for(i in seq(1, length(fls))){

  if(file.exists(file.path(path_out,fls[i]))){
    message("Skipping ",i)
    next
  }
  message(fls[i])
  r1 = rast(file.path(path_in,fls[i]))
  r2 = crop(r_os, r1)
  r2 = resample(r2, r1)
  r1 = ifel(is.na(r1),r2,r1)

  writeRaster(r1, file.path(path_out,fls[i]),
              overwrite=TRUE,
              gdal=c("COMPRESS=DEFLATE", "BIGTIFF=YES"))
  rm(r1, r2)
  gc()
}

