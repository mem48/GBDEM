# Re sample Scotland Raster to 2m
library(terra)
library(sf)
library(tmap)
tmap_mode("view")
base_path = "F:/Big Data"
fls = c(#"R2Mb_DTM_Scotland_Phase1.tif",
  "R2M_DTM_Scotland_Phase2.tif",
        "R2M_DTM_Scotland_Phase3-6.tif","R2M_DTM_Scotland_HES_25CM.tif",
        "R2M_DTM_Scotland_HES_50CM.tif","R2M_DTM_Scotland_OuterHebridies.tif")

# Make a grid
scot = readRDS("../../atumscot/inputdata/DataZones.Rds")
scot = st_transform(scot, 27700)
grid = st_make_grid(scot, cellsize = 100000)

grid = st_as_sf(grid)
grid$id = 1:nrow(grid)
qtm(grid, fill = "id")

dir.create(file.path(base_path,"grids"))
for(k in 1:nrow(grid)){
  dir.create(file.path(base_path,"grids",paste0("grid_",k)))
}

# Loop of files and grid
for(i in seq_along(fls)){
  message(Sys.time()," ",fls[i])
  r = rast(file.path(base_path,fls[i]))

  for(j in 1:35){
    message(Sys.time()," grid ",j)
    e = st_bbox(grid[j,])
    rc <- try(crop(r, e), silent = T)
    if(inherits(rc, "try-error")){
      #Failed
      if(rc[1] == "Error : [crop] extents do not overlap\n"){
        message("No overlap for grid ",j)
        next
      } else {
        stop()
      }
    } else {
      #worked
      writeRaster(rc, file.path(base_path,"grids",paste0("grid_",j),fls[i]), overwrite=TRUE)
    }

  }
}

# Combine toghter
dir.create(file.path(base_path,"grids_combined"))
for(j in 5:35){
  message(Sys.time()," grid ",j)
  grid_fls = list.files(file.path(base_path,"grids",paste0("grid_",j)), full.names = TRUE)

  if(length(grid_fls) == 0){
    message("No rasters in grid ",j)
    next
  }

  e = ext(st_bbox(grid[j,]))
  r1 = rast(grid_fls[1])
  r1 = extend(r1, e)

  if(length(grid_fls) > 1){
    for(l in seq(2,length(grid_fls))){
      message("Adding ",grid_fls[l])
      r2 = rast(grid_fls[l])
      r2 = extend(r2, ext(r1))
      r2b = snap(r2, r1)
      #r1 = max(r1, r2, na.rm = TRUE)
      r3 = max(r1, r2b, na.rm = TRUE)
    }
  }

  writeRaster(r1, file.path(base_path,"grids_combined",paste0("grid_",j,".tiff")),
              overwrite=TRUE,
              gdal=c("COMPRESS=DEFLATE", "BIGTIFF=YES"))

  gc()


}

