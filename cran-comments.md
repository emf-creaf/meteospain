This version of `meteospain` adds new functionality
to AEMET methods.

## Test environments

* local R installation (Arch Linux), R 4.2.3
* windows-latest (on github actions), R release
* macOS-latest (on github actions), R release
* ubuntu-latest (on github actions), R release
* ubuntu-latest (on github actions), R devel
* ubuntu-latest (on github actions), R oldrel-1
* win-builder (devel, oldrelease and release)
* debian-clang-devel (on rhub)

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
