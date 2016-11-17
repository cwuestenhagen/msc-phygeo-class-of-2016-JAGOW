
install.packages("glcm")
library(glcm)
library(raster)

source("GitHub/msc_phygeo_class_of_2016/remote_sensing_2016/data/rdata/path_rs.R")
source("GitHub/msc-phygeo-class-of-2016-JAGOW/remote_sensing/rs-ws-04-1/green_leave_idx.R")


tst_lst<-list.files(rsras_airP, recursive=TRUE, pattern=glob2rx("*.tif"), full.names=TRUE)


##green leve index auf allen
s_gl<-lapply(seq(tst_lst), function(i){
  x<-stack(tst_lst[i])
  z<-green_leave_idx(x)
  return(z)
})

##homogenität auf einer kachel 
hom_one<-lapply(seq(3:50), function(i){if(i%%2!=0)
  {x<-glcm(s_gl[[4]], window=c(i,i), statistics="homogeneity")
  return(x)}})

##homogenität mit der besten Fenstergröße für alle Kacheln
hom_all<-lapply(seq(s_gl), function (i) {
  x<-glcm(s_gl[[i]], window=c(beste,beste), statistics="homogeneity")
  return(x)
  }))


