# imports from other packages ---------------------------------------------------------------------------

#' @importFrom magrittr %>%
#' @export
magrittr::`%>%`

#' @importFrom rlang := .data
NULL


# crayon styles -----------------------------------------------------------------------------------------

copyright_style <- crayon::yellow$bold
legal_note_style <- crayon::blue$bold$underline


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

.riaa_url2station <- function(station_url) {
  if (stringr::str_detect(station_url, 'mensuales')) {
    stringr::str_remove_all(
      station_url, 'https://www.juntadeandalucia.es/agriculturaypesca/ifapa/riaws/datosmensuales/'
    ) %>%
      stringr::str_split('/', n = 3, simplify = TRUE) %>%
      magrittr::extract(2)
  }
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
    testthat::expect_identical(units(rlang::eval_tidy(args$temperature, data = test_object))$numerator, "\u00B0C")
    testthat::expect_s3_class(test_object$timestamp, 'POSIXct')
    testthat::expect_false(all(is.na(test_object$timestamp)))
  }
  # selected stations: ONLY IN DATA WHEN SUBSETTING STATIONS
  if (!is.null(args$stations_to_check)) {
    testthat::expect_equal(unique(test_object$station_id), rlang::eval_tidy(args$stations_to_check))
  }
}

unnest_debug <- function(x, ...) {

  if (inherits(x, 'list')) {
    stop(glue::glue(
      "Something went wrong, no data.frame returned, but a list with the following names {names(x)} and the following contents {glue::glue_collapse(x, sep = '\n'}"
    ))
  }

  return(tidyr::unnest(x, ...))

}
