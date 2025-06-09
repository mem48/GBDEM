path = "D:/OneDrive - University of Leeds/Data/LIDAR/DSM DTM attempt 2/"

library(stars)
big_zips = paste0("DTM_",1:6)

for(zip in big_zips){
  # Unzip Main Zip
  message("Unzipping ", zip)
  dir.create(file.path(tempdir(),zip))
  unzip(paste0(path,zip,".zip"), exdir = file.path(tempdir(),zip))

  zips = list.files(file.path(tempdir(),zip), full.names = TRUE, recursive = TRUE,
                    pattern = ".zip")


  for(i in seq_len(length(zips))){
    unzip(zips[i], exdir = file.path(tempdir(),zip))
  }

  fls = list.files(file.path(tempdir(),zip), full.names = TRUE, recursive = TRUE)

  #fls_tif = fls[grepl(".tif$",fls)]
  fls_alt = fls[!grepl(".tif$",fls)]

  unlink(fls_alt)
  rm(fls_alt,fls,zips)

}

fls = list.files(tempdir(), full.names = TRUE, recursive = TRUE, pattern = ".tif")

mos = st_mosaic(fls)
mos2 = read_stars(mos)
#write_stars(mos2,file.path("C:/tiles/DTM_England_2m.tif"))

write_stars(mos2,file.path("C:/tiles/DTM_England_2m.tif"),
            driver = "GTiff", options = c("COMPRESS=DEFLATE","PREDICTOR=3","ZLEVEL=9","BIGTIFF=YES"))



