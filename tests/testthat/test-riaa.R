# skip on cran ----------------------------------------------------------------------------------------

skip_on_cran()
skip_if_no_internet()

# ria service options tests ---------------------------------------------------------------------------

test_that("ria service options works", {
  expected_names <- c("resolution", "start_date", "end_date", "stations")
  expect_type(ria_options(), 'list')
  expect_named(ria_options(), expected_names)
  expect_identical(
    ria_options(),
    ria_options(
      resolution = 'daily', start_date = Sys.Date() - 1, end_date = Sys.Date() - 1
    )
  )

  # errors
  expect_error(ria_options(resolution = 'not_valid_resolution'), "must be one of")
  expect_error(ria_options(stations = c(25, 26, 27)), "must be a character vector")

})

# ria get info tests ----------------------------------------------------------------------------------

test_that("ria get info works", {
  api_options <- ria_options()
  test_object <- suppressMessages(get_stations_info_from('ria', api_options))
  expected_names <- c(
    "service", "station_id", "station_name", "station_province",
    "province_id", "altitude", "under_plastic", "geometry"
  )
  main_test_battery(test_object, service = 'ria', expected_names = expected_names)
})


# ria get data tests ------------------------------------------------------------------------------------

test_that("ria daily works", {
  # all stations
  api_options <- ria_options('daily', start_date = Sys.Date() - 1)
  expect_message((test_object <- get_meteo_from('ria', api_options)), 'www.juntadeandalucia.es')
  expected_names <- c(
    "timestamp", "service", "station_id", "station_name", "station_province", "altitude",
    "mean_temperature", "min_temperature", "max_temperature",
    "mean_relative_humidity", "min_relative_humidity", "max_relative_humidity",
    "precipitation",
    "mean_wind_direction", "mean_wind_speed",
    "solar_radiation",
    "under_plastic",
    "geometry"
  )
  main_test_battery(
    test_object, service = 'ria', expected_names = expected_names, temperature = mean_temperature
  )

  # some stations
  stations_to_check <- test_object[['station_id']][1:3]
  api_options$stations <- stations_to_check
  expect_message((test_object <- get_meteo_from('ria', api_options)), 'www.juntadeandalucia.es')
  main_test_battery(
    test_object, service = 'ria', expected_names = expected_names, temperature = mean_temperature,
    stations_to_check = stations_to_check
  )
})

test_that("ria monthly works", {
  # all stations
  api_options <- ria_options('monthly', start_date = Sys.Date() - 120, end_date = Sys.Date() - 1)
  expect_message((test_object <- get_meteo_from('ria', api_options)), 'www.juntadeandalucia.es')
  expected_names <- c(
    "timestamp", "service", "station_id", "station_name", "station_province", "altitude",
    "mean_temperature", "min_temperature", "max_temperature",
    "mean_relative_humidity", "min_relative_humidity", "max_relative_humidity",
    "precipitation",
    "mean_wind_direction", "mean_wind_speed",
    "solar_radiation",
    "under_plastic",
    "geometry"
  )
  main_test_battery(
    test_object, service = 'ria', expected_names = expected_names, temperature = mean_temperature
  )

  # some stations
  stations_to_check <- unique(test_object[['station_id']])[1:3]
  api_options$stations <- stations_to_check
  expect_message((test_object <- get_meteo_from('ria', api_options)), 'www.juntadeandalucia.es')
  main_test_battery(
    test_object, service = 'ria', expected_names = expected_names, temperature = mean_temperature,
    stations_to_check = stations_to_check
  )
})


test_that("ria API errors, messages, warnings are correctly raised", {
  # copyright message
  api_options <- ria_options()
  # invalid stations
  api_options <- ria_options(stations = c('18-4234', '18-12323', '234wdas-aq3', 'tururu'))
  expect_error(get_meteo_from('ria', api_options), "Unable to obtain data from RIA API")
  # dates out of bounds
  api_options <- ria_options('daily', start_date = as.Date('1890-01-01'))
  expect_error(get_meteo_from('ria', api_options), "Unable to obtain data from RIA API:")
  api_options$resolution <- 'tururu'
  expect_error(get_meteo_from('ria', api_options), "is not a valid temporal resolution")
})
