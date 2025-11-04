# imports from other packages ---------------------------------------------------------------------------

#' @importFrom rlang := .data
NULL


# cli styles -----------------------------------------------------------------------------------------

#' cli styles to use
#' @noRd
copyright_style <- cli::combine_ansi_styles('bold', 'yellow')
legal_note_style <- cli::combine_ansi_styles('blue', 'underline')


# swiss knives ------------------------------------------------------------------------------------------

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
    "1" = "max_atmospheric_pressure",
    "2" = "min_atmospheric_pressure",
    "3" = "max_relative_humidity",
    "32" = "temperature",
    "33" = "relative_humidity",
    "34" = "atmospheric_pressure",
    "35" = "precipitation",
    "36" = "global_solar_radiation",
    "38" = "snow_cover",
    "40" = "max_temperature",
    "42" = "min_temperature",
    "44" = "min_relative_humidity",
    "46" = "wind_speed",
    "47" = "wind_direction",
    "56" = "max_wind_speed",
    "57" = "max_wind_direction",
    "59" = "net_solar_radiation",
    "72" = "max_precipitation_minute",
    # daily
    "1000" = "mean_temperature",
    "1001" = "max_temperature",
    "1002" = "min_temperature",
    "1003" = "mean_temperature_classic",
    "1004" = "thermal_amplitude",
    "1100" = "mean_relative_humidity",
    "1101" = "max_relative_humidity",
    "1102" = "min_relative_humidity",
    "1200" = "mean_atmospheric_pressure",
    "1201" = "max_atmospheric_pressure",
    "1202" = "min_atmospheric_pressure",
    "1300" = "precipitation",
    "1301" = "precipitation_8h_8h",
    "1302" = "max_precipitation_minute",
    "1303" = "max_precipitation_hour",
    "1304" = "max_precipitation_30m",
    "1305" = "max_precipitation_10m",
    "1400" = "global_solar_radiation",
    "1505" = "mean_wind_speed",
    "1511" = "mean_wind_direction",
    "1514" = "max_wind_speed",
    "1517" = "max_wind_direction",
    "1600" = "mean_snow_cover",
    "1601" = "max_snow_cover",
    "1602" = "new_snow_cover",
    "1603" = "min_snow_cover",
    "1700" = "reference_evapotranspiration",
    # monthly
    "2000" = "mean_temperature",
    "2001" = "max_temperature_absolute",
    "2002" = "min_temperature_absolute",
    "2003" = "max_temperature_mean",
    "2004" = "min_temperature_mean",
    "2005" = "mean_temperature_classic",
    "2006" = "frost_days",
    "2007" = "max_thermal_amplitude",
    "2008" = "mean_thermal_amplitude",
    "2009" = "extreme_thermal_amplitude",
    "2100" = "mean_relative_humidity",
    "2101" = "max_relative_humidity_absolute",
    "2102" = "min_relative_humidity_absolute",
    "2103" = "max_relative_humidity_mean",
    "2104" = "min_relative_humidity_mean",
    "2200" = "mean_atmospheric_pressure",
    "2201" = "max_atmospheric_pressure_absolute",
    "2202" = "min_atmospheric_pressure_absolute",
    "2203" = "max_atmospheric_pressure_mean",
    "2204" = "min_atmospheric_pressure_mean",
    "2300" = "precipitation",
    "2301" = "precipitation_8h_8h",
    "2302" = "max_precipitation_minute",
    "2303" = "max_precipitation_24h",
    "2304" = "max_precipitation_24h_8h_8h",
    "2305" = "rain_days_0",
    "2306" = "rain_days_02",
    "2307" = "max_precipitation_hour",
    "2308" = "max_precipitation_30m",
    "2309" = "max_precipitation_10m",
    "2400" = "global_solar_radiation",
    "2505" = "mean_wind_speed",
    "2511" = "mean_wind_direction",
    "2514" = "max_wind_speed",
    "2517" = "max_wind_direction",
    "2520" = "max_wind_speed_mean",
    "2600" = "mean_snow_cover",
    "2601" = "max_snow_cover",
    "2602" = "new_snow_cover",
    # yearly
    "3000" = "mean_temperature",
    "3001" = "max_temperature_absolute",
    "3002" = "min_temperature_absolute",
    "3003" = "max_temperature_mean",
    "3004" = "min_temperature_mean",
    "3005" = "mean_temperature_classic",
    "3006" = "frost_days",
    "3007" = "max_thermal_amplitude",
    "3008" = "mean_thermal_amplitude",
    "3009" = "extreme_thermal_amplitude",
    "3010" = "thermal_oscillation",
    "3100" = "mean_relative_humidity",
    "3101" = "max_relative_humidity_absolute",
    "3102" = "min_relative_humidity_absolute",
    "3103" = "max_relative_humidity_mean",
    "3104" = "min_relative_humidity_mean",
    "3200" = "mean_atmospheric_pressure",
    "3201" = "max_atmospheric_pressure_absolute",
    "3202" = "min_atmospheric_pressure_absolute",
    "3203" = "max_atmospheric_pressure_mean",
    "3204" = "min_atmospheric_pressure_mean",
    "3300" = "precipitation",
    "3301" = "precipitation_8h_8h",
    "3302" = "max_precipitation_minute",
    "3303" = "max_precipitation_24h",
    "3304" = "max_precipitation_24h_8h_8h",
    "3305" = "rain_days_0",
    "3306" = "rain_days_02",
    "3307" = "max_precipitation_hour",
    "3308" = "max_precipitation_30m",
    "3309" = "max_precipitation_10m",
    "3400" = "global_solar_radiation",
    "3505" = "mean_wind_speed",
    "3511" = "mean_wind_direction",
    "3514" = "max_wind_speed",
    "3517" = "max_wind_direction",
    "3520" = "max_wind_speed_mean",
    "3600" = "mean_snow_cover",
    "3601" = "max_snow_cover",
    "3602" = "new_snow_cover"
  )

  code_dictionary[as.character(codes)]

}

