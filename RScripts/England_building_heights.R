# Test England Building Height
library(sf)
library(terra)
library(tmap)

path = "D:/OneDrive - University of Leeds/Data/LIDAR/DSM DTM attempt 2/"

path_tmp = "C:/Temp/"

buildings <- geojsonsf::geojson_sf("../../creds2/CarbonCalculator/data/zoomstackgeojson/local_buildings.geojson")
buildings <- st_transform(buildings, 27700)
buildings$id = 1:nrow(buildings)

# Make Grid
os_grid = read_sf("../../OrdnanceSurvey/OS-British-National-Grids/os_bng_grids/os_bng_grids.gpkg", layer = "5km_grid")
os_grid$`1km_grid_ref` = NULL

buildings = st_make_valid(buildings)
buildings = st_join(buildings, os_grid, largest = TRUE)

big_zips = c(paste0("DTM_",1:6),paste0("DSM_",1:6))

for(zip in big_zips){
  # Unzip Main Zip
  message("Unzipping ", zip)
  dir.create(file.path(tempdir(),zip))
  unzip(paste0(path,zip,".zip"), exdir = file.path(tempdir(),zip))

  zips = list.files(file.path(tempdir(),zip), full.names = TRUE, recursive = TRUE,
                    pattern = ".zip")

}

#zip_dirs <- file.path(tempdir(),big_zips)
zip_dirs <- file.path(path_tmp,big_zips)

small_zips = list()
for(i in seq_len(length(zip_dirs))){
  small_zips[[i]] = list.files(zip_dirs[i], full.names = TRUE, pattern = ".zip", recursive = TRUE)
}
small_zips = unlist(small_zips)

grids = sapply(small_zips, function(x) substr(x, nchar(x)-9, nchar(x)), USE.NAMES = FALSE)
grids = substr(grids,1,6)
grids = unique(grids)

dir.create(file.path(tempdir(),"grids"))

for(i in seq(3801, length(grids))){
  message(Sys.time()," Grid ",grids[i]," ",i)
  dir.create(file.path(tempdir(),"grids",grids[i]))
  zips_sub = small_zips[grepl(grids[i],small_zips)]
  zips_dsm_sub = zips_sub[grepl("DTM",zips_sub)]
  zips_dtm_sub = zips_sub[grepl("DSM",zips_sub)]

  if(length(zips_dtm_sub) == 1){
    unzip(zips_dtm_sub, exdir = file.path(tempdir(),"grids",grids[i]))
  } else {
    message("No DTM zip")
    rm(zips_sub, zips_dtm_sub, zips_dsm_sub)
    unlink(file.path(tempdir(),"grids",grids[i]), recursive = TRUE)
    next
  }

  if(length(zips_dsm_sub) == 1){
    unzip(zips_dsm_sub, exdir = file.path(tempdir(),"grids",grids[i]))
  } else {
    message("No DSM zip")
    rm(zips_sub, zips_dtm_sub, zips_dsm_sub)
    unlink(file.path(tempdir(),"grids",grids[i]), recursive = TRUE)
    next
  }



  r_dtm = list.files(file.path(tempdir(),"grids",grids[i]), pattern = "DTM")
  r_dtm = r_dtm[grepl(".tif$",r_dtm)]
  r_dsm = list.files(file.path(tempdir(),"grids",grids[i]), pattern = "DSM")
  r_dsm = r_dsm[grepl(".tif$",r_dsm)]

  # Read in Raster
  if(length(r_dtm) == 1){
    r_dtm = rast(file.path(tempdir(),"grids",grids[i],r_dtm))
  } else {
    message("No DTM")
    next
  }

  if(length(r_dsm) == 1){
    r_dsm = rast(file.path(tempdir(),"grids",grids[i],r_dsm))
  } else {
    message("No DSM")
    next
  }

  # Check for matches
  if(any(res(r_dtm) != res(r_dsm))){
    message("Resolutions don't match ",grids[i])
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

  buildings_sub = buildings[buildings$tile_name == toupper(grids[i]),]

  # tm_shape(r_diff) +
  #   tm_raster(breaks = c(-1,0,1,2,4,8,10,20,80)) +
  #   tm_shape(buildings_sub) +
  #   tm_borders("black")

  if(nrow(buildings_sub) > 0){
    heights = try(extract(r_diff, buildings_sub, fun = max))
    if(inherits(heights,"try-error")){
      buildings_sub = buildings_sub[st_geometry_type(buildings_sub) %in% c("POLYGON","MULTIPOLYGON"),]
      heights = extract(r_diff, buildings_sub, fun = max)
    }

    buildings_sub$height = round(heights[,2],1)
    saveRDS(buildings_sub,paste0("F:/Big Data/England Building Heights/",grids[i],".Rds"))
    rm(heights)
  } else {
    message("No buildings")
  }

  writeRaster(r_dsm, paste0("F:/Big Data/England DSM/",grids[i],".tiff"),
              overwrite=TRUE,
              gdal=c("COMPRESS=DEFLATE"))
  writeRaster(r_diff, paste0("F:/Big Data/England Height Diff/",grids[i],".tiff"),
              overwrite=TRUE,
              gdal=c("COMPRESS=DEFLATE"))

  unlink(file.path(tempdir(),"grids",grids[i]), recursive = TRUE)
  rm(r_diff, buildings_sub, r_dsm, r_dtm,
     zips_sub, zips_dsm_sub, zips_dtm_sub)

  # tm_shape(buildings_sub)+
  # tm_fill("height", breaks = c(0,2,4,6,8,10,15,20,30,50,80))

}


