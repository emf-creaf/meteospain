# skip if no key ----------------------------------------------------------------------------------------

skip_if_no_auth('aemet')
skip_if_no_internet()

# aemet service options tests ---------------------------------------------------------------------------
withr::local_options(list("keyring_backend" = "env"))
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

# aemet get info tests ----------------------------------------------------------------------------------

test_that("aemet get info works", {
  api_options <- aemet_options(api_key = keyring::key_get('aemet'))
  test_object <- suppressMessages(get_stations_info_from('aemet', api_options))
  expected_names <- c("service", "station_id", "station_name", "station_province", "altitude", "geometry")
  main_test_battery(test_object, service = 'aemet', expected_names = expected_names)

  # test the aemet coords transformation
  expect_equal(
    .aemet_coords_generator(c("393339N", "024412E", "393339S", "024412W")),
    c(39.5608333, 2.7366667, -39.5608333, -2.7366667)
  )
})

# aemet get meteo tests ----------------------------------------------------------------------------------

test_that("aemet current works", {
  # all stations
  api_options <- aemet_options('current_day', api_key = keyring::key_get('aemet'))
  test_object <- get_meteo_from('aemet', api_options)
  # expect_message((test_object <- get_meteo_from('aemet', api_options)), 'Autorizado el uso')
  expected_names <- c(
    "timestamp", "service", "station_id", "station_name", "station_province", "altitude",
    "temperature", "min_temperature", "max_temperature",
    "relative_humidity", "precipitation",
    "wind_direction", "wind_speed", "insolation", "geometry"
  )
  main_test_battery(test_object, service = 'aemet', expected_names = expected_names, temperature = temperature)
  # some stations
  stations_to_check <- unique(test_object[['station_id']])[1:3]
  api_options$stations <- unique(stations_to_check)
  test_object <- get_meteo_from('aemet', api_options)
  # expect_message((test_object <- get_meteo_from('aemet', api_options)), 'Autorizado el uso')
  main_test_battery(
    test_object, service = 'aemet',
    expected_names = expected_names, stations_to_check = stations_to_check, temperature = temperature
  )
})

test_that("aemet daily works", {
  # all stations "modern" time
  api_options <- aemet_options(
    'daily',
    start_date = as.Date('2020-04-16'), end_date = as.Date('2020-05-01'),
    api_key = keyring::key_get('aemet')
  )
  test_object <- get_meteo_from('aemet', api_options)
  # expect_message((test_object <- get_meteo_from('aemet', api_options)), 'Autorizado el uso')
  expected_names <- c(
    "timestamp", "service", "station_id", "station_name", "station_province", "altitude",
    "mean_temperature", "min_temperature", "max_temperature",
    "mean_relative_humidity", "min_relative_humidity", "max_relative_humidity",
    "precipitation", "mean_wind_speed", "insolation", "geometry"
  )
  main_test_battery(test_object, service = 'aemet', expected_names = expected_names, temperature = mean_temperature)
  # some stations
  stations_to_check <- unique(test_object[['station_id']])[1:3]
  api_options$stations <- unique(stations_to_check)
  test_object <- get_meteo_from('aemet', api_options)
  # expect_message((test_object <- get_meteo_from('aemet', api_options)), 'Autorizado el uso')
  main_test_battery(
    test_object, service = 'aemet',
    expected_names = expected_names, stations_to_check = stations_to_check, temperature = mean_temperature
  )
  # all stations 2000's
  api_options <- aemet_options(
    'daily',
    start_date = as.Date('2005-04-16'), end_date = as.Date('2005-05-01'),
    api_key = keyring::key_get('aemet')
  )
  test_object <- get_meteo_from('aemet', api_options)
  # expect_message((test_object <- get_meteo_from('aemet', api_options)), 'Autorizado el uso')
  main_test_battery(test_object, service = 'aemet', expected_names = expected_names, temperature = mean_temperature)
  # all stations 1990's
  api_options <- aemet_options(
    'daily',
    start_date = as.Date('1990-04-16'), end_date = as.Date('1990-05-01'),
    api_key = keyring::key_get('aemet')
  )
  expect_message((test_object <- get_meteo_from('aemet', api_options)), 'Autorizado el uso')
  main_test_battery(test_object, service = 'aemet', expected_names = expected_names, temperature = mean_temperature)
})

