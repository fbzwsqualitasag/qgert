

## ---- Glue Replacement Values To Placeholders --------------------------------


#' @title Replace Placeholders in Template with Replacement Values
#'
#' @description
#' In a template text with placeholders, these placeholders are replaced with
#' values that are specified via the list of replacement values. As a result
#' the text is returned with the placeholders replaced by the values specified
#' in the list of replacement values.
#'
#' @details
#' Placeholders are words that are enclosed between an opening tag and an end tag.
#' These tags can be specified as arguments ps_ph_open_tag and ps_ph_end_tag.
#' The word between the tags corresponds to the name of the placeholder. This
#' name is also used as a name in the list of replacement values. The value
#' with which the placeholder is to be replaced is given as the list element
#' associated with the name of the placeholder.
#'
#'
#' @param ps_tmpl template text containing placeholders
#' @param pl_repl_value list with replacement values
#' @param ps_ph_open_tag open-tag for placeholder
#' @param ps_ph_end_tag end-tag for placeholder
#'
#' @return s_result where placeholders have been replaced with replacement values
string_replace <- function(ps_tmpl, pl_repl_value,
                           ps_ph_open_tag = "<ph>",
                           ps_ph_end_tag = "</ph>"){
  # get placeholder tags as names from pl_repl_value
  vec_ph_tag <- names(pl_repl_value)
  # initialise result
  s_result <- ps_tmpl
  for (p in vec_ph_tag){
    s_result <- stringr::str_replace(s_result, pattern = paste0(ps_ph_open_tag, p, ps_ph_end_tag, collapse = ""), replacement = pl_repl_value[[p]])
  }

  return(s_result)
}


## ---- Replacement Value Defaults ---------------------------------------------

#' Defaults For Generic Comparison Plot Report Template Replacement Values
#'
#' @description
#' The template for the comparison plot report contains a number of placeholders
#' which are to be replaced by values when the report is generated. This function
#' returns useful default values to be inserted into the template as a replacement
#' for the placeholders.
#'
#' @return list of comparison plot report replacement values
get_generic_comparison_plot_report_default_replacement_values <- function(){
  return(list(title                = "Generic Comparison Plot Report",
              author               = "Report Author",
              date                 = Sys.Date(),
              output_format        = "pdf_document",
              ps_current_plot_dir  = "Current Plot Directory",
              ps_previous_plot_dir = "Previous Plot Directory"))
}


## ---- Default List Extension ------------------------------------------------


#' @title Merge List To Default
#'
#' @description
#' Given two lists (pl_base and pl_default), the lists should be merged into a
#' result list (l_result) such that the result contains all entries of pl_base
#' and for the entries whose names are in pl_default, but are not in pl_base,
#' the entries of pl_default is included in l_result. This leads to a list (l_result)
#' which has the same names as pl_default, but for those names which are also
#' in pl_base, the values from pl_base overwrite the values of pl_default.
#'
#' @details
#' This merging procedure is used in replacement of placeholders in templates
#' where only parts of the placeholders are replaced with specified values and
#' the rest is replaced with assumed default values.
#'
#' @param pl_base list of base entries
#' @param pl_default list with default entries
#'
#' @return l_result list with merged entries of pl_base and pl_default
#'
#' @examples
#' \dontrun{
#' n <- 9
#' l2 <- lapply(1:n, function(x) x)
#' names(l2) <- LETTERS[1:9]
#' merge_list_to_default(pl_base = list(A = 10L, B = 20L), pl_default = l2)
#' }
merge_list_to_default <- function(pl_base, pl_default){
  l_result <- NULL
  # determine names of pl_base and pl_default
  vec_name_base <- names(pl_base)
  vec_name_default <- names(pl_default)
  # Make sure that result has the same names as pl_default.
  # When merging, the elements in pl_base have priority
  for (idx in seq_along(vec_name_default)){
    s_cur_name <- vec_name_default[idx]
    if (is.element(s_cur_name, vec_name_base)){
      l_result[[s_cur_name]] <- pl_base[[s_cur_name]]
    } else {
      l_result[[s_cur_name]] <- pl_default[[s_cur_name]]
    }
  }
  return(l_result)
}
