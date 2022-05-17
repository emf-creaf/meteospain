# skip on cran ----------------------------------------------------------------------------------------

skip_on_cran()
skip_if_no_internet()

# meteogalicia service options tests ---------------------------------------------------------------------------

test_that("meteogalicia service options works", {
  expected_names <- c("resolution", "start_date", "end_date", "stations")
  expect_type(meteogalicia_options(), 'list')
  expect_named(meteogalicia_options(), expected_names)
  expect_identical(
    meteogalicia_options(),
    meteogalicia_options(resolution = 'instant', start_date = Sys.Date(), end_date = Sys.Date())
  )

  # errors
  expect_error(meteogalicia_options(resolution = 'not_valid_resolution'), "must be one of")
  expect_error(meteogalicia_options(stations = c(25, 26, 27)), "must be a character vector")

})

# meteogalicia get info tests ----------------------------------------------------------------------------------

test_that("meteogalicia get info works", {
  api_options <- meteogalicia_options()
  test_object <- suppressMessages(get_stations_info_from('meteogalicia', api_options))
  expected_names <- c("service", "station_id", "station_name", "station_province", "altitude", "geometry")
  main_test_battery(
    test_object, service = 'meteogalicia', expected_names = expected_names
  )
})

# meteogalicia get meteo tests ---------------------------------------------------------------------------
test_that("meteogalicia instant works", {
  # all stations
  api_options <- meteogalicia_options('instant')
  expect_message((test_object <- get_meteo_from('meteogalicia', api_options)), 'mencionar expresamente a MeteoGalicia')
  expected_names <- c(
    "timestamp", "service", "station_id", "station_name", "station_province", "altitude",
    "temperature",
    "relative_humidity", "precipitation",
    "wind_direction", "wind_speed",
    "insolation", #"global_solar_radiation",
    "geometry"
  )
  main_test_battery(
    test_object, service = 'meteogalicia', expected_names = expected_names, temperature = temperature,
  )
  # expect_identical(units(test_object$global_solar_radiation)$numerator, "MJ")
  # expect_identical(units(test_object$global_solar_radiation)$denominator, c('m', 'm'))
  # some stations
  stations_to_check <- test_object[['station_id']][1:3]
  api_options$stations <- stations_to_check
  expect_message((test_object <- get_meteo_from('meteogalicia', api_options)), 'mencionar expresamente a MeteoGalicia')
  main_test_battery(
    test_object, service = 'meteogalicia', expected_names = expected_names, temperature = temperature,
    stations_to_check = stations_to_check
  )
})

test_that("meteogalicia current works", {
  # all stations
  api_options <- meteogalicia_options('current_day')
  expect_message((test_object <- get_meteo_from('meteogalicia', api_options)), 'mencionar expresamente a MeteoGalicia')
  expected_names <- c(
    "timestamp", "service", "station_id", "station_name", "station_province", "altitude",
    "temperature", "min_temperature", "max_temperature",
    "relative_humidity", "precipitation",
    "wind_direction", "wind_speed",
    "insolation",
    "geometry"
  )
  main_test_battery(
    test_object, service = 'meteogalicia', expected_names = expected_names, temperature = temperature
  )
  # some stations
  stations_to_check <- test_object[['station_id']][1:3]
  api_options$stations <- stations_to_check
  expect_message((test_object <- get_meteo_from('meteogalicia', api_options)), 'mencionar expresamente a MeteoGalicia')
  main_test_battery(
    test_object, service = 'meteogalicia', expected_names = expected_names, temperature = temperature,
    stations_to_check = stations_to_check
  )
})

