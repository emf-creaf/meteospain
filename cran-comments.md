## Test environments
* local R installation (Arch Linux), R 4.1.1
* ubuntu 20.04 (on github actions), R 4.1.1
* windows-latest (on github actions), R 4.1.1
* macOS-latest (on github actions), R 4.1.1
* win-builder (devel, oldrelease and release)
* debian-clang-devel (on rhub)

## R CMD check results

* checking CRAN incoming feasibility ... NOTE
0 errors | 0 warnings | 1 note

## Resubmission
This is a resubmission. In this version I have:

* Fixed failing tests in debian-clang build

* Package now comply with the CRAN policy: 'Packages which use Internet resources should fail
gracefully with an informative message if the resource is not available or has changed (and not
give a check warning nor error).' which fixes ERRORs in the CRAN checks at
<https://cran.r-project.org/web/checks/check_results_meteospain.html>
