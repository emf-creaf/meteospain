# imports from other packages ---------------------------------------------------------------------------

#' @importFrom magrittr %>%
#' @export
magrittr::`%>%`


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
