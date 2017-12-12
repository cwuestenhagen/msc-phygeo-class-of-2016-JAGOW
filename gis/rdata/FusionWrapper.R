########LasListTxt
# creates list with las files from a given directory in mainDir/inDir/. 
# Function checks if list allready exists and, if exists, deletes it from the Folder
# Function checks if Outputfolder exists and creates it if it is missing

### @Name: should be the project name. Keep it constant for all functions or define it 
### in the beginning (Name="projectName").



lasListTxt<-function(lasDir, Name){
  
  las_files<-list.files(paste0(mainDir,inDir,lasDir, "/"), 
                        pattern=".las$", full.names=TRUE,recursive = TRUE)
  ifelse (!file.exists(paste0(mainDir, inDir, "table/")),dir.create(paste0(mainDir, inDir, "table/")), print("Folder Exists"))
  ifelse (file.exists(paste0(mainDir, inDir, "table/", Name, "_las_files.txt")),unlink(paste0(mainDir, inDir, "table/", Name, "_las_files.txt"), recursive = FALSE, force = FALSE),
         print("new las list .txt created"))
  
  lapply(las_files, write,paste0(mainDir,inDir,"table/",Name,"_las_files.txt"), append=T)
  }

#lasListTxt(lasDir = "lidar/", Name="test")





#############   basInfo
# Creates html and .csv of all las files in laslist created with LasListTxt
# Function checks if Outputfolder exists and creates it if it is missing

### @Name: should be the project name. Keep it constant for all functions 
### or define it in the beginning (Name="projectName").



basInfo<-function( Name){
  ifelse(!file.exists(paste0( mainDir, outDir,"table/")), 
         dir.create(paste0(mainDir, outDir,"table/")), print("Folder exists"))
  system(paste0(FUSION, "catalog.exe ",mainDir, inDir,"table/", Name, "_las_files.txt ",
                mainDir, outDir,"table/",Name,".html"))}

#basInfo(Name="test")





############   missingExtents
# For some .las files extent information is missing. 
# The following function rounds coordinates, so neighbouring tiles can be identified, 
# and fills missing x or y extent by substrringing the name of the las file. 
# Only works if lasfilenames are made of xmin ynd ymin coordinates.
# Function checks if Outputfolder exists and creates it if it is missing

### @CatalogTable: ist the output .csv from the basInfo function
### @Name: should be the project name. Keep it constant for all functions or define it in the beginning (Name="projectName").



missingExtents<-function(catalogTable, Name){
  
  for (i in 3:nrow(catalogTable)){
    
    findrows <- which(catalogTable$MinX ==0|catalogTable$MinY==0|
                        catalogTable$MaxX==0|catalogTable$MaxY==0)
    
    for (j in findrows){
      coor<-substr(catalogTable[j,1],nchar(as.character(catalogTable[j,1]))-10, nchar(as.character(catalogTable[j,1])))
      
      xmin<-paste0(substr(coor, 1,3), "000")
      
      ymin<-paste0(substr(coor, 4,7), "000")
      
      catalogTable[j,]$MinX=as.numeric(xmin)
      
      catalogTable[j,]$MinY=as.numeric(ymin)
    }}
  catalogTable$MaxX<-round(catalogTable$MaxX,0)
  
  catalogTable$MaxY<-round(catalogTable$MaxY,0)
  
  ifelse(!file.exists(paste0( mainDir, outDir,"table/")), 
         dir.create(paste0(mainDir, outDir,"table/")), print("Folder exists"))
  
  write.csv(catalogTable,paste0(mainDir, outDir, "table/",Name,".csv"))
}

#caldern<-read.csv(paste0(mainDir, outDir,"table/","test",".csv"))
#missingExtents(catalogTable = caldern,Name = "test")

###########     createTiles

# Since many operations involve  adjacent cells, edges might become a problem. 
# To use a buffer, points or cells need to be taken from neighbouring las tiles. 
# The following function searches for adjacent las tiles by shared X and Y 
# and writes all neighbours of central las file into a seperate txt, named after the central las file.
# Function checks if Outputfolder exists and creates it if it is missing

### @catalogTable: the rounded and corrected (missingExtents) .csv catalog output.
### @templist: an empty list
### @Name: should be the project name. Keep it constant for all functions or define it 
### in the beginning (Name="projectName").

#left: xmin=xmax and ymin=ymin
#right:xmax=xmin and ymin=ymin
#down: xmin=xmin and ymin=ymax
#up:   xmin=xmin and ymax=ymin

#tempolist<-list()
#myTable<-read.csv(paste0(mainDir, outDir,"table/","test",".csv"))

createTiles<-function(catalogTable, templist, Name){for (i in 1:nrow(catalogTable)){
  adjacent<-which( 
    #left
    catalogTable$MaxX==catalogTable[i,]$MinX & catalogTable$MinY==catalogTable[i,]$MinY
    |#right
      catalogTable$MinX==catalogTable[i,]$MaxX &    catalogTable$MinY==catalogTable[i,]$MinY
    | ##down
      catalogTable$MinX==catalogTable[i,]$MinX & catalogTable$MaxY==catalogTable[i,]$MinY
    | ##up
      catalogTable$MinX==catalogTable[i,]$MinX & catalogTable$MinY==catalogTable[i,]$MaxY)
  
  for (j in 1:length(adjacent)){
    tmp<-as.character(catalogTable[adjacent[j],]$FileName)
    
    templist[[j]]<-tmp
  }
  ifelse(!file.exists(paste0( mainDir, outDir,"lidar/tiles/")), 
         dir.create(paste0(mainDir, outDir,"lidar/tiles/")), print("Folder exists"))
  
  lapply(templist, write,paste0(mainDir,inDir,"lidar/tiles/",
                                substr(catalogTable[i,]$FileName,nchar(as.character(catalogTable[i,]$FileName))-11,nchar(as.character(catalogTable[i,]$FileName))-4),"_",Name,"_tiles.txt"),
         append=T)
  
}
}



