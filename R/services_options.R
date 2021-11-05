#' Options for meteorological services
#'
#' Set the options for accessing the different Spanish meteorological services
#'
#' @param resolution Character indicating the temporal resolution for the data. Services allows different
#'   temporal resolutions that can be present or not in each of them (current_day, instant, daily, monthly).
#' @param start_date Date class object with the start date from which start collecting data. Ignored if
#'   resolution is one of \code{current_day} or \code{instant}.
#' @param end_date Date class object with the end date from which stop collecting data. By default, same
#'   date as \code{start_date}. Ignored if resolution is one of \code{current_day} or \code{instant}.
#' @param stations Character vector with the stations codes from which extract data from. If NULL (default)
#'   all available stations are returned. See Stations section for more details.
#' @param api_key Character with the API key. NULL by default as not all services require keys. See API Keys
#'   section for more details.
#'
#' @section Resolution:
#' Temporal resolutions vary from service to service. Check the "Usage" section to see resolutions available
#' to each service. Possible values are:
#' \itemize{
#'   \item{\code{current_day} returns the last 24h of measures.}
#'   \item{\code{instant} returns the last measures available.}
#'   \item{\code{hourly} returns the hourly measures.}
#'   \item{\code{daily} returns any past date/s with daily aggregation.}
#'   \item{\code{monthly} returns any past date/s with monthly aggregation.}
#'   \item{\code{yearly} returns any past date/s with yearly aggregation.}
#' }
#'
#' @section Keys:
#' Some services (i.e. AEMET, MeteoCat...) require an API key to access the data. The requirements and process
#' to obtain the key varies from service to service.
#' \itemize{
#'   \item{AEMET: Visit \url{https://opendata.aemet.es/centrodedescargas/inicio} and follow the instructions
#'   at "Obtencion de API Key".}
#'   \item{MeteoCat: Visit \url{https://apidocs.meteocat.gencat.cat/} and follow the instructions there.}
#' }
#' It is not advisable to use the keys directly in any script shared or publicly available (github...), neither
#' store them in plain text files. One option is using the \href{https://github.com/r-lib/keyring}{keyring}
#' package for managing and accessing keys.
#'
#' @section Stations:
#' Some services accept querying multiple stations at once, and other only allows one station per query:
#' \itemize{
#'   \item{AEMET: One or more stations can be provided in a character vector.}
#'   \item{MeteoCat: One or more stations can be provided in a character vector.}
#'   \item{MeteoGalicia: One or more stations can be provided in a character vector.}
#'   \item{Meteoclimatic: Only one station can be provided. Nevertheless, some codes can be used to retrieve
#'   common group of stations: "ES" for all Spanish stations, "ESCAT", "ESCYL", "ESAND"... for the different
#'   autonomous communities.}
#'   \item{RIA: API accepts only one station. Nonetheless, an internal loop is performed to retrieve all the
#'   stations provided}
#' }
#'
#'
#' @name services_options
#' @return A list with the service API options to make the query to obtain the data.
NULL


#' Options for AEMET service
#'
#' @examples
#' \donttest{
#' library(keyring)
#' library(meteospain)
#'
#' ## AEMET examples ---------------------------------------------------------
#'
#' # setting the key (a prompt will appear in console to supply the API key)
#' # keyring::key_set(service = 'aemet')
#'
#' # Options for the last 24h data
#' current_opts <- aemet_options(
#'   resolution = 'current_day',
#'   api = keyring::key_get('aemet')
#' )
#'
#' # Options for daily data for January, 1990
#' daily_opts <- aemet_options(
#'   resolution = 'daily',
#'   start_date = as.Date('1990-01-01'),
#'   end_date = as.Date('1990-01-31'),
#'   api = keyring::key_get('aemet')
#' )
#' }
#'
#' @rdname services_options
#'
#' @export
aemet_options <- function(
  resolution = c('current_day', 'daily'),
  start_date = Sys.Date(),
  end_date = start_date,
  stations = NULL,
  api_key
) {
  # check arguments
  resolution <- rlang::arg_match(resolution)
  assertthat::assert_that(
    assertthat::is.date(start_date),
    assertthat::is.date(end_date),
    rlang::is_character(api_key)
  )
  assertthat::assert_that(
    dplyr::if_else(rlang::is_null(stations), TRUE, rlang::is_character(stations)),
    msg = "'stations' must be a character vector"
  )

  # build list
  res <- list(
    resolution = resolution,
    start_date = start_date,
    end_date = end_date,
    stations = stations,
    api_key = api_key
  )

  return(res)
}

