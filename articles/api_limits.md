# API limits and loops

``` r
library(meteospain)
library(sf)
#> Linking to GEOS 3.12.1, GDAL 3.8.4, PROJ 9.4.0; sf_use_s2() is TRUE
```

The following APIs impose a period limit in the data retrieved, not
allowing querying more than the predetermined period in each API.

## AEMET API

AEMET API limit the daily data download to 15 days, and the monthly and
yearly data to 36 months:

``` r
# aemet api has a limit for 15 days in daily:
get_meteo_from(
  'aemet',
  aemet_options(
    api_key = keyring::key_get('aemet'),
    resolution = 'daily',
    start_date = as.Date('1990-01-01'),
    end_date = as.Date('1990-12-31')
  )
)
#> Error in `.create_aemet_request()`:
#> ✖ 404
#> ℹ El rango de fechas no puede ser superior a 15 dias

# and monthly and yearly data to 36 months
get_meteo_from(
  'aemet',
  aemet_options(
    api_key = keyring::key_get('aemet'),
    resolution = 'yearly',
    start_date = as.Date('2005-01-01'),
    end_date = as.Date('2020-12-31'),
    stations = "0149X"
  )
)
#> Error in `.create_aemet_request()`:
#> ✖ 404
#> ℹ El rango de las fechas no puede ser superior a 36 mesess
```

This means that with one call to `get_meteo_from` to the AEMET service,
one can only download 15 days of data, (or 36 months in monthly and
yearly data).  
If the period needed is bigger than that, one option is performing all
the calls necessary and join the results:

``` r
res_1990_jan_1 <- get_meteo_from(
  'aemet',
  aemet_options(
    api_key = keyring::key_get('aemet'),
    resolution = 'daily',
    start_date = as.Date('1990-01-01'),
    end_date = as.Date('1990-01-15')
  )
)
#> ℹ © AEMET. Autorizado el uso de la información y su reproducción citando a
#>   AEMET como autora de la misma.
#> https://www.aemet.es/es/nota_legal

res_1990_jan_2 <- get_meteo_from(
  'aemet',
  aemet_options(
    api_key = keyring::key_get('aemet'),
    resolution = 'daily',
    start_date = as.Date('1990-01-16'),
    end_date = as.Date('1990-01-31')
  )
)
#> ℹ © AEMET. Autorizado el uso de la información y su reproducción citando a
#>   AEMET como autora de la misma.
#> https://www.aemet.es/es/nota_legal

res_1990_jan <- rbind(res_1990_jan_1, res_1990_jan_2)
res_1990_jan
#> Simple feature collection with 5066 features and 19 fields
#> Geometry type: POINT
#> Dimension:     XY
#> Bounding box:  xmin: -18.115 ymin: 27.72528 xmax: 4.215556 ymax: 43.65111
#> Geodetic CRS:  WGS 84
#> # A tibble: 5,066 × 20
#>    timestamp           service station_id station_name station_province altitude
#>  * <dttm>              <chr>   <chr>      <chr>        <chr>                 [m]
#>  1 1990-01-01 00:00:00 aemet   0002I      "VANDELLÒS … TARRAGONA              32
#>  2 1990-01-01 00:00:00 aemet   0016A      "REUS AEROP… TARRAGONA              71
#>  3 1990-01-01 00:00:00 aemet   0016B      "REUS (CENT… TARRAGONA             118
#>  4 1990-01-01 00:00:00 aemet   0076       "BARCELONA … BARCELONA               4
#>  5 1990-01-01 00:00:00 aemet   0149D      "MANRESA (L… BARCELONA             291
#>  6 1990-01-01 00:00:00 aemet   0158O      "MONTSERRAT" BARCELONA             738
#>  7 1990-01-01 00:00:00 aemet   0200E      "BARCELONA,… BARCELONA             408
#>  8 1990-01-01 00:00:00 aemet   0229I      "SABADELL A… BARCELONA             146
#>  9 1990-01-01 00:00:00 aemet   0294B      "LA BISBAL … GIRONA                 51
#> 10 1990-01-01 00:00:00 aemet   0321       "CAMPDEVANO… GIRONA                731
#> # ℹ 5,056 more rows
#> # ℹ 14 more variables: mean_temperature [°C], min_temperature [°C],
#> #   max_temperature [°C], mean_relative_humidity [%],
#> #   min_relative_humidity [%], max_relative_humidity [%],
#> #   precipitation [L/m^2], wind_direction [°], mean_wind_speed [m/s],
#> #   max_wind_speed [m/s], insolation [h], max_atmospheric_pressure [hPa],
#> #   min_atmospheric_pressure [hPa], geometry <POINT [°]>
```

