This version of `meteospain` fixes changes in MeteoGalicia and RIA APIs. Also
introduces a new method to get variables metadata.

## Test environments

* local R installation (Arch Linux), R 4.5.2
* windows-latest (on github actions), R release
* macOS-latest (on github actions), R release
* ubuntu-latest (on github actions), R release
* ubuntu-latest (on github actions), R devel
* ubuntu-latest (on github actions), R oldrel-1
* win-builder (devel)
* mac-builder (release)

## R CMD check results

* checking CRAN incoming feasibility ... NOTE

  - Possibly mis-spelled words in DESCRIPTION:
      AEMET
      APIs
      Meteoclimatic
      SMC
  
Words detected are Spanish meteorological services API names
and are not mis-spelled

  - Found the following (possibly) invalid URLs:
      URL: https://opendata.aemet.es/centrodedescargas/inicio
        From: man/services_options.Rd
              inst/doc/aemet.html
        Status: Error
        Message: Failure when receiving data from the peer [opendata.aemet.es]:
          schannel: server closed abruptly (missing close_notify)

URL is correct, but sometimes fails

  - Found the following (possibly) invalid URLs:
      URL: https://www.juntadeandalucia.es/agriculturaypesca/ifapa/riaweb/web/
        From: inst/doc/ria.html
              README.md
        Status: Error
        Message: Timeout was reached [www.juntadeandalucia.es]:
          Operation timed out after 60006 milliseconds with 0 bytes received

URL is correct, but sometimes fails

## Reverse/Downstream dependencies

R CMD check was run with no fail for downstream dependencies:

* meteoland
