# riaa service options tests ---------------------------------------------------------------------------

test_that("riaa service options works", {
  expected_names <- c("resolution", "start_date", "end_date", "stations")
  expect_type(riaa_options(), 'list')
  expect_named(riaa_options(), expected_names)
  expect_identical(
    riaa_options(),
    riaa_options(
      resolution = 'daily', start_date = Sys.Date() - 1, end_date = Sys.Date() - 1
    )
  )

  # errors
  expect_error(riaa_options(resolution = 'not_valid_resolution'), "must be one of")
  expect_error(riaa_options(stations = c(25, 26, 27)), "must be a character vector")

})

# riaa get info tests ----------------------------------------------------------------------------------

test_that("riaa get info works", {
  api_options <- riaa_options()
  test_object <- suppressMessages(get_stations_info_from('riaa', api_options))
  expected_names <- c(
    "service", "station_id", "station_name", "station_province", "altitude", "under_plastic", "geometry"
  )
  main_test_battery(test_object, service = 'riaa', expected_names = expected_names)
})
