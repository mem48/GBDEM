# Test England Building Height
library(sf)
library(terra)
library(tmap)

path_base = "F:/DTM_DSM/GB_10k"

dtm_fls = list.files(file.path(path_base,"DTM_infill"))
dsm_fls = list.files(file.path(path_base,"DSM_infill"))

os_grid_10 = read_sf("../../OrdnanceSurvey/OS-British-National-Grids/os_bng_grids/os_bng_grids.gpkg", layer = "10km_grid")

if(file.exists("os_buildings_10k_grid.Rds")){
  buildings = readRDS("os_buildings_10k_grid.Rds")
} else {
  dir.create(file.path(tempdir(),"zoomstack"))
  unzip("../../PlaceBasedCarbonCalculator/inputdata/os_zoomstack/OS_Open_Zoomstack.zip", exdir = file.path(tempdir(),"zoomstack"))
  buildings = sf::st_read(file.path(tempdir(),"zoomstack","OS_Open_Zoomstack.gpkg"), layer = "local_buildings")
  unlink(file.path(tempdir(),"zoomstack"), recursive = TRUE)
  buildings = st_make_valid(buildings)
  buildings = st_join(buildings, os_grid_10, largest = TRUE)
  saveRDS(buildings, "os_buildings_10k_grid.Rds")
}

for(i in 1300:length(dtm_fls)){
  message(Sys.time()," ",dtm_fls[i]," ",i,"/",length(dtm_fls))
  if(file.exists(file.path(path_base,"Building_heights",paste0(substr(dtm_fls[i],1,4),".Rds")))){
    message("Skip ",i)
    next
  }

  r_dtm = rast(file.path(path_base,"DTM_infill",dtm_fls[i]))
  r_dsm = rast(file.path(path_base,"DSM_infill",dtm_fls[i]))

  r_diff = r_dsm - r_dtm
  buildings_sub = buildings[buildings$tile_name == substr(dtm_fls[i],1,4),]

  if(nrow(buildings_sub) > 0){

    heights_max = extract(r_diff, buildings_sub, fun = max, na.rm = TRUE)
    heights_min = extract(r_diff, buildings_sub, fun = min, na.rm = TRUE)
    volume = extract(r_diff, buildings_sub, fun = sum, weights = TRUE, na.rm = TRUE)

    buildings_sub$height_max = round(heights_max[,2],1)
    buildings_sub$heights_min = round(heights_min[,2],1)
    buildings_sub$volume = round(volume[,2] * 4,0)

    # tmap_options(max.raster = c(plot = 1e8, view = 1e8))
    # tm_shape(r_diff) + tm_raster(breaks = c(-Inf,-10,-0.1,0.1,0.5,3,10,20,Inf),
    #                              palette = c("#a50026","#d73027","#f46d43","#fee08b",
    #                                          "#a6d96a","#66bd63","#1a9850","#006837")) + qtm(buildings_sub)

    saveRDS(buildings_sub,file.path(path_base,"Building_heights",paste0(substr(dtm_fls[i],1,4),".Rds")))
    rm(heights_max, heights_min, volume, buildings_sub)
  } else {
    message("No buildings")
  }

    writeRaster(r_diff, file.path(path_base,"Difference",dtm_fls[i]),
              overwrite=TRUE,
              gdal=c("COMPRESS=DEFLATE"))

}


