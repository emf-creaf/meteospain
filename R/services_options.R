#' Options for meteorological services
#'
#' Set the options for accessing the different spanish meteorological services
#'
#' @param resolution Character indicating the temporal resolution for the data. Services allows different
#'   temporal resolutions that can be present or not in each of them (hourly, daily, monthly, instant).
#' @param start_date Date class object with the start date from which start collecting data. Ignored if
#'   resolution is one of \code{current_day} or \code{instant}.
#' @param end_date Date class object with the end date from which stop collecting data. If NULL (default),
#'   only the date in \code{start_date} is returned. Ignored if resolution is one of \code{current_day} or
#'   \code{instant}.
#' @param stations Character vector with the stations codes from which extract data from. If NULL (default)
#'   all available stations are returned.
#' @param api_key Character with the API key. NULL by default as not all services require keys. See API Keys
#'   section for more details.
#'
#' @section Resolution:
#' Temporal resolutions vary from service to service. Check the "Usage" section to see resolutions available
#' to each service. Possible values are:
#' \itemize{
#'   \item{\code{current_day} returns the last 24h of measures.}
#'   \item{\code{instant} returns the last measure available.}
#'   \item{\code{hourly} returns any past date/s in hourly format.}
#'   \item{\code{daily} returns any past date/s with daily aggregation.}
#'   \item{\code{monthly} returns any past date/s with monthly aggregation.}
#' }
#'
#' @section Keys:
#' Some services (i.e. AEMET, SMC...) require an API key to access the data. The requirements and process
#' to obtain the key varies from service to service.
#' \itemize{
#'   \item{AEMET: Visit \link{https://opendata.aemet.es/centrodedescargas/inicio} and follow the instructions
#'   at "Obtencion de API Key".}
#'   \item{SMC: Visit \link{https://apidocs.meteocat.gencat.cat/} and follow the instructions there.}
#' }
#' It is not advisable to use the keys directly in any script shared or publicly available (github...), neither
#' store them in plain text files.One option is using the keyring package
#' (\link{https://github.com/r-lib/keyring}) for managing and accesing keys.
#'
#' @name services_options
#' @return A list with the service API options to make the query to obtain the data.
NULL


#' Options for AEMET service
#'
#' Set the options for accessing the AEMET service
#'
#' @examples
#' library(keyring)
#' library(meteospain)
#' library(lubridate)
#'
#' # setting the key (a prompt will appear in console to supply the API key)
#' keyring::key_set(service = 'aemet', user = 'me')
#'
#' # create the options
#' query_options <- aemet_options(
#'   dates = as_date(as_date('1990-01-01'):as_date('1990-02-01')),
#'   resolution = 'daily',
#'   api = keyring::key_get('aemet', 'me')
#' )
#'
#' @rdname services_options
#'
#' @export
aemet_options <- function(
  resolution = c('current_day', 'daily'),
  start_date = Sys.Date(),
  end_date = NULL,
  stations = NULL,
  api_key
) {
  # check arguments
  resolution <- rlang::arg_match(resolution)
  assertthat::assert_that(
    assertthat::is.date(start_date),
    dplyr::if_else(rlang::is_null(end_date), TRUE, assertthat::is.date(end_date)),
    dplyr::if_else(rlang::is_null(stations), TRUE, rlang::is_character(stations)),
    rlang::is_character(api_key)
  )

  # stamp dates function
  aemet_stamp <- lubridate::stamp("2020-12-25T00:00:00UTC")

  # build list
  res <- list(
    resolution = resolution,
    start_date = aemet_stamp(start_date),
    end_date = dplyr::if_else(rlang::is_null(end_date), aemet_stamp(start_date), aemet_stamp(end_date)),
    stations = stations,
    api_key = api_key
  )

  return(res)
}

#' Options for SMC service
#'
#' Set the options for accessing the SMC service
#'
#' @examples
#' library(keyring)
#' library(meteospain)
#' library(lubridate)
#'
#' # setting the key (a prompt will appear in console to supply the API key)
#' keyring::key_set(service = 'smc', user = 'me')
#'
#' # create the options
#' query_options <- smc_options(
#'   dates = as_date(as_date('1990-01-01'):as_date('2020-12-31')),
#'   resolution = 'daily',
#'   api = keyring::key_get('smc', 'me')
#' )
#'
#' @rdname services_options
#'
#' @export
smc_options <- function(
  dates,
  stations = NULL,
  resolution = c('instant', 'hourly', 'daily', 'monthly'),
  api_key
) {
  # check arguments
  resolution <- rlang::arg_match(resolution)
  assertthat::assert_that(
    assertthat::is.date(dates),
    dplyr::if_else(rlang::is_null(stations), TRUE, rlang::is_character(stations)),
    rlang::is_character(api_key)
  )

  # build list
  list(
    dates = dates,
    stations = stations,
    resolution = resolution,
    api_key = api_key
  )
}

#' Options for Meteoclimatic service
#'
#' Set the options for accessing the Meteoclimatic service
#'
#' @examples
#' library(meteospain)
#' library(lubridate)
#'
#' query_options <- meteoclimatic_options(
#'   resolution = 'present_day'
#' )
#'
#' @rdname services_options
#'
#' @export
meteoclimatic_options <- function(
  stations = NULL,
  resolution = c('instant', 'present_day')
) {
  # check arguments
  resolution <- rlang::arg_match(resolution)
  assertthat::assert_that(
    dplyr::if_else(rlang::is_null(stations), TRUE, rlang::is_character(stations))
  )

  # build list
  list(
    stations = stations,
    resolution = resolution
  )
}

#' Options for MeteoGalicia service
#'
#' Set the options for accessing the MeteoGalicia service
#'
#' @examples
#' library(meteospain)
#' library(lubridate)
#'
#' # create the options
#' query_options <- meteogalicia_options(
#'   dates = as_date(as_date('1990-01-01'):as_date('2020-12-31')),
#'   resolution = 'daily'
#' )
#'
#' @rdname services_options
#'
#' @export
meteogalicia_options <- function(
  dates,
  stations = NULL,
  resolution = c('instant', 'hourly', 'daily', 'monthly')
) {
  # check arguments
  resolution <- rlang::arg_match(resolution)
  assertthat::assert_that(
    assertthat::is.date(dates),
    dplyr::if_else(rlang::is_null(stations), TRUE, rlang::is_character(stations))
  )

  # build list
  list(
    dates = dates,
    stations = stations,
    resolution = resolution
  )
}
