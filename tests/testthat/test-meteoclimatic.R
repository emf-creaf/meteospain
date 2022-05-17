# skip on cran ----------------------------------------------------------------------------------------

skip_on_cran()
skip_if_no_internet()

# meteoclimatic service options tests -------------------------------------------------------------------

test_that("meteoclimatic options works", {
  expected_names <- c("resolution", "stations")
  expect_type(meteoclimatic_options(), 'list')
  expect_identical(meteoclimatic_options(), meteoclimatic_options('current_day', 'ES'))
  expect_named(meteoclimatic_options(), expected_names)
  # errors
  expect_error(meteoclimatic_options('not_valid_resolution'), "must be one of")
  expect_error(meteoclimatic_options(stations = c('ESCAT', 'ESCYL')), 'length 1')
  expect_error(meteoclimatic_options(stations = c(25, 26, 27)), "must be a character vector")

})

# meteoclimatic get info tests ----------------------------------------------------------------------------------

test_that("meteoclimatic get info works", {
  api_options <- meteoclimatic_options()
  test_object <- suppressMessages(get_stations_info_from('meteoclimatic', api_options))
  expected_names <- c("service", "station_id", "station_name", "geometry")
  main_test_battery(
    test_object, service = 'meteoclimatic', expected_names = expected_names, meteoclimatic = TRUE
  )
})

# meteoclimatic get meteo tests --------------------------------------------------------------------------

test_that("Meteoclimatic works as expected", {
  # all stations
  api_options <- meteoclimatic_options(stations = 'ES', 'current_day')
  expect_message((test_object <- get_meteo_from('meteoclimatic', api_options)), 'non-professional')
  expected_names <- c(
    "timestamp", "service", "station_id", "station_name", "min_temperature", "max_temperature",
    "min_relative_humidity", "max_relative_humidity", "precipitation", "geometry"
  )
  main_test_battery(
    test_object, service = 'meteoclimatic', expected_names = expected_names, temperature = min_temperature,
    meteoclimatic = TRUE
  )
  # one station
  stations_to_check <- get_stations_info_from('meteoclimatic', api_options)[['station_id']][11]
  api_options$stations <- stations_to_check
  test_object <- suppressMessages(get_meteo_from('meteoclimatic', api_options))
  main_test_battery(
    test_object, service = 'meteoclimatic', expected_names = expected_names, temperature = min_temperature,
    stations_to_check = stations_to_check, meteoclimatic = TRUE
  )
})

test_that("meteoclimatic errors, warnings and messages are correctly raised", {
  # copyright message
  api_options <- meteoclimatic_options(stations = 'ES', 'current_day')
  api_options$stations <- 'tururu'
  expect_error(get_meteo_from('meteoclimatic', api_options), 'not found in Meteoclimatic')
})
