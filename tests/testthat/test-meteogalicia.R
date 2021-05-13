# meteogalicia get meteo tests ---------------------------------------------------------------------------
test_that("meteogalicia instant works", {
  # all stations
  api_options <- meteogalicia_options('instant')
  test_object <- suppressMessages(get_meteo_from('meteogalicia', api_options))
  expected_names <- c(
    "timestamp", "station_id", "station_name", "station_province", "altitude",
    "temperature",
    "relative_humidity", "precipitation",
    "wind_direction", "wind_speed",
    "insolation", "global_solar_radiation",
    "geometry"
  )
  expect_s3_class(test_object, 'sf')
  expect_true(nrow(test_object) > 1)
  expect_named(test_object, expected_names)
  # some stations
  stations_to_check <- test_object[['station_id']][1:3]
  api_options$stations <- stations_to_check
  test_object <- suppressMessages(get_meteo_from('meteogalicia', api_options))
  expect_s3_class(test_object, 'sf')
  expect_true(nrow(test_object) > 1)
  expect_equal(unique(test_object$station_id), stations_to_check)
  expect_named(test_object, expected_names)
})

test_that("meteogalicia current works", {
  # all stations
  api_options <- meteogalicia_options('current_day')
  test_object <- suppressMessages(get_meteo_from('meteogalicia', api_options))
  expected_names <- c(
    "timestamp", "station_id", "station_name", "station_province", "altitude",
    "temperature", "min_temperature", "max_temperature",
    "relative_humidity", "precipitation",
    "wind_direction", "wind_speed",
    "insolation",
    "geometry"
  )
  expect_s3_class(test_object, 'sf')
  expect_true(nrow(test_object) > 1)
  expect_named(test_object, expected_names)
  # some stations
  stations_to_check <- test_object[['station_id']][1:3]
  api_options$stations <- stations_to_check
  test_object <- suppressMessages(get_meteo_from('meteogalicia', api_options))
  expect_s3_class(test_object, 'sf')
  expect_true(nrow(test_object) > 1)
  expect_equal(unique(test_object$station_id), stations_to_check)
  expect_named(test_object, expected_names)
})

test_that("meteogalicia daily works", {
  # all stations actual
  api_options <- meteogalicia_options('daily', start_date = Sys.Date() - 30, end_date = Sys.Date())
  test_object <- suppressMessages(get_meteo_from('meteogalicia', api_options))
  expected_names <- c(
    "timestamp", "station_id", "station_name", "station_province", "altitude",
    "temperature", "min_temperature", "max_temperature",
    "relative_humidity", "min_relative_humidity", "max_relative_humidity", "precipitation",
    "wind_direction", "wind_speed",
    "insolation",
    "geometry"
  )
  expect_s3_class(test_object, 'sf')
  expect_true(nrow(test_object) > 1)
  expect_named(test_object, expected_names)
  expect_equal(unique(test_object$timestamp), seq(api_options$start_date, api_options$end_date, 1))
  # some stations actual
  stations_to_check <- test_object[['station_id']][1:3]
  api_options$stations <- stations_to_check
  test_object <- suppressMessages(get_meteo_from('meteogalicia', api_options))
  expect_s3_class(test_object, 'sf')
  expect_true(nrow(test_object) > 1)
  expect_equal(unique(test_object$station_id), stations_to_check)
  expect_named(test_object, expected_names)
  expect_equal(unique(test_object$timestamp), seq(api_options$start_date, api_options$end_date, 1))

  # all stations 2000s
  api_options <- meteogalicia_options('daily', start_date = as.Date('2000-01-25'), end_date = as.Date('2000-01-30'))
  test_object <- suppressMessages(get_meteo_from('meteogalicia', api_options))
  expect_s3_class(test_object, 'sf')
  expect_true(nrow(test_object) > 1)
  expect_named(test_object, expected_names)
  expect_equal(unique(test_object$timestamp), seq(api_options$start_date, api_options$end_date, 1))
  # some stations 2000s
  stations_to_check <- test_object[['station_id']][1:3]
  api_options$stations <- stations_to_check
  test_object <- suppressMessages(get_meteo_from('meteogalicia', api_options))
  expect_s3_class(test_object, 'sf')
  expect_true(nrow(test_object) > 1)
  expect_equal(unique(test_object$station_id), stations_to_check)
  expect_named(test_object, expected_names)
  expect_equal(unique(test_object$timestamp), seq(api_options$start_date, api_options$end_date, 1))
})

