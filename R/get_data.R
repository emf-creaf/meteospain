#' Get meteorological stations data
#'
#' Connect and retrieve data from AEMET, SMC and other Spanish meteorological stations services.
#'
#' Depending on the service and the temporal resolution selected, the variables present can change, but all
#' services have at least temperature values.
#'
#' @param service Character with the service name (in lower case).
#' @param options List with the needed service options. See \code{\link{services_options}} to have more info
#'   about the different services and their options.
#'
#' @section API limits:
#' Some APIs have limits in terms of the data that can be retrieved with one call. For example, AEMET
#' only serves daily data for 31 days in one query. See \code{vignette('api_limits', package = 'meteospain')}
#' for a detailed explanations of those limits and the ways to retrieve longer periods.
#'
#' @section Cache:
#' In order to avoid unnecessary API calls, results of this function are cached in memory with
#' \code{\link[memoise]{memoise}}. This means that subsequent calls from \code{get_meteo_from} with the same
#' arguments will be faster as they will not call the meteorological service API. This cache has a maximum
#' size of 1024 MB and persist 24 hours in the same R session after loading the package.
#'
#' @examples
#' \donttest{
#' library(meteospain)
#' library(keyring)
#'
#' # AEMET (we need a key)
#' # key_set('aemet')
#' options_for_aemet <- aemet_options(
#'   'daily',
#'   start_date = as.Date('2012-01-01'),
#'   end_date = as.Date('2012-02-01'),
#'   api_key = key_get('aemet')
#' )
#' get_meteo_from('aemet', options_for_aemet)
#' }
#'
#' @return An sf (spatial) object with the stations meteorological data.
#'
#' @export
get_meteo_from <- function(service = c('aemet', 'meteocat', 'meteoclimatic', 'meteogalicia', 'ria'), options) {
  # check internet connection
  if (!curl::has_internet()) {
    stop("No internet connection detected")
  }

  # check arguments
  service <- rlang::arg_match(service)

  # dispatch the correct function depending on the service selected
  api_function <- switch(
    service,
    'aemet' = .get_data_aemet,
    'meteocat' = .get_data_meteocat,
    'meteoclimatic' = .get_data_meteoclimatic,
    'meteogalicia' = .get_data_meteogalicia,
    'ria' = .get_data_ria
  )

  return(api_function(options))

}

#' Get meteorological stations info
#'
#' Obtain info and metadata for the available stations in the different services
#'
#' Depending on the service the metadata available can be different. Also, some services only offer
#' info for active stations (i.e. AEMET), not historical stations, so some mismatch can occur between
#' the stations returned by this function and the stations returned by \code{\link{get_meteo_from}} for
#' historical dates.
#'
#' @param service Character with the service name (in lower case).
#' @param options List with the needed service options. See \code{\link{services_options}} to have more info
#'   about the different services and their options.
#'
#' @section Cache:
#' In order to avoid unnecessary API calls, results of this function are cached in memory with
#' \code{\link[memoise]{memoise}}. This means that subsequent calls from \code{get_meteo_from} with the same
#' arguments will be faster as they will not call the meteorological service API. This cache has a maximum
#' size of 1024 MB and persist 24 hours in the same R session after loading the package.
#'
#' @examples
#' \donttest{
#' library(meteospain)
#' library(keyring)
#'
#' # AEMET (we need a key)
#' # key_set('aemet')
#' api_options <- aemet_options(api_key = key_get('aemet'))
#' get_stations_info_from('aemet', api_options)
#' }
#'
#' @return An sf (spatial) object with the stations metadata.
#'
#' @export
get_stations_info_from <- function(
  service = c('aemet', 'meteocat', 'meteoclimatic', 'meteogalicia', 'ria'),
  options
) {
  # check internet connection
  if (!curl::has_internet()) {
    stop("No internet connection detected")
  }

  # check arguments
  service <- rlang::arg_match(service)

  # dispatch the correct function depending on the service selected
  res <- switch(
    service,
    'aemet' = .get_info_aemet(options),
    'meteocat' = .get_info_meteocat(options),
    'meteoclimatic' = .get_info_meteoclimatic(options),
    'meteogalicia' = .get_info_meteogalicia(),
    'ria' = .get_info_ria(options)
  )

  return(res)
}

#' Get api quota info
#'
#' Obtain info about the API quota used
#'
#' Depending on the service, some APIs allows only a number of data requests. This function access the user
#' quota numbers in the services that allow for this, \strong{(currently only MeteoCat)}
#'
#' @param service Character with the service name (in lower case).
#' @param options List with the needed service options. See \code{\link{services_options}} to have more info
#'   about the different services and their options.
#'
#' @examples
#' \donttest{
#' library(meteospain)
#' library(keyring)
#'
#' # MeteoCat (we need a key)
#' # key_set('meteocat')
#' api_options <- meteocat_options(api_key = key_get('meteocat'))
#' get_quota_from('meteocat', api_options)
#' }
#'
#' @return A data frame with the quota info
#'
#' @export
get_quota_from <- function(service = c('meteocat'), options) {
  # check internet connection
  if (!curl::has_internet()) {
    stop("No internet connection detected")
  }

  # check arguments
  service <- rlang::arg_match(service)

  # dispatch the correct function depending on the service selected
  res <- switch(
    service,
    'meteocat' = .get_quota_meteocat(options)
  )

  return(res)
}
