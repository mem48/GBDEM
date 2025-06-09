library(stars)

for(i in 4:6){
  fls = list.files("D:/OneDrive - University of Leeds/Data/LIDAR/Scotland/DTM/",
                   full.names = TRUE,
                   pattern = paste0("PHASE",i), recursive = TRUE)

  message(Sys.time()," Mosaic ", i)
  mos = st_mosaic(fls)
  mos2 = read_stars(mos)
  message(Sys.time()," Writing ", i)
  write_stars(mos2,file.path("F:/Big Data", paste0("DTM_Scotland_Phase",i,".tif")),
              driver = "GTiff", options = c("COMPRESS=DEFLATE","PREDICTOR=3","ZLEVEL=9","BIGTIFF=YES"))

}

#r = read_stars("D:/OneDrive - University of Leeds/Data/LIDAR/Scotland/DTM/Phase 1/HY20_1M_DTM_PHASE1.tif")
#
# write_stars(r, "F:/Big Data/FTM Scotland Phase2 Compress.tif", driver = "GTiff", options = c("COMPRESS=DEFLATE","PREDICTOR=2","ZLEVEL=9"))

#options = c("COMPRESS=DEFLATE","PREDICTOR=2","ZLEVEL=9")

# SOmething wrong with 3

i = 3
fls = list.files("D:/OneDrive - University of Leeds/Data/LIDAR/Scotland/DTM/",
                 full.names = TRUE,
                 pattern = paste0("PHASE",3), recursive = TRUE)

batch_size <- 100
num_rows <- length(fls)
split_indices <- rep(seq(1,ceiling(num_rows/batch_size)), each = batch_size)
split_indices <- split_indices[1:num_rows]
fls_list <- split(fls, split_indices)

for(i in c(5,7)){
  message(Sys.time()," Mosaic ", i)
  fls_sub = fls_list[[i]]
  mos = st_mosaic(fls_sub)
  mos2 = read_stars(mos)
  message(Sys.time()," Writing ", i)
  write_stars(mos2,file.path("F:/Big Data", paste0("DTM_Scotland_Phase3_part_",i,".tif")),
              driver = "GTiff", options = c("COMPRESS=DEFLATE","PREDICTOR=3","ZLEVEL=9","BIGTIFF=YES"))
}



fls = list.files("D:/OneDrive - University of Leeds/Data/LIDAR/Scotland/DTM/",
                 full.names = TRUE,
                 pattern = "OUTERHEB", recursive = TRUE)

message(Sys.time()," Mosaic ")
mos = st_mosaic(fls)
mos2 = read_stars(mos)
message(Sys.time()," Writing ")
write_stars(mos2,file.path("F:/Big Data", paste0("DTM_Scotland_OuterHebridies.tif")),
            driver = "GTiff", options = c("COMPRESS=DEFLATE","PREDICTOR=3","ZLEVEL=9","BIGTIFF=YES"))


fls = list.files("D:/OneDrive - University of Leeds/Data/LIDAR/Scotland/DTM/",
                 full.names = TRUE,
                 pattern = "DTM_HES", recursive = TRUE)

fls_50 = fls[grepl("_50CM_", fls)]


message(Sys.time()," Mosaic 50CM ")
mos = st_mosaic(fls_50)
mos2 = read_stars(mos)
message(Sys.time()," Writing 50CM ")
write_stars(mos2,file.path("F:/Big Data", paste0("DTM_Scotland_HES_50CM.tif")),
            driver = "GTiff", options = c("COMPRESS=DEFLATE","PREDICTOR=3","ZLEVEL=9","BIGTIFF=YES"))



fls_25 = fls[grepl("_25CM_", fls)]

message(Sys.time()," Mosaic 25CM ")
mos = st_mosaic(fls_25)
mos2 = read_stars(mos)
message(Sys.time()," Writing 25CM ")
write_stars(mos2,file.path("F:/Big Data", paste0("DTM_Scotland_HES_25CM.tif")),
            driver = "GTiff", options = c("COMPRESS=DEFLATE","PREDICTOR=3","ZLEVEL=9","BIGTIFF=YES"))