#' Relocate all vars in the same way for any service/resolution combination
#' @noRd
relocate_vars <- function(data) {
  data |>
    dplyr::relocate(
      dplyr::matches("timestamp"),
      dplyr::matches("service"),
      dplyr::contains("station"),
      dplyr::contains("altitude"),
      dplyr::starts_with("temperature"),
      dplyr::starts_with("mean_temperature"),
      dplyr::starts_with("min_temperature"),
      dplyr::starts_with("max_temperature"),
      dplyr::contains("thermal"),
      dplyr::starts_with("relative_humidity"),
      dplyr::starts_with("mean_relative_humidity"),
      dplyr::starts_with("min_relative_humidity"),
      dplyr::starts_with("max_relative_humidity"),
      dplyr::contains("precipitation"),
      dplyr::contains("direction"),
      dplyr::contains("speed"),
      dplyr::contains("sol"),
      dplyr::contains("pressure"),
      dplyr::contains("snow"),
      dplyr::contains("evapotranspiration"),
      "geometry"
    )
}

.ria_url2station <- function(stations_url) {
  purrr::map_chr(
    stations_url,
    \(station_url) {
      if (stringr::str_detect(station_url, 'mensuales')) {
        parts <- stringr::str_remove_all(
          station_url, 'https://www.juntadeandalucia.es/agriculturaypesca/ifapa/riaws/datosmensuales/'
        ) |>
          stringr::str_split('/', n = 3, simplify = TRUE)
        return(glue::glue("{parts[,1]}-{parts[,2]}"))
      } else {
        parts <- stringr::str_remove_all(
          station_url, 'https://www.juntadeandalucia.es/agriculturaypesca/ifapa/riaws/datosdiarios/forceEt0/'
        ) |>
          stringr::str_split('/', n = 3, simplify = TRUE)
        return(glue::glue("{parts[,1]}-{parts[,2]}"))
      }
    }
  )
}

