# RIA service

``` r
library(meteospain)
library(dplyr)
#> 
#> Attaching package: 'dplyr'
#> The following objects are masked from 'package:stats':
#> 
#>     filter, lag
#> The following objects are masked from 'package:base':
#> 
#>     intersect, setdiff, setequal, union
library(ggplot2)
library(ggforce)
library(units)
#> udunits database from /usr/share/xml/udunits/udunits2.xml
library(sf)
#> Linking to GEOS 3.12.1, GDAL 3.8.4, PROJ 9.4.0; sf_use_s2() is TRUE
```

## Red de Información Agroclimática de Andalucía (RIA) service

[RIA](https://www.juntadeandalucia.es/agriculturaypesca/ifapa/riaweb/web/)
service offers the data of the andalucian automatic meteorological
stations network. This network is supported and assessed by the Junta de
Andalucía and the data should be trustworthy.

### RIA options

#### Temporal resolution

RIA API offers data at different temporal resolutions:

- “daily”, returning the daily aggregated measures for all or selected
  stations.
- “monthly”, returning the monthly aggregated measures for all or
  selected stations.

In both, “daily” and “monthly”, a `start_date` (and optionally an
`end_date`) arguments must be provided, indicating the period from which
retrieve the data.

#### Stations

RIA API needs station codes and province codes to retrieve the data.
Sadly, RIA doesn’t provide unique station codes, and the uniqueness
comes with the province id and station code together. So, to narrow the
data retrieving to the desired stations they must be provided as a
character vector of “province_id-station_code” values (i.e. “14-2”) for
the `stations` argument. Calling
`get_stations_info_from('ria', ria_options)` will show the station
correct codes in the `station_id` column to take as reference.

#### Examples

``` r
# default, daily for yesterday
api_options <- ria_options()
api_options
#> $resolution
#> [1] "daily"
#> 
#> $start_date
#> [1] "2026-01-07"
#> 
#> $end_date
#> [1] "2026-01-07"
#> 
#> $stations
#> NULL

# daily, only some stations
api_options <- ria_options(
  resolution = 'daily',
  stations = c('14-2', '4-2')
)
api_options
#> $resolution
#> [1] "daily"
#> 
#> $start_date
#> [1] "2026-01-07"
#> 
#> $end_date
#> [1] "2026-01-07"
#> 
#> $stations
#> [1] "14-2" "4-2"

# monthly, some stations
api_options <- ria_options(
  resolution = 'monthly',
  start_date = as.Date('2020-04-01'), end_date = as.Date('2020-08-01'),
  stations = c('14-2', '4-2')
)
api_options
#> $resolution
#> [1] "monthly"
#> 
#> $start_date
#> [1] "2020-04-01"
#> 
#> $end_date
#> [1] "2020-08-01"
#> 
#> $stations
#> [1] "14-2" "4-2"
```

### RIA stations info

Accessing station metadata for RIA is simple:

``` r
get_stations_info_from('ria', api_options)
#> Simple feature collection with 123 features and 7 fields
#> Geometry type: POINT
#> Dimension:     XY
#> Bounding box:  xmin: -7.248333 ymin: 36.285 xmax: -1.770278 ymax: 38.49611
#> Geodetic CRS:  WGS 84
#> # A tibble: 123 × 8
#>    service station_id station_name         station_province province_id altitude
#>  * <chr>   <chr>      <chr>                <chr>                  <int>      [m]
#>  1 ria     14-2       Adamuz               Córdoba                   14      145
#>  2 ria     4-10       Adra                 Almería                    4        2
#>  3 ria     23-6       Alcaudete            Jaén                      23      640
#>  4 ria     4-2        Almería              Almería                    4        5
#>  5 ria     21-10      Almonte              Huelva                    21       13
#>  6 ria     21-103     Almonte bajo plásti… Huelva                    21       38
#>  7 ria     21-104     Almonte bajo plásti… Huelva                    21       23
#>  8 ria     18-11      Almuñecar            Granada                   18       29
#>  9 ria     18-9       Almuñecar            Granada                   18       49
#> 10 ria     29-3       Antequera            Málaga                    29      457
#> # ℹ 113 more rows
#> # ℹ 2 more variables: under_plastic <lgl>, geometry <POINT [°]>
```

### RIA data

``` r
api_options <- ria_options(
  resolution = 'monthly',
  start_date = as.Date('2020-01-01'),
  end_date = as.Date('2020-12-31')
)
andalucia_2020 <- get_meteo_from('ria', options = api_options)
#> iterating ■■■                                6% | ETA: 19s
#> iterating ■■■■■■                            17% | ETA: 17s
#> iterating ■■■■■■■■■■■                       33% | ETA: 13s
#> iterating ■■■■■■■■■■■■■■■                   48% | ETA: 10s
#> iterating ■■■■■■■■■■■■■■■■■■■■              63% | ETA:  7s
#> iterating ■■■■■■■■■■■■■■■■■■■■■■■■          78% | ETA:  4s
#> iterating ■■■■■■■■■■■■■■■■■■■■■■■■■■■■■     93% | ETA:  1s
#> iterating ■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■  100% | ETA:  0s
#> ✖ Some stations didn't return data:
#> https://www.juntadeandalucia.es/agriculturaypesca/ifapa/riaws/datosmensuales/21/104/2020/1/12:
#> HTTP 404 Not Found.
#> https://www.juntadeandalucia.es/agriculturaypesca/ifapa/riaws/datosmensuales/18/9/2020/1/12:
#> HTTP 404 Not Found.
#> https://www.juntadeandalucia.es/agriculturaypesca/ifapa/riaws/datosmensuales/29/3/2020/1/12:
#> HTTP 404 Not Found.
#> https://www.juntadeandalucia.es/agriculturaypesca/ifapa/riaws/datosmensuales/29/5/2020/1/12:
#> HTTP 404 Not Found.
#> https://www.juntadeandalucia.es/agriculturaypesca/ifapa/riaws/datosmensuales/21/1/2020/1/12:
#> HTTP 404 Not Found.
#> https://www.juntadeandalucia.es/agriculturaypesca/ifapa/riaws/datosmensuales/41/4/2020/1/12:
#> HTTP 404 Not Found.
#> https://www.juntadeandalucia.es/agriculturaypesca/ifapa/riaws/datosmensuales/21/106/2020/1/12:
#> HTTP 404 Not Found.
#> https://www.juntadeandalucia.es/agriculturaypesca/ifapa/riaws/datosmensuales/23/9/2020/1/12:
#> HTTP 404 Not Found.
#> https://www.juntadeandalucia.es/agriculturaypesca/ifapa/riaws/datosmensuales/41/1/2020/1/12:
#> HTTP 404 Not Found.
#> https://www.juntadeandalucia.es/agriculturaypesca/ifapa/riaws/datosmensuales/23/10/2020/1/12:
#> HTTP 404 Not Found.
#> https://www.juntadeandalucia.es/agriculturaypesca/ifapa/riaws/datosmensuales/23/13/2020/1/12:
#> HTTP 404 Not Found.
#> https://www.juntadeandalucia.es/agriculturaypesca/ifapa/riaws/datosmensuales/21/12/2020/1/12:
#> HTTP 404 Not Found.
#> https://www.juntadeandalucia.es/agriculturaypesca/ifapa/riaws/datosmensuales/4/3/2020/1/12:
#> HTTP 404 Not Found.
#> https://www.juntadeandalucia.es/agriculturaypesca/ifapa/riaws/datosmensuales/14/3/2020/1/12:
#> HTTP 404 Not Found.
#> https://www.juntadeandalucia.es/agriculturaypesca/ifapa/riaws/datosmensuales/21/107/2020/1/12:
#> HTTP 404 Not Found.
#> https://www.juntadeandalucia.es/agriculturaypesca/ifapa/riaws/datosmensuales/18/4/2020/1/12:
#> HTTP 404 Not Found.
#> https://www.juntadeandalucia.es/agriculturaypesca/ifapa/riaws/datosmensuales/11/8/2020/1/12:
#> HTTP 404 Not Found.
#> https://www.juntadeandalucia.es/agriculturaypesca/ifapa/riaws/datosmensuales/11/3/2020/1/12:
#> HTTP 404 Not Found.
#> https://www.juntadeandalucia.es/agriculturaypesca/ifapa/riaws/datosmensuales/11/9/2020/1/12:
#> HTTP 404 Not Found.
#> https://www.juntadeandalucia.es/agriculturaypesca/ifapa/riaws/datosmensuales/4/9/2020/1/12:
#> HTTP 404 Not Found.
#> https://www.juntadeandalucia.es/agriculturaypesca/ifapa/riaws/datosmensuales/41/6/2020/1/12:
#> HTTP 404 Not Found.
#> https://www.juntadeandalucia.es/agriculturaypesca/ifapa/riaws/datosmensuales/41/14/2020/1/12:
#> HTTP 404 Not Found.
#> ℹ Data provided by Red de Información Agroclimática de Andalucía (RIA)
#> https://www.juntadeandalucia.es/agriculturaypesca/ifapa/riaweb/web/
andalucia_2020
#> Simple feature collection with 1209 features and 19 fields
#> Geometry type: POINT
#> Dimension:     XY
#> Bounding box:  xmin: -7.248333 ymin: 36.285 xmax: -1.770278 ymax: 38.49611
#> Geodetic CRS:  WGS 84
#> # A tibble: 1,209 × 20
#>    timestamp           service station_id station_name station_province altitude
#>    <dttm>              <chr>   <chr>      <chr>        <chr>                 [m]
#>  1 2020-01-01 00:00:00 ria     14-2       Adamuz       Córdoba               145
#>  2 2020-02-01 00:00:00 ria     14-2       Adamuz       Córdoba               145
#>  3 2020-03-01 00:00:00 ria     14-2       Adamuz       Córdoba               145
#>  4 2020-04-01 00:00:00 ria     14-2       Adamuz       Córdoba               145
#>  5 2020-05-01 00:00:00 ria     14-2       Adamuz       Córdoba               145
#>  6 2020-06-01 00:00:00 ria     14-2       Adamuz       Córdoba               145
#>  7 2020-07-01 00:00:00 ria     14-2       Adamuz       Córdoba               145
#>  8 2020-08-01 00:00:00 ria     14-2       Adamuz       Córdoba               145
#>  9 2020-09-01 00:00:00 ria     14-2       Adamuz       Córdoba               145
#> 10 2020-10-01 00:00:00 ria     14-2       Adamuz       Córdoba               145
#> # ℹ 1,199 more rows
#> # ℹ 14 more variables: mean_temperature [°C], min_temperature [°C],
#> #   max_temperature [°C], mean_relative_humidity [%],
#> #   min_relative_humidity [%], max_relative_humidity [%],
#> #   precipitation [L/m^2], mean_wind_direction [°], max_wind_direction [°],
#> #   mean_wind_speed [m/s], max_wind_speed [m/s], solar_radiation [MJ/(d*m^2)],
#> #   geometry <POINT [°]>, under_plastic <lgl>
```

Visually:

``` r
andalucia_2020 |>
  units::drop_units() |>
  mutate(month = lubridate::month(timestamp, label = TRUE)) |>
  ggplot() +
  geom_sf(aes(colour = max_temperature)) +
  facet_wrap(vars(month), ncol = 4) +
  scale_colour_viridis_c()
```

![](ria_files/figure-html/ria_data_plot-1.png)

``` r

andalucia_2020 |>
  mutate(month = lubridate::month(timestamp, label = TRUE)) |>
  ggplot() +
  geom_histogram(aes(x = precipitation)) +
  facet_wrap(vars(month), ncol = 4)
#> `stat_bin()` using `bins = 30`. Pick better value `binwidth`.
#> Warning: Removed 21 rows containing non-finite outside the scale range
#> (`stat_bin()`).
```

![](ria_files/figure-html/ria_data_plot-2.png)
