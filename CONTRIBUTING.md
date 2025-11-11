# Contributing to meteospain

This outlines how to propose a change to meteospain.

## Bigger changes

If you want to make a bigger change, it’s a good idea to first file an
issue and make sure someone from the team agrees that it’s needed. If
you’ve found a bug, please file an issue that illustrates the bug with a
minimal [reprex](https://www.tidyverse.org/help/#reprex) (this will also
help you write a unit test, if needed).

### Pull request process

- Fork the package and clone onto your computer. If you haven’t done
  this before, we recommend using
  `usethis::create_from_github("emf-creaf/meteospain", fork = TRUE)`.

- Install all development dependences with
  `devtools::install_dev_deps()`, and then make sure the package passes
  R CMD check by running `devtools::check()`. If R CMD check doesn’t
  pass cleanly, it’s a good idea to ask for help before continuing.

- For passing tests and building vignettes, you will need API keys for
  AEMET and MeteoCat (see
  [`?services_options`](https://emf-creaf.github.io/meteospain/reference/services_options.md)).
  A workaround to develop without those keys is setting the `NOT_CRAN`
  environment variable to `false` (`Sys.setenv(NOT_CRAN = 'false')`),
  but with this, most of the tests and examples will be not run when
  building, testing and checking.

- Create a Git branch for your pull request (PR). We recommend using
  `usethis::pr_init("brief-description-of-change")`.

- Make your changes, commit to git, and then create a PR by running
  `usethis::pr_push()`, and following the prompts in your browser. The
  title of your PR should briefly describe the change. The body of your
  PR should contain `Fixes #issue-number`.

- For user-facing changes, add a bullet to the top of `NEWS.md`
  (i.e. just below the first header). Follow the style described in
  <https://style.tidyverse.org/news.html>.

### Code style

- We use [roxygen2](https://cran.r-project.org/package=roxygen2), with
  [Markdown
  syntax](https://cran.r-project.org/web/packages/roxygen2/vignettes/rd-formatting.html),
  for documentation.

- We use [testthat](https://cran.r-project.org/package=testthat) for
  unit tests. Contributions with test cases included are easier to
  accept.

### Dependencies

Any interaction with a meteorological API must be done with `httr`
and/or `jsonlite` and/or `xml2`, as they are already dependencies of
`meteospain`. See DESCRIPTION file for a list of available dependencies.

## Service code guide

When adding a new service to `meteospain`, there are some conventions to
follow:

### Helpers

Each service has an R file associated, `[service_name]_helpers.R`. In
this file we will put all helpers needed to access the service API:

- `.create_[service]_path(api_options)`: to build the vector with the
  path, usually depending on the temporal resolution.

- `.create_[service]_query(api_options)`: some APIs need the parameters
  supplied as queries.

- `.check_status_[service](api_options)`: logic to check the response
  statuses (200, 429, 500…).

- `.get_info_[service](api_options)`: Access, transform and return the
  stations info and metadata.

- `.get_data_[service](api_options)`: Access, transform and return the
  data based on the api options provided (temporal resolution,
  stations…). This function will use the `.create_*` and
  `.check_status_[service]` helpers.

Data must be transformed to sf, adding the stations metadata. Numerical
data must be converted to units and variables names standardized among
all services.

### Options

Each service must have a dedicated function to create the API options,
`[service]_options`. This function will control which parameters are
needed:

- `resolution`: Temporal resolution for the data (hourly, daily…), used
  to build paths, queries…
- `start_date`: Starting date for the desired data, used to build paths,
  queries…. If the API only accepts one date (see MeteoCat for example),
  use this one.
- `end_date`: End date for the desired data, used to build paths,
  queries…. If the API only accepts one date, this argument is not
  necessary.
- `stations`: Character vector with stations IDs to use in paths or
  queries before retrieving the data or filters after.

> NOTE: When the API only accepts one station when querying by stations,
> but there is a path to obtain all stations, this one must be used and
> the desired stations filtered afterwards. This way we reduce the calls
> to the API, as we dont need to create a loop to return every station
> in `stations` argument. If no path exists for getting data from all
> stations, then a loop should be used.

- `api_key`: If the API needs a key, add this argument for the user to
  supply the key.

> NOTE: `meteospain` does not store or encrypt in any way the supplied
> key. Is the user responsability to manage their keys. We recommend the
> keyring package for this in all docs and functions help.

### Tests

`tests/testthat/test-concordance_between_services.R` adds tests for
joining data between services.

`tests/testthat/test-[service].R` adds tests for each service.

In `utils.R` there is a helper function for the main test battery
applied to each service: `main_test_battery()`. See examples of use in
the test files of services already implemented.
