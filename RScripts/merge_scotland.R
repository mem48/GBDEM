library(terra)

r1 = rast("F:/Big Data/DTM_Scotland_Phase1.tif")
r2 = rast("F:/Big Data/DTM_Scotland_Phase2.tif")

ext = sapply(list(r1, r2), function(i) ext(i) |> as.vector())
ext = ext(min(ext[1,]), max(ext[2,]), min(ext[3,]), max(ext[4,]))

r_template <- rast(ext, res=1) #TODO; Check resolution

gg <- lapply(list(r1, r2), function(i) resample(i, crop(r_template, i, "out")))
g <- merge(sprc(gg))


#r_merge = st_mosaic(r1, r2)
r_merge = st_apply(c(r1, r2), 1:2, mean, na.rm = TRUE)
write_stars(r_merge,file.path("F:/Big Data/DTM_Scotland_test_P1_P2.tif"),
            driver = "GTiff", options = c("COMPRESS=DEFLATE","PREDICTOR=3","ZLEVEL=9","BIGTIFF=YES"))
