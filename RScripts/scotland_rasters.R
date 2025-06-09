txt <- readLines("D:/OneDrive - University of Leeds/Data/LIDAR/Scotland/DSM_HES2_OuterHeb.txt")
txt <- txt[grepl("eu-west-2.amazonaws.com",txt, fixed = TRUE)]
txt <- gsub('\t\t\t\t<form method=\"get\" action=\"',"",txt, fixed = TRUE)
txt <- gsub('style=\"display: inline;',"",txt, fixed = TRUE)
txt <- gsub('>',"",txt, fixed = TRUE)
txt <- gsub('\t',"",txt, fixed = TRUE)
txt <- gsub('"',"",txt)
txt <- gsub(' ',"",txt)

path_out = "D:/OneDrive - University of Leeds/Data/LIDAR/Scotland/DSM/"

options(timeout=120)

for(i in 1:length(txt)){
  url = txt[i]
  nm = strsplit(url,"/")[[1]]
  nm = nm[length(nm)]
  destfile = paste0(path_out,nm)
  if(file.exists(destfile)){
    message("skipping ",destfile)
  } else {
    message(i," of ",length(txt))
    download.file(url, destfile = destfile, mode = "wb")
  }
}


