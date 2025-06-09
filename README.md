# GBDEM
A 2m resolution Digital Terrain Model (DEM) and Digital Surface Model (DSM) of Great Britain.

## Source Data

1. England - Environment Agency LIDAR (>90% coverage)
1. Wales - Welsh Government LIDAR (~70% coverage)
1. Scotland - Scottish Government LIDAR (~40% Coverage)
1. OS Open50 - 50m DTM used to fill in gaps (100% coverages)

## Method

I tried Several methods with scripts in the repo but this is the final working method. Igore other scripts.

### In R

***Country Specific***
Unzip/open and downscale to 2m resolution as required

***GB_10km_tiles.R***
Take small tiles from and make into larger tiles that match the OS National Grid 10km tiles (e.g. NS80). This resolves boarder issues between datasets and some minor misalignments.


***GB_10km_fill_in_gaps.R***
Replace any missing values in the LIDAR data with OS Open 50 Terrrain Data. This is low resolution but give the output national coverage.

***GB_10km_building_heights.R***
For each 10km raster creates a difference raster (DSM - DTM) and uses that to calculate building heights and volumes for the OS Open Vector Stack Buildings. 

Planned improvement is to replace OS buildings with OSM where available and split up the OS buildings with the INSPIRE polygons. OSM buildings tend to be more detailed, and OS groups terraced buildings into a single long building.

***GB_10km_mosaic.R***
Mosaic the 10km rasters into a single large raster of whole GB (about 95 GB compressed TIF)

### In QGIS

Reproject the raster from epsg:27700 to epsg:3857

Command to use:

```gdalwarp -s_srs EPSG:27700 -t_srs EPSG:3857 -dstnodata 0.0 -r near -multi -of GTiff -co COMPRESS=DEFLATE -co PREDICTOR=3 -co ZLEVEL=9 -co BIGTIFF=YES -co NUM_THREADS=30 F:\DTM_DSM\large_rasters\GB\GB_DTM_27700.tif C:/tiles/GB_DTM_3857.tif```

Key Points

1. `-dstnodata 0.0` replace nodata value with 0, this is important later as RGB raster can't have very large or very small values
1. `-co COMPRESS=DEFLATE -co PREDICTOR=3 -co ZLEVEL=9`  use best compression as very large files 
1. `-co BIGTIFF=YES` Use big TIFF or fails (> 4GB)
1. `-co NUM_THREADS=30` Use multicore
1. `C:/tiles/GB_DTM_3857.tif` write to SSD or will be limited by disk speed

This will still take a day to do

OPTIMISATION use TILED=YES ????

Then use gdal warp to change the nodatavalue to none `-dstnodata None`. Otherwise RGB files have black dots for 0m elevation
https://mapscaping.com/nodata-values-in-rasters-with-qgis/ 

```
gdalwarp -s_srs EPSG:3857 -t_srs EPSG:3857 -r near -multi -of GTiff -co COMPRESS=DEFLATE -co PREDICTOR=2 -co ZLEVEL=9 -co BIGTIFF=YES -co NUM_THREADS=30 -dstnodata None  C:/tiles/GB_DTM_3857_nodata.tif C:/tiles/GB_DTM_3857_nodata2.tif
```

https://github.com/syncpoint/terrain-rgb/blob/master/README.md 



### In WSL

Convert from single band to RGB encoded with `rio-rgbify`.

``` rio rgbify -b -10000 -i 0.1 --workers 10 --co BIGTIFF=YES --co TILED=YES GB_DTM_3857_nodata.tif GB_DSM_RGB.tif```

Key Points

1. rio rgbify can go straight to mbtiles but I got loads of errors so go to anther raster first
1. `-b -10000 -i 0.1` use mapbox encoding nothing else seems to worth with MapLibre
1. `--workers 10` this is ram limited so can use some but not all mulitcore
1. `--co BIGTIFF=YES` still need to use big tif
1. `--co TILED=YES` massive performance impact on the tileing stage (later)

This will take a night to run

## Powershell

Onetime install of QGIS processing
```
 c:\OSGeo4W\bin\qgis_process-qgis.bat

```
```
processing.run("qgis:tilesxyzdirectory", {'EXTENT':'-1040892.679200000,310376.142900000,6405989.265200000,8614934.383400001 [EPSG:3857]','ZOOM_MIN':6,'ZOOM_MAX':14,'DPI':192,'BACKGROUND_COLOR':QColor(0, 0, 0, 0),'TILE_FORMAT':0,'QUALITY':75,'METATILESIZE':4,'TILE_WIDTH':512,'TILE_HEIGHT':512,'TMS_CONVENTION':False,'OUTPUT_DIRECTORY':'C:\\tiles\\DTM_QGIS','OUTPUT_HTML':'C:/tiles/DTM_QGIS/leaflet.html'})
```

### Back in QGIS

Generate XYZ Tiles (directory)

QGIS doesn't have the option to create webp tiles, so create PNG tiles. This could be a bug as the WEBP driver has been added to GDAL since version 3.6

The mbtiles version can't create high res (512x512) images so create individual pictures first

Use a custom background colour to avoid obvious edge to the tiles.


### WSL

Convert to webp using imagemagic

For Zoom 0 to 10 goes from 200 MB to 127 MB

```
find . -type f -name "*.png" -exec mogrify -format webp -define webp:lossless=true {}  \; -print
find . -type f -name "*.png" -exec rm {}  \; -print
```

Convert to mbtiles

```
cd ..
mb-util --image_format=webp DTM_QGIS DTM_QGIS.mbtiles
```

Convert to pmtiles

```
./pmtiles convert DTM_QGIS.mbtiles DTM_QGIS.pmtiles
```
For Zoom 0 to 10 is to 130 MB






