# meteoclimatic get meteo tests --------------------------------------------------------------------------

test_that("Meteoclimatic works as expected", {
  # all stations
  api_options <- meteoclimatic_options(stations = 'ES', 'current_day')
  test_object <- suppressMessages(get_meteo_from('meteoclimatic', api_options))
  expected_names <- c(
    "timestamp", "station_id", "station_name", "max_temperature", "min_temperature",
    "max_relative_humidity", "min_relative_humidity", "precipitation", "geometry"
  )
  expect_s3_class(test_object, 'sf')
  expect_true(nrow(test_object) > 1)
  expect_named(test_object, expected_names)
  # one station
  api_options$stations <- test_object[['station_id']][1]
  test_object <- suppressMessages(get_meteo_from('meteoclimatic', api_options))
  expect_s3_class(test_object, 'sf')
  expect_true(nrow(test_object) == 1)
  expect_named(test_object, expected_names)
})

test_that("meteoclimatic errors, warnings and messages are correctly raised", {
  # copyright message
  api_options <- meteoclimatic_options(stations = 'ES', 'current_day')
  expect_message(get_meteo_from('meteoclimatic', api_options), 'non-professional')
  api_options$stations <- 'tururu'
  expect_error(get_meteo_from('meteoclimatic', api_options), 'not found in Meteoclimatic')
})

# meteoclimatic get info tests ----------------------------------------------------------------------------------

test_that("meteoclimatic get info works", {
  api_options <- meteoclimatic_options()
  test_object <- suppressMessages(get_stations_info_from('meteoclimatic', api_options))
  expected_names <- c("station_id", "station_name", "geometry")

  expect_s3_class(test_object, 'sf')
  expect_true(nrow(test_object) > 1)
  expect_named(test_object, expected_names)
})