.aemet_coords_generator <- function(coord_vec) {
  dplyr::if_else(
    stringr::str_detect(coord_vec, "S") | stringr::str_detect(coord_vec, "W"),
    stringr::str_remove_all(coord_vec, '[A-Za-z]') |>
      stringr::str_extract_all(".{1,2}") |>
      purrr::map(.f = as.numeric) |>
      purrr::map(\(splitted_values) {splitted_values * c(1, 1/60, 1/3600)}) |>
      purrr::map_dbl(\(x) {sum(x, na.rm = TRUE) * (-1)}),
    stringr::str_remove_all(coord_vec, '[A-Za-z]') |>
      stringr::str_extract_all(".{1,2}") |>
      purrr::map(.f = as.numeric) |>
      purrr::map(\(splitted_values) {splitted_values * c(1, 1/60, 1/3600)}) |>
      purrr::map_dbl(\(x) {sum(x, na.rm = TRUE)})
  )
}

#' @noRd
#' @author Ruben F. Casal
.parse_coords_dmsh <- function(coord){

  # converts from "DDMMSSsssH" DMS format to numeric DD
  dmsh <- stringr::str_sub_all(
    coord, cbind(start = c(1, 3, 5, 10), length = c(2, 2, 5, 1))
  )
  sapply(
    dmsh,
    function(x) {
      (as.numeric(x[1]) + as.numeric(x[2])/60 +  as.numeric(x[3])/3600000) *
        if (grepl(x[4],"W|S")) -1 else 1
    }
  )
}


unnest_safe <- function(x, ...) {

  # if x is a list instead of a dataframe, something went wrong (happens sometimes in
  # meteogalicia or meteocat).
  if (inherits(x, 'list')) {

    # with new purrr (>=1.0.0) empty response (like in some cases for meteocat
    # variables) is maintained as list() instead of NULL. So if is an empty
    # list, return tibble(), if is a list not empty, issue a warning
    if (length(x) > 0) {
      cli::cli_warn(c(
        "Something went wrong, no data.frame returned, but a list with the following names",
        names(x),
        "and the following contents {glue::glue_collapse(x, sep = '\n')}",
        "Returning an empty data.frame"
      ))
    }

    return(dplyr::tibble())
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

skip_if_no_internet <- function() {
  if (!httr2::is_online()) {
    testthat::skip("No internet connection, skipping tests")
  }
}

skip_if_no_auth <- function(service) {
  if (identical(Sys.getenv(service), "")) {
    testthat::skip(glue::glue("No authentication available for {service}"))
  } else {
    cli::cli_inform(c(
      i = "{.arg {service}} key found, running tests"
    ))
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
  testthat::expect_named(test_object, rlang::eval_tidy(args$expected_names), ignore.order = TRUE)
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
    testthat::expect_equal(sort(unique(test_object$station_id)), sort(rlang::eval_tidy(args$stations_to_check)))
  }
}

# cache functions
.get_cached_result <- function(cache_ref, x) {
  # logic:
  # if cache_ref exists, return its value.
  # cache is an internal package object created on load
  if (apis_cache$exists(cache_ref)) {
    return(apis_cache$get(cache_ref))
  }

  # if not create the cache with the evaluation of x and return that result
  res <- eval(x)
  apis_cache$set(cache_ref, res)
  return(res)
}

#' Clear all cached results
#'
#' Reset the internal cache used to limit the API requests.
#'
#' Cached results reduces the number of API requests, but sometimes we need
#' fresh results without restarting the R session. \code{clear_meteospain_cache} function
#' reset the cache for the actual R session.
#'
#' @export
clear_meteospain_cache <- function() {
  apis_cache$reset()
  cli::cli_alert_success("Cache cleared sucessfully")
  return(invisible(TRUE))
}