test_that("aemet monthly works", {
  # all stations "modern" time
  api_options <- aemet_options(
    'monthly',
    start_date = as.Date('2020-01-01'), end_date = as.Date('2020-12-31'),
    stations = "0149X",
    api_key = keyring::key_get('aemet')
  )
  test_object <- get_meteo_from('aemet', api_options)
  # expect_message((test_object <- get_meteo_from('aemet', api_options)), 'Autorizado el uso')
  expected_names <- c(
    "timestamp", "service", "station_id", "station_name", "station_province", "altitude",
    "mean_temperature", "mean_min_temperature", "mean_max_temperature",
    "mean_relative_humidity", "total_precipitation", "days_precipitation",
    "mean_wind_speed", "mean_insolation", "mean_global_radiation", "geometry"
  )
  main_test_battery(test_object, service = 'aemet', expected_names = expected_names, temperature = mean_temperature)
  # more than one station -> warning
  stations_to_check <- c("0149X", "0252D")
  api_options$stations <- unique(stations_to_check)
  expect_warning(test_object <- get_meteo_from('aemet', api_options), "Only the first station")
  # test_object <- get_meteo_from('aemet', api_options)
  # expect_message((test_object <- get_meteo_from('aemet', api_options)), 'Autorizado el uso')
  main_test_battery(
    test_object, service = 'aemet',
    expected_names = expected_names, stations_to_check = stations_to_check[1], temperature = mean_temperature
  )
  # stations 2000's
  api_options <- aemet_options(
    'monthly',
    start_date = as.Date('2005-04-01'), end_date = as.Date('2005-05-01'),
    stations = "0149X",
    api_key = keyring::key_get('aemet')
  )
  test_object <- get_meteo_from('aemet', api_options)
  # expect_message((test_object <- get_meteo_from('aemet', api_options)), 'Autorizado el uso')
  main_test_battery(test_object, service = 'aemet', expected_names = expected_names, temperature = mean_temperature)
  # all stations 1990's
  # api_options <- aemet_options(
  #   'monthly',
  #   start_date = as.Date('1990-04-01'), end_date = as.Date('1990-05-01'),
  #   stations = "0149X",
  #   api_key = keyring::key_get('aemet')
  # )
  # expect_message((test_object <- get_meteo_from('aemet', api_options)), 'Autorizado el uso')
  # main_test_battery(test_object, service = 'aemet', expected_names = expected_names, temperature = mean_temperature)
})

test_that("aemet yearly works", {
  # all stations "modern" time
  api_options <- aemet_options(
    'yearly',
    start_date = as.Date('2020-01-01'), end_date = as.Date('2020-12-31'),
    stations = "0149X",
    api_key = keyring::key_get('aemet')
  )
  test_object <- get_meteo_from('aemet', api_options)
  # expect_message((test_object <- get_meteo_from('aemet', api_options)), 'Autorizado el uso')
  expected_names <- c(
    "timestamp", "service", "station_id", "station_name", "station_province", "altitude",
    "mean_temperature", "mean_min_temperature", "mean_max_temperature",
    "mean_relative_humidity", "total_precipitation", "days_precipitation",
    "mean_wind_speed", "mean_insolation", "mean_global_radiation", "geometry"
  )
  main_test_battery(test_object, service = 'aemet', expected_names = expected_names, temperature = mean_temperature)
  # more than one station -> warning
  stations_to_check <- c("0149X", "0252D")
  api_options$stations <- unique(stations_to_check)
  expect_warning(test_object <- get_meteo_from('aemet', api_options), "Only the first station")
  # test_object <- get_meteo_from('aemet', api_options)
  # expect_message((test_object <- get_meteo_from('aemet', api_options)), 'Autorizado el uso')
  main_test_battery(
    test_object, service = 'aemet',
    expected_names = expected_names, stations_to_check = stations_to_check[1], temperature = mean_temperature
  )
  # stations 2000's
  api_options <- aemet_options(
    'yearly',
    start_date = as.Date('2005-04-01'), end_date = as.Date('2005-05-01'),
    stations = "0149X",
    api_key = keyring::key_get('aemet')
  )
  test_object <- get_meteo_from('aemet', api_options)
  # expect_message((test_object <- get_meteo_from('aemet', api_options)), 'Autorizado el uso')
  main_test_battery(test_object, service = 'aemet', expected_names = expected_names, temperature = mean_temperature)
  # all stations 1990's
  # api_options <- aemet_options(
  #   'yearly',
  #   start_date = as.Date('1990-04-01'), end_date = as.Date('1990-05-01'),
  #   stations = "0149X",
  #   api_key = keyring::key_get('aemet')
  # )
  # expect_message((test_object <- get_meteo_from('aemet', api_options)), 'Autorizado el uso')
  # main_test_battery(test_object, service = 'aemet', expected_names = expected_names, temperature = mean_temperature)
})

test_that("aemet API errors, messages, warnings are correctly raised", {
  # copyright message
  api_options <- aemet_options('current_day', api_key = keyring::key_get('aemet'))
  # invalid key
  api_options <- aemet_options('current_day', api_key = 'tururu')
  expect_error(get_meteo_from('aemet', api_options), "Invalid API Key")
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

  # monthly errors
  api_options <- aemet_options(
    'monthly',
    start_date = as.Date('2020-01-01'), end_date = as.Date('2020-01-02'),
    api_key = keyring::key_get('aemet'),
    stations = 'XXXXXX'
  )
  expect_error(get_meteo_from('aemet', api_options), "404")
  api_options$stations <- NULL
  expect_error(get_meteo_from('aemet', api_options), "needs one station provided")
  api_options$resolution <- "yearly"
  expect_error(get_meteo_from('aemet', api_options), "needs one station provided")
  api_options$stations <- 'XXXXXX'
  expect_error(get_meteo_from('aemet', api_options), "404")

  api_options <- aemet_options(
    'monthly',
    start_date = as.Date('2015-01-01'), end_date = as.Date('2020-01-02'),
    api_key = keyring::key_get('aemet'),
    stations = '0149X'
  )
  expect_error(get_meteo_from('aemet', api_options), "36 meses")
})
