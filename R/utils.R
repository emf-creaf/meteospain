# imports from other packages ---------------------------------------------------------------------------

#' @importFrom magrittr %>%
#' @export
magrittr::`%>%`

#' @importFrom rlang := .data
NULL


# crayon styles -----------------------------------------------------------------------------------------

#' crayon styles to use
#' @importFrom  crayon combine_styles
#' @noRd
copyright_style <- crayon::combine_styles('bold', 'yellow')
legal_note_style <- crayon::combine_styles('blue', 'bold', 'underline')


# swiss knives ------------------------------------------------------------------------------------------

.empty_string_to_null <- function(glue_string) {
  if (length(glue_string) < 1) {
    NULL
  } else {
    glue_string
  }
}

.create_missing_vars <- function(df, var_names) {

  missing_var_names <- var_names[which(!var_names %in% names(df))]

  for (missing_var in missing_var_names) {
    df <- dplyr::mutate(df, {{ missing_var }} := rlang::na_dbl)
  }

  return(df)

}

.meteocat_var_codes_2_names <- function(codes) {

  code_dictionary <- c(
    # instant and hourly
    '32' = 'temperature',
    '33' = 'relative_humidity',
    '35' = 'precipitation',
    '36' = 'global_solar_radiation',
    '46' = 'wind_speed',
    '47' = 'wind_direction',
    # daily
    '1000' = 'mean_temperature',
    '1001' = 'max_temperature',
    '1002' = 'min_temperature',
    '1100' = 'mean_relative_humidity',
    '1101' = 'max_relative_humidity',
    '1102' = 'min_relative_humidity',
    '1300' = 'precipitation',
    '1400' = 'global_solar_radiation',
    '1505' = 'mean_wind_speed',
    '1511' = 'mean_wind_direction',
    # monthly
    '2000' = 'mean_temperature',
    '2001' = 'max_temperature_absolute',
    '2002' = 'min_temperature_absolute',
    '2003' = 'max_temperature_mean',
    '2004' = 'min_temperature_mean',
    '2100' = 'mean_relative_humidity',
    '2101' = 'max_relative_humidity_absolute',
    '2102' = 'min_relative_humidity_absolute',
    '2103' = 'max_relative_humidity_mean',
    '2104' = 'min_relative_humidity_mean',
    '2300' = 'precipitation',
    '2400' = 'global_solar_radiation',
    '2505' = 'mean_wind_speed',
    '2511' = 'mean_wind_direction',
    # yearly
    '3000' = 'mean_temperature',
    '3001' = 'max_temperature_absolute',
    '3002' = 'min_temperature_absolute',
    '3003' = 'max_temperature_mean',
    '3004' = 'min_temperature_mean',
    '3100' = 'mean_relative_humidity',
    '3101' = 'max_relative_humidity_absolute',
    '3102' = 'min_relative_humidity_absolute',
    '3103' = 'max_relative_humidity_mean',
    '3104' = 'min_relative_humidity_mean',
    '3300' = 'precipitation',
    '3400' = 'global_solar_radiation',
    '3505' = 'mean_wind_speed',
    '3511' = 'mean_wind_direction'
  )

  code_dictionary[as.character(codes)]

}

#' Relocate all vars in the same way for any service/resolution combination
#' @noRd
relocate_vars <- function(data) {
  data %>%
    dplyr::relocate(
      dplyr::matches('timestamp'),
      dplyr::matches('service'),
      dplyr::contains('station'),
      dplyr::contains('altitude'),
      dplyr::starts_with('temperature'),
      dplyr::starts_with('mean_temperature'),
      dplyr::starts_with('min_temperature'),
      dplyr::starts_with('max_temperature'),
      dplyr::starts_with('relative_humidity'),
      dplyr::starts_with('mean_relative_humidity'),
      dplyr::starts_with('min_relative_humidity'),
      dplyr::starts_with('max_relative_humidity'),
      dplyr::contains('precipitation'),
      dplyr::contains('direction'),
      dplyr::contains('speed'),
      dplyr::contains('sol'),
      .data$geometry
    )
}

.ria_url2station <- function(station_url) {
  if (stringr::str_detect(station_url, 'mensuales')) {
    parts <- stringr::str_remove_all(
      station_url, 'https://www.juntadeandalucia.es/agriculturaypesca/ifapa/riaws/datosmensuales/'
    ) %>%
      stringr::str_split('/', n = 3, simplify = TRUE)
    return(glue::glue("{parts[,1]}-{parts[,2]}"))
  } else {
    parts <- stringr::str_remove_all(
      station_url, 'https://www.juntadeandalucia.es/agriculturaypesca/ifapa/riaws/datosdiarios/forceEt0/'
    ) %>%
      stringr::str_split('/', n = 3, simplify = TRUE)
    return(glue::glue("{parts[,1]}-{parts[,2]}"))
  }
}

