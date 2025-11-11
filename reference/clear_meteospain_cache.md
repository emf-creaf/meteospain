# Clear all cached results

Reset the internal cache used to limit the API requests.

## Usage

``` r
clear_meteospain_cache()
```

## Details

Cached results reduces the number of API requests, but sometimes we need
fresh results without restarting the R session. `clear_meteospain_cache`
function reset the cache for the actual R session.
