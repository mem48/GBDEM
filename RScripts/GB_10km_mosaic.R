path = "F:/DTM_DSM"

library(terra)
fls = list.files(file.path(path,"GB_10k","DSM_infill"), full.names = TRUE, pattern = ".tif")
dir.create("C:/rastTemp")
terraOptions(memfrac = 0.7, tempdir = "C:/rastTemp")

rlist = lapply(fls, rast)
rsrc <- sprc(rlist)
m <- mosaic(rsrc)



#m <- project(m, "epsg:4326", threads = 20) crashed

# Crashes a write raster but mosaic is in tempdir

# writeRaster(m,
#             file.path(path,"large_rasters","GB","GB_DTM.tif"),
#             gdal = c("COMPRESS=DEFLATE","PREDICTOR=3","ZLEVEL=9","BIGTIFF=YES"))

# library(stars)
#
# r = read_stars("F:/DTM_DSM/large_rasters/GB/spat_584c7c6d4af1_22604.tif")

# terra::vrt(raster_files, "E:/raster_file_output")
#
# or
#
# gdalUtils::gdalbuildvrt(gdalfile = raster_files,
#                         output.vrt = "E:/raster_file_output")



# mos = st_mosaic(fls[1:2])
# mos2 = read_stars(mos)
#
# mos2 = st_transform(mos2, st_crs(4326))
#
# write_stars(mos2,file.path(path,"large_rasters","GB","GB_DTM.tif"),
#             driver = "GTiff",
#             options = c("COMPRESS=DEFLATE","PREDICTOR=3","ZLEVEL=9","BIGTIFF=YES"))



