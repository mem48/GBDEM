path = "F:/Big Data/England DSM"

library(stars)

fls = list.files(path, full.names = TRUE, recursive = TRUE, pattern = ".tif")

mos = st_mosaic(fls)
mos2 = read_stars(mos)
#write_stars(mos2,file.path("C:/tiles/DTM_England_2m.tif"))

write_stars(mos2,file.path("F:/Big Data/DSM_England_2m.tif"),
            driver = "GTiff", options = c("COMPRESS=DEFLATE","PREDICTOR=3","ZLEVEL=9","BIGTIFF=YES"))



