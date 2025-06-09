# Reproject 10k titles and round to a centemeter as interger
# Didn't work as alingment issues


path = "F:/DTM_DSM/GB_10k"
path_in =  file.path(path,"DTM_infill")
path_out =  file.path(path,"DTM_4326")


library(terra)
fls = list.files(path_in, pattern = ".tif")

for(i in 1:50){

  if(file.exists(file.path(path_out,fls[i]))){
    message("Skip ",i)
    next
  } else {
    message(Sys.time()," ",fls[i]," ",i,"/",length(fls))
  }

  r = rast(file.path(path_in,fls[i]))
  r = round(r * 100)
  r = project(r, "epsg:4326", threads = 20)
  r = ifel(r < -100000, -100000, r)
  r = ifel(r > 150000, 0, r)

  writeRaster(r, file.path(path_out,fls[i]),
              overwrite=TRUE,
              datatype = "INT4S",
              gdal=c("COMPRESS=DEFLATE","PREDICTOR=2","ZLEVEL=9"))

}


dir.create("C:/rastTemp")
terraOptions(memfrac = 0.7, tempdir = "C:/rastTemp")

rlist = lapply(fls, rast)
rsrc <- sprc(rlist)
m <- mosaic(rsrc)
