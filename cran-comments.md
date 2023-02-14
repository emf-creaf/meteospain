This version of `meteospain` fixes a bug in AEMET
stations coordinates.

## Test environments

* local R installation (Arch Linux), R 4.2.2
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
  AEMET (25:90)
  APIs (25:84)
  Meteoclimatic (26:3)
  SMC (25:97)
  
Words detected are Spanish meteorological services API names
and are not mis-spelled
 
## Reverse/Downstream dependencies

R CMD check was run with no fail for downstream dependencies:

* meteoland
