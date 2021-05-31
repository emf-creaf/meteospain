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
