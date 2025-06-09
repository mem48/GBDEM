# Make a coverage maps
library(sf)
library(tmap)
library(tmaptools)

os_grid_5 = read_sf("../../OrdnanceSurvey/OS-British-National-Grids/os_bng_grids/os_bng_grids.gpkg", layer = "5km_grid")
os_grid_1 = read_sf("../../OrdnanceSurvey/OS-British-National-Grids/os_bng_grids/os_bng_grids.gpkg", layer = "1km_grid")
os_grid_10 = read_sf("../../OrdnanceSurvey/OS-British-National-Grids/os_bng_grids/os_bng_grids.gpkg", layer = "10km_grid")

path = "F:/DTM_DSM/small_rasters"

england_dtm = list.files(file.path(path, "England/DTM"))
england_dsm = list.files(file.path(path, "England/DSM"))

wales_dtm = list.files(file.path(path, "Wales/DTM"))
wales_dsm = list.files(file.path(path, "Wales/DSM"))

scotland_dtm = list.files(file.path(path, "Scotland/DTM"))
scotland_dsm = list.files(file.path(path, "Scotland/DSM"))

england_dtm = gsub("_DTM_2m.tif","",england_dtm)
england_dsm = gsub(".tiff","",england_dsm)

wales_dtm = gsub("_dtm_2m.asc","",wales_dtm)
wales_dsm = gsub("_dsm_2m.asc","",wales_dsm)

scotland_dtm = gsub(".tiff","",scotland_dtm)
scotland_dsm = gsub(".tiff","",scotland_dsm)

england_dtm = toupper(england_dtm)
england_dsm = toupper(england_dsm)

wales_dtm = toupper(wales_dtm)
wales_dsm = toupper(wales_dsm)

scotland_dtm = toupper(scotland_dtm)
scotland_dsm = toupper(scotland_dsm)


summary(england_dtm %in% os_grid_5$tile_name)

os_grid_5$has_dtm = os_grid_5$tile_name %in% england_dtm
os_grid_5$has_dsm = os_grid_5$tile_name %in% england_dsm

os_grid_1$has_dtm = os_grid_1$tile_name %in% wales_dtm
os_grid_1$has_dsm = os_grid_1$tile_name %in% wales_dsm

os_grid_10$has_dtm = os_grid_10$tile_name %in% scotland_dtm
os_grid_10$has_dsm = os_grid_10$tile_name %in% scotland_dsm


os_grid_5 = os_grid_5[os_grid_5$has_dtm | os_grid_5$has_dsm,]
os_grid_1 = os_grid_1[os_grid_1$has_dtm | os_grid_1$has_dsm,]
os_grid_10 = os_grid_10[os_grid_10$has_dtm | os_grid_10$has_dsm,]

os_grid_10$Type = ifelse(os_grid_10$has_dtm & os_grid_10$has_dsm,"Both","Other")
os_grid_10$Type[os_grid_10$has_dtm & !os_grid_10$has_dsm] = "DTM Only"
os_grid_10$Type[!os_grid_10$has_dtm & os_grid_10$has_dsm] = "DSM"

os_grid_5$Type = ifelse(os_grid_5$has_dtm & os_grid_5$has_dsm,"Both","Other")
os_grid_5$Type[os_grid_5$has_dtm & !os_grid_5$has_dsm] = "DTM Only"
os_grid_5$Type[!os_grid_5$has_dtm & os_grid_5$has_dsm] = "DSM"

os_grid_1$Type = ifelse(os_grid_1$has_dtm & os_grid_1$has_dsm,"Both","Other")
os_grid_1$Type[os_grid_1$has_dtm & !os_grid_1$has_dsm] = "DTM Only"
os_grid_1$Type[!os_grid_1$has_dtm & os_grid_1$has_dsm] = "DSM"

os_grid_5$`1km_grid_ref` = NULL


os_all = rbind(os_grid_10, os_grid_5, os_grid_1)

osm <- read_osm(os_all, type = "esri-physical", ext=1.1)

m1 = tm_shape(osm) +
  tm_rgb() +
    tm_shape(os_all) +
  tm_fill(fill = "Type", fill_alpha = 0.6, fill.scale = tm_scale_categorical(values = c("red","green")))

tmap_save(m1,"images/coverage.png")
