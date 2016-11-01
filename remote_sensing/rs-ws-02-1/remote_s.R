setwd('D:/Ben/Vorndran/gis/474000_5630000/')
library(raster)
lidar<-raster("geonode_las_intensity_05.tif")
ext_1<-crop(bil_1,extent(478000, 479000, 5630000, 5632000))
ext_2<-crop(bil_2, extent(478000, 479000, 5632000, 5634000))

bil_1<-stack("478000_5630000.tif")
ext_1<-crop(bil_1,extent(478000, 479000, 5630000, 5632000))
bil_2<-stack("478000_5632000.tif")
ext_2<-crop(bil_2, extent(478000, 479000, 5632000, 5634000))


writeRaster(bil_1, filename="bil_1.tif", bylayers=TRUE)
writeRaster(bil_2, filename="bil_2.tif", bylayers=TRUE)


bi<-stack("bil_2.tif")