#' Options for MeteoCat service
#'
#' @examples
#' \donttest{
#' ## MeteoCat examples -----------------------------------------------------------
#'
#' # setting the key (a prompt will appear in console to supply the API key)
#' # keyring::key_set(service = 'meteocat')
#'
#' # create the options
#' query_options <- meteocat_options(
#'   resolution = 'hourly',
#'   start_date = as.Date('2020-12-31'),
#'   api = keyring::key_get('meteocat')
#' )
#' }
#'
#' @rdname services_options
#'
#' @export
meteocat_options <- function(
  resolution = c('instant', 'hourly', 'daily', 'monthly', 'yearly'),
  start_date = Sys.Date(),
  stations = NULL,
  api_key
) {
  # check arguments
  resolution <- rlang::arg_match(resolution)
  assertthat::assert_that(
    assertthat::is.date(start_date),
    rlang::is_character(api_key)
  )
  assertthat::assert_that(
    dplyr::if_else(rlang::is_null(stations), TRUE, rlang::is_character(stations)),
    msg = "'stations' must be a character vector"
  )

  # build list
  list(
    resolution = resolution,
    start_date = start_date,
    stations = stations,
    api_key = api_key
  )
}

#' Options for Meteoclimatic service
#'
#' @examples
#'
#' ## Meteoclimatic examples -------------------------------------------------
#'
#' current_opts <- meteoclimatic_options()
#' # same as before, but more verbose
#' current_opts <- meteoclimatic_options(resolution = 'current_day', stations = 'ES')
#'
#' @rdname services_options
#'
#' @export
meteoclimatic_options <- function(
  resolution = c('current_day'),
  stations = NULL
) {
  # check arguments
  resolution <- rlang::arg_match(resolution)
  assertthat::assert_that(
    dplyr::if_else(rlang::is_null(stations), TRUE, rlang::is_character(stations)),
    dplyr::if_else(rlang::is_null(stations), TRUE, !length(stations) > 1),
    msg = "'stations' must be a character vector of length 1"
  )

  # check if stations is NULL, then return all Spanish stations
  if (rlang::is_null(stations)) {
    stations <- 'ES'
  }

  # build list
  list(
    resolution = resolution,
    stations = stations
  )
}

#' Options for MeteoGalicia service
#'
#' @examples
#'
#' ## MeteoGalicia examples --------------------------------------------------
#'
#' # Options for the last measured data
#' instant_opts <- meteogalicia_options(resolution = 'instant')
#'
#' # Options for the last 24h data
#' current_opts <- meteogalicia_options(resolution = 'current_day')
#' # same, with stations
#' current_opts <- meteogalicia_options('current_day', stations = c('10045', '10046'))
#'
#' # Options for daily data for January, 2000
#' daily_opts <- meteogalicia_options(
#'   resolution = 'daily',
#'   start_date = as.Date('2000-01-01'),
#'   end_date = as.Date('2000-01-31')
#' )
#'
#' # Options for monthly data for year 2000
#' monthly_opts <- meteogalicia_options(
#'   resolution = 'monthly',
#'   start_date = as.Date('2000-01-01'),
#'   end_date = as.Date('2000-12-31')
#' )
#'
#' @rdname services_options
#'
#' @export
meteogalicia_options <- function(
  resolution = c('instant', 'current_day', 'daily', 'monthly'),
  start_date = Sys.Date(),
  end_date = start_date,
  stations = NULL
) {
  # check arguments
  resolution <- rlang::arg_match(resolution)
  assertthat::assert_that(
    assertthat::is.date(start_date),
    assertthat::is.date(end_date)
  )
  assertthat::assert_that(
    dplyr::if_else(rlang::is_null(stations), TRUE, rlang::is_character(stations)),
    msg = "'stations' must be a character vector"
  )

  # build list
  res <- list(
    resolution = resolution,
    start_date = start_date,
    end_date = dplyr::if_else(rlang::is_null(end_date), start_date, end_date),
    stations = stations
  )

  return(res)
}

#' Options for RIA service
#'
#' @examples
#' \donttest{
#' library(keyring)
#' library(meteospain)
#'
#' ## RIA examples ---------------------------------------------------------
#'
#' # Options for daily data for April, 2020
#' daily_opts <- ria_options(
#'   resolution = 'daily',
#'   start_date = as.Date('2020-04-01'),
#'   end_date = as.Date('2020-04-30')
#' )
#' }
#'
#' @rdname services_options
#'
#' @export
ria_options <- function(
  resolution = c('daily', 'monthly'),
  start_date = Sys.Date() - 1,
  end_date = start_date,
  stations = NULL
) {
  # check arguments
  resolution <- rlang::arg_match(resolution)
  assertthat::assert_that(
    assertthat::is.date(start_date),
    assertthat::is.date(end_date)
  )
  assertthat::assert_that(
    dplyr::if_else(rlang::is_null(stations), TRUE, rlang::is_character(stations)),
    msg = "'stations' must be a character vector"
  )

  # build list
  res <- list(
    resolution = resolution,
    start_date = start_date,
    end_date = end_date,
    stations = stations
  )

  return(res)
}
