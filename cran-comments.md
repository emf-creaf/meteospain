This version of `meteospain` adds needed updates for some API connections as
well as improves data returned by meteocat and aemet APIs.

## Test environments

* local R installation (Arch Linux), R 4.5.1
* windows-latest (on github actions), R release
* macOS-latest (on github actions), R release
* ubuntu-latest (on github actions), R release
* ubuntu-latest (on github actions), R devel
* ubuntu-latest (on github actions), R oldrel-1
* win-builder (devel)
* mac-builder (release)

## R CMD check results

* checking CRAN incoming feasibility ... NOTE

Possibly mis-spelled words in DESCRIPTION:
  AEMET
  APIs
  Meteoclimatic
  SMC
  
Words detected are Spanish meteorological services API names
and are not mis-spelled
 
## Reverse/Downstream dependencies

R CMD check was run with no fail for downstream dependencies:

* meteoland