While for short periods this can be easily done, when needing long
periods (years, decades), this can be tedious and prone to error (or at
least involves a lot of *copy&paste* and generate longer scripts).  
To avoid this, we can use loops, both in a tidyverse way
([`purrr::map`](https://purrr.tidyverse.org/reference/map.html)) or in a
more classic approach (`for`). For both ways, the first thing to do is
create the vectors of dates to retrieve:

``` r
# First, we prepare the date vectors, with the start and end dates.
start_dates <- seq(as.Date('1990-01-01'), as.Date('1990-07-01'), '15 days')
end_dates <- seq(as.Date('1990-01-15'), as.Date('1990-07-15'), '15 days')

# Both vectors must have the same length
length(start_dates) == length(end_dates)
#> [1] TRUE

# lets see them
data.frame(start_dates, end_dates)
#>    start_dates  end_dates
#> 1   1990-01-01 1990-01-15
#> 2   1990-01-16 1990-01-30
#> 3   1990-01-31 1990-02-14
#> 4   1990-02-15 1990-03-01
#> 5   1990-03-02 1990-03-16
#> 6   1990-03-17 1990-03-31
#> 7   1990-04-01 1990-04-15
#> 8   1990-04-16 1990-04-30
#> 9   1990-05-01 1990-05-15
#> 10  1990-05-16 1990-05-30
#> 11  1990-05-31 1990-06-14
#> 12  1990-06-15 1990-06-29
#> 13  1990-06-30 1990-07-14
```

### tidyverse loop

We are gonna use
[`purrr::map2`](https://purrr.tidyverse.org/reference/map2.html), to
iterate both date vectors at the same time and return a data frame with
all the results directly:

``` r
# tidyverse map
res_tidyverse <-
  purrr::map2(
    .x = start_dates, .y = end_dates,
    .f = function(start_date, end_date) {
      res <- get_meteo_from(
        'aemet',
        aemet_options(
          api_key = keyring::key_get('aemet'),
          resolution = 'daily',
          start_date = start_date,
          end_date = end_date
        )
      )
      return(res)
    }
  ) |>
  purrr::list_rbind()
#> ℹ © AEMET. Autorizado el uso de la información y su reproducción citando a
#>   AEMET como autora de la misma.
#> https://www.aemet.es/es/nota_legal
#> ℹ © AEMET. Autorizado el uso de la información y su reproducción citando a
#>   AEMET como autora de la misma.
#> https://www.aemet.es/es/nota_legal
#> ℹ © AEMET. Autorizado el uso de la información y su reproducción citando a
#>   AEMET como autora de la misma.
#> https://www.aemet.es/es/nota_legal
#> ℹ © AEMET. Autorizado el uso de la información y su reproducción citando a
#>   AEMET como autora de la misma.
#> https://www.aemet.es/es/nota_legal
#> ℹ © AEMET. Autorizado el uso de la información y su reproducción citando a
#>   AEMET como autora de la misma.
#> https://www.aemet.es/es/nota_legal
#> ℹ © AEMET. Autorizado el uso de la información y su reproducción citando a
#>   AEMET como autora de la misma.
#> https://www.aemet.es/es/nota_legal
#> Waiting 61s for retry backoff ■                               
#> 
#> Waiting 61s for retry backoff ■■■                             
#> 
#> Waiting 61s for retry backoff ■■■■                            
#> 
#> Waiting 61s for retry backoff ■■■■■■                          
#> 
#> Waiting 61s for retry backoff ■■■■■■■                         
#> 
#> Waiting 61s for retry backoff ■■■■■■■■■                       
#> 
#> Waiting 61s for retry backoff ■■■■■■■■■■                      
#> 
#> Waiting 61s for retry backoff ■■■■■■■■■■■                     
#> 
#> Waiting 61s for retry backoff ■■■■■■■■■■■■■                   
#> 
#> Waiting 61s for retry backoff ■■■■■■■■■■■■■■                  
#> 
#> Waiting 61s for retry backoff ■■■■■■■■■■■■■■■■                
#> 
#> Waiting 61s for retry backoff ■■■■■■■■■■■■■■■■■               
#> 
#> Waiting 61s for retry backoff ■■■■■■■■■■■■■■■■■■■             
#> 
#> Waiting 61s for retry backoff ■■■■■■■■■■■■■■■■■■■■            
#> 
#> Waiting 61s for retry backoff ■■■■■■■■■■■■■■■■■■■■■■          
#> 
#> Waiting 61s for retry backoff ■■■■■■■■■■■■■■■■■■■■■■■         
#> 
#> Waiting 61s for retry backoff ■■■■■■■■■■■■■■■■■■■■■■■■■       
#> 
#> Waiting 61s for retry backoff ■■■■■■■■■■■■■■■■■■■■■■■■■■      
#> 
#> Waiting 61s for retry backoff ■■■■■■■■■■■■■■■■■■■■■■■■■■■■    
#> 
#> Waiting 61s for retry backoff ■■■■■■■■■■■■■■■■■■■■■■■■■■■■■   
#> 
#> Waiting 61s for retry backoff ■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■ 
#> 
#> Waiting 61s for retry backoff ■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■ 
#> 
#> Waiting 61s for retry backoff ■■                              
#> 
#> Waiting 61s for retry backoff ■■■                             
#> 
#> Waiting 61s for retry backoff ■■■■■                           
#> 
#> Waiting 61s for retry backoff ■■■■■■                          
#> 
#> Waiting 61s for retry backoff ■■■■■■■■                        
#> 
#> Waiting 61s for retry backoff ■■■■■■■■■                       
#> 
#> Waiting 61s for retry backoff ■■■■■■■■■■■                     
#> 
#> Waiting 61s for retry backoff ■■■■■■■■■■■■                    
#> 
#> Waiting 61s for retry backoff ■■■■■■■■■■■■■■                  
#> 
#> Waiting 61s for retry backoff ■■■■■■■■■■■■■■■                 
#> 
#> Waiting 61s for retry backoff ■■■■■■■■■■■■■■■■■               
#> 
#> Waiting 61s for retry backoff ■■■■■■■■■■■■■■■■■■              
#> 
#> Waiting 61s for retry backoff ■■■■■■■■■■■■■■■■■■■■            
#> 
#> Waiting 61s for retry backoff ■■■■■■■■■■■■■■■■■■■■■           
#> 
#> Waiting 61s for retry backoff ■■■■■■■■■■■■■■■■■■■■■■■         
#> 
#> Waiting 61s for retry backoff ■■■■■■■■■■■■■■■■■■■■■■■■        
#> 
#> Waiting 61s for retry backoff ■■■■■■■■■■■■■■■■■■■■■■■■■       
#> 
#> Waiting 61s for retry backoff ■■■■■■■■■■■■■■■■■■■■■■■■■■■     
#> 
#> Waiting 61s for retry backoff ■■■■■■■■■■■■■■■■■■■■■■■■■■■■    
#> 
#> Waiting 61s for retry backoff ■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■  
#> 
#> Waiting 61s for retry backoff ■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■ 
#> 
#> ℹ © AEMET. Autorizado el uso de la información y su reproducción citando a
#>   AEMET como autora de la misma.
#> https://www.aemet.es/es/nota_legal
#> ℹ © AEMET. Autorizado el uso de la información y su reproducción citando a
#>   AEMET como autora de la misma.
#> https://www.aemet.es/es/nota_legal
#> ℹ © AEMET. Autorizado el uso de la información y su reproducción citando a
#>   AEMET como autora de la misma.
#> https://www.aemet.es/es/nota_legal
#> ℹ © AEMET. Autorizado el uso de la información y su reproducción citando a
#>   AEMET como autora de la misma.
#> https://www.aemet.es/es/nota_legal
#> ℹ © AEMET. Autorizado el uso de la información y su reproducción citando a
#>   AEMET como autora de la misma.
#> https://www.aemet.es/es/nota_legal
#> ℹ © AEMET. Autorizado el uso de la información y su reproducción citando a
#>   AEMET como autora de la misma.
#> https://www.aemet.es/es/nota_legal

head(res_tidyverse)
#>    timestamp service station_id          station_name station_province altitude
#> 1 1990-01-01   aemet      0002I           VANDELLÒS          TARRAGONA   32 [m]
#> 2 1990-01-01   aemet      0016A       REUS AEROPUERTO        TARRAGONA   71 [m]
#> 3 1990-01-01   aemet      0016B REUS (CENTRE LECTURA)        TARRAGONA  118 [m]
#> 4 1990-01-01   aemet       0076  BARCELONA AEROPUERTO        BARCELONA    4 [m]
#> 5 1990-01-01   aemet      0149D    MANRESA (LA CULLA)        BARCELONA  291 [m]
#> 6 1990-01-01   aemet      0158O            MONTSERRAT        BARCELONA  738 [m]
#>   mean_temperature min_temperature max_temperature mean_relative_humidity
#> 1        11.2 [°C]        8.8 [°C]       13.7 [°C]                 80 [%]
#> 2         9.0 [°C]        5.4 [°C]       12.6 [°C]                 89 [%]
#> 3        10.1 [°C]        8.4 [°C]       11.8 [°C]                 82 [%]
#> 4         9.2 [°C]        4.0 [°C]       14.4 [°C]                 74 [%]
#> 5         5.0 [°C]       -1.5 [°C]       11.6 [°C]                 69 [%]
#> 6         7.0 [°C]        3.0 [°C]       11.0 [°C]                 NA [%]
#>   min_relative_humidity max_relative_humidity precipitation wind_direction
#> 1                NA [%]                NA [%]     0 [L/m^2]         30 [°]
#> 2                NA [%]                NA [%]     0 [L/m^2]         99 [°]
#> 3                NA [%]                NA [%]     0 [L/m^2]         NA [°]
#> 4                NA [%]                NA [%]     0 [L/m^2]         NA [°]
#> 5                NA [%]                NA [%]     0 [L/m^2]         22 [°]
#> 6                NA [%]                NA [%]     0 [L/m^2]         NA [°]
#>   mean_wind_speed max_wind_speed insolation max_atmospheric_pressure
#> 1       1.7 [m/s]      6.4 [m/s]    0.1 [h]                 NA [hPa]
#> 2       0.6 [m/s]      5.0 [m/s]    0.1 [h]                 NA [hPa]
#> 3       0.6 [m/s]       NA [m/s]    0.2 [h]                 NA [hPa]
#> 4       3.6 [m/s]       NA [m/s]    6.7 [h]                 NA [hPa]
#> 5       0.8 [m/s]      3.9 [m/s]    7.8 [h]                 NA [hPa]
#> 6        NA [m/s]       NA [m/s]     NA [h]                 NA [hPa]
#>   min_atmospheric_pressure                   geometry
#> 1                 NA [hPa] POINT (0.8713889 40.95806)
#> 2                 NA [hPa]    POINT (1.163611 41.145)
#> 3                 NA [hPa]  POINT (1.108889 41.15417)
#> 4                 NA [hPa]      POINT (2.07 41.29278)
#> 5                 NA [hPa]     POINT (1.840278 41.72)
#> 6                 NA [hPa]  POINT (1.839167 41.59444)
```

### for loop

We use `base::for`, iterating by the index of the dates vectors:

``` r
# base for loop
res_for <- data.frame()

for (index in seq_along(start_dates)) {
  temp_res <- get_meteo_from(
    'aemet',
    aemet_options(
      api_key = keyring::key_get('aemet'),
      resolution = 'daily',
      start_date = start_dates[index],
      end_date = end_dates[index]
    )
  )
  
  res_for <- rbind(res_for, temp_res)
}

head(res_for)
#> Simple feature collection with 6 features and 19 fields
#> Geometry type: POINT
#> Dimension:     XY
#> Bounding box:  xmin: 0.8713889 ymin: 40.95806 xmax: 2.07 ymax: 41.72
#> Geodetic CRS:  WGS 84
#> # A tibble: 6 × 20
#>   timestamp           service station_id station_name  station_province altitude
#>   <dttm>              <chr>   <chr>      <chr>         <chr>                 [m]
#> 1 1990-01-01 00:00:00 aemet   0002I      "VANDELLÒS  " TARRAGONA              32
#> 2 1990-01-01 00:00:00 aemet   0016A      "REUS AEROPU… TARRAGONA              71
#> 3 1990-01-01 00:00:00 aemet   0016B      "REUS (CENTR… TARRAGONA             118
#> 4 1990-01-01 00:00:00 aemet   0076       "BARCELONA A… BARCELONA               4
#> 5 1990-01-01 00:00:00 aemet   0149D      "MANRESA (LA… BARCELONA             291
#> 6 1990-01-01 00:00:00 aemet   0158O      "MONTSERRAT"  BARCELONA             738
#> # ℹ 14 more variables: mean_temperature [°C], min_temperature [°C],
#> #   max_temperature [°C], mean_relative_humidity [%],
#> #   min_relative_humidity [%], max_relative_humidity [%],
#> #   precipitation [L/m^2], wind_direction [°], mean_wind_speed [m/s],
#> #   max_wind_speed [m/s], insolation [h], max_atmospheric_pressure [hPa],
#> #   min_atmospheric_pressure [hPa], geometry <POINT [°]>
```

Both methods return identical results:

``` r
# both are identical
identical(res_tidyverse, res_for)
#> [1] FALSE
```

> In a loop, no matter if a
> [`purrr::map`](https://purrr.tidyverse.org/reference/map.html) or a
> `for` loop, each iteration will connect with the API, consuming
> connections from the user quota. Take this into consideration when
> creating loops for longer periods, as you can reach your API request
> limits for the day/month… (it depends on the service API).

## MeteoCat API

When using MeteoCat in `daily`, `monthly` and `yearly` there are
restrictions on the period that can be accessed.

### `daily`

`daily` always returns the whole month the date selected is in, i.e. for
`start_date = as.Date('2020-04-10')` it will return all days in April,
2020:

``` r
api_options <- meteocat_options(
  'daily', start_date = as.Date('2020-04-10'),
  api_key = keyring::key_get('meteocat')
)
april_2020 <- get_meteo_from('meteocat', api_options)
#> iterating ■■                                 4% | ETA: 28s
#> iterating ■■■■                              11% | ETA: 22s
#> iterating ■■■■■■■                           19% | ETA: 23s
#> iterating ■■■■■■■■■■                        30% | ETA: 21s
#> iterating ■■■■■■■■■■■■■                     41% | ETA: 16s
#> iterating ■■■■■■■■■■■■■■■■■                 52% | ETA: 13s
#> iterating ■■■■■■■■■■■■■■■■■■■■■■            70% | ETA:  7s
#> iterating ■■■■■■■■■■■■■■■■■■■■■■■■■■■       85% | ETA:  3s
#> iterating ■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■  100% | ETA:  0s
#> ℹ Data provided by meteo.cat © Servei Meteorològic de Catalunya
#> https://www.meteo.cat/wpweb/avis-legal/#info
unique(april_2020$timestamp)
#>  [1] "2020-04-01 UTC" "2020-04-02 UTC" "2020-04-03 UTC" "2020-04-04 UTC"
#>  [5] "2020-04-05 UTC" "2020-04-06 UTC" "2020-04-07 UTC" "2020-04-08 UTC"
#>  [9] "2020-04-09 UTC" "2020-04-10 UTC" "2020-04-11 UTC" "2020-04-12 UTC"
#> [13] "2020-04-13 UTC" "2020-04-14 UTC" "2020-04-15 UTC" "2020-04-16 UTC"
#> [17] "2020-04-17 UTC" "2020-04-18 UTC" "2020-04-19 UTC" "2020-04-20 UTC"
#> [21] "2020-04-21 UTC" "2020-04-22 UTC" "2020-04-23 UTC" "2020-04-24 UTC"
#> [25] "2020-04-25 UTC" "2020-04-26 UTC" "2020-04-27 UTC" "2020-04-28 UTC"
#> [29] "2020-04-29 UTC" "2020-04-30 UTC"
```

This means that if we want more than one month, we need to use loops in
a similar way as described previously for AEMET:

``` r
start_dates <- seq(as.Date('2020-01-01'), as.Date('2020-04-01'), 'months')
# tidyverse map
meteocat_2020q1_tidyverse <-
  purrr::map(
    .x = start_dates,
    .f = function(start_date) {
      res <- get_meteo_from(
        'meteocat',
        meteocat_options(
          api_key = keyring::key_get('meteocat'),
          resolution = 'daily',
          start_date = start_date
        )
      )
      return(res)
    }
  ) |>
  purrr::list_rbind()
#> iterating ■■                                 4% | ETA: 27s
#> iterating ■■■                                7% | ETA: 31s
#> iterating ■■■■■■■                           19% | ETA: 27s
#> iterating ■■■■■■■■■■                        30% | ETA: 21s
#> iterating ■■■■■■■■■■■■■■                    44% | ETA: 14s
#> iterating ■■■■■■■■■■■■■■■■■■                56% | ETA: 12s
#> iterating ■■■■■■■■■■■■■■■■■■■■■             67% | ETA:  9s
#> iterating ■■■■■■■■■■■■■■■■■■■■■■■■■         81% | ETA:  5s
#> iterating ■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■  100% | ETA:  0s
#> ℹ Data provided by meteo.cat © Servei Meteorològic de Catalunya
#> https://www.meteo.cat/wpweb/avis-legal/#info
#> iterating ■■■                                7% | ETA: 28s
#> 
#> iterating ■■■■■                             15% | ETA: 26s
#> 
#> iterating ■■■■■■■■■■                        30% | ETA: 20s
#> 
#> iterating ■■■■■■■■■■■■                      37% | ETA: 18s
#> 
#> iterating ■■■■■■■■■■■■■■■                   48% | ETA: 15s
#> 
#> iterating ■■■■■■■■■■■■■■■■■■■■              63% | ETA: 10s
#> 
#> iterating ■■■■■■■■■■■■■■■■■■■■■■■■          78% | ETA:  6s
#> 
#> iterating ■■■■■■■■■■■■■■■■■■■■■■■■■■■■      89% | ETA:  3s
#> 
#> iterating ■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■  100% | ETA:  0s
#> 
#> ℹ Data provided by meteo.cat © Servei Meteorològic de Catalunya
#> https://www.meteo.cat/wpweb/avis-legal/#info
#> iterating ■■■                                7% | ETA: 31s
#> 
#> iterating ■■■■■■■                           19% | ETA: 23s
#> 
#> iterating ■■■■■■■■■■                        30% | ETA: 21s
#> 
#> iterating ■■■■■■■■■■■■■                     41% | ETA: 17s
#> 
#> iterating ■■■■■■■■■■■■■■■■■                 52% | ETA: 13s
#> 
#> iterating ■■■■■■■■■■■■■■■■■■■■■             67% | ETA:  9s
#> 
#> iterating ■■■■■■■■■■■■■■■■■■■■■■■■          78% | ETA:  6s
#> 
#> iterating ■■■■■■■■■■■■■■■■■■■■■■■■■■■■■     93% | ETA:  2s
#> 
#> iterating ■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■  100% | ETA:  0s
#> 
#> ℹ Data provided by meteo.cat © Servei Meteorològic de Catalunya
#> https://www.meteo.cat/wpweb/avis-legal/#info

head(meteocat_2020q1_tidyverse)
#>    timestamp  service station_id                station_name station_province
#> 1 2020-01-01 meteocat         C6         Castellnou de Seana           Lleida
#> 2 2020-01-01 meteocat         C7                     Tàrrega           Lleida
#> 3 2020-01-01 meteocat         C8                     Cervera           Lleida
#> 4 2020-01-01 meteocat         C9            Mas de Barberans        Tarragona
#> 5 2020-01-01 meteocat         CC                        Orís        Barcelona
#> 6 2020-01-01 meteocat         CD la Seu d'Urgell - Bellestar           Lleida
#>   altitude mean_temperature mean_temperature_classic min_temperature
#> 1  264 [m]         3.9 [°C]                 3.9 [°C]        3.2 [°C]
#> 2  427 [m]         2.5 [°C]                 2.6 [°C]        1.9 [°C]
#> 3  554 [m]         1.6 [°C]                 1.5 [°C]        0.6 [°C]
#> 4  240 [m]         3.4 [°C]                 4.1 [°C]        1.7 [°C]
#> 5  626 [m]         2.2 [°C]                 4.3 [°C]       -2.5 [°C]
#> 6  849 [m]         2.5 [°C]                 4.4 [°C]       -3.2 [°C]
#>   max_temperature thermal_amplitude mean_relative_humidity
#> 1        4.5 [°C]          1.3 [°C]                 93 [%]
#> 2        3.3 [°C]          1.4 [°C]                 97 [%]
#> 3        2.3 [°C]          1.7 [°C]                100 [%]
#> 4        6.5 [°C]          4.8 [°C]                 87 [%]
#> 5       11.1 [°C]         13.6 [°C]                 85 [%]
#> 6       11.9 [°C]         15.1 [°C]                 82 [%]
#>   min_relative_humidity max_relative_humidity precipitation precipitation_8h_8h
#> 1                87 [%]                97 [%]   0.0 [L/m^2]         0.0 [L/m^2]
#> 2                93 [%]               100 [%]   0.0 [L/m^2]         0.3 [L/m^2]
#> 3               100 [%]               100 [%]   0.1 [L/m^2]         0.3 [L/m^2]
#> 4                72 [%]                97 [%]   0.0 [L/m^2]         0.0 [L/m^2]
#> 5                53 [%]                96 [%]   0.0 [L/m^2]         0.0 [L/m^2]
#> 6                45 [%]                98 [%]   0.0 [L/m^2]         0.0 [L/m^2]
#>   max_precipitation_minute max_precipitation_hour max_precipitation_30m
#> 1              0.0 [L/m^2]            0.0 [L/m^2]           0.0 [L/m^2]
#> 2              0.0 [L/m^2]            0.0 [L/m^2]           0.0 [L/m^2]
#> 3              0.1 [L/m^2]            0.1 [L/m^2]           0.1 [L/m^2]
#> 4              0.0 [L/m^2]            0.0 [L/m^2]           0.0 [L/m^2]
#> 5              0.0 [L/m^2]            0.0 [L/m^2]           0.0 [L/m^2]
#> 6              0.0 [L/m^2]            0.0 [L/m^2]           0.0 [L/m^2]
#>   max_precipitation_10m mean_wind_direction max_wind_direction mean_wind_speed
#> 1            NA [L/m^2]              NA [°]             NA [°]        NA [m/s]
#> 2            NA [L/m^2]              NA [°]             NA [°]        NA [m/s]
#> 3            NA [L/m^2]              NA [°]             NA [°]        NA [m/s]
#> 4            NA [L/m^2]              NA [°]             NA [°]        NA [m/s]
#> 5            NA [L/m^2]              NA [°]             NA [°]        NA [m/s]
#> 6            NA [L/m^2]              NA [°]             NA [°]        NA [m/s]
#>   max_wind_speed global_solar_radiation mean_atmospheric_pressure
#> 1       NA [m/s]           1.6 [MJ/m^2]              1001.7 [hPa]
#> 2       NA [m/s]           1.4 [MJ/m^2]               981.6 [hPa]
#> 3       NA [m/s]           1.6 [MJ/m^2]               965.9 [hPa]
#> 4       NA [m/s]           4.1 [MJ/m^2]              1003.2 [hPa]
#> 5       NA [m/s]           8.1 [MJ/m^2]               956.6 [hPa]
#> 6       NA [m/s]           8.2 [MJ/m^2]               931.5 [hPa]
#>   max_atmospheric_pressure min_atmospheric_pressure mean_snow_cover
#> 1             1003.3 [hPa]             1000.7 [hPa]         NA [cm]
#> 2              983.1 [hPa]              980.7 [hPa]         NA [cm]
#> 3              967.3 [hPa]              965.0 [hPa]         NA [cm]
#> 4             1004.9 [hPa]             1002.1 [hPa]         NA [cm]
#> 5              957.9 [hPa]              955.5 [hPa]         NA [cm]
#> 6              933.1 [hPa]              929.7 [hPa]         NA [cm]
#>   max_snow_cover new_snow_cover min_snow_cover reference_evapotranspiration
#> 1        NA [cm]        NA [cm]        NA [cm]                 0.22 [L/m^2]
#> 2        NA [cm]        NA [cm]        NA [cm]                 0.18 [L/m^2]
#> 3        NA [cm]        NA [cm]        NA [cm]                 0.16 [L/m^2]
#> 4        NA [cm]        NA [cm]        NA [cm]                 0.48 [L/m^2]
#> 5        NA [cm]        NA [cm]        NA [cm]                 0.75 [L/m^2]
#> 6        NA [cm]        NA [cm]        NA [cm]                 0.83 [L/m^2]
#>                   geometry
#> 1  POINT (0.95172 41.6566)
#> 2 POINT (1.16234 41.66695)
#> 3 POINT (1.29609 41.67555)
#> 4 POINT (0.39988 40.71825)
#> 5 POINT (2.20862 42.07398)
#> 6 POINT (1.43277 42.37083)

# base for loop
meteocat_2020q1_for <- data.frame()

for (index in seq_along(start_dates)) {
  temp_res <- get_meteo_from(
    'meteocat',
    meteocat_options(
      api_key = keyring::key_get('meteocat'),
      resolution = 'daily',
      start_date = start_dates[index]
    )
  )
  
  meteocat_2020q1_for <- rbind(meteocat_2020q1_for, temp_res)
}

head(meteocat_2020q1_for)
#> Simple feature collection with 6 features and 33 fields
#> Geometry type: POINT
#> Dimension:     XY
#> Bounding box:  xmin: 0.39988 ymin: 40.71825 xmax: 2.20862 ymax: 42.37083
#> Geodetic CRS:  WGS 84
#> # A tibble: 6 × 34
#>   timestamp           service  station_id station_name station_province altitude
#>   <dttm>              <chr>    <chr>      <chr>        <chr>                 [m]
#> 1 2020-01-01 00:00:00 meteocat C6         Castellnou … Lleida                264
#> 2 2020-01-01 00:00:00 meteocat C7         Tàrrega      Lleida                427
#> 3 2020-01-01 00:00:00 meteocat C8         Cervera      Lleida                554
#> 4 2020-01-01 00:00:00 meteocat C9         Mas de Barb… Tarragona             240
#> 5 2020-01-01 00:00:00 meteocat CC         Orís         Barcelona             626
#> 6 2020-01-01 00:00:00 meteocat CD         la Seu d'Ur… Lleida                849
#> # ℹ 28 more variables: mean_temperature [°C], mean_temperature_classic [°C],
#> #   min_temperature [°C], max_temperature [°C], thermal_amplitude [°C],
#> #   mean_relative_humidity [%], min_relative_humidity [%],
#> #   max_relative_humidity [%], precipitation [L/m^2],
#> #   precipitation_8h_8h [L/m^2], max_precipitation_minute [L/m^2],
#> #   max_precipitation_hour [L/m^2], max_precipitation_30m [L/m^2],
#> #   max_precipitation_10m [L/m^2], mean_wind_direction [°], …

# both are identical
identical(meteocat_2020q1_tidyverse, meteocat_2020q1_for)
#> [1] FALSE
```

### `monthly`

`monthly` always returns the whole year the date selected is in,
i.e. for `start_date = as.Date('2020-04-10')` it will return all months
in 2020:

``` r
api_options <- meteocat_options(
  'monthly', start_date = as.Date('2020-04-10'),
  api_key = keyring::key_get('meteocat')
)
year_2020 <- get_meteo_from('meteocat', api_options)
#> iterating ■■■                                5% | ETA: 33s
#> iterating ■■■                                8% | ETA: 32s
#> iterating ■■■■■■                            15% | ETA: 29s
#> iterating ■■■■■■■■■                         26% | ETA: 26s
#> iterating ■■■■■■■■■■■■                      36% | ETA: 22s
#> iterating ■■■■■■■■■■■■■■                    44% | ETA: 19s
#> iterating ■■■■■■■■■■■■■■■■■■                56% | ETA: 14s
#> iterating ■■■■■■■■■■■■■■■■■■■■              64% | ETA: 11s
#> iterating ■■■■■■■■■■■■■■■■■■■■■■■           74% | ETA:  8s
#> iterating ■■■■■■■■■■■■■■■■■■■■■■■■■■        85% | ETA:  5s
#> iterating ■■■■■■■■■■■■■■■■■■■■■■■■■■■■■     95% | ETA:  2s
#> iterating ■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■  100% | ETA:  0s
#> ℹ Data provided by meteo.cat © Servei Meteorològic de Catalunya
#> https://www.meteo.cat/wpweb/avis-legal/#info
unique(year_2020$timestamp)
#>  [1] "2020-01-01 UTC" "2020-02-01 UTC" "2020-03-01 UTC" "2020-04-01 UTC"
#>  [5] "2020-05-01 UTC" "2020-06-01 UTC" "2020-07-01 UTC" "2020-08-01 UTC"
#>  [9] "2020-09-01 UTC" "2020-10-01 UTC" "2020-11-01 UTC" "2020-12-01 UTC"
```

Which means that if we need more than one year of monthly data, we need
to use loops again:

``` r
start_dates <- seq(as.Date('2019-01-01'), as.Date('2020-01-01'), 'years')
# tidyverse map
meteocat_2019_20_tidyverse <-
  purrr::map(
    .x = start_dates,
    .f = function(start_date) {
      res <- get_meteo_from(
        'meteocat',
        meteocat_options(
          api_key = keyring::key_get('meteocat'),
          resolution = 'monthly',
          start_date = start_date
        )
      )
      return(res)
    }
  ) |>
  purrr::list_rbind()
#> iterating ■■■                                5% | ETA: 33s
#> iterating ■■■■■                             13% | ETA: 30s
#> iterating ■■■■■■■                           21% | ETA: 28s
#> iterating ■■■■■■■■■■                        31% | ETA: 24s
#> iterating ■■■■■■■■■■■■■                     41% | ETA: 20s
#> iterating ■■■■■■■■■■■■■■■■                  51% | ETA: 16s
#> iterating ■■■■■■■■■■■■■■■■■■■               59% | ETA: 14s
#> iterating ■■■■■■■■■■■■■■■■■■■■■             67% | ETA: 11s
#> iterating ■■■■■■■■■■■■■■■■■■■■■■■■■         79% | ETA:  7s
#> iterating ■■■■■■■■■■■■■■■■■■■■■■■■■■■■      90% | ETA:  3s
#> iterating ■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■  100% | ETA:  0s
#> ℹ Data provided by meteo.cat © Servei Meteorològic de Catalunya
#> https://www.meteo.cat/wpweb/avis-legal/#info

head(meteocat_2019_20_tidyverse)
#>    timestamp  service station_id                station_name station_province
#> 1 2019-01-01 meteocat         C6         Castellnou de Seana           Lleida
#> 2 2019-01-01 meteocat         C7                     Tàrrega           Lleida
#> 3 2019-01-01 meteocat         C8                     Cervera           Lleida
#> 4 2019-01-01 meteocat         C9            Mas de Barberans        Tarragona
#> 5 2019-01-01 meteocat         CC                        Orís        Barcelona
#> 6 2019-01-01 meteocat         CD la Seu d'Urgell - Bellestar           Lleida
#>   altitude mean_temperature mean_temperature_classic min_temperature_absolute
#> 1  264 [m]         2.9 [°C]                 3.3 [°C]                -7.0 [°C]
#> 2  427 [m]         2.9 [°C]                 3.5 [°C]                -5.0 [°C]
#> 3  554 [m]         2.5 [°C]                 2.9 [°C]                -5.6 [°C]
#> 4  240 [m]         9.4 [°C]                 9.6 [°C]                 0.2 [°C]
#> 5  626 [m]         2.3 [°C]                 3.6 [°C]                -8.3 [°C]
#> 6  849 [m]         2.9 [°C]                 3.8 [°C]                -7.1 [°C]
#>   min_temperature_mean max_temperature_absolute max_temperature_mean
#> 1            -1.8 [°C]                17.9 [°C]             8.5 [°C]
#> 2            -0.5 [°C]                15.9 [°C]             7.4 [°C]
#> 3            -0.7 [°C]                14.0 [°C]             6.5 [°C]
#> 4             5.1 [°C]                18.0 [°C]            14.0 [°C]
#> 5            -2.7 [°C]                15.7 [°C]             9.9 [°C]
#> 6            -3.0 [°C]                17.9 [°C]            10.7 [°C]
#>   max_thermal_amplitude mean_thermal_amplitude extreme_thermal_amplitude
#> 1             21.7 [°C]              10.3 [°C]                 24.9 [°C]
#> 2             17.9 [°C]               7.8 [°C]                 20.9 [°C]
#> 3             16.2 [°C]               7.2 [°C]                 19.6 [°C]
#> 4             16.0 [°C]               8.9 [°C]                 17.8 [°C]
#> 5             18.5 [°C]              12.6 [°C]                 24.0 [°C]
#> 6             20.6 [°C]              13.7 [°C]                 25.0 [°C]
#>   mean_relative_humidity min_relative_humidity_absolute
#> 1                 84 [%]                         23 [%]
#> 2                 85 [%]                         28 [%]
#> 3                 85 [%]                         27 [%]
#> 4                 55 [%]                         17 [%]
#> 5                 73 [%]                          8 [%]
#> 6                 56 [%]                          4 [%]
#>   min_relative_humidity_mean max_relative_humidity_absolute
#> 1                     64 [%]                        100 [%]
#> 2                     68 [%]                        100 [%]
#> 3                     70 [%]                        100 [%]
#> 4                     38 [%]                         97 [%]
#> 5                     43 [%]                         96 [%]
#> 6                     28 [%]                         98 [%]
#>   max_relative_humidity_mean precipitation precipitation_8h_8h
#> 1                     97 [%]   8.4 [L/m^2]        15.1 [L/m^2]
#> 2                     96 [%]  14.1 [L/m^2]        19.5 [L/m^2]
#> 3                     95 [%]  10.4 [L/m^2]        15.1 [L/m^2]
#> 4                     76 [%]   4.0 [L/m^2]         5.4 [L/m^2]
#> 5                     90 [%]   8.0 [L/m^2]         9.9 [L/m^2]
#> 6                     78 [%]  34.9 [L/m^2]        40.5 [L/m^2]
#>   max_precipitation_minute max_precipitation_24h max_precipitation_24h_8h_8h
#> 1              0.1 [L/m^2]           3.3 [L/m^2]                 7.3 [L/m^2]
#> 2              0.1 [L/m^2]           6.1 [L/m^2]                 6.1 [L/m^2]
#> 3              0.1 [L/m^2]           5.0 [L/m^2]                 5.1 [L/m^2]
#> 4              0.1 [L/m^2]           1.3 [L/m^2]                 1.4 [L/m^2]
#> 5              0.2 [L/m^2]           3.6 [L/m^2]                 3.6 [L/m^2]
#> 6              0.2 [L/m^2]          16.6 [L/m^2]                15.7 [L/m^2]
#>   max_precipitation_hour max_precipitation_30m max_precipitation_10m
#> 1            1.0 [L/m^2]           0.8 [L/m^2]            NA [L/m^2]
#> 2            1.5 [L/m^2]           0.9 [L/m^2]            NA [L/m^2]
#> 3            1.8 [L/m^2]           1.1 [L/m^2]            NA [L/m^2]
#> 4            0.6 [L/m^2]           0.6 [L/m^2]            NA [L/m^2]
#> 5            2.8 [L/m^2]           1.5 [L/m^2]            NA [L/m^2]
#> 6            3.1 [L/m^2]           1.8 [L/m^2]            NA [L/m^2]
#>   mean_wind_direction max_wind_direction mean_wind_speed max_wind_speed
#> 1              NA [°]             NA [°]        NA [m/s]       NA [m/s]
#> 2              NA [°]             NA [°]        NA [m/s]       NA [m/s]
#> 3              NA [°]             NA [°]        NA [m/s]       NA [m/s]
#> 4              NA [°]             NA [°]        NA [m/s]       NA [m/s]
#> 5              NA [°]             NA [°]        NA [m/s]       NA [m/s]
#> 6              NA [°]             NA [°]        NA [m/s]       NA [m/s]
#>   max_wind_speed_mean max_atmospheric_pressure_absolute
#> 1            NA [m/s]                      1002.1 [hPa]
#> 2            NA [m/s]                       982.0 [hPa]
#> 3            NA [m/s]                       966.2 [hPa]
#> 4            NA [m/s]                      1004.0 [hPa]
#> 5            NA [m/s]                       957.7 [hPa]
#> 6            NA [m/s]                       932.2 [hPa]
#>   min_atmospheric_pressure_absolute global_solar_radiation
#> 1                       963.8 [hPa]           6.4 [MJ/m^2]
#> 2                       945.4 [hPa]           6.4 [MJ/m^2]
#> 3                       930.8 [hPa]           6.7 [MJ/m^2]
#> 4                       966.9 [hPa]           9.3 [MJ/m^2]
#> 5                       922.3 [hPa]           8.0 [MJ/m^2]
#> 6                       897.9 [hPa]           8.4 [MJ/m^2]
#>   mean_atmospheric_pressure max_atmospheric_pressure_mean
#> 1               987.2 [hPa]                   990.1 [hPa]
#> 2               967.8 [hPa]                   970.6 [hPa]
#> 3               952.3 [hPa]                   955.1 [hPa]
#> 4               989.1 [hPa]                   991.9 [hPa]
#> 5               942.9 [hPa]                   945.8 [hPa]
#> 6               918.4 [hPa]                   921.2 [hPa]
#>   min_atmospheric_pressure_mean mean_snow_cover max_snow_cover new_snow_cover
#> 1                   984.4 [hPa]         NA [cm]        NA [cm]        NA [cm]
#> 2                   965.1 [hPa]         NA [cm]        NA [cm]        NA [cm]
#> 3                   949.8 [hPa]         NA [cm]        NA [cm]        NA [cm]
#> 4                   986.4 [hPa]         NA [cm]        NA [cm]        NA [cm]
#> 5                   940.4 [hPa]         NA [cm]        NA [cm]        NA [cm]
#> 6                   915.8 [hPa]         NA [cm]        NA [cm]        NA [cm]
#>                   geometry frost_days rain_days_0 rain_days_02
#> 1  POINT (0.95172 41.6566)     22 [d]       5 [d]        5 [d]
#> 2 POINT (1.16234 41.66695)     17 [d]      12 [d]        9 [d]
#> 3 POINT (1.29609 41.67555)     18 [d]       6 [d]        4 [d]
#> 4 POINT (0.39988 40.71825)      0 [d]       5 [d]        3 [d]
#> 5 POINT (2.20862 42.07398)     29 [d]       4 [d]        4 [d]
#> 6 POINT (1.43277 42.37083)     28 [d]       5 [d]        4 [d]

# base for loop
meteocat_2019_20_for <- data.frame()

for (index in seq_along(start_dates)) {
  temp_res <- get_meteo_from(
    'meteocat',
    meteocat_options(
      api_key = keyring::key_get('meteocat'),
      resolution = 'monthly',
      start_date = start_dates[index]
    )
  )
  
  meteocat_2019_20_for <- rbind(meteocat_2019_20_for, temp_res)
}
head(meteocat_2019_20_for)
#> Simple feature collection with 6 features and 45 fields
#> Geometry type: POINT
#> Dimension:     XY
#> Bounding box:  xmin: 0.39988 ymin: 40.71825 xmax: 2.20862 ymax: 42.37083
#> Geodetic CRS:  WGS 84
#> # A tibble: 6 × 46
#>   timestamp           service  station_id station_name station_province altitude
#>   <dttm>              <chr>    <chr>      <chr>        <chr>                 [m]
#> 1 2019-01-01 00:00:00 meteocat C6         Castellnou … Lleida                264
#> 2 2019-01-01 00:00:00 meteocat C7         Tàrrega      Lleida                427
#> 3 2019-01-01 00:00:00 meteocat C8         Cervera      Lleida                554
#> 4 2019-01-01 00:00:00 meteocat C9         Mas de Barb… Tarragona             240
#> 5 2019-01-01 00:00:00 meteocat CC         Orís         Barcelona             626
#> 6 2019-01-01 00:00:00 meteocat CD         la Seu d'Ur… Lleida                849
#> # ℹ 40 more variables: mean_temperature [°C], mean_temperature_classic [°C],
#> #   min_temperature_absolute [°C], min_temperature_mean [°C],
#> #   max_temperature_absolute [°C], max_temperature_mean [°C],
#> #   max_thermal_amplitude [°C], mean_thermal_amplitude [°C],
#> #   extreme_thermal_amplitude [°C], mean_relative_humidity [%],
#> #   min_relative_humidity_absolute [%], min_relative_humidity_mean [%],
#> #   max_relative_humidity_absolute [%], max_relative_humidity_mean [%], …

# both are identical
identical(meteocat_2019_20_tidyverse, meteocat_2019_20_for)
#> [1] FALSE
```

### `yearly`

`yearly` always returns all available years and `start_date` argument is
ignored, i.e. using `start_date = as.Date('2020-04-10')` will return all
years, independently of the date supplied:

``` r
api_options <- meteocat_options(
  'yearly', start_date = as.Date('2020-04-10'),
  api_key = keyring::key_get('meteocat')
)
all_years <- get_meteo_from('meteocat', api_options)
#> iterating ■■■                                5% | ETA: 30s
#> iterating ■■■■                              10% | ETA: 32s
#> iterating ■■■■■■■                           20% | ETA: 25s
#> iterating ■■■■■■■■■                         28% | ETA: 26s
#> iterating ■■■■■■■■■■■                       35% | ETA: 24s
#> iterating ■■■■■■■■■■■■■                     40% | ETA: 23s
#> iterating ■■■■■■■■■■■■■■■■                  50% | ETA: 19s
#> iterating ■■■■■■■■■■■■■■■■■■                57% | ETA: 16s
#> iterating ■■■■■■■■■■■■■■■■■■■■              62% | ETA: 15s
#> iterating ■■■■■■■■■■■■■■■■■■■■■■            70% | ETA: 12s
#> iterating ■■■■■■■■■■■■■■■■■■■■■■■■          78% | ETA:  9s
#> iterating ■■■■■■■■■■■■■■■■■■■■■■■■■■■       85% | ETA:  6s
#> iterating ■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■    98% | ETA:  1s
#> iterating ■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■  100% | ETA:  0s
#> ℹ Data provided by meteo.cat © Servei Meteorològic de Catalunya
#> https://www.meteo.cat/wpweb/avis-legal/#info
unique(all_years$timestamp)
#>  [1] "1989-01-01 UTC" "1990-01-01 UTC" "1991-01-01 UTC" "1992-01-01 UTC"
#>  [5] "1993-01-01 UTC" "1994-01-01 UTC" "1995-01-01 UTC" "1996-01-01 UTC"
#>  [9] "1997-01-01 UTC" "1998-01-01 UTC" "1999-01-01 UTC" "2000-01-01 UTC"
#> [13] "2001-01-01 UTC" "2002-01-01 UTC" "2003-01-01 UTC" "2004-01-01 UTC"
#> [17] "2005-01-01 UTC" "2006-01-01 UTC" "2007-01-01 UTC" "2008-01-01 UTC"
#> [21] "2009-01-01 UTC" "2010-01-01 UTC" "2011-01-01 UTC" "2012-01-01 UTC"
#> [25] "2013-01-01 UTC" "2014-01-01 UTC" "2015-01-01 UTC" "2016-01-01 UTC"
#> [29] "2017-01-01 UTC" "2018-01-01 UTC" "2019-01-01 UTC" "2020-01-01 UTC"
#> [33] "2021-01-01 UTC" "2022-01-01 UTC" "2023-01-01 UTC" "2024-01-01 UTC"
#> [37] "2025-01-01 UTC"
```

This means that with yearly we always get all the data available, so
there is no need of loops.
