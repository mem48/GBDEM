path = "D:/OneDrive - University of Leeds/Data/LIDAR/Scotland/DTM"

fls = list.files(path, pattern = ".tif")

fls_p3 = fls[grepl("PHASE3",fls)]

for(i in 1:length(fls_p3)){
  file.rename(file.path(path,fls_p3[i]), file.path(path,"PHASE3",fls_p3[i]))
}

fls_p4 = fls[grepl("HES_2017",fls)]

for(i in 1:length(fls_p4)){
  file.rename(file.path(path,fls_p4[i]), file.path(path,"HES_2017",fls_p4[i]))
}
