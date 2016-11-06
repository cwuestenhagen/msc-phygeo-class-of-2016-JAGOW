library(raster)
install.packages("tools")
library(tools)


setwd("C:/Users/Jannis/Documents/GitHub/msc_phygeo_class_of_2016/remote_sensing_2016/data/raster/cross_check/")

read<-list.files( recursive=TRUE, pattern=glob2rx("*.tif"), full.names=TRUE)

ngb_aerials <- function(aerial_files, step = 2000){
  
  ngb_files <- lapply(basename(aerial_files), function(act_file){
    
    # Get names without path to compare names although path might be different
    act_ext <- file_ext(act_file)
    fnames <- basename(aerial_files)
    
    # Get x and y coordinates of actual file from filename
    act_file_x <- as.numeric(substr(act_file, 1, 6))
    act_file_y <- as.numeric(substr(act_file, 8, 14))
    
    # Set neighbours starting from north with clockwise rotation (N, E, S, W)
    pot_ngb <- c(paste0(act_file_x, "_", act_file_y + step, ".", act_ext),
                 paste0(act_file_x + step, "_", act_file_y, ".", act_ext),
                 paste0(act_file_x, "_", act_file_y - step, ".", act_ext),
                 paste0(act_file_x - step, "_", act_file_y, ".", act_ext))
    
    # Check if neighburs exist and create vector with full filepath
    act_ngb <- sapply(pot_ngb, function(f){
      pos <- grep(f, fnames)
      if(length(pos) > 0){
        return(aerial_files[pos])
      } else {
        return(NA)
      }
    })
    return(act_ngb)
  })
  
  names(ngb_files) <- aerial_files
  return(ngb_files)
  
}


neighb<-ngb_aerials(read)

y<-NULL
z<-NULL

for (i in seq(neighb)){ 
  if(!is.na(neighb[[i]][[1]]))
  {
    x <-stack(sub("cross_check/","", names(neighb[i])))
    y<-mean((x[1,])/
                   (stack(basename(neighb[[i]][1]))[nrow(stack(basename(neighb[[i]][1]))),]))
   
  }
  else if(!is.na(neighb[[i]][[2]])) 
  {
    x <-stack(sub("cross_check/","", names(neighb[i])))
    y<-mean((x[,ncol(x)])/
                      (stack(basename(neighb[[i]][2]))[,1])) 
 
  }
  else if(!is.na(neighb[[i]][[3]])) 
  {
    x <-stack(sub("cross_check/","", names(neighb[i])))
    y<-mean((x[nrow(x),])/
                      (stack(basename(neighb[[i]][3]))[1,])) 
   
  }
  else if(!is.na(neighb[[i]][[4]])) 
  {
    x <-stack(sub("cross_check/","", names(neighb[i])))
    y<-mean((x[,1])/
                      (stack(basename(neighb[[i]][4]))[,ncol(stack(basename(neighb[[i]][4])))])) 
   
  }
    z<-c(z,y)
}
 


