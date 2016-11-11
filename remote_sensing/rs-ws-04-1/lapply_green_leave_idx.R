lapply(seq(read), function(i){
  x<-stack(read[i])
  z<-green_leave_idx(x)
  return(z)
})