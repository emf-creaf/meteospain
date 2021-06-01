# skip if no key ----------------------------------------------------------------------------------------

skip_if_no_auth('meteocat')

# meteocat service options tests ---------------------------------------------------------------------------

test_that("meteocat service options works", {
  expected_names <- c("resolution", "start_date", "stations", "api_key")
  expect_type(meteocat_options(api_key = 'tururu'), 'list')
  expect_named(meteocat_options(api_key = 'tururu'), expected_names)
  expect_identical(
    meteocat_options(api_key = 'tururu'),
    meteocat_options(
      resolution = 'instant', start_date = Sys.Date(), api_key = 'tururu'
    )
  )

  # errors
  expect_error(meteocat_options(resolution = 'not_valid_resolution', api_key = 'tururu'), "must be one of")
  expect_error(meteocat_options(), "is missing, with no default")
  expect_error(meteocat_options(stations = 25, api_key = 'tururu'), "must be a character vector")

})

# meteocat get info tests ----------------------------------------------------------------------------------

test_that("meteocat get info works", {
  api_options <- meteocat_options(api_key = keyring::key_get('meteocat'))
  test_object <- suppressMessages(get_stations_info_from('meteocat', api_options))
  expected_names <- c("station_id", "station_name", "station_province", "altitude", "geometry")

  expect_s3_class(test_object, 'sf')
  expect_true(nrow(test_object) > 1)
  expect_named(test_object, expected_names)
  expect_s3_class(test_object$altitude, 'units')
  expect_identical(units(test_object$altitude)$numerator, "m")
})

# meteocat get meteo tests ---------------------------------------------------------------------------
test_that("meteocat instant works", {
  # all stations
  api_options <- meteocat_options('instant', api_key = keyring::key_get('meteocat'))
  test_object <- suppressMessages(get_meteo_from('meteocat', api_options))
  expected_names <- c(
    "timestamp", "station_id", "station_name", "station_province", "altitude",
    "temperature",
    "relative_humidity", "precipitation",
    "wind_speed", "wind_direction",
    "global_solar_radiation",
    "geometry"
  )
  expect_s3_class(test_object, 'sf')
  expect_true(nrow(test_object) > 1)
  expect_named(test_object, expected_names)
  expect_s3_class(test_object$altitude, 'units')
  expect_identical(units(test_object$altitude)$numerator, "m")
  expect_s3_class(test_object$temperature, 'units')
  expect_identical(units(test_object$temperature)$numerator, "°C")
  expect_false(all(is.na(test_object$timestamp)))
  # some stations
  stations_to_check <- test_object[['station_id']][1:3]
  api_options$stations <- stations_to_check
  test_object <- suppressMessages(get_meteo_from('meteocat', api_options))
  expect_s3_class(test_object, 'sf')
  expect_true(nrow(test_object) > 1)
  expect_equal(nrow(test_object), length(stations_to_check)) # one row with the latest measure by station
  expect_equal(unique(test_object$station_id), stations_to_check)
  expect_named(test_object, expected_names)
  expect_s3_class(test_object$altitude, 'units')
  expect_identical(units(test_object$altitude)$numerator, "m")
  expect_s3_class(test_object$temperature, 'units')
  expect_identical(units(test_object$temperature)$numerator, "°C")
})

test_that("meteocat hourly works", {
  # all stations
  api_options <- meteocat_options(
    'hourly', start_date = as.Date('2021-04-25'), api_key = keyring::key_get('meteocat')
  )
  test_object <- suppressMessages(get_meteo_from('meteocat', api_options))
  expected_names <- c(
    "timestamp", "station_id", "station_name", "station_province", "altitude",
    "temperature",
    "relative_humidity", "precipitation",
    "wind_speed", "wind_direction",
    "global_solar_radiation",
    "geometry"
  )
  expect_s3_class(test_object, 'sf')
  expect_true(nrow(test_object) > 1)
  expect_named(test_object, expected_names)
  expect_s3_class(test_object$altitude, 'units')
  expect_identical(units(test_object$altitude)$numerator, "m")
  expect_s3_class(test_object$temperature, 'units')
  expect_identical(units(test_object$temperature)$numerator, "°C")
  expect_false(all(is.na(test_object$timestamp)))
  # some stations
  stations_to_check <- test_object[['station_id']][1:3]
  api_options$stations <- stations_to_check
  test_object <- suppressMessages(get_meteo_from('meteocat', api_options))
  expect_s3_class(test_object, 'sf')
  expect_true(nrow(test_object) > 1)
  expect_equal(nrow(test_object), length(stations_to_check)*48) # stations*48 measures (as measures are every 30 min)
  expect_equal(unique(test_object$station_id), stations_to_check)
  expect_named(test_object, expected_names)
  expect_s3_class(test_object$altitude, 'units')
  expect_identical(units(test_object$altitude)$numerator, "m")
  expect_s3_class(test_object$temperature, 'units')
  expect_identical(units(test_object$temperature)$numerator, "°C")
})

