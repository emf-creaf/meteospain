# Get meteorological stations info

Obtain info and metadata for the available stations in the different
services

## Usage

``` r
get_stations_info_from(
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

An sf (spatial) object with the stations metadata.

## Details

Depending on the service the metadata available can be different. Also,
some services only offer info for active stations (i.e. AEMET), not
historical stations, so some mismatch can occur between the stations
returned by this function and the stations returned by
[`get_meteo_from`](https://emf-creaf.github.io/meteospain/reference/get_meteo_from.md)
for historical dates.

## Cache

To avoid unnecessary API calls (especially in rate-limited APIs),
results are cached to memory in a
[`cache_mem`](https://cachem.r-lib.org/reference/cache_mem.html) object.
This cache is limited to the actual R session and invalidates after 24h.

This cache can be cleared with
[`clear_meteospain_cache`](https://emf-creaf.github.io/meteospain/reference/clear_meteospain_cache.md).

## Examples

``` r
if (FALSE) { # interactive()
  library(meteospain)
  library(keyring)

  # AEMET (we need a key)
  # key_set('aemet')
  api_options <- aemet_options(api_key = key_get('aemet'))
  get_stations_info_from('aemet', api_options)
}
```
