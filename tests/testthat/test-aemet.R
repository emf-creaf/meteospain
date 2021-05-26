# skip if no key ----------------------------------------------------------------------------------------

skip_if_no_auth('aemet')

# aemet service options tests ---------------------------------------------------------------------------

test_that("aemet service options works", {
  expected_names <- c("resolution", "start_date", "end_date", "stations", "api_key")
  expect_type(aemet_options(api_key = 'tururu'), 'list')
  expect_named(aemet_options(api_key = 'tururu'), expected_names)
  expect_identical(
    aemet_options(api_key = 'tururu'),
    aemet_options(
      resolution = 'current_day', start_date = Sys.Date(), end_date = Sys.Date(), api_key = 'tururu'
    )
  )

  # errors
  expect_error(aemet_options(resolution = 'not_valid_resolution', api_key = 'tururu'), "must be one of")
  expect_error(aemet_options(), "is missing, with no default")
  expect_error(aemet_options(stations = c(25, 26, 27), api_key = 'tururu'), "must be a character vector")

})

# aemet get meteo tests ----------------------------------------------------------------------------------

test_that("aemet current works", {
  # all stations
  api_options <- aemet_options('current_day', api_key = keyring::key_get('aemet'))
  test_object <- suppressMessages(get_meteo_from('aemet', api_options))
  expected_names <- c(
    "timestamp", "station_id", "station_name", "altitude",
    "temperature", "min_temperature", "max_temperature",
    "relative_humidity", "precipitation", "wind_speed", "wind_direction", "geometry"
  )
  expect_s3_class(test_object, 'sf')
  expect_true(nrow(test_object) > 1)
  expect_named(test_object, expected_names)
  expect_s3_class(test_object$altitude, 'units')
  expect_identical(units(test_object$altitude)$numerator, "m")
  expect_s3_class(test_object$temperature, 'units')
  expect_identical(units(test_object$temperature)$numerator, "°C")
  # some stations
  stations_to_check <- test_object[['station_id']][1:3]
  api_options$stations <- stations_to_check
  test_object <- suppressMessages(get_meteo_from('aemet', api_options))
  expect_s3_class(test_object, 'sf')
  expect_true(nrow(test_object) > 1)
  expect_equal(unique(test_object$station_id), stations_to_check)
  expect_named(test_object, expected_names)
  expect_s3_class(test_object$altitude, 'units')
  expect_identical(units(test_object$altitude)$numerator, "m")
  expect_s3_class(test_object$temperature, 'units')
  expect_identical(units(test_object$temperature)$numerator, "°C")
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
    "timestamp", "station_id", "station_name", "station_province", "altitude",
    "mean_temperature", "min_temperature", "max_temperature",
    "precipitation", "mean_wind_speed", "insolation", "geometry"
  )
  expect_s3_class(test_object, 'sf')
  expect_true(nrow(test_object) > 1)
  expect_named(test_object, expected_names)
  expect_s3_class(test_object$altitude, 'units')
  expect_identical(units(test_object$altitude)$numerator, "m")
  expect_s3_class(test_object$mean_temperature, 'units')
  expect_identical(units(test_object$mean_temperature)$numerator, "°C")
  # some stations
  stations_to_check <- test_object[['station_id']][1:3]
  api_options$stations <- stations_to_check
  test_object <- suppressMessages(get_meteo_from('aemet', api_options))
  expect_s3_class(test_object, 'sf')
  expect_true(nrow(test_object) > 1)
  expect_equal(unique(test_object$station_id), stations_to_check)
  expect_named(test_object, expected_names)
  expect_s3_class(test_object$altitude, 'units')
  expect_identical(units(test_object$altitude)$numerator, "m")
  expect_s3_class(test_object$mean_temperature, 'units')
  expect_identical(units(test_object$mean_temperature)$numerator, "°C")
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
  expect_s3_class(test_object$altitude, 'units')
  expect_identical(units(test_object$altitude)$numerator, "m")
  expect_s3_class(test_object$mean_temperature, 'units')
  expect_identical(units(test_object$mean_temperature)$numerator, "°C")
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
  expect_s3_class(test_object$altitude, 'units')
  expect_identical(units(test_object$altitude)$numerator, "m")
  expect_s3_class(test_object$mean_temperature, 'units')
  expect_identical(units(test_object$mean_temperature)$numerator, "°C")
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

# aemet get info tests ----------------------------------------------------------------------------------

test_that("aemet get info works", {
  api_options <- aemet_options(api_key = keyring::key_get('aemet'))
  test_object <- suppressMessages(get_stations_info_from('aemet', api_options))
  expected_names <- c("station_id", "station_name", "altitude", "geometry")

  expect_s3_class(test_object, 'sf')
  expect_true(nrow(test_object) > 1)
  expect_named(test_object, expected_names)
  expect_s3_class(test_object$altitude, 'units')
  expect_identical(units(test_object$altitude)$numerator, "m")
})
