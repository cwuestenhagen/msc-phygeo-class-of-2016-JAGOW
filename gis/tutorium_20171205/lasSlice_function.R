mainDir <- "C:/Users/user/Projekte/POINTCLOUD_processing" ##my working directory
inDir <- "/two_tiles/"## my input folder
outDir<- "/temp/"##my output folder for temorary products
results<-"/results/"

Fusion<-"C:/FUSION/"


sliceLasData<-function(lasList,heights){
  for (i in lasList){
   ##get basic info (expl. extent for clipData)
    system(paste0(Fusion, "catalog.exe ",mainDir, inDir, i," ",
                mainDir, outDir,i, ".html"))
  
     extent<-read.csv(paste0(mainDir, outDir,i,".csv"))
     
     system(paste0(paste0(Fusion, "clipdata.exe"," /class:2 ",
                mainDir, inDir, i," ",
                mainDir, outDir,i, "_GroundPts.las "),
                paste(extent$MinX,extent$MinY,extent$MaxX,extent$MaxY))
                )
     system(paste0(Fusion, "gridsurfacecreate.exe ", 
             mainDir, outDir, i,"_GridSurf.dtm ",
             "1 M M 1 32 0 0 ",mainDir, outDir,i, "_GroundPts.las"))
   
     for (j in 1:length(heights)-1){
    
     system(paste0(paste0(Fusion, "clipdata.exe"," /zmin:",zVals[j], "/zmax:",zVals[j+1],
                   " /height /dtm:",mainDir, outDir,i,"_GridSurf.dtm ",
                   mainDir, inDir, i," ",##input
                   mainDir, outDir, i,
                   zVals[j],"_",zVals[j+1],"_normalized.las "),
                   paste(extent$MinX,extent$MinY,extent$MaxX,extent$MaxY)))
     
     system(paste0(Fusion, "returndensity.exe ","/ascii ",mainDir,results,i, "_",zVals[j],"_",zVals[j+1], "density.asc ",
                   "1 ",   mainDir, outDir, i,
                   zVals[j],"_",zVals[j+1],"_normalized.las "))
     
     
     
   }
   }
}








las_files<-list.files(paste0(mainDir,inDir), pattern=".las$", full.names=TRUE,recursive = TRUE)

las_names<-list.files(paste0(mainDir,inDir), pattern=".las$", full.names=FALSE,recursive = TRUE)


zValues<-c(0,2,5,10,15,25,30,50)


sliceLasData(lasList=las_names,heights=zValues)
sliceLasData(lasList = las_names,heights = zValues)
