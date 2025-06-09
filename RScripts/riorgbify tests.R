library(terra)

r = rast("F:/DTM_DSM/GB_10k/DSM_infill/SU38.tiff")
r = project(r, "epsg:3857")
