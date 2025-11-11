# Get api quota info

Obtain info about the API quota used

## Usage

``` r
get_quota_from(service = c("meteocat"), options)
```

## Arguments

- service:

  Character with the service name (in lower case).

- options:

  List with the needed service options. See
  [`services_options`](https://emf-creaf.github.io/meteospain/reference/services_options.md)
  to have more info about the different services and their options.

## Value

A data frame with the quota info

## Details

Depending on the service, some APIs allows only a number of data
requests. This function access the user quota numbers in the services
that allow for this, **(currently only MeteoCat)**

## Examples

``` r
if (FALSE) { # interactive()
  library(meteospain)
  library(keyring)

  # MeteoCat (we need a key)
  # key_set('meteocat')
  api_options <- meteocat_options(api_key = key_get('meteocat'))
  get_quota_from('meteocat', api_options)
}
```
