# skip if no key ----------------------------------------------------------------------------------------

skip_if_no_auth('meteocat')
skip_if_no_internet()

# meteocat service options tests ---------------------------------------------------------------------------
withr::local_options(list("keyring_backend" = "env"))
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
  expect_error(meteocat_options(start_date = as.Date('1988-04-25'), api_key = 'tururu'), "'1989-01-01'")

})

# meteocat get info tests ----------------------------------------------------------------------------------

test_that("meteocat get info works", {
  api_options <- meteocat_options(api_key = keyring::key_get('meteocat'))
  test_object <- suppressMessages(get_stations_info_from('meteocat', api_options))
  expected_names <- c("service", "station_id", "station_name", "station_province", "altitude", "geometry")
  main_test_battery(test_object, service = 'meteocat', expected_names = expected_names)
})

# meteocat get meteo tests ---------------------------------------------------------------------------
test_that("meteocat instant works", {
  # all stations
  api_options <- meteocat_options('instant', api_key = keyring::key_get('meteocat'))
  test_object <- get_meteo_from('meteocat', api_options)
  # expect_message((test_object <- get_meteo_from('meteocat', api_options)), 'meteo.cat')
  expected_names <- c(
    "timestamp", "service", "station_id", "station_name", "station_province", "altitude",
    "temperature", "min_temperature", "max_temperature",
    "relative_humidity", "min_relative_humidity", "max_relative_humidity",
    "precipitation", "max_precipitation_minute",
    "wind_direction", "wind_speed", "max_wind_direction", "max_wind_speed",
    "global_solar_radiation", "net_solar_radiation",
    "snow_cover",
    "atmospheric_pressure", "min_atmospheric_pressure", "max_atmospheric_pressure",
    "geometry"
  )
  main_test_battery(
    test_object, service = 'meteocat', expected_names = expected_names, temperature = temperature
  )
  # some stations
  stations_to_check <- unique(test_object[['station_id']])[1:3]
  api_options$stations <- unique(stations_to_check)
  test_object <- suppressMessages(get_meteo_from('meteocat', api_options))
  main_test_battery(
    test_object, service = 'meteocat', expected_names = expected_names, temperature = temperature,
    stations_to_check = stations_to_check
  )
  # extra check for radiation units as they are different in short than in large
  expect_true(
    units(test_object$global_solar_radiation)$numerator %in% c("W")
  )
})

test_that("meteocat hourly works", {
  # all stations
  api_options <- meteocat_options(
    'hourly', start_date = as.Date('2021-04-25'), api_key = keyring::key_get('meteocat')
  )
  test_object <- get_meteo_from('meteocat', api_options)
  # expect_message((test_object <- get_meteo_from('meteocat', api_options)), 'meteo.cat')
  expected_names <- c(
    "timestamp", "service", "station_id", "station_name", "station_province", "altitude",
    "temperature", "min_temperature", "max_temperature",
    "relative_humidity", "min_relative_humidity", "max_relative_humidity",
    "precipitation", "max_precipitation_minute",
    "wind_direction", "wind_speed", "max_wind_direction", "max_wind_speed",
    "global_solar_radiation", "net_solar_radiation",
    "snow_cover",
    "atmospheric_pressure", "min_atmospheric_pressure", "max_atmospheric_pressure",
    "geometry"
  )
  main_test_battery(
    test_object, service = 'meteocat', expected_names = expected_names, temperature = temperature
  )
  # some stations
  stations_to_check <- unique(test_object[['station_id']])[1:3]
  api_options$stations <- unique(stations_to_check)
  test_object <- get_meteo_from('meteocat', api_options)
  # expect_message((test_object <- get_meteo_from('meteocat', api_options)), 'meteo.cat')
  main_test_battery(
    test_object, service = 'meteocat', expected_names = expected_names, temperature = temperature,
    stations_to_check = stations_to_check
  )
  # extra check for radiation units as they are different in short than in large
  expect_true(
    units(test_object$global_solar_radiation)$numerator %in% c("W")
  )

  # 2008 to 2010 stations lack some variables, check it works without those variables
  api_options <- meteocat_options(
    'hourly', start_date = as.Date('2008-04-25'), api_key = keyring::key_get('meteocat')
  )
  test_object <- get_meteo_from('meteocat', api_options)
  # expect_message((test_object <- get_meteo_from('meteocat', api_options)), 'meteo.cat')
  expected_names <- c(
    "timestamp", "service", "station_id", "station_name", "station_province", "altitude",
    "temperature", "min_temperature", "max_temperature",
    "relative_humidity", "min_relative_humidity", "max_relative_humidity",
    "precipitation", "max_precipitation_minute",
    "wind_direction", "wind_speed", "max_wind_direction", "max_wind_speed",
    "global_solar_radiation", "net_solar_radiation",
    "snow_cover",
    "atmospheric_pressure", "min_atmospheric_pressure", "max_atmospheric_pressure",
    "geometry"
  )
  main_test_battery(
    test_object, service = 'meteocat', expected_names = expected_names, temperature = temperature
  )
})

