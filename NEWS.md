# meteospain 0.1.4

* Fixed bug in RIA coordinates (#20)

# meteospain 0.1.3

* meteocat API: new data limits, now daily data can be retrieved starting on 1989

# meteospain 0.1.2

* Added monthly and yearly temporal resolutions to AEMET service
* Removed dependencies:
  + Removed dependency (and exports) from magrittr. Substituted all magrittr pipes (`%>%`) by native
  pipes (`|>`)
  + Removed dependency from crayon. Using cli now.
* New dependencies
  + Added cli to manage communication with the user (messages, warnings and errors)
* Minor changes
  + Improved tests
  + AEMET API: return always the same variables (depending on resolution). If the variable doesn't
  exists for the station and date, is created with NA.
  + AEMET API: `insolation` variable added to returned AEMET current data
  + RIA API: improved messages
  + meteogalicia API: improved error managing
  + meteogalicia API: improved path creation
  + Code cleaning (removing old code, fixing typos, code style...)

# meteospain 0.1.1

* Fixed bug in AEMET coordinates (#18)
* Minimal versions of `dplyr` and `purrr` added (both `1.0.0`)
* Lambda functions to the new r base syntax (`\(x) {}`)

# meteospain 0.1.0

* Substitute `.data` calls by `"variable_name"` as recommended by tidyselect after deprecation of `.data`
* Fixed new meteogalicia API by @dataleteo (#13)

# meteospain 0.0.4

* Minor improvements in vignettes
* Added units to solar_radiation in RIA service
* Added curl as a dependency. Now we can check for connection before querying the API.
* Added safe versions of httr::GET and xml2::read_xml. If the API is down or not reachable, the error is caught.
* Tests for aemet and meteocat use now env backend for keyring
* Fixed parsing of dates in meteoclimatic to make it independent of the system's locale
* Fixed tidy error when retrieving MeteoCat data from 2008 to 2010 (#11)
* Limited dates in meteocat_options to dates available in the API (2008 or greater)
* Fixed lack of station_province in aemet stations info (#10)

# meteospain 0.0.3

* Package now comply with CRAN policy "Packages which use Internet resources should fail
gracefully with an informative message if the resource is not available or has changed"
* Fixed checks for debian-clang OS
* Memoization added for get_meteo_from and get_stations_info_from functions, to avoid excessive calls to APIs

# meteospain 0.0.2

* Fixed bug (#9) in managing 429 errors in meteocat and aemet
* Added RIA (Red de Información Agroclimática de Andalucía) service
* Better error for when MeteoGalicia stations info does not return all the columns needed

# meteospain 0.0.1

* Initial version of the package

# meteospain 0.0.0.9000

* Added a `NEWS.md` file to track changes to the package.
* Services added: AEMET, MeteoCat, MeteoGalicia, Meteoclimatic.
* Initial version of the package.
