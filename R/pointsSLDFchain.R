pointsSLDFchain <- function(SLDF, xy, SLmsk='FEAT_ID', mask=NULL, type='SpatialPointsDataFrame') {

  if (!(type %in% c('points','SpatialPointsDataFrame')))
    stop('pointsSLDFchain :: ERR01 - wrong type input')


  nL <- length(SLDF)

  if (inherits(xy, "SpatialPointsDataFrame"))
    xcoo <- coordinates(xy)
  else
    xcoo <- xy

  ldf <- SLDF@data

  if (is.null(mask)) {
    for (i in 1:nL) {
      vcoo <-  coordinates(SLDF)[[i]][[1]]                  # vector node coordinates: just 1-line features accepted
      xchinf <- pointsPolylineD(vcoo, xcoo)
      xchinf <- cbind(xchinf, il=i)
      if (i == 1) {
        xchain <- xchinf
      } else {
        ids <- xchain[,'dis'] > xchinf[,'dis']
        xchain[ids,] <- xchinf[ids,]
      }
    }
  } else {
    if (length(mask) != nrow(xcoo))
      stop('pointsSLDFchain: mask length differs from input point length')
    xchain <- NULL
    for (i in 1:nL) {
      vcoo <- coordinates(SLDF)[[i]][[1]]                                       # vector node coordinates: just 1-line features accepted
      xco  <- xcoo[mask ==  ldf[i,SLmsk],]
      xchinf <- pointsPolylineD(vcoo, xco)
      xchinf <- cbind(xchinf, il=i)
      xchain <- rbind(xchain,xchinf)
    }
  }
  chai <- xchain[,'chain0'] + xchain[,'dc']
  eID <- row.names(ldf)[xchain[,'il']]
  xchain <- data.frame('chain'=chai, 'eID'=eID, stringsAsFactors = FALSE)

  if (type == 'SpatialPointsDataFrame') {
    rownames(xchain) <- rownames(xcoo)
    colnames(xcoo) <- c('x', 'y')
    xchain <- cbind(xcoo, xchain)
    coordinates(xchain) <- c('x','y')
  }
  return(xchain)
} # end function pointsSLDFchain
