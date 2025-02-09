\name{Compare-methods}

\docType{methods}

\alias{Compare-methods}
\alias{Logic-methods}

\alias{Compare,SpatRaster,SpatRaster-method}
\alias{Compare,numeric,SpatRaster-method}
\alias{Compare,SpatRaster,numeric-method}
\alias{Compare,SpatRaster,character-method}

\alias{Logic,SpatRaster,SpatRaster-method}
\alias{Logic,SpatRaster,numeric-method}
\alias{Logic,numeric,SpatRaster-method}
\alias{Logic,SpatRaster,logical-method}
\alias{Logic,logical,SpatRaster-method}


\alias{Compare,SpatExtent,SpatExtent-method}

\alias{is.na,SpatRaster-method}
\alias{is.nan,SpatRaster-method}
\alias{!,SpatRaster-method}
\alias{is.finite,SpatRaster-method}
\alias{is.infinite,SpatRaster-method}


\title{Compare and logical methods}

\description{

Standard comparison and logical operators for computations with SpatRasters. Computations are local (applied on a cell by cell basis). If multiple SpatRaster objects are used, these must have the same geometry (extent and resolution). These operators have been implemented:

\bold{Logical}: \code{!, &, |, isTRUE, isFALSE}

\bold{Compare}: \code{ ==, !=, >, <,  <=, >=, is.na, is.nan, is.finite, is.infinite}

The terra package does not distinguish between \code{NA} (not available) and \code{NaN} (not a number). In most cases this state is represented by \code{NaN}.  


The following method has been implemented for 

\bold{(SpatExtent, SpatExtent)}: \code{==}
}

\seealso{
\code{\link{all.equal}}, \link{Arith-methods}. See \code{\link{ifel}} to conveniently combine operations and \code{\link{Math-methods}} or \code{\link{app}} to apply any R function to a SpatRaster. 
}


\value{
SpatRaster or SpatExtent
}


\examples{
r1 <- rast(ncols=10, nrows=10)
values(r1) <- runif(ncell(r1))
r1[10:20] <- NA
r2 <- rast(r1)
values(r2) <- 1:ncell(r2) / ncell(r2)

x <- is.na(r1)
!x
r1 == r2 
}

\keyword{methods}
\keyword{math}
\keyword{spatial}