test_that("meteocat daily works", {
  # all stations
  api_options <- meteocat_options(
    'daily', start_date = as.Date('2021-04-25'), api_key = keyring::key_get('meteocat')
  )
  test_object <- suppressMessages(get_meteo_from('meteocat', api_options))
  expected_names <- c(
    "timestamp", "station_id", "station_name", "station_province", "altitude",
    "mean_temperature", 'max_temperature', 'min_temperature',
    "mean_relative_humidity", "max_relative_humidity", "min_relative_humidity",
    "precipitation",
    "mean_wind_speed", "mean_wind_direction",
    "global_solar_radiation",
    "geometry"
  )
  expect_s3_class(test_object, 'sf')
  expect_true(nrow(test_object) > 1)
  expect_named(test_object, expected_names)
  expect_s3_class(test_object$altitude, 'units')
  expect_identical(units(test_object$altitude)$numerator, "m")
  expect_s3_class(test_object$mean_temperature, 'units')
  expect_identical(units(test_object$mean_temperature)$numerator, "°C")
  expect_false(all(is.na(test_object$timestamp)))
  # some stations
  stations_to_check <- test_object[['station_id']][1:3]
  api_options$stations <- stations_to_check
  test_object <- suppressMessages(get_meteo_from('meteocat', api_options))
  expect_s3_class(test_object, 'sf')
  expect_true(nrow(test_object) > 1)
  expect_equal(nrow(test_object), length(stations_to_check)*30) # stations * 30 (one measure per day in April)
  expect_equal(unique(test_object$station_id), stations_to_check)
  expect_named(test_object, expected_names)
  expect_s3_class(test_object$altitude, 'units')
  expect_identical(units(test_object$altitude)$numerator, "m")
  expect_s3_class(test_object$mean_temperature, 'units')
  expect_identical(units(test_object$mean_temperature)$numerator, "°C")
})

test_that("meteocat monthly works", {
  # all stations
  api_options <- meteocat_options(
    'monthly', start_date = as.Date('2020-04-25'), api_key = keyring::key_get('meteocat')
  )
  test_object <- suppressMessages(get_meteo_from('meteocat', api_options))
  expected_names <- c(
    "timestamp", "station_id", "station_name", "station_province", "altitude",
    "mean_temperature", 'max_temperature_absolute', 'min_temperature_absolute',
    'max_temperature_mean', 'min_temperature_mean',
    "mean_relative_humidity", "max_relative_humidity_absolute", "min_relative_humidity_absolute",
    "max_relative_humidity_mean", "min_relative_humidity_mean",
    "precipitation",
    "mean_wind_speed", "mean_wind_direction",
    "global_solar_radiation",
    "geometry"
  )
  expect_s3_class(test_object, 'sf')
  expect_true(nrow(test_object) > 1)
  expect_named(test_object, expected_names)
  expect_s3_class(test_object$altitude, 'units')
  expect_identical(units(test_object$altitude)$numerator, "m")
  expect_s3_class(test_object$mean_temperature, 'units')
  expect_identical(units(test_object$mean_temperature)$numerator, "°C")
  expect_false(all(is.na(test_object$timestamp)))
  # some stations
  stations_to_check <- unique(test_object[['station_id']])[1:3]
  api_options$stations <- stations_to_check
  test_object <- suppressMessages(get_meteo_from('meteocat', api_options))
  expect_s3_class(test_object, 'sf')
  expect_true(nrow(test_object) > 1)
  expect_equal(nrow(test_object), length(stations_to_check)*12) # stations * 12 (one measure per month in 2020)
  expect_equal(unique(test_object$station_id), stations_to_check)
  expect_named(test_object, expected_names)
  expect_s3_class(test_object$altitude, 'units')
  expect_identical(units(test_object$altitude)$numerator, "m")
  expect_s3_class(test_object$mean_temperature, 'units')
  expect_identical(units(test_object$mean_temperature)$numerator, "°C")
})

test_that("meteocat yearly works", {
  # all stations
  api_options <- meteocat_options(
    'yearly', start_date = as.Date('2020-04-25'), api_key = keyring::key_get('meteocat')
  )
  test_object <- suppressMessages(get_meteo_from('meteocat', api_options))
  expected_names <- c(
    "timestamp", "station_id", "station_name", "station_province", "altitude",
    "mean_temperature", 'max_temperature_absolute', 'min_temperature_absolute',
    'max_temperature_mean', 'min_temperature_mean',
    "mean_relative_humidity", "max_relative_humidity_absolute", "min_relative_humidity_absolute",
    "max_relative_humidity_mean", "min_relative_humidity_mean",
    "precipitation",
    "mean_wind_speed", "mean_wind_direction",
    "global_solar_radiation",
    "geometry"
  )
  expect_s3_class(test_object, 'sf')
  expect_true(nrow(test_object) > 1)
  expect_named(test_object, expected_names)
  expect_s3_class(test_object$altitude, 'units')
  expect_identical(units(test_object$altitude)$numerator, "m")
  expect_s3_class(test_object$mean_temperature, 'units')
  expect_identical(units(test_object$mean_temperature)$numerator, "°C")
  expect_false(all(is.na(test_object$timestamp)))
  # some stations
  stations_to_check <- unique(test_object[['station_id']])[1:3]
  api_options$stations <- stations_to_check
  test_object <- suppressMessages(get_meteo_from('meteocat', api_options))
  expect_s3_class(test_object, 'sf')
  expect_true(nrow(test_object) > 1)
  expect_equal(unique(test_object$station_id), stations_to_check)
  expect_named(test_object, expected_names)
  expect_s3_class(test_object$altitude, 'units')
  expect_identical(units(test_object$altitude)$numerator, "m")
  expect_s3_class(test_object$mean_temperature, 'units')
  expect_identical(units(test_object$mean_temperature)$numerator, "°C")
})