test_that("meteogalicia monthly works", {
  # all stations actual
  api_options <- meteogalicia_options('monthly', start_date = Sys.Date() - 365, end_date = Sys.Date())
  test_object <- suppressMessages(get_meteo_from('meteogalicia', api_options))
  expected_names <- c(
    "timestamp", "station_id", "station_name", "station_province", "altitude",
    "temperature", "min_temperature", "max_temperature",
    "relative_humidity", "precipitation",
    "wind_speed",
    "insolation",
    "geometry"
  )
  expect_s3_class(test_object, 'sf')
  expect_true(nrow(test_object) > 1)
  expect_named(test_object, expected_names)
  expect_length(unique(test_object$timestamp), 12)
  # some stations actual
  stations_to_check <- test_object[['station_id']][1:3]
  api_options$stations <- stations_to_check
  test_object <- suppressMessages(get_meteo_from('meteogalicia', api_options))
  expect_s3_class(test_object, 'sf')
  expect_true(nrow(test_object) > 1)
  expect_equal(unique(test_object$station_id), stations_to_check)
  expect_named(test_object, expected_names)
  expect_length(unique(test_object$timestamp), 12)

  # all stations 2000s
  api_options <- meteogalicia_options('monthly', start_date = as.Date('2000-01-01'), end_date = as.Date('2000-12-01'))
  test_object <- suppressMessages(get_meteo_from('meteogalicia', api_options))
  expect_s3_class(test_object, 'sf')
  expect_true(nrow(test_object) > 1)
  expect_named(test_object, expected_names)
  expect_length(unique(test_object$timestamp), 12)
  # some stations 2000s
  stations_to_check <- test_object[['station_id']][1:3]
  api_options$stations <- stations_to_check
  test_object <- suppressMessages(get_meteo_from('meteogalicia', api_options))
  expect_s3_class(test_object, 'sf')
  expect_true(nrow(test_object) > 1)
  expect_equal(unique(test_object$station_id), stations_to_check)
  expect_named(test_object, expected_names)
  expect_length(unique(test_object$timestamp), 12)
})

test_that("meteogalicia API errors, messages, warnings are correctly raised", {
  # copyright message
  api_options <- meteogalicia_options('current_day')
  expect_message(get_meteo_from('meteogalicia', api_options), 'A información divulgada')
  # dates out of bounds
  api_options <- meteogalicia_options(
    'daily',
    start_date = as.Date('1890-01-01'), end_date = as.Date('1890-01-02')
  )
  expect_error(get_meteo_from('meteogalicia', api_options), "MeteoGalicia API returned no data")
  # no data for stations selected
  api_options <- meteogalicia_options(
    'daily',
    start_date = as.Date('2020-01-01'), end_date = as.Date('2020-01-02'),
    stations = 'XXXXXX'
  )
  expect_error(get_meteo_from('meteogalicia', api_options), "bad station ids")
  api_options$resolution <- 'yearly'
  expect_error(get_meteo_from('meteogalicia', api_options), "is not a valid temporal resolution")
})


# meteogalicia get info tests ----------------------------------------------------------------------------------

test_that("meteogalicia get info works", {
  api_options <- meteogalicia_options()
  test_object <- suppressMessages(get_stations_info_from('meteogalicia', api_options))
  expected_names <- c("station_id", "station_name", "station_province", "altitude", "geometry")

  expect_s3_class(test_object, 'sf')
  expect_true(nrow(test_object) > 1)
  expect_named(test_object, expected_names)
})
