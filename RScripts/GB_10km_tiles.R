# Aim Make Whole GB 10km rasters
library(sf)
library(terra)
library(tmap)
library(stars)

# Make Grid
os_grid_10 = read_sf("../../OrdnanceSurvey/OS-British-National-Grids/os_bng_grids/os_bng_grids.gpkg", layer = "10km_grid")

path_base = "F:/DTM_DSM/small_rasters"
path_out = "F:/DTM_DSM/GB_10k/DSM"

dtm_eng = list.files(file.path(path_base,"England","DSM"), recursive = TRUE)
dtm_scot = list.files(file.path(path_base,"Scotland","DSM"), recursive = TRUE)
dtm_wal = list.files(file.path(path_base,"Wales","DSM"), recursive = TRUE)

dtm_eng = data.frame(id = dtm_eng, path = file.path(path_base,"England","DSM", dtm_eng))
dtm_scot = data.frame(id = dtm_scot, path = file.path(path_base,"Scotland","DSM", dtm_scot))
dtm_wal = data.frame(id = dtm_wal, path = file.path(path_base,"Wales","DSM", dtm_wal))

dtm_eng$id_clean = gsub("_DSM_2m.tif","",dtm_eng$id)
dtm_eng$id_clean = gsub(".tiff","",dtm_eng$id)
dtm_scot$id_clean = gsub(".tiff","",dtm_scot$id)
dtm_wal$id_clean = gsub("_dsm_2m.asc","",dtm_wal$id)

dtm_eng$country = "England"
dtm_scot$country = "Scotland"
dtm_wal$country = "Wales"


dtm_all = rbind(dtm_eng, dtm_scot, dtm_wal)


empty_grids = c("HL","HM","HN","HO","JL","JM","HQ","HR","HS","JQ","JR","HV","JV",
                "JW","NE","OA","OB","OF","OG","NP","OL","OM","OQ","OR","OW","TB",
                "TW","SQ","SL","SF","SG","SA","SB","NV","NQ")

os_grid_10 = os_grid_10[!substr(os_grid_10$tile_name,1,2) %in% empty_grids, ]

grids = os_grid_10$tile_name

mosaic_mode = TRUE

for(i in 1:length(grids)){
  patt1 = paste0("^",grids[i],"$")
  patt2 = paste0("^",grids[i],"(N|S)(E|W)","$")
  patt3 = paste0("^",substr(grids[i],1,3),"\\d",substr(grids[i],4,4),"\\d","$")
  patt = paste0("(",patt1,")|(",patt2,")|(",patt3,")")
  #patt = paste0(substr(grids[i],1,3),"\\d?",substr(grids[i],4,4),"\\d?")

  dtm_sub = dtm_all[grepl(patt, dtm_all$id_clean, ignore.case = TRUE),]

  if(nrow(dtm_sub) > 100){
    #stop("more than 100 rasters")
  }

  sub_eng = dtm_sub$path[dtm_sub$country == "England"]
  sub_scot = dtm_sub$path[dtm_sub$country == "Scotland"]
  sub_wal = dtm_sub$path[dtm_sub$country == "Wales"]

  sub_all = c(sub_eng, sub_scot, sub_wal)
  if(length(sub_all) == 0){
    message(grids[i]," ",i,"/",length(grids)," - No rasters")
    next
  } else {

    if(file.exists(file.path(path_out,paste0(grids[i],".tiff")))){
      message("skipping ",grids[i])
      next
    } else {
      message(grids[i]," ",i,"/",length(grids)," - ",Sys.time())
    }

    if(mosaic_mode &
       length(sub_all) > 10 &
       length(sub_scot) == 0 &
       (length(sub_eng) == 0 | length(sub_wal) == 0)
       )
    {

      # Use Mosaic Mode
      message("Mosaic Mode")
      # mos = st_mosaic(sub_all)
      # mos2 = read_stars(mos)
      # write_stars(mos2,file.path(path_out,paste0(grids[i],".tiff")),
      #             driver = "GTiff", options = c("COMPRESS=DEFLATE", "BIGTIFF=YES"))
      # rm(mos, mos2)

      rlist <- lapply(sub_all, rast)
      rsrc <- sprc(rlist)
      m <- mosaic(rsrc)
      writeRaster(m, file.path(path_out,paste0(grids[i],".tiff")),
                  overwrite=TRUE,
                  gdal=c("COMPRESS=DEFLATE", "BIGTIFF=YES"))


    } else {
      # Use Exband Mode

      r1 = rast(sub_all[1])

      if(length(sub_all) > 1){
        for(l in seq(2,length(sub_all))){
          #for(l in seq(2,5)){
          message("Adding ",sub_all[l])
          r2 = rast(sub_all[l])
          e1 = ext(r1)
          e2 = ext(r2)
          if(e1 != e2){
            e = ext(c(min(e1[1],e2[1]),max(e1[2],e2[2]),min(e1[3],e2[3]),max(e1[4],e2[4])))
            r1 = extend(r1, e)
            r2 = extend(r2, e)
          }

          e1 = ext(r1)
          e2 = ext(r2)
          if(e1 != e2){
            r2 = resample(r2, r1)
          }
          if(ext(r1) != ext(r2)){
            stop("resample failed")
          }


          r1 = max(r1, r2, na.rm = TRUE)
          rm(r2)
        }
    }

      writeRaster(r1, file.path(path_out,paste0(grids[i],".tiff")),
                  overwrite=TRUE,
                  gdal=c("COMPRESS=DEFLATE", "BIGTIFF=YES"))

    }
  }
}



