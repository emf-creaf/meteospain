# on load memoization of get functions
.onLoad <- function(libname, pkgname) {
  # get_meteo_from <<- memoise::memoise(
  #   get_meteo_from, cache = cachem::cache_mem(max_size = 1024 * 1024^2, max_age = 3600*24)
  # )
  # get_stations_info_from <<- memoise::memoise(
  #   get_stations_info_from, cache = cachem::cache_mem(max_size = 1024 * 1024^2, max_age = 3600*24)
  # )
  apis_cache <<- cachem::cache_mem(max_size = 1024 * 1024^2, max_age = 3600*24)
}
