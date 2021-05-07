
# aemet get data tests ----------------------------------------------------------------------------------

test_that("aemet current works", {
  # all stations
  api_options <- aemet_options('current_day', api_key = keyring::key_get('aemet'))
  test_object <- get_data_from('aemet', api_options)
  expected_names <- c(
    "timestamp", "station_id", "station_name", "altitude", "temperature", "min_temperature", "max_temperature",
    "precipitation", "relative_humidity", "wind_speed", "wind_direction", "geometry"
  )
  expect_s3_class(test_object, 'sf')
  expect_true(nrow(test_object) > 1)
  expect_named(test_object, expected_names)
  # some stations
  api_options$stations <- c('0009X', '0016A', '0034X')
  test_object <- get_data_from('aemet', api_options)
  expect_s3_class(test_object, 'sf')
  expect_true(nrow(test_object) > 1)
  expect_equal(unique(test_object$station_id), c('0009X', '0016A', '0034X'))
  expect_named(test_object, expected_names)
})

test_that("aemet daily works", {
  # all stations "modern" time
  api_options <- aemet_options(
    'daily',
    start_date = as.Date('2020-04-01'), end_date = as.Date('2020-05-01'),
    api_key = keyring::key_get('aemet')
  )
  test_object <- get_data_from('aemet', api_options)
  expected_names <- c(
    "timestamp", "station_id", "station_name", "station_province",
    "mean_temperature", "min_temperature", "max_temperature",
    "precipitation", "mean_wind_speed", "insolation", "altitude", "geometry"
  )
  expect_s3_class(test_object, 'sf')
  expect_true(nrow(test_object) > 1)
  expect_named(test_object, expected_names)
  # some stations
  api_options$stations <- c('4358X', '4220X', 'C447A')
  test_object <- get_data_from('aemet', api_options)
  expect_s3_class(test_object, 'sf')
  expect_true(nrow(test_object) > 1)
  expect_equal(unique(test_object$station_id), c('4358X', '4220X', 'C447A'))
  expect_named(test_object, expected_names)
  # all stations 2000's
  api_options <- aemet_options(
    'daily',
    start_date = as.Date('2005-04-01'), end_date = as.Date('2005-05-01'),
    api_key = keyring::key_get('aemet')
  )
  test_object <- get_data_from('aemet', api_options)
  expect_s3_class(test_object, 'sf')
  expect_true(nrow(test_object) > 1)
  expect_named(test_object, expected_names)
  # all stations 1990's
  api_options <- aemet_options(
    'daily',
    start_date = as.Date('1990-04-01'), end_date = as.Date('1990-05-01'),
    api_key = keyring::key_get('aemet')
  )
  test_object <- get_data_from('aemet', api_options)
  expect_s3_class(test_object, 'sf')
  expect_true(nrow(test_object) > 1)
  expect_named(test_object, expected_names)
})

test_that("aemet API errors, messages, warnings are correctly raised", {
  # copyright message
  api_options <- aemet_options('current_day', api_key = keyring::key_get('aemet'))
  expect_message(get_data_from('aemet', api_options), 'Autorizado el uso')
  # invalid key
  api_options <- aemet_options('current_day', api_key = 'tururu')
  expect_error(get_data_from('aemet', api_options), "API key invalido")
  # dates out of bounds
  api_options <- aemet_options(
    'daily',
    start_date = as.Date('1890-01-01'), end_date = as.Date('1890-01-02'),
    api_key = keyring::key_get('aemet')
  )
  expect_error(get_data_from('aemet', api_options), "No hay datos")
  api_options <- aemet_options(
    'daily',
    start_date = as.Date('1990-01-01'), end_date = as.Date('1991-01-01'),
    api_key = keyring::key_get('aemet')
  )
  expect_error(get_data_from('aemet', api_options), "El rango de fechas")
  # no data for stations selected
  api_options <- aemet_options(
    'daily',
    start_date = as.Date('1990-01-01'), end_date = as.Date('1990-01-02'),
    api_key = keyring::key_get('aemet'),
    stations = 'XXXXXX'
  )
  expect_error(
    get_data_from('aemet', api_options),
    "provided have no data for the dates selected"
  )
  api_options$resolution <- 'monthly'
  expect_error(get_data_from('aemet', api_options), "is not a valid temporal resolution")
  # query limit reached
  ## TODO test in some way if we catch the query limit (json error, because it returns html)???
})
