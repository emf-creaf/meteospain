# on load memoization of get functions
.onLoad <- function(libname, pkgname) {
  # cache creation
  apis_cache <<- cachem::cache_mem(max_size = 1024 * 1024^2, max_age = 3600*24)
}
