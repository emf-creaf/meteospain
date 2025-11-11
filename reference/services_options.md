# Options for meteorological services

Set the options for accessing the different Spanish meteorological
services

## Usage

``` r
aemet_options(
  resolution = c("current_day", "daily", "monthly", "yearly"),
  start_date = Sys.Date(),
  end_date = start_date,
  stations = NULL,
  api_key
)

meteocat_options(
  resolution = c("instant", "hourly", "daily", "monthly", "yearly"),
  start_date = Sys.Date(),
  stations = NULL,
  api_key
)

meteoclimatic_options(resolution = c("current_day"), stations = NULL)

meteogalicia_options(
  resolution = c("instant", "current_day", "daily", "monthly"),
  start_date = Sys.Date(),
  end_date = start_date,
  stations = NULL
)

ria_options(
  resolution = c("daily", "monthly"),
  start_date = Sys.Date() - 1,
  end_date = start_date,
  stations = NULL
)
```

## Arguments

- resolution:

  Character indicating the temporal resolution for the data. Services
  allows different temporal resolutions that can be present or not in
  each of them (current_day, instant, daily, monthly).

- start_date:

  Date class object with the start date from which start collecting
  data. Ignored if resolution is one of `current_day` or `instant`.

- end_date:

  Date class object with the end date from which stop collecting data.
  By default, same date as `start_date`. Ignored if resolution is one of
  `current_day` or `instant`.

- stations:

  Character vector with the stations codes from which extract data from.
  If NULL (default) all available stations are returned. See Stations
  section for more details.

- api_key:

  Character with the API key. NULL by default as not all services
  require keys. See API Keys section for more details.

## Value

A list with the service API options to make the query to obtain the
data.

## Resolution

Temporal resolutions vary from service to service. Check the "Usage"
section to see resolutions available to each service. Possible values
are:

- `current_day` returns the last 12-24h of measures.

- `instant` returns the last measures available.

- `hourly` returns the hourly measures.

- `daily` returns any past date/s with daily aggregation.

- `monthly` returns any past date/s with monthly aggregation.

- `yearly` returns any past date/s with yearly aggregation.

## Keys

Some services (i.e. AEMET, MeteoCat...) require an API key to access the
data. The requirements and process to obtain the key varies from service
to service.

- AEMET: Visit <https://opendata.aemet.es/centrodedescargas/inicio> and
  follow the instructions at "Obtención de API Key".

- MeteoCat: Visit <https://apidocs.meteocat.gencat.cat/> and follow the
  instructions there.

It is not advisable to use the keys directly in any script shared or
publicly available (github...), neither store them in plain text files.
One option is using the [keyring](https://github.com/r-lib/keyring)
package for managing and accessing keys.

## Stations

Some services accept querying multiple stations at once, and other only
allows one station per query:

- AEMET: One or more stations can be provided in a character vector
  (except for monthly and yearly resolutions, as they only accept one
  station.

- MeteoCat: One or more stations can be provided in a character vector.

- MeteoGalicia: One or more stations can be provided in a character
  vector.

- Meteoclimatic: Only one station can be provided. Nevertheless, some
  codes can be used to retrieve common group of stations: "ES" for all
  Spanish stations, "ESCAT", "ESCYL", "ESAND"... for the different
  autonomous communities.

- RIA: API accepts only one station. Nonetheless, an internal loop is
  performed to retrieve all the stations provided

## Examples

``` r
if (FALSE) { # interactive()
  library(keyring)
  library(meteospain)

  ## AEMET examples ---------------------------------------------------------

  # setting the key (a prompt will appear in console to supply the API key)
  # keyring::key_set(service = 'aemet')

  # Options for the last 24h data
  current_opts <- aemet_options(
    resolution = 'current_day',
    api = keyring::key_get('aemet')
  )

  # Options for daily data for January, 1990
  daily_opts <- aemet_options(
    resolution = 'daily',
    start_date = as.Date('1990-01-01'),
    end_date = as.Date('1990-01-15'),
    api = keyring::key_get('aemet')
  )
}
if (FALSE) { # interactive()
  ## MeteoCat examples -----------------------------------------------------------

  # setting the key (a prompt will appear in console to supply the API key)
  # keyring::key_set(service = 'meteocat')

  # create the options
  query_options <- meteocat_options(
    resolution = 'hourly',
    start_date = as.Date('2020-12-31'),
    api = keyring::key_get('meteocat')
  )
}

## Meteoclimatic examples -------------------------------------------------

current_opts <- meteoclimatic_options()
# same as before, but more verbose
current_opts <- meteoclimatic_options(resolution = 'current_day', stations = 'ES')


## MeteoGalicia examples --------------------------------------------------

# Options for the last measured data
instant_opts <- meteogalicia_options(resolution = 'instant')

# Options for the last 24h data
current_opts <- meteogalicia_options(resolution = 'current_day')
# same, with stations
current_opts <- meteogalicia_options('current_day', stations = c('10045', '10046'))

# Options for daily data for January, 2000
daily_opts <- meteogalicia_options(
  resolution = 'daily',
  start_date = as.Date('2000-01-01'),
  end_date = as.Date('2000-01-31')
)

# Options for monthly data for year 2000
monthly_opts <- meteogalicia_options(
  resolution = 'monthly',
  start_date = as.Date('2000-01-01'),
  end_date = as.Date('2000-12-31')
)

if (FALSE) { # interactive()
  library(keyring)
  library(meteospain)

  ## RIA examples ---------------------------------------------------------

  # Options for daily data for April, 2020
  daily_opts <- ria_options(
    resolution = 'daily',
    start_date = as.Date('2020-04-01'),
    end_date = as.Date('2020-04-30')
  )
}
```
