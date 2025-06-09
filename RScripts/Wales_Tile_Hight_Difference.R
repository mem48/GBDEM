# Aim, Unzip Wales Data
# Make Folders of DTM and DSM titles
# Make Folder of Heigh Difference Files

library(sf)
library(terra)
library(tmap)
library(stars)

path_in = "D:/OneDrive - University of Leeds/Data/LIDAR/Wales/"
path_out = "F:/DTM_DSM/small_rasters/Wales"

message(Sys.time()," Uzipping DTM")
zps = list.files(file.path(path_in,"DTM"), full.names = TRUE)
for(i in zps){
  unzip(i, exdir = file.path(path_out,"DTM"))
}

message(Sys.time()," Uzipping DSM")
zps = list.files(file.path(path_in,"DSM"), full.names = TRUE)
for(i in zps){
  unzip(i, exdir = file.path(path_out,"DSM"))
}

r_dem = list.files(file.path(path_out,"DTM"))
r_dsm = list.files(file.path(path_out,"DSM"))
r_dem = gsub("_dtm_2m.asc","",r_dem)
r_dsm = gsub("_dsm_2m.asc","",r_dsm)

r_both = r_dem[r_dem %in% r_dsm]
message(length(r_both),"/",length(r_dem)," have DSM and DTM")

for(i in seq(1, length(r_both))){
  message(Sys.time()," Grid ",r_both[i]," ",i,"/",length(r_both))

  # Read in Rasters
  r_dtm = rast(file.path(path_out,"DTM",paste0(r_both[i],"_dtm_2m.asc")))
  r_dsm = rast(file.path(path_out,"DSM",paste0(r_both[i],"_dsm_2m.asc")))

  # Check for matches
  if(any(res(r_dtm) != res(r_dsm))){
    message("Resolutions don't match ",r_both[i])
  }
  if(ext(r_dtm) != ext(r_dsm)){
    message("Adjsting extents ",grids[i])
    e1 = ext(r_dtm)
    e2 = ext(r_dsm)
    e = ext(c(min(e1[1],e2[1]),max(e1[2],e2[2]),min(e1[3],e2[3]),max(e1[4],e2[4])))
    r_dsm = extend(r_dsm, e)
    r_dtm = extend(r_dtm, e)
  }

  r_diff = r_dsm - r_dtm

  # tm_shape(r_diff) +
  #    tm_raster(breaks = c(-1,0,1,2,4,8,10,20,80))

  writeRaster(r_diff, file.path(path_out,"Difference",paste0(r_both[i],"_diff_2m.tif")),
              overwrite=TRUE,
              gdal=c("COMPRESS=DEFLATE"))


}


