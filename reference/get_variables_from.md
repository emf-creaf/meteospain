# Get variables info

Obtain information about variables as offered by the APIs

## Usage

``` r
get_variables_from(service = c("meteocat"), options)
```

## Arguments

- service:

  Character with the service name (in lower case).

- options:

  List with the needed service options. See
  [`services_options`](https://emf-creaf.github.io/meteospain/reference/services_options.md)
  to have more info about the different services and their options.

## Value

A data frame with the variables info

## Details

Depending on the service, information about original variable names,
menaning, original units... **Currently only MeteoCat is available**,
other services will result in an error

## Examples

``` r
if (FALSE) { # interactive()
  library(meteospain)
  library(keyring)

  # MeteoCat (we need a key)
  # key_set('meteocat')
  api_options <- meteocat_options("daily", api_key = key_get('meteocat'))
  get_variables_from('meteocat', api_options)
}
```