#createTiles(catalogTable=myTable,templist=tempolist,Name="test")





#########    GridSurfForTiles

# This Function creates ground surface dtm from classified groundpoints for the new tiles (createTiles)
# Function checks if outputfolders exist and creates them if missing

### @cellzise: the desired cellsize for the bare earth .dtm
### @Name: should be the project name. Keep it constant for all functions or define it 
### in the beginning (Name="projectName").


GridSurfForTiles<-function( cellzise, Name){
  tiles<-list.files(paste0(mainDir,inDir,"lidar/tiles/"), pattern=paste0("test", "_tiles",".txt$"),   full.names=TRUE,recursive = TRUE)
  ifelse (!file.exists( paste0(mainDir, outDir,"raster/BareGround/")),dir.create(paste0(mainDir, outDir,"raster/BareGround/")))
  ifelse (!file.exists( paste0(mainDir, outDir,"lidar/")),dir.create(paste0(mainDir, outDir,"lidar/")))  
  for (i in tiles){
      ##get basic info (expl. extent for clipData)
      system(paste0(FUSION, "catalog.exe ", i," ",
                    mainDir, outDir,"table/",substr(i,nchar(i)-(nchar(paste0(Name, "-tiles.txt"))+8),nchar(i)-4),"Info", ".html"))
      
      tempExt<-read.csv(paste0(mainDir, outDir,"table/",substr(i,nchar(i)-(nchar(paste0(Name, "-tiles.txt"))+8),nchar(i)-4),"Info",".csv"))
      
      missingExtents(tempExt, paste0(substr(i,nchar(i)-(nchar(paste0(Name, "-tiles.txt"))+8),nchar(i)-4),"Info"))
      
      extent<-read.csv(paste0(mainDir, outDir,"table/",substr(i,nchar(i)-(nchar(paste0(Name, "-tiles.txt"))+8),nchar(i)-4),"Info",".csv"))
      
      system(paste0(paste0(FUSION, "clipdata.exe"," /class:2 ", i," ",
                           mainDir, outDir,"lidar/",substr(i,nchar(i)-(nchar(paste0(Name, "-tiles.txt"))+8),nchar(i)-4),"_GroundPts.las "),
                    paste(min(extent$MinX),min(extent$MinY),max(extent$MaxX),max(extent$MaxY))))
      
      system(paste0(FUSION, "gridsurfacecreate.exe ", 
                    mainDir, outDir,"raster/BareGround/", substr(i,nchar(i)-(nchar(paste0(Name, "_tiles.txt"))+8),nchar(i)-4),"_GridSurf.dtm ",cellzise,
                    " M M 1 32 0 0 ", mainDir, outDir,"lidar/",substr(i,nchar(i)-(nchar(paste0(Name, "_tiles.txt"))+8),nchar(i)-4), "_GroundPts.las"))
      
    } }

##GridSurfForTiles( cellzise = 50, Name="test")



######## GridMetrics
#paste0(0.15,",",1.37,",",5,",",10,",",20,",",30)

GridMetrics(Name = "test", groundFolder = "raster/BareGround/", tileFolder = "lidar/tiles/", catalogFolder = "table/",heightbreak=1.37, cellsize=50)

GridMetrics<-function(Name="projName",groundFolder="groundFolder", 
                      tileFolder="tileFolder", catalogFolder="catalogFolder",heightbreak, cellsize, buffer=FALSE, bufferWidth,cellbuffer,cellbufferWidth,
                      strata, heights, instrata, inHeights
                    )
  {

groundList<-list.files(paste0(mainDir,outDir,groundFolder), pattern=paste0(Name, "_tiles_GridSurf",".dtm$"),   full.names=TRUE,recursive = TRUE)

tiles<-list.files(paste0(mainDir,inDir,tileFolder), pattern=paste0(Name, "_tiles",".txt$"),   full.names=TRUE,recursive = TRUE)

myTable<-read.csv(paste0(mainDir, outDir,catalogFolder,Name,".csv"))

ifelse(!missing(buffer), buffer<-paste0("/buffer:", bufferWidth, " "), buffer<-"" )

ifelse(!missing(cellbuffer), cellbuffer<-paste0("/cellbuffer:", cellbufferWidth, " "), cellbuffer<-"" )

ifelse( !missing(strata), strata<-paste0("/strata:", heights, " "), strata<-"" )

ifelse(!missing(instrata), instrata<-paste0("/instrata:", inHeights, " "), instrata<-"")

results<-paste0(mainDir, outDir, "/raster/", "GridMetrics", cellsize)

dir.create(results, showWarnings = FALSE)

for (i in 1:length(tiles)){

system(paste0(FUSION, "gridmetrics.exe ", "/gridxy:",myTable[i,]$MinX,",",myTable[i,]$MinY,",",myTable[i,]$MaxX,",",myTable[i,]$MaxY,
              " ",buffer,cellbuffer,strata,instrata,groundList[i], " ", heightbreak, " ", cellsize, " ", results,"/",
              substr(tiles[i],nchar(tiles[i])-((nchar(paste0("test", "_tiles.txt")))+8),nchar(tiles[i])-4),"_",
              cellsize, "m","_GridMetrics.csv ", tiles[i], " "))
  }}


