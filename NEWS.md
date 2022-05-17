# meteospain (development version)

* Added safe version of httr::GET. Now we can check for connection before quering the API, and if the API is down or not reachable, the error is caught.
* Tests for aemet and meteocat use now env backend for keyring
* Fixed parsing of dates in meteoclimatic to make independent of locale
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
