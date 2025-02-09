# Author: Robert J. Hijmans
# Date : July 2019
# Version 1.0
# License GPL v3



setMethod("buffer", signature(x="SpatRaster"),
	function(x, width, filename="", ...) {
		opt <- spatOptions(filename, ...)
		x@ptr <- x@ptr$buffer(width, opt)
		messages(x, "buffer")
	}
)


setMethod("distance", signature(x="SpatRaster", y="missing"),
	function(x, y, target=NA, exclude=NULL, unit="m", filename="", ...) {
		if (!is.null(list(...)$grid)) {
			error("distance", "use 'gridDistance(x)' instead of  'distance(x, grid=TRUE)'")
		}
		opt <- spatOptions(filename, ...)
		target <- as.numeric(target[1])
		if (!is.null(exclude)) {
			exclude <- as.numeric(exclude[1])
			if ((is.na(exclude) && is.na(target)) || isTRUE(exclude == target)) {
				error("distance", "'target' and 'exclude' must be different") 
			}
		} else {
			exclude <- NA
		}
		x@ptr <- x@ptr$rastDistance(target, exclude, tolower(unit), opt)
		messages(x, "distance")
	}
)


setMethod("costDistance", signature(x="SpatRaster"),
	function(x, target=0, scale=1000, maxiter=50, filename="", ...) {
		opt <- spatOptions(filename, ...)
		maxiter <- max(maxiter[1], 2)
		x@ptr <- x@ptr$costDistance(target[1], scale[1], maxiter, FALSE, opt)
		messages(x, "costDistance")
	}
)


setMethod("gridDistance", signature(x="SpatRaster"),
	function(x, target=0, scale=1000, maxiter=50, filename="", ...) {
		opt <- spatOptions(filename, ...)
		if (is.na(target)) {
			x@ptr <- x@ptr$gridDistance(opt)
		} else {
			maxiter <- max(maxiter[1], 2)
			x@ptr <- x@ptr$costDistance(target[1], scale[1], maxiter, TRUE, opt)
		}
		messages(x, "gridDistance")
	}
)


setMethod("distance", signature(x="SpatRaster", y="SpatVector"),
	function(x, y, unit="m", filename="", ...) {
		opt <- spatOptions(filename, ...)
		unit <- as.character(unit[1])
		if (is.lonlat(x, perhaps=TRUE)) {
			x <- rast(x)
			x@ptr <- x@ptr$vectDisdirRasterize(y@ptr, TRUE, TRUE, FALSE, FALSE, NA, NA, unit, opt)
		} else {
			x@ptr <- x@ptr$vectDistanceDirect(y@ptr, unit, opt)
		}
		messages(x, "distance")
	}
)



mat2wide <- function(m, sym=TRUE, keep=NULL) {
	if (inherits(m, "dist")) {
		# sym must be true in this case
		nr <- attr(m, "Size")
		x <- rep(1:(nr-1), (nr-1):1)
		y <- unlist(sapply(2:nr, function(i) i:nr))
		cbind(x,y, as.vector(m))
	} else {
		bool <- is.logical(m)
		if (sym) {
			m[lower.tri(m)] <- NA
		}
		m <- cbind(from=rep(1:nrow(m), each=ncol(m)), to=rep(1:ncol(m), nrow(m)), value=as.vector(t(m)))
		m <- m[!is.na(m[,3]), , drop=FALSE]
		if (!is.null(keep)) {
			m <- m[m[,3] == keep, 1:2, drop=FALSE]
		}
		m
	}
}

setMethod("distance", signature(x="SpatVector", y="ANY"),
	function(x, y, sequential=FALSE, pairs=FALSE, symmetrical=TRUE, unit="m") {
		if (!missing(y)) {
			error("distance", "If 'x' is a SpatVector, 'y' should be a SpatVector or missing")
		}

		if (sequential) {
			return( x@ptr$distance_self(sequential))
		}
		unit <- as.character(unit[1])
		d <- x@ptr$distance_self(sequential, unit)
		messages(x, "distance")
		class(d) <- "dist"
		attr(d, "Size") <- nrow(x)
		attr(d, "Diag") <- FALSE
		attr(d, "Upper") <- FALSE
		attr(d, "method") <- "spatial"
		if (pairs) {
			d <- as.matrix(d)
			diag(d) <- NA
			d <- mat2wide(d, symmetrical)
		}
		d
	}
)


setMethod("distance", signature(x="SpatVector", y="SpatVector"),
	function(x, y, pairwise=FALSE, unit="m") {
		unit <- as.character(unit[1])
		d <- x@ptr$distance_other(y@ptr, pairwise, unit)
		messages(x, "distance")
		if (!pairwise) {
			d <- matrix(d, nrow=nrow(x), ncol=nrow(y), byrow=TRUE)
		}
		d
	}
)


setMethod("distance", signature(x="matrix", y="matrix"),
	function(x, y, lonlat, pairwise=FALSE, unit="m") {
		if (missing(lonlat)) {
			error("distance", "you must set lonlat to TRUE or FALSE")
		}
		unit <- as.character(unit[1])
		stopifnot(ncol(x) == 2)
		stopifnot(ncol(y) == 2)
		crs <- ifelse(lonlat, "+proj=longlat +datum=WGS84",
							  "+proj=utm +zone=1 +datum=WGS84")
		x <- vect(x, crs=crs)
		y <- vect(y, crs=crs)
		distance(x, y, pairwise, unit=unit)
	}
)


setMethod("distance", signature(x="matrix", y="missing"),
	function(x, y, lonlat=NULL, sequential=FALSE, unit="m") {
		if (is.null(lonlat)) {
			error("distance", "lonlat should be TRUE or FALSE")
		}
		unit <- as.character(unit[1])
		crs <- ifelse(isTRUE(lonlat), "+proj=longlat +datum=WGS84",
							  "+proj=utm +zone=1 +datum=WGS84")
		x <- vect(x, crs=crs)
		distance(x, sequential=sequential, unit=unit)
	}
)


setMethod("direction", signature(x="SpatRaster"),
	function(x, from=FALSE, degrees=FALSE, filename="", ...) {
		opt <- spatOptions(filename, ...)
		x@ptr <- x@ptr$rastDirection(from[1], degrees[1], NA, NA, opt)
		messages(x, "direction")
	}
)

