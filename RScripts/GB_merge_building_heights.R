library(sf)
library(data.table)
library(tmap)
tmap_mode("view")

path_base = "F:/DTM_DSM/GB_10k"

fls = list.files(file.path(path_base,"Building_heights"), full.names = TRUE)

buildings = list()
for(i in 1:length(fls)){
  buildings[[i]] = readRDS(fls[i])
}

bind_sf = function(x) {
  if (length(x) == 0) stop("Empty list")
  geom_name = attr(x[[1]], "sf_column")
  x = data.table::rbindlist(x, use.names = FALSE)
  x[[geom_name]] = sf::st_sfc(x[[geom_name]], recompute_bbox = TRUE)
  x = sf::st_as_sf(x)
  x
}

buildings = bind_sf(buildings)
buildings$height_max[is.na(buildings$height_max)] = 0
buildings$height_max[buildings$height_max < 0] = 0

buildings$heights_min[is.na(buildings$heights_min)] = 0
buildings$heights_min[buildings$heights_min < 0] = 0

buildings$volume[is.na(buildings$volume)] = 0
buildings$volume[buildings$volume < 0] = 0

write_sf(buildings,"data/building_heights_gb.gpkg")

tm_shape(buildings) +
  tm_polygons("height_max", breaks = c(0,0.5,3,6,9,12,100))
