# skip if no key ----------------------------------------------------------------------------------------
skip_if_no_auth('aemet')
skip_if_no_auth('meteocat')

withr::local_options(list("keyring_backend" = "env"))

# instant_concordance
test_that("instant concordance exists", {
  meteocat_instant <- suppressMessages(get_meteo_from(
    'meteocat',
    meteocat_options('instant', api_key = keyring::key_get('meteocat'))
  ))
  meteogalicia_instant <- suppressMessages(get_meteo_from(
    'meteogalicia',
    meteogalicia_options('instant')
  ))
  test_object <- suppressMessages(
    dplyr::full_join(dplyr::as_tibble(meteocat_instant), dplyr::as_tibble(meteogalicia_instant)) %>%
      sf::st_as_sf()
  )
  expect_s3_class(test_object, 'sf')
  expect_identical(unique(test_object$service), c('meteocat', 'meteogalicia'))
})

test_that("current concordance exists", {
  aemet_current <- suppressMessages(get_meteo_from(
    'aemet',
    aemet_options('current_day', api_key = keyring::key_get('aemet'))
  ))
  meteocat_current <- suppressMessages(get_meteo_from(
    'meteocat',
    meteocat_options('hourly', api_key = keyring::key_get('meteocat'))
  ))
  meteoclimatic_current <- suppressMessages(get_meteo_from(
    'meteoclimatic',
    meteoclimatic_options('current_day')
  ))
  meteogalicia_current <- suppressMessages(get_meteo_from(
    'meteogalicia',
    meteogalicia_options('current_day')
  ))
  test_object <- suppressMessages(purrr::reduce(
    list(
      dplyr::as_tibble(aemet_current), dplyr::as_tibble(meteocat_current),
      dplyr::as_tibble(meteoclimatic_current), dplyr::as_tibble(meteogalicia_current)
    ),
    dplyr::full_join
  ) %>%
    sf::st_as_sf())
  expect_s3_class(test_object, 'sf')
  expect_identical(unique(test_object$service), c('aemet', 'meteocat', 'meteoclimatic', 'meteogalicia'))
})

test_that("daily concordance exists", {
  aemet_daily <- suppressMessages(get_meteo_from(
    'aemet', aemet_options(
      'daily', start_date = as.Date('2020-04-01'), end_date = as.Date('2020-04-30'),
      api_key = keyring::key_get('aemet')
    )
  ))
  meteocat_daily <- suppressMessages(get_meteo_from(
    'meteocat',
    meteocat_options('daily', start_date = as.Date('2020-04-01'), api_key = keyring::key_get('meteocat'))
  ))
  meteogalicia_daily <- suppressMessages(get_meteo_from(
    'meteogalicia',
    meteogalicia_options('daily', start_date = as.Date('2020-04-01'), end_date = as.Date('2020-04-30'))
  ))
  ria_daily <- suppressMessages(get_meteo_from(
    'ria',
    ria_options('daily', start_date = as.Date('2020-04-01'), end_date = as.Date('2020-04-30'))
  ))
  test_object <- suppressMessages(purrr::reduce(
    list(
      dplyr::as_tibble(aemet_daily), dplyr::as_tibble(meteocat_daily),
      dplyr::as_tibble(meteogalicia_daily), dplyr::as_tibble(ria_daily)
    ),
    dplyr::full_join
  ) %>%
    sf::st_as_sf())
  expect_s3_class(test_object, 'sf')
  expect_identical(unique(test_object$service), c('aemet', 'meteocat', 'meteogalicia', 'ria'))
})

test_that("monthly concordance exists", {
  # aemet_monthly <- get_meteo_from(
  #   'aemet', aemet_options(
  #     'monthly', start_date = as.Date('2020-01-01'), end_date = as.Date('2020-12-31'),
  #     api_key = keyring::key_get('aemet')
  #   )
  # )
  meteocat_monthly <- suppressMessages(get_meteo_from(
    'meteocat',
    meteocat_options('monthly', start_date = as.Date('2020-01-01'), api_key = keyring::key_get('meteocat'))
  ))
  meteogalicia_monthly <- suppressMessages(get_meteo_from(
    'meteogalicia',
    meteogalicia_options('monthly', start_date = as.Date('2020-01-01'), end_date = as.Date('2020-12-31'))
  ))
  ria_monthly <- suppressMessages(get_meteo_from(
    'ria',
    ria_options('monthly', start_date = as.Date('2020-01-01'), end_date = as.Date('2020-12-31'))
  ))
  test_object <- suppressMessages(purrr::reduce(
    list(
      # dplyr::as_tibble(aemet_monthly),
      dplyr::as_tibble(meteocat_monthly),
      dplyr::as_tibble(meteogalicia_monthly),
      dplyr::as_tibble(ria_monthly)
    ),
    dplyr::full_join
  ) %>%
    sf::st_as_sf())
  expect_s3_class(test_object, 'sf')
  expect_identical(unique(test_object$service), c('meteocat', 'meteogalicia', 'ria'))
})
