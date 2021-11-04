
<!-- README.md is generated from README.Rmd. Please edit that file -->

# meteospain

<!-- badges: start -->

[![R-CMD-check](https://github.com/emf-creaf/meteospain/workflows/R-CMD-check/badge.svg)](https://github.com/emf-creaf/meteospain/actions)
<!-- badges: end -->

`meteospain` aims to offer access to different Spanish meteorological
stations data in an uniform way.

## Installation

`meteospain` is in CRAN, and can be installed as any other package:

``` r
install.packages('meteospain')
```

Also, `meteospain` is in active development. You can install the
development version from [GitHub](https://github.com/) with:

``` r
# install.packages("remotes")
remotes::install_github("emf-creaf/meteospain")
```

## Services

The following meteorological stations services are available:

-   [AEMET](https://www.aemet.es/en/portada), the Spanish State
    Meteorological Agency.
-   [MeteoCat](https://meteo.cat), the Catalan Meteorology Service.
-   [MeteoGalicia](https://www.meteogalicia.gal/web/inicio.action), the
    Galician Meteorological Service.
-   [RIA](https://www.juntadeandalucia.es/agriculturaypesca/ifapa/riaweb/web/),
    the Andalucian Agroclimatic Information Network.
-   [Meteoclimatic](https://www.meteoclimatic.net/), the Spanish
    non-professional meteorological stations network.

## Examples

Access to the services is done with the `get_meteo_from` function,
providing the name of the service and the options. Each service has a
dedicated options function to guide through the especifics of each
service:

``` r
library(meteospain)

mg_options <- meteogalicia_options(resolution = 'current_day')
get_meteo_from('meteogalicia', mg_options)
#> A información divulgada a través deste servidor ofrécese gratuitamente aos cidadáns para que poida ser 
#> utilizada libremente por eles, co único compromiso de mencionar expresamente a MeteoGalicia e á 
#> Consellería de Medio Ambiente, Territorio e Vivenda da Xunta de Galicia como fonte da mesma cada vez 
#> que as utilice para os usos distintos do particular e privado.
#> https://www.meteogalicia.gal/web/informacion/notaIndex.action
#> Simple feature collection with 3693 features and 14 fields
#> Geometry type: POINT
#> Dimension:     XY
#> Bounding box:  xmin: -9.178318 ymin: 41.8982 xmax: -6.765224 ymax: 43.734
#> Geodetic CRS:  WGS 84
#> # A tibble: 3,693 x 15
#>    timestamp           service station_id station_name station_province altitude
#>    <dttm>              <chr>   <chr>      <chr>        <chr>                 [m]
#>  1 2021-10-24 08:00:00 meteog… 10045      Mabegondo    A Coruña               94
#>  2 2021-10-24 08:00:00 meteog… 10046      Marco da Cu… A Coruña              651
#>  3 2021-10-24 08:00:00 meteog… 10047      Pedro Murias Lugo                   51
#>  4 2021-10-24 08:00:00 meteog… 10048      O Invernade… Ourense              1026
#>  5 2021-10-24 08:00:00 meteog… 10049      Corrubedo    A Coruña               30
#>  6 2021-10-24 08:00:00 meteog… 10050      CIS Ferrol   A Coruña               37
#>  7 2021-10-24 08:00:00 meteog… 10052      Muralla      A Coruña              661
#>  8 2021-10-24 08:00:00 meteog… 10053      Campus Lugo  Lugo                  400
#>  9 2021-10-24 08:00:00 meteog… 10055      Guitiriz-Mi… Lugo                  684
#> 10 2021-10-24 08:00:00 meteog… 10056      Marroxo      Lugo                  645
#> # … with 3,683 more rows, and 9 more variables: temperature [°C],
#> #   min_temperature [°C], max_temperature [°C], relative_humidity [%],
#> #   precipitation [L/m^2], wind_direction [°], wind_speed [m/s],
#> #   insolation [h], geometry <POINT [°]>
```

Stations info can be accessed with `get_stations_info_from` function:

``` r
get_stations_info_from('meteogalicia', mg_options)
#> Simple feature collection with 154 features and 5 fields
#> Geometry type: POINT
#> Dimension:     XY
#> Bounding box:  xmin: -9.178318 ymin: 41.8982 xmax: -6.765224 ymax: 43.734
#> Geodetic CRS:  WGS 84
#> # A tibble: 154 x 6
#>    service      station_id station_name             station_province altitude
#>  * <chr>        <chr>      <chr>                    <chr>                 [m]
#>  1 meteogalicia 10157      Coruña-Torre de Hércules A Coruña               21
#>  2 meteogalicia 14000      Coruña-Dique             A Coruña                5
#>  3 meteogalicia 10045      Mabegondo                A Coruña               94
#>  4 meteogalicia 14003      Punta Langosteira        A Coruña                5
#>  5 meteogalicia 10144      Arzúa                    A Coruña              362
#>  6 meteogalicia 19005      Guísamo                  A Coruña              175
#>  7 meteogalicia 19012      Cespón                   A Coruña               59
#>  8 meteogalicia 10095      Sergude                  A Coruña              231
#>  9 meteogalicia 10800      Camariñas                A Coruña                5
#> 10 meteogalicia 19001      Rus                      A Coruña              134
#> # … with 144 more rows, and 1 more variable: geometry <POINT [°]>
```

Returned objects are spatial objects (thanks to the
[`sf`](https://r-spatial.github.io/sf/) R package), so we can plot the
results directly.

``` r
library(sf)
#> Linking to GEOS 3.9.1, GDAL 3.3.1, PROJ 8.0.1
mg_options <- meteogalicia_options(resolution = 'daily', start_date = as.Date('2021-04-25'))
plot(get_meteo_from('meteogalicia', mg_options))
#> A información divulgada a través deste servidor ofrécese gratuitamente aos cidadáns para que poida ser 
#> utilizada libremente por eles, co único compromiso de mencionar expresamente a MeteoGalicia e á 
#> Consellería de Medio Ambiente, Territorio e Vivenda da Xunta de Galicia como fonte da mesma cada vez 
#> que as utilice para os usos distintos do particular e privado.
#> https://www.meteogalicia.gal/web/informacion/notaIndex.action
#> Warning: plotting the first 9 out of 16 attributes; use max.plot = 16 to plot
#> all
```

<img src="man/figures/README-plot_stations-1.png" width="100%" />

``` r
plot(get_stations_info_from('meteogalicia', mg_options))
```

<img src="man/figures/README-plot_stations-2.png" width="100%" />