test_that("meteogalicia daily works", {
  # all stations actual
  api_options <- meteogalicia_options('daily', start_date = Sys.Date() - 30, end_date = Sys.Date())
  expect_message((test_object <- get_meteo_from('meteogalicia', api_options)), 'mencionar expresamente a MeteoGalicia')
  expected_names <- c(
    "timestamp", "service", "station_id", "station_name", "station_province", "altitude",
    "mean_temperature", "min_temperature", "max_temperature",
    "mean_relative_humidity", "min_relative_humidity", "max_relative_humidity", "precipitation",
    "mean_wind_direction", "mean_wind_speed",
    "insolation",
    "geometry"
  )
  main_test_battery(
    test_object, service = 'meteogalicia', expected_names = expected_names, temperature = mean_temperature
  )
  expect_equal(as.Date(unique(test_object$timestamp)), seq(api_options$start_date, api_options$end_date, 1))
  # some stations actual
  stations_to_check <- test_object[['station_id']][1:3]
  api_options$stations <- stations_to_check
  expect_message((test_object <- get_meteo_from('meteogalicia', api_options)), 'mencionar expresamente a MeteoGalicia')
  main_test_battery(
    test_object, service = 'meteogalicia', expected_names = expected_names, temperature = mean_temperature,
    stations_to_check = stations_to_check
  )
  expect_equal(as.Date(unique(test_object$timestamp)), seq(api_options$start_date, api_options$end_date, 1))

  # all stations 2000s
  api_options <- meteogalicia_options('daily', start_date = as.Date('2000-01-25'), end_date = as.Date('2000-01-30'))
  expect_message((test_object <- get_meteo_from('meteogalicia', api_options)), 'mencionar expresamente a MeteoGalicia')
  main_test_battery(
    test_object, service = 'meteogalicia', expected_names = expected_names, temperature = mean_temperature
  )
  expect_equal(as.Date(unique(test_object$timestamp)), seq(api_options$start_date, api_options$end_date, 1))
  # some stations 2000s
  stations_to_check <- test_object[['station_id']][1:3]
  api_options$stations <- stations_to_check
  expect_message((test_object <- get_meteo_from('meteogalicia', api_options)), 'mencionar expresamente a MeteoGalicia')
  main_test_battery(
    test_object, service = 'meteogalicia', expected_names = expected_names, temperature = mean_temperature
  )
  expect_equal(as.Date(unique(test_object$timestamp)), seq(api_options$start_date, api_options$end_date, 1))
})

test_that("meteogalicia monthly works", {
  # all stations actual
  api_options <- meteogalicia_options('monthly', start_date = Sys.Date() - 365, end_date = Sys.Date())
  expect_message((test_object <- get_meteo_from('meteogalicia', api_options)), 'mencionar expresamente a MeteoGalicia')
  expected_names <- c(
    "timestamp", "service", "station_id", "station_name", "station_province", "altitude",
    "mean_temperature", "min_temperature", "max_temperature",
    "mean_relative_humidity", "precipitation",
    "mean_wind_speed",
    "insolation",
    "geometry"
  )
  main_test_battery(
    test_object, service = 'meteogalicia', expected_names = expected_names, temperature = mean_temperature
  )
  # some stations actual
  stations_to_check <- test_object[['station_id']][1:3]
  api_options$stations <- stations_to_check
  expect_message((test_object <- get_meteo_from('meteogalicia', api_options)), 'mencionar expresamente a MeteoGalicia')
  main_test_battery(
    test_object, service = 'meteogalicia', expected_names = expected_names, temperature = mean_temperature,
    stations_to_check = stations_to_check
  )

  # all stations 2000s
  api_options <- meteogalicia_options('monthly', start_date = as.Date('2000-01-01'), end_date = as.Date('2000-12-01'))
  expect_message((test_object <- get_meteo_from('meteogalicia', api_options)), 'mencionar expresamente a MeteoGalicia')
  main_test_battery(
    test_object, service = 'meteogalicia', expected_names = expected_names, temperature = mean_temperature
  )
  expect_length(unique(test_object$timestamp), 12)
  # some stations 2000s
  stations_to_check <- test_object[['station_id']][1:3]
  api_options$stations <- stations_to_check
  expect_message((test_object <- get_meteo_from('meteogalicia', api_options)), 'mencionar expresamente a MeteoGalicia')
  main_test_battery(
    test_object, service = 'meteogalicia', expected_names = expected_names, temperature = mean_temperature,
    stations_to_check = stations_to_check
  )
  expect_length(unique(test_object$timestamp), 12)
})

test_that("meteogalicia API errors, messages, warnings are correctly raised", {
  # copyright message
  api_options <- meteogalicia_options('current_day')
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
  expect_error(get_meteo_from('meteogalicia', api_options), "unknown station ids")
  api_options$resolution <- 'yearly'
  expect_error(get_meteo_from('meteogalicia', api_options), "is not a valid temporal resolution")
})