test_that("meteocat daily works", {
  # all stations
  api_options <- meteocat_options(
    'daily', start_date = as.Date('2021-04-25'), api_key = keyring::key_get('meteocat')
  )
  test_object <- get_meteo_from('meteocat', api_options)
  # expect_message((test_object <- get_meteo_from('meteocat', api_options)), 'meteo.cat')
  expected_names <- c(
    "timestamp", "service", "station_id", "station_name", "station_province", "altitude",
    "mean_temperature", "max_temperature", "min_temperature",
    "mean_temperature_classic", "thermal_amplitude", "mean_relative_humidity",
    "max_relative_humidity", "min_relative_humidity", "mean_atmospheric_pressure",
    "max_atmospheric_pressure", "min_atmospheric_pressure", "precipitation",
    "precipitation_8h_8h", "max_precipitation_minute", "max_precipitation_hour",
    "max_precipitation_30m", "max_precipitation_10m", "global_solar_radiation",
    "mean_wind_speed", "mean_wind_direction", "max_wind_speed",
    "max_wind_direction", "mean_snow_cover", "max_snow_cover", "new_snow_cover",
    "min_snow_cover", "reference_evapotranspiration",
    "geometry"
  )
  main_test_battery(
    test_object, service = 'meteocat', expected_names = expected_names, temperature = mean_temperature
  )
  # extra check for radiation units as they are different in short than in large
  expect_true(
    units(test_object$global_solar_radiation)$numerator %in% c("MJ")
  )
  # some stations
  stations_to_check <- unique(test_object[['station_id']])[1:3]
  api_options$stations <- unique(stations_to_check)
  test_object <- get_meteo_from('meteocat', api_options)
  # expect_message((test_object <- get_meteo_from('meteocat', api_options)), 'meteo.cat')
  main_test_battery(
    test_object, service = 'meteocat', expected_names = expected_names, temperature = mean_temperature,
    stations_to_check = stations_to_check
  )

  # 2008 to 2010 stations lack some variables, check it works without those variables
  api_options <- meteocat_options(
    'daily', start_date = as.Date('2008-04-25'), api_key = keyring::key_get('meteocat')
  )
  test_object <- get_meteo_from('meteocat', api_options)
  # expect_message((test_object <- get_meteo_from('meteocat', api_options)), 'meteo.cat')
  main_test_battery(
    test_object, service = 'meteocat', expected_names = expected_names, temperature = mean_temperature
  )
})

test_that("meteocat monthly works", {
  # all stations
  api_options <- meteocat_options(
    'monthly', start_date = as.Date('2020-04-25'), api_key = keyring::key_get('meteocat')
  )
  test_object <- get_meteo_from('meteocat', api_options)
  # expect_message((test_object <- get_meteo_from('meteocat', api_options)), 'meteo.cat')
  expected_names <- c(
    "timestamp", "service", "station_id", "station_name", "station_province", "altitude",
    "mean_temperature", "max_temperature_absolute", "min_temperature_absolute",
    "max_temperature_mean", "min_temperature_mean", "mean_temperature_classic",
    "frost_days", "max_thermal_amplitude", "mean_thermal_amplitude",
    "extreme_thermal_amplitude", "mean_relative_humidity",
    "max_relative_humidity_absolute", "min_relative_humidity_absolute",
    "max_relative_humidity_mean", "min_relative_humidity_mean",
    "mean_atmospheric_pressure", "max_atmospheric_pressure_absolute",
    "min_atmospheric_pressure_absolute", "max_atmospheric_pressure_mean",
    "min_atmospheric_pressure_mean", "precipitation", "precipitation_8h_8h",
    "max_precipitation_minute", "max_precipitation_24h",
    "max_precipitation_24h_8h_8h", "rain_days_0", "rain_days_02",
    "max_precipitation_hour", "max_precipitation_30m", "max_precipitation_10m",
    "global_solar_radiation", "mean_wind_speed", "mean_wind_direction",
    "max_wind_speed", "max_wind_direction", "max_wind_speed_mean", "mean_snow_cover",
    "max_snow_cover", "new_snow_cover",
    "geometry"
  )
  main_test_battery(
    test_object, service = 'meteocat', expected_names = expected_names, temperature = mean_temperature
  )
  # extra check for radiation units as they are different in short than in large
  expect_true(
    units(test_object$global_solar_radiation)$numerator %in% c("MJ")
  )
  # some stations
  stations_to_check <- unique(test_object[['station_id']])[1:3]
  api_options$stations <- unique(stations_to_check)
  test_object <- get_meteo_from('meteocat', api_options)
  # expect_message((test_object <- get_meteo_from('meteocat', api_options)), 'meteo.cat')
  main_test_battery(
    test_object, service = 'meteocat', expected_names = expected_names, temperature = mean_temperature,
    stations_to_check = stations_to_check
  )
})

