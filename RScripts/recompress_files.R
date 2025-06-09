# Files don't always have best compression so read in a write out again.
library(terra)

dir_in = "D:/OneDrive - University of Leeds/Data/LIDAR/Scotland/DTM/OUTERHEBRIDES"
dir_out = "D:/OneDrive - University of Leeds/Data/LIDAR/Scotland/DTM/OUTERHEBRIDES_compressed"

if(!dir.exists(dir_out)){
  dir.create(dir_out)
}

fls = list.files(dir_in, pattern = ".tif")

for(i in 1:length(fls)){
  r = rast(file.path(dir_in,fls[i]))
  writeRaster(r, file.path(dir_out,fls[i]),
              overwrite=TRUE,
              gdal=c("COMPRESS=DEFLATE", "PREDICTOR=3","ZLEVEL=9"))

  message(Sys.time()," ",i,"/",length(fls)," ",fls[i]," ",
          round(file.size(file.path(dir_out,fls[i]))/file.size(file.path(dir_in,fls[i])) * 100, 1),"%")

}