.manage_429_errors <- function(api_status_check, api_options, .f) {

  # if api request limit reached, do a recursive call to the function after 60 seconds
  # But only once. Is complicated to know if the limit is because too much request per second or
  # if the quota limit has been reached. So, we repeat once after 60 seconds, and if the error
  # persists, stop.
  # For that we use api_options$while_number. If it is null or less than one repeat,
  # if not, stop
  while (is.null(api_options$while_number) || api_options$while_number < 1) {
    message(copyright_style(api_status_check$message))
    message("Trying again in 60 seconds")
    Sys.sleep(60)
    api_options$while_number <- 1
    return(.f(api_options))
  }
  stop(api_status_check$code, ':\n', api_status_check$message)
}

unnest_safe <- function(x, ...) {

  # if x is a list instead of a dataframe, something went wrong (happens sometimes in
  # meteogalicia or meteocat).
  if (inherits(x, 'list')) {
    stop(glue::glue(
      "Something went wrong, no data.frame returned, but a list with the following names {names(x)} and the following contents {glue::glue_collapse(x, sep = '\n')}"
    ))
  }

  # now, we need to check if "x" is NULL. Sometimes the list of dataframes is not complete, with
  # some elements being NULL. This happens for example in meteocat with some variables before 2010.
  # If this happens, we must return something, instead of processing the data with dplyr::unnest.
  if (is.null(x) || nrow(x) < 1) {
    return(dplyr::tibble())
  }

  return(tidyr::unnest(x, ...))

}

# test helpers ------------------------------------------------------------------------------------------

skip_if_no_auth <- function(service) {
  if (identical(Sys.getenv(service), "")) {
    testthat::skip(glue::glue("No authentication available for {service}"))
  } else {
    message(glue::glue("{service} key found, running tests"))
  }
}

main_test_battery <- function(test_object, ...) {
  args <- rlang::enquos(...)

  # general tests, common for data and stations info
  # is a sf
  testthat::expect_s3_class(test_object, 'sf')
  # has data, more than zero rows
  testthat::expect_true(nrow(test_object) > 0)
  # has expected names
  testthat::expect_named(test_object, rlang::eval_tidy(args$expected_names))
  # has the correct service value
  testthat::expect_identical(unique(test_object$service), rlang::eval_tidy(args$service))

  # conditional tests.
  # units in altitude ON ALL SERVICES EXCEPT FOR METEOCLIMATIC
  if (is.null(args$meteoclimatic)) {
    testthat::expect_s3_class(test_object$altitude, 'units')
    testthat::expect_identical(units(test_object$altitude)$numerator, "m")
  }

  # units in temperature and timestamp: ONLY IN DATA, NOT STATIONS
  if (!is.null(args$temperature)) {
    testthat::expect_s3_class(rlang::eval_tidy(args$temperature, data = test_object), 'units')
    # testthat::expect_identical(units(rlang::eval_tidy(args$temperature, data = test_object))$numerator, "\u00B0C")
    # The commented test above doesn't work in debian-clang latin-1 CRAN tests, so we test then that it gives
    # the symbol unit or the text unit:
    testthat::expect_true(
      units(rlang::eval_tidy(args$temperature, data = test_object))$numerator %in% c("\u00B0C", "degree_Celsius")
    )
    testthat::expect_s3_class(test_object$timestamp, 'POSIXct')
    testthat::expect_false(all(is.na(test_object$timestamp)))
  }
  # selected stations: ONLY IN DATA WHEN SUBSETTING STATIONS
  if (!is.null(args$stations_to_check)) {
    testthat::expect_equal(unique(test_object$station_id), rlang::eval_tidy(args$stations_to_check))
  }
}

# unnest_debug <- function(x, ...) {
#
#   if (inherits(x, 'list')) {
#     stop(glue::glue(
#       "Something went wrong, no data.frame returned, but a list with the following names {names(x)} and the following contents {glue::glue_collapse(x, sep = '\n')}"
#     ))
#   }
#
#   return(tidyr::unnest(x, ...))
#
# }


# httr safe functions -----------------------------------------------------

# safe GET
safeGET <- function(...) {

  # first of all, check internet connection
  if (!curl::has_internet()) {
    stop("No internet connection detected")
  }

  # create safe version
  sGET <- purrr::safely(httr::GET)

  # get response
  response <- sGET(...)

  # checks and errors
  if (is.null(response$result)) {
    din_dots <- rlang::list2(...)
    stop(
      glue::glue("Unable to connect to API at {din_dots[[1]]}: {response$error}\n"),
      glue::glue("This usually happens when connection with {din_dots[[1]]} is not possible")
    )
  }

  return(response$result)
}
