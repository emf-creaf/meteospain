#' Get meteorological stations data
#'
#' Connect and retrieve data from AEMET, SMC and other spanish meteorological stations services.
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
#' only serves daily data for 31 days in one query. In case a bigger period is wanted, a loop must
#' be done (see \code{\link[base]{for}}, \code{\link[base]{lapply}} or \code{\link[purrr]{map}}). When doing
#' this is recommendable to add a wait step of 3-5 seconds between loop steps, to avoid hitting the
#' query limits per minute.
#'
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
get_meteo_from <- function(service = c('aemet', 'smc', 'meteoclimatic', 'meteogalicia'), options) {
  # check arguments
  service <- rlang::arg_match(service)

  # dispatch the correct function depending on the service selected
  api_function <- switch(
    service,
    'aemet' = .get_data_aemet,
    'meteoclimatic' = .get_data_meteoclimatic,
    'meteogalicia' = .get_data_meteogalicia
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
  service = c('aemet', 'smc', 'meteoclimatic', 'meteogalicia'),
  options
) {
  # check arguments
  service <- rlang::arg_match(service)

  # dispatch the correct function depending on the service selected
  res <- switch(
    service,
    'aemet' = .get_info_aemet(options),
    'meteoclimatic' = .get_info_meteoclimatic(options),
    'meteogalicia' = .get_info_meteogalicia()
  )

  return(res)
}
