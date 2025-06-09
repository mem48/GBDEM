# Aim Make Whole GB 10km rasters
library(sf)
library(terra)
library(tmap)
tmap_mode("view")

path_base = "F:/DTM_DSM/GB_10k"

dtm_fls = list.files(file.path(path_base,"DTM"))
dsm_fls = list.files(file.path(path_base,"DSM"))

path_out_dtm = file.path(path_base,"DTM_infill")
path_out_dsm = file.path(path_base,"DSM_infill")

#Unzip OS
folder.in = "D:/OneDrive - University of Leeds/Data/OS/Terrain50/terr50_gagg_gb_2022.zip"
folder.out = "C:/dem"
folder.tmp = "C:/tmp"

unzip(folder.in, exdir = folder.tmp)


files = list.files(folder.tmp, recursive = T, full.names = T, pattern = ".zip")

for(i in 1:length(files)){
  message(paste0(Sys.time()," doing ",files[i]))

  # unzip and find the asc file
  unzip(files[i],exdir=folder.out)
}



for(i in 1:length(dtm_fls)){

  if(file.exists(file.path(path_out_dtm,dtm_fls[i]))){
    message("skipping ",dtm_fls[i])
  } else {
    if(file.exists(file.path(folder.out,paste0(gsub(".tiff","",dtm_fls[i]),".asc")))){
      message(dtm_fls[i])
      r1 = rast(file.path(path_base,"DTM",dtm_fls[i]))
      os_sub = rast(file.path(folder.out,paste0(gsub(".tiff","",dtm_fls[i]),".asc")))
      os_sub = disagg(os_sub, 25)

      if(ext(r1) != ext(os_sub)){
        r1 = resample(r1, os_sub)
      }

      r2 = cover(r1, os_sub)
      writeRaster(r2, file.path(path_out_dtm,dtm_fls[i]),
                  overwrite=TRUE,
                  gdal=c("COMPRESS=DEFLATE", "BIGTIFF=YES"))
      rm(r1, r2, os_sub)
    } else {
      message(dtm_fls[i]," no OS raster")
      r1 = rast(file.path(path_base,"DTM",dtm_fls[i]))
      writeRaster(r1, file.path(path_out_dtm,dtm_fls[i]),
                  overwrite=TRUE,
                  gdal=c("COMPRESS=DEFLATE", "BIGTIFF=YES"))
      rm(r1)
    }
  }
}


for(i in 1:length(dsm_fls)){

  if(file.exists(file.path(path_out_dsm,dsm_fls[i]))){
    message("skipping ",dsm_fls[i])
  } else {
    if(file.exists(file.path(folder.out,paste0(gsub(".tiff","",dsm_fls[i]),".asc")))){
      message(dsm_fls[i])
      r1 = rast(file.path(path_base,"DSM",dsm_fls[i]))
      os_sub = rast(file.path(folder.out,paste0(gsub(".tiff","",dsm_fls[i]),".asc")))
      os_sub = disagg(os_sub, 25)

      if(ext(r1) != ext(os_sub)){
        r1 = resample(r1, os_sub)
      }

      r2 = cover(r1, os_sub)
      writeRaster(r2, file.path(path_out_dsm,dsm_fls[i]),
                  overwrite=TRUE,
                  gdal=c("COMPRESS=DEFLATE", "BIGTIFF=YES"))
      rm(r1, r2, os_sub)
    } else {
      message(dsm_fls[i]," no OS raster")
      r1 = rast(file.path(path_base,"DSM",dsm_fls[i]))
      writeRaster(r1, file.path(path_out_dsm,dsm_fls[i]),
                  overwrite=TRUE,
                  gdal=c("COMPRESS=DEFLATE", "BIGTIFF=YES"))
      rm(r1)
    }
  }
}


# Status

os_grid_10 = read_sf("../../OrdnanceSurvey/OS-British-National-Grids/os_bng_grids/os_bng_grids.gpkg", layer = "10km_grid")

os_fls = list.files(folder.out, pattern = ".asc")
os_fls = os_fls[!grepl(".xml",os_fls)]

os_grid_10$in_dtm = os_grid_10$tile_name %in% gsub(".tiff","",dtm_fls)
os_grid_10$in_dsm = os_grid_10$tile_name %in% gsub(".tiff","",dsm_fls)
os_grid_10$in_os = os_grid_10$tile_name %in% gsub(".asc","",os_fls)

os_grid_10$in_comine = paste0(os_grid_10$in_os,os_grid_10$in_dtm,os_grid_10$in_dsm )

qtm(os_grid_10[os_grid_10$in_comine != "FALSEFALSEFALSE",], fill = "in_comine")


# Fill in missing tiles and prune unnedded files

tiles_rem = os_grid_10$tile_name[!os_grid_10$in_os]
tiles_rem = paste0(tiles_rem,".tiff")
tiles_rem = tiles_rem[tiles_rem %in% c(dtm_fls, dsm_fls)]

unlink(file.path(path_out_dsm,tiles_rem))
unlink(file.path(path_out_dtm,tiles_rem))

tiles_add = os_grid_10$tile_name[os_grid_10$in_os & (!os_grid_10$in_dtm | !os_grid_10$in_dsm)]

for(i in 509:length(tiles_add)){
  message(tiles_add[i]," ",i,"/",length(tiles_add))
  os_sub = rast(file.path(folder.out,paste0(gsub(".tiff","",tiles_add[i]),".asc")))
  os_sub = disagg(os_sub, 25)

  p_dsm = file.path(path_out_dsm,paste0(tiles_add[i],".tiff"))
  if(!file.exists(p_dsm)){
    writeRaster(os_sub, p_dsm,
                overwrite=TRUE,
                gdal=c("COMPRESS=DEFLATE", "BIGTIFF=YES"))
  }

  p_dtm = file.path(path_out_dtm,paste0(tiles_add[i],".tiff"))
  if(!file.exists(p_dtm)){
    writeRaster(os_sub, p_dtm,
                overwrite=TRUE,
                gdal=c("COMPRESS=DEFLATE", "BIGTIFF=YES"))
  }


}


