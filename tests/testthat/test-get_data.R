
# aemet get data tests ----------------------------------------------------------------------------------

test_that("aemet current works", {
  # all stations
  api_options <- aemet_options('current_day', api_key = keyring::key_get('aemet'))
  test_object <- suppressMessages(get_meteo_from('aemet', api_options))
  expected_names <- c(
    "timestamp", "station_id", "station_name", "altitude", "temperature", "min_temperature", "max_temperature",
    "precipitation", "relative_humidity", "wind_speed", "wind_direction", "geometry"
  )
  expect_s3_class(test_object, 'sf')
  expect_true(nrow(test_object) > 1)
  expect_named(test_object, expected_names)
  # some stations
  stations_to_check <- test_object[['station_id']][1:3]
  api_options$stations <- stations_to_check
  test_object <- suppressMessages(get_meteo_from('aemet', api_options))
  expect_s3_class(test_object, 'sf')
  expect_true(nrow(test_object) > 1)
  expect_equal(unique(test_object$station_id), stations_to_check)
  expect_named(test_object, expected_names)
})

test_that("aemet daily works", {
  # all stations "modern" time
  api_options <- aemet_options(
    'daily',
    start_date = as.Date('2020-04-01'), end_date = as.Date('2020-05-01'),
    api_key = keyring::key_get('aemet')
  )
  test_object <- suppressMessages(get_meteo_from('aemet', api_options))
  expected_names <- c(
    "timestamp", "station_id", "station_name", "station_province",
    "mean_temperature", "min_temperature", "max_temperature",
    "precipitation", "mean_wind_speed", "insolation", "altitude", "geometry"
  )
  expect_s3_class(test_object, 'sf')
  expect_true(nrow(test_object) > 1)
  expect_named(test_object, expected_names)
  # some stations
  stations_to_check <- test_object[['station_id']][1:3]
  api_options$stations <- stations_to_check
  test_object <- suppressMessages(get_meteo_from('aemet', api_options))
  expect_s3_class(test_object, 'sf')
  expect_true(nrow(test_object) > 1)
  expect_equal(unique(test_object$station_id), stations_to_check)
  expect_named(test_object, expected_names)
  # all stations 2000's
  api_options <- aemet_options(
    'daily',
    start_date = as.Date('2005-04-01'), end_date = as.Date('2005-05-01'),
    api_key = keyring::key_get('aemet')
  )
  test_object <- suppressMessages(get_meteo_from('aemet', api_options))
  expect_s3_class(test_object, 'sf')
  expect_true(nrow(test_object) > 1)
  expect_named(test_object, expected_names)
  # all stations 1990's
  api_options <- aemet_options(
    'daily',
    start_date = as.Date('1990-04-01'), end_date = as.Date('1990-05-01'),
    api_key = keyring::key_get('aemet')
  )
  test_object <- suppressMessages(get_meteo_from('aemet', api_options))
  expect_s3_class(test_object, 'sf')
  expect_true(nrow(test_object) > 1)
  expect_named(test_object, expected_names)
})

test_that("aemet API errors, messages, warnings are correctly raised", {
  # copyright message
  api_options <- aemet_options('current_day', api_key = keyring::key_get('aemet'))
  expect_message(get_meteo_from('aemet', api_options), 'Autorizado el uso')
  # invalid key
  api_options <- aemet_options('current_day', api_key = 'tururu')
  expect_error(get_meteo_from('aemet', api_options), "API key invalido")
  # dates out of bounds
  api_options <- aemet_options(
    'daily',
    start_date = as.Date('1890-01-01'), end_date = as.Date('1890-01-02'),
    api_key = keyring::key_get('aemet')
  )
  expect_error(get_meteo_from('aemet', api_options), "No hay datos")
  api_options <- aemet_options(
    'daily',
    start_date = as.Date('1990-01-01'), end_date = as.Date('1991-01-01'),
    api_key = keyring::key_get('aemet')
  )
  expect_error(get_meteo_from('aemet', api_options), "El rango de fechas")
  # no data for stations selected
  api_options <- aemet_options(
    'daily',
    start_date = as.Date('1990-01-01'), end_date = as.Date('1990-01-02'),
    api_key = keyring::key_get('aemet'),
    stations = 'XXXXXX'
  )
  expect_error(
    get_meteo_from('aemet', api_options),
    "provided have no data for the dates selected"
  )
  api_options$resolution <- 'monthly'
  expect_error(get_meteo_from('aemet', api_options), "is not a valid temporal resolution")
})

# meteoclimatic get data tests --------------------------------------------------------------------------

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


# meteogalicia get data tests ---------------------------------------------------------------------------
test_that("meteogalicia instant works", {
  # all stations
  api_options <- meteogalicia_options('instant')
  test_object <- suppressMessages(get_meteo_from('meteogalicia', api_options))
  expected_names <- c(
    "timestamp", "station_id", "station_name",
    "temperature",
    "wind_direction", "wind_speed",
    "relative_humidity", "precipitation", "insolation", "global_solar_radiation",
    "station_province", "altitude", "geometry"
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
    "timestamp", "station_id", "station_name",
    "temperature", "min_temperature", "max_temperature",
    "wind_direction", "wind_speed",
    "relative_humidity", "precipitation", "insolation",
    "station_province", "altitude", "geometry"
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
    "timestamp", "station_id", "station_name", "station_province",
    "temperature", "min_temperature", "max_temperature",
    "wind_direction", "wind_speed",
    "relative_humidity", "min_relative_humidity", "max_relative_humidity",
    "precipitation", "insolation",
    "altitude", "geometry"
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
    "timestamp", "station_id", "station_name", "station_province",
    "temperature", "min_temperature", "max_temperature",
    "wind_speed",
    "relative_humidity",
    "precipitation", "insolation",
    "altitude", "geometry"
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
