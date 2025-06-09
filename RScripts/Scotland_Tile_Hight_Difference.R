# Aim, Unzip Sctoland Data
# Make Folders of DTM and DSM titles (DTM already done)
# Make Folder of Heigh Difference Files


library(terra)
library(sf)
library(tmap)
tmap_mode("view")

# Stack then merge by small tiles

base_path = "D:/OneDrive - University of Leeds/Data/LIDAR/Scotland/DSM"
path_out = "F:/DTM_DSM/small_rasters/Scotland/DSM"


fls = list.files(base_path)
grids = strsplit(fls,"_")
grids = sapply(grids, function(x){x[1]})
grids = unique(grids)

for(i in seq(1, length(grids))){
  if(file.exists(file.path(path_out,paste0(grids[i],".tiff")))){
    message("skipping ",i)
    next
  }

  fls_grid = fls[grepl(paste0(grids[i],"_"),fls)]
  message(grids[i]," ",fls_grid[1])
  r1 = rast(file.path(base_path, fls_grid[1]))
  # Downscale to 2m
  fact = round(2 / res(r1)[1])
  r1 = terra::aggregate(r1, fact)

  if(length(fls_grid) > 1){
    for(l in seq(2,length(fls_grid))){
      message("Adding ",fls_grid[l])
      r2 = rast(file.path(base_path, fls_grid[l]))
      fact = round(2 / res(r2)[1])
      r2 = terra::aggregate(r2, fact)
      e1 = ext(r1)
      e2 = ext(r2)
      if(e1 != e2){
        e = ext(c(min(e1[1],e2[1]),max(e1[2],e2[2]),min(e1[3],e2[3]),max(e1[4],e2[4])))
        r1 = extend(r1, e)
        r2 = extend(r2, e)
      }
      r1 = max(r1, r2, na.rm = TRUE)
      rm(r2)
    }
  }

  writeRaster(r1, file.path(path_out,paste0(grids[i],".tiff")),
              overwrite=TRUE,
              gdal=c("COMPRESS=DEFLATE", "BIGTIFF=YES"))
  rm(r1)

  gc()

}

# Round 2 Larger Tiles

fls = list.files(file.path(path_out,"DSM"))
grid_done = list.files(file.path(path_out,"DSM_larger_tiles"))
grid_done = gsub(".tiff","",grid_done, fixed = TRUE)
for(i in seq_along(grid_done)){
  fls = fls[!grepl(paste0("^",grid_done[i]),fls)]
}

grid_large = unique(substr(fls,1,2))
#grid_medium = unique(substr(fls,1,6))

# i = 2,     failed
#HY24looks off
for(i in seq(1, length(grid_large))){
  if(file.exists(file.path(path_out,"DSM_larger_tiles",paste0(grid_large[i],".tiff")))){
    message("skipping ",i)
    next
  }

  fls_grid = fls[grepl(paste0("^",grid_large[i]),fls)]
  message(grid_large[i]," ",fls_grid[1])
  r1 = rast(file.path(path_out, fls_grid[1]))

  if(length(fls_grid) > 1){
    for(l in seq(2,length(fls_grid))){
      message(Sys.time()," Adding ",fls_grid[l])
      r2 = rast(file.path(path_out, fls_grid[l]))
      if(res(r2)[1] != 2){
        message("wrong res")
      }
      e1 = ext(r1)
      e2 = ext(r2)
      if(e1 != e2){
        e = ext(c(min(e1[1],e2[1]),max(e1[2],e2[2]),min(e1[3],e2[3]),max(e1[4],e2[4])))
        r1 = extend(r1, e)
        r2 = extend(r2, e)
      }
      r1 = max(r1, r2, na.rm = TRUE)
      #plot(r1)
      rm(r2)
      gc()
    }
  }

  writeRaster(r1, file.path(path_out2,paste0(grid_large[i],".tiff")),
              overwrite=TRUE,
              gdal=c("COMPRESS=DEFLATE", "BIGTIFF=YES"))
  rm(r1)

  gc()

}

# Do failing tiles as smaller sections
fls = list.files(path_out)
grid_done = list.files(path_out2)
grid_done = gsub(".tiff","",grid_done, fixed = TRUE)
for(i in seq_along(grid_done)){
  fls = fls[!grepl(paste0("^",grid_done[i]),fls)]
}

# Types 4 char (NS95), 6 char (NS88SW), 6 char (NS9479)
flsdf = data.frame(fls)
flsdf$id = gsub(".tiff","",flsdf$fls, fixed = TRUE)

getgrid = function(x){
  if(nchar(x) == 4){
    return(x)
  }
  if(nchar(x) == 6){
    if(substr(x,5,5) %in% c("N","S")){
      return(substr(x,1,4))
    } else {
      return(paste0(substr(x,1,3),substr(x,5,5)))
    }
  }
  stop(x)
}

flsdf$grid = sapply(flsdf$id, getgrid)

grid_medium = unique(flsdf$grid)

#HY24looks off
for(i in seq(1, length(grid_medium))){
  if(file.exists(file.path(path_out2,paste0(grid_medium[i],".tiff")))){
    message("skipping ",i)
    next
  }

  fls_grid = flsdf$fls[flsdf$grid == grid_medium[i]]
  message(grid_medium[i]," ",fls_grid[1])
  r1 = rast(file.path(path_out, fls_grid[1]))

  if(length(fls_grid) > 1){
    for(l in seq(2,length(fls_grid))){
      message(Sys.time()," Adding ",fls_grid[l])
      r2 = rast(file.path(path_out, fls_grid[l]))
      if(res(r2)[1] != 2){
        message("wrong res")
      }
      e1 = ext(r1)
      e2 = ext(r2)
      if(e1 != e2){
        e = ext(c(min(e1[1],e2[1]),max(e1[2],e2[2]),min(e1[3],e2[3]),max(e1[4],e2[4])))
        r1 = extend(r1, e)
        r2 = extend(r2, e)
      }
      e1 = ext(r1)
      e2 = ext(r2)
      if(e1 != e2){
        r2 = resample(r2, r1)
      }
      if(ext(r1) != ext(r2)){
        stop("resample failed")
      }
      r1 = max(r1, r2, na.rm = TRUE)
      plot(r1)
      rm(r2)
      gc()
    }
  }

  writeRaster(r1, file.path(path_out2,paste0(grid_medium[i],".tiff")),
              overwrite=TRUE,
              gdal=c("COMPRESS=DEFLATE", "BIGTIFF=YES"))
  rm(r1)

  gc()

}





# Calculate Hight Differences

path_out = "F:/DTM_DSM/small_rasters/Scotland/"

r_dem = list.files(file.path(path_out,"DTM"))
r_dsm = list.files(file.path(path_out,"DSM"))

r_both = r_dem[r_dem %in% r_dsm]
r_miss = r_dem[!r_dem %in% r_dsm]

message(length(r_both),"/",length(r_dem)," have DSM and DTM")

for(i in seq(1, length(r_both))){
  message(Sys.time()," Grid ",r_both[i]," ",i,"/",length(r_both))

  # Read in Rasters
  r_dtm = rast(file.path(path_out,"DTM",paste0(r_both[i],".tif")))
  r_dsm = rast(file.path(path_out,"DSM",paste0(r_both[i],".tif")))

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





