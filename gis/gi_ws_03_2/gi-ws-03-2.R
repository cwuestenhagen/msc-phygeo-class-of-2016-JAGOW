
install.packages("raster")
install.packages("rgdal")
install.packages("rgeos")
install.packages("doParallel")
library(rgeos)
library(raster)
library(rgdal)



###define directories
path_gis<-("C:/Users/Jannis/Documents/GitHub/msc_phygeo_class_of_2016/gis_2016/")
path_ras<-("C:/Users/Jannis/Documents/GitHub/msc_phygeo_class_of_2016/gis_2016/data/raster/")

###translate DEM into .sdat
system('C:/OSGeo4W64/OSGeo4W.bat gdal_translate 
       -of SAGA -ot Float32 
       C:/Users/Jannis/Documents/GitHub/msc_phygeo_class_of_2016/gis_2016/data/raster/DEM.tif 
       C:/Users/Jannis/Documents/GitHub/msc_phygeo_class_of_2016/gis_2016/data/raster/test/DEM.sdat')


###calculate inputs forr fuzzy landform element classifier by using the saga modul "Slope, Aspect, Curvature"
###and the saga shell within osgeos4w
system('C:/OSGeo4W64/apps/saga/saga_cmd.exe ta_morphometry "Slope, Aspect, Curvature" 
       -ELEVATION "C:/Users/Jannis/Documents/GitHub/msc_phygeo_class_of_2016/gis_2016/data/raster/test/DEM.sgrd" 
       -METHOD 6 -UNIT_SLOPE 1 -UNIT_ASPECT 1 
       -SLOPE "C:/Users/Jannis/Documents/GitHub/msc_phygeo_class_of_2016/gis_2016/data/raster/test/slope.sgrd" 
       -ASPECT "C:/Users/Jannis/Documents/GitHub/msc_phygeo_class_of_2016/gis_2016/data/raster/test/aspect.sgrd" 
       -C_GENE "C:/Users/Jannis/Documents/GitHub/msc_phygeo_class_of_2016/gis_2016/data/raster/test/gc.sgrd" 
       -C_PLAN "C:/Users/Jannis/Documents/GitHub/msc_phygeo_class_of_2016/gis_2016/data/raster/test/pc.sgrd" 
       -C_PROF "C:/Users/Jannis/Documents/GitHub/msc_phygeo_class_of_2016/gis_2016/data/raster/test/proC.sgrd" 
       -C_TANG "C:/Users/Jannis/Documents/GitHub/msc_phygeo_class_of_2016/gis_2016/data/raster/test/tang_c.sgrd" 
       -C_MINI "C:/Users/Jannis/Documents/GitHub/msc_phygeo_class_of_2016/gis_2016/data/raster/test/min_c.sgrd" 
       -C_MAXI "C:/Users/Jannis/Documents/GitHub/msc_phygeo_class_of_2016/gis_2016/data/raster/test/max_c.sgrd')

###calculate fuzzy landform elements classifier with default thresholds. Since this modul is not implemented
### in osgeos4w we had to download saga software and use the saga shell of the downloaded software

system('C:/saga/saga/saga_cmd.exe ta_morphometry 25 
-SLOPE=C:/Users/Jannis/Documents/GitHub/msc_phygeo_class_of_2016/gis_2016/data/raster/morpho/slope.sgrd 
-MINCURV=C:/Users/Jannis/Documents/GitHub/msc_phygeo_class_of_2016/gis_2016/data/raster/morpho/minc.sgrd 
-MAXCURV=C:/Users/Jannis/Documents/GitHub/msc_phygeo_class_of_2016/gis_2016/data/raster/morpho/max_c.sgrd 
-PCURV=C:/Users/Jannis/Documents/GitHub/msc_phygeo_class_of_2016/gis_2016/data/raster/morpho/pro_c.sgrd 
-TCURV=C:/Users/Jannis/Documents/GitHub/msc_phygeo_class_of_2016/gis_2016/data/raster/morpho/tan_c.sgrd 
-PLAIN=C:/Users/Jannis/Documents/GitHub/msc_phygeo_class_of_2016/gis_2016/data/raster/morpho/PLAIN.sgrd  
-PIT=NULL -PEAK=NULL -RIDGE=NULL -CHANNEL=NULL -SADDLE=NULL -BSLOPE=NULL -FSLOPE=NULL -SSLOPE=NULL 
-HOLLOW=NULL -FHOLLOW=NULL -SHOLLOW=NULL -SPUR=NULL -FSPUR=NULL -SSPUR=NULL 
-FORM=C:/Users/Jannis/Documents/GitHub/msc_phygeo_class_of_2016/gis_2016/data/raster/morpho/FORM.sgrd  
-MEM=C:/Users/Jannis/Documents/GitHub/msc_phygeo_class_of_2016/gis_2016/data/raster/morpho/mem.sgrd  
-ENTROPY=C:/Users/Jannis/Documents/GitHub/msc_phygeo_class_of_2016/gis_2016/data/raster/morpho/entro.sgrd  
-CI=C:/Users/Jannis/Documents/GitHub/msc_phygeo_class_of_2016/gis_2016/data/raster/morpho/cindex.sgrd 
       -SLOPETODEG=0 -T_SLOPE_MIN=5.000000 -T_SLOPE_MAX=15.000000 -T_CURVE_MIN=0.000002 -T_CURVE_MAX=0.000050')

system('C:/OSGeo4W64/OSGeo4W.bat gdal_translate -of GTiff 
-ot Float32 C:/Users/Jannis/Documents/GitHub/msc_phygeo_class_of_2016/gis_2016/data/raster/morpho/FORM.sdat 
       C:/Users/Jannis/Documents/GitHub/msc_phygeo_class_of_2016/gis_2016/data/raster/translate/form_2.tif')


### visual control of the output showed a heterogenous value distribution. We applied focal statistics 
### (mean) to smooth the distrbution of values.

fuzz<-raster(paste0(path_ras, "translate/form_2.tif"))

fuzz_focal<-focal(fuzz, matrix(1,5,5), fun=mean, pad = T, padValue = 0 )

writeRaster(fuzz_focal, file=paste0(path_ras,"fuzz_focal.tif"), bylayer=TRUE)

###reclassification of the landform output according to the code in the function 
##(https://sourceforge.net/p/saga-gis/code/ci/master/tree/saga-gis/src/tools/terrain_analysis/ta_morphometry/fuzzy_landform_elements.cpp#l132)

m<-c(0, 95, 3, 95, 122, 1)

fuzzm<-matrix(m, ncol=3, byrow=TRUE)

fuzz_rc<-reclassify(fuzz_focal, fuzzm)


writeRaster(fuzz_rc, file="GitHub/msc_phygeo_class_of_2016/gis_2016/data/raster/fuzz_rc.tif", bylayer=TRUE, overwrite=TRUE)


### calculate area of connected raster cells by conversion into polygons and reconversion into raster

##we stopped to polygonize the raster with rasterTopolygons from the raster pacckage after two days without any results
##and decided to use the gdal_polygonize function. It was done after two minutes!
 system('C:/OSGeo4W64/OSGeo4W.bat gdal_polygonize 
C:/Users/Jannis/Documents/GitHub/msc_phygeo_class_of_2016/gis_2016/data/raster/fuzz_rc.tif
        -f "ESRI Shapefile" C:/Users/Jannis/Documents/GitHub/msc_phygeo_class_of_2016/gis_2016/data/shape/fuzz_rc.shp')

 
 
pol<-shapefile("GitHub/msc_phygeo_class_of_2016/gis_2016/data/shape/fuzz_rc.shp")

pol_sep<-disaggregate(pol)

##calculate area
pol_sep$area<-area(pol_sep)

shapefile(pol_sep, filename="GitHub/msc_phygeo_class_of_2016/gis_2016/data/shape/area.shp")

##rasterize polygon
system('C:/OSGeo4W64/OSGeo4W.bat gdal_rasterize 
       -a area -ot Float32 -of GTiff -te 474000.0 5630000.0 479000.0 5634000.0 
       -tr 1 1 -co COMPRESS=DEFLATE -co PREDICTOR=1 -co ZLEVEL=6 -l area 
       C:/Users/Jannis/Documents/GitHub/msc_phygeo_class_of_2016/gis_2016/data/shape/area.shp 
       C:/Users/Jannis/Documents/GitHub/msc_phygeo_class_of_2016/gis_2016/data/raster/area1.tif')



##get varaibles for algorithm
ras_area<-raster("GitHub/msc_phygeo_class_of_2016/gis_2016/data/raster/area1.tif")

DEM<-raster("GitHub/msc_phygeo_class_of_2016/gis_2016/data/raster/DEM.tif")


### looping with several conditions over 20000000 raster cells takes forever
for(i in seq(DEM)){if(DEM[i]>220 & fuzz_rc[i]==1) {fuzz_rc[i]<-2}}
  
## parallel processing on 4 cores still takes forever

install.packages("doParallel")
library(doParallel)

cl <- makeCluster(4)  
registerDoParallel(cl) 

foreach(i=1:20000000)%dopar%{if(DEM[i]>220 & fuzz_rc[i]==1) {fuzz_rc[i]<-2}}
  


##### so why not straight forward

plot(fuzz_rc)
hist(fuzz_rc)


fuzz_rc[fuzz_rc==1 & DEM>240]<-2
fuzz_rc[fuzz_rc==2 &ras_area<30000 ]<-3
fuzz_rc[fuzz_rc==1 &ras_area<30000 ]<-3

### takes a few seconds

writeRaster(fuzz_rc, file="GitHub/msc_phygeo_class_of_2016/gis_2016/data/raster/plains_plateaus.tif", bylayer=TRUE, overwrite=TRUE)