test_that("meteocat yearly works", {
  # all stations
  api_options <- meteocat_options(
    'yearly', start_date = as.Date('2020-04-25'), api_key = keyring::key_get('meteocat')
  )
  test_object <- get_meteo_from('meteocat', api_options)
  # expect_message((test_object <- get_meteo_from('meteocat', api_options)), 'meteo.cat')
  expected_names <- c(
    "timestamp", "service", "station_id", "station_name", "station_province", "altitude",
    "mean_temperature", "max_temperature_absolute", "min_temperature_absolute",
    "max_temperature_mean", "min_temperature_mean", "mean_temperature_classic",
    "frost_days", "max_thermal_amplitude", "mean_thermal_amplitude",
    "extreme_thermal_amplitude", "thermal_oscillation", "mean_relative_humidity",
    "max_relative_humidity_absolute", "min_relative_humidity_absolute",
    "max_relative_humidity_mean", "min_relative_humidity_mean",
    "mean_atmospheric_pressure", "max_atmospheric_pressure_absolute",
    "min_atmospheric_pressure_absolute", "max_atmospheric_pressure_mean",
    "min_atmospheric_pressure_mean", "precipitation", "precipitation_8h_8h",
    "max_precipitation_minute", "max_precipitation_24h",
    "max_precipitation_24h_8h_8h", "rain_days_0", "rain_days_02",
    "max_precipitation_hour", "max_precipitation_30m", "max_precipitation_10m",
    "global_solar_radiation", "mean_wind_speed", "mean_wind_direction",
    "max_wind_speed", "max_wind_direction", "max_wind_speed_mean",
    "mean_snow_cover", "max_snow_cover", "new_snow_cover",
    "geometry"
  )
  main_test_battery(
    test_object, service = 'meteocat', expected_names = expected_names, temperature = mean_temperature
  )
  # extra check for radiation units as they are different in short than in large
  expect_true(
    units(test_object$global_solar_radiation)$numerator %in% c("MJ")
  )
  # some stations
  stations_to_check <- unique(test_object[['station_id']])[1:3]
  api_options$stations <- unique(stations_to_check)
  test_object <- get_meteo_from('meteocat', api_options)
  # expect_message((test_object <- get_meteo_from('meteocat', api_options)), 'meteo.cat')
  main_test_battery(
    test_object, service = 'meteocat', expected_names = expected_names, temperature = mean_temperature,
    stations_to_check = stations_to_check
  )
})

test_that("meteocat API errors, messages, warnings are correctly raised", {
  # invalid key
  clear_meteospain_cache()
  api_options <- meteocat_options(api_key = 'tururu')
  expect_error(get_meteo_from('meteocat', api_options), "API key")
  # dates out of bounds:
  # This is checked on the service options level

  # no data for stations selected
  api_options <- meteocat_options(
    'daily',
    start_date = as.Date('2020-01-01'),
    stations = 'XXXXXX',
    api_key = keyring::key_get('meteocat')
  )
  expect_error(get_meteo_from('meteocat', api_options), "provided have no data for the dates selected")
  api_options$resolution <- 'tururu'
  expect_error(get_meteo_from('meteocat', api_options), "is not a valid temporal resolution")
})


# meteocat get quota tests ------------------------------------------------------------------------------

test_that("meteocat get_quota works as expected", {
  api_options <- meteocat_options(api_key = keyring::key_get('meteocat'))
  expect_s3_class((test_object <- get_quota_from('meteocat', api_options)), 'tbl')
  expect_named(test_object, c("client", 'nom', 'periode', 'maxConsultes', 'consultesRestants', 'consultesRealitzades'))
})
