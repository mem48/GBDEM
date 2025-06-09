library(stars)

dir.create(file.path(tempdir(),"wales"))

zps = list.files("D:/OneDrive - University of Leeds/Data/LIDAR/Wales/DTM", full.names = TRUE)
for(i in zps){
  unzip(i, exdir = file.path(tempdir(),"wales"))
}

fls = list.files(file.path(tempdir(),"wales"), full.names = TRUE)



message("Mosaic")
mos = st_mosaic(fls)
mos2 = read_stars(mos)
message("Writing")
write_stars(mos2,file.path("C:/tiles/DTM_Wales_2m.tif"),
            driver = "GTiff", options = c("COMPRESS=DEFLATE","PREDICTOR=3","ZLEVEL=9","BIGTIFF=YES"))
unlink(file.path(tempdir(),"wales"), recursive = TRUE)


dir.create(file.path(tempdir(),"wales"))

zps = list.files("D:/OneDrive - University of Leeds/Data/LIDAR/Wales/DSM", full.names = TRUE)
for(i in zps){
  message(i)
  unzip(i, exdir = file.path(tempdir(),"wales"))
}

fls = list.files(file.path(tempdir(),"wales"), full.names = TRUE)



message("Mosaic")
mos = st_mosaic(fls)
mos2 = read_stars(mos)
message("Writing")
write_stars(mos2,file.path("C:/tiles/DSM_Wales_2m.tif"),
            driver = "GTiff", options = c("COMPRESS=DEFLATE","PREDICTOR=3","ZLEVEL=9","BIGTIFF=YES"))
unlink(file.path(tempdir(),"wales"), recursive = TRUE)
