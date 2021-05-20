# imports from other packages ---------------------------------------------------------------------------

#' @importFrom magrittr %>%
#' @export
magrittr::`%>%`

#' @importFrom rlang := .data
NULL


# crayon styles -----------------------------------------------------------------------------------------

copyright_style <- crayon::yellow$bold
legal_note_style <- crayon::blue$bold$underline


# swiss knives ------------------------------------------------------------------------------------------

.empty_string_to_null <- function(glue_string) {
  if (length(glue_string) < 1) {
    NULL
  } else {
    glue_string
  }
}

.create_missing_vars <- function(df, var_names) {

  missing_var_names <- var_names[which(!var_names %in% names(df))]

  for (missing_var in missing_var_names) {
    df <- dplyr::mutate(df, {{ missing_var }} := rlang::na_dbl)
  }

  return(df)

}

# test helpers ------------------------------------------------------------------------------------------

skip_if_no_auth <- function(service) {
  if (identical(Sys.getenv(service), "")) {
    testthat::skip(glue::glue("No authentication available for {service}"))
  } else {
    message(glue::glue("{service} key found, running tests"))
  }
}
