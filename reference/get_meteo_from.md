# Get meteorological stations data

Connect and retrieve data from AEMET, SMC and other Spanish
meteorological stations services.

## Usage

``` r
get_meteo_from(
  service = c("aemet", "meteocat", "meteoclimatic", "meteogalicia", "ria"),
  options
)
```

## Arguments

- service:

  Character with the service name (in lower case).

- options:

  List with the needed service options. See
  [`services_options`](https://emf-creaf.github.io/meteospain/reference/services_options.md)
  to have more info about the different services and their options.

## Value

An sf (spatial) object with the stations meteorological data.

## Details

Depending on the service and the temporal resolution selected, the
variables present can change, but all services have at least temperature
values.

## API limits

Some APIs have limits in terms of the data that can be retrieved with
one call. For example, AEMET only serves daily data for 31 days in one
query. See
[`vignette('api_limits', package = 'meteospain')`](https://emf-creaf.github.io/meteospain/articles/api_limits.md)
for a detailed explanations of those limits and the ways to retrieve
longer periods.

## Cache

To avoid unnecessary API calls (especially in rate-limited APIs),
results are cached to memory in a
[`cache_mem`](https://cachem.r-lib.org/reference/cache_mem.html) object.
This cache is limited to the actual R session and invalidates after 24h.
Temporal resolutions below daily are not cached, as they change often.

This cache can be cleared with
[`clear_meteospain_cache`](https://emf-creaf.github.io/meteospain/reference/clear_meteospain_cache.md).

## Examples

``` r
if (FALSE) { # interactive()
  library(meteospain)
  library(keyring)

  # AEMET (we need a key)
  # key_set('aemet')
  options_for_aemet <- aemet_options(
    'daily',
    start_date = as.Date('2012-01-16'),
    end_date = as.Date('2012-01-31'),
    api_key = key_get('aemet')
  )
  get_meteo_from('aemet', options_for_aemet)
}
```
