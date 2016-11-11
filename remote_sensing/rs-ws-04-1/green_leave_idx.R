green_leave_idx<-function(x, r=1, g=2, b=3){
  
  (2*x[[g]]-x[[r]]-x[[b]])/(2*x[[g]]+x[[r]]+x[[b]])
}