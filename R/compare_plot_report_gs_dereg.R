###
###
###
###   Purpose:   Create a Comparison Plot Report for de-regressed values in GS
###   started:   2019-10-14 (pvr)
###
### ########################################################## ###


## -- Creator Function for dereg GS ----------------------------------------- ##

#' @title Comparison Plot Report Creator Function For De-regressed Values in GS
#'
#' @description
#' A comparison plot report containing all generated plots of a GE side-by-side
#' with the plots from the previous GE are constructed for de-regressed values
#' in GS.
#'
#' @param pn_cur_ge_label label of current genetic evaluation (GE)
#' @param pn_prev_ge_label label of previous GE
#' @param ps_cur_plot_root directory with plots of current evaluation
#' @param ps_prev_plot_root directory with plots from previous evaluation
#' @param ps_template template document for report
#' @param ps_breed create comparison plot report for just one breed
#' @param pl_plot_opts list of options specifying input for plot report creator
#' @param pb_debug flag whether debug output should be shown
#' @param plogger log4r logger object
#'
#' @examples
#' \dontrun{
#' create_ge_compare_plot_report_gs_dereg(pn_cur_ge_label  = 1908,
#'                                   pn_prev_ge_label = 1904,
#'                                   pb_debug = TRUE)
#' }
#'
#' @export create_ge_compare_plot_report_gs_dereg
create_ge_compare_plot_report_gs_dereg <- function(pn_cur_ge_label,
                                              pn_prev_ge_label,
                                              ps_cur_plot_root  = NULL,
                                              ps_prev_plot_root = NULL,
                                              ps_template       = system.file("templates", "compare_plots.Rmd.template", package = 'qgert'),
                                              ps_breed          = NULL,
                                              pl_plot_opts      = NULL,
                                              pb_debug          = FALSE,
                                              plogger           = NULL){
  # debugging message at the beginning
  if (pb_debug) {
    if (is.null(plogger)){
      lgr <- get_qgert_logger(ps_logfile = 'create_ge_compare_plot_report_gs_dereg.log', ps_level = 'INFO')
    } else {
      lgr <- plogger
    }
    qgert_log_info(plogger = lgr, ps_caller = 'create_ge_plot_report',
                   ps_msg = " Start of function create_ge_compare_plot_report_gs_dereg ... ")
    qgert_log_info(plogger = lgr, ps_caller = "create_ge_compare_plot_report_gs_dereg",
             ps_msg    = paste0(" * Label of current GE: ", pn_cur_ge_label))
    qgert_log_info(plogger = lgr, ps_caller = "create_ge_compare_plot_report_gs_dereg",
             ps_msg    = paste0(" * Label of previous GE: ", pn_prev_ge_label))
  }

  # if no options are specified, we have to get the default options
  l_plot_opts <- pl_plot_opts
  if (is.null(l_plot_opts)){
    l_plot_opts <- get_default_plot_opts_gs_dereg()
  }

  # check whether specific breed was specified
  vec_breed <- l_plot_opts$vec_breed
  if (!is.null(ps_breed)){
    vec_breed <- c(ps_breed)
  }

  # check whether root of directory of current plots is specified
  s_cur_plot_root <- l_plot_opts$ge_dir_stem
  if (!is.null(ps_cur_plot_root)){
    s_cur_plot_root <- ps_cur_plot_root
  }

  # check whether root of directory of previous plots is specified
  s_prev_plot_root <- file.path(l_plot_opts$arch_dir_stem,
                                pn_prev_ge_label,
                                "gs/work")
  if (!is.null(ps_prev_plot_root)){
    s_prev_plot_root <- ps_prev_plot_root
  }


  # loop over breeds
  for (breed in vec_breed){
    # loop over breeds
    if (pb_debug)
      qgert_log_info(plogger = lgr, ps_caller = "create_ge_compare_plot_report_gs_dereg",
               ps_msg    = paste0(" ** Loop for breed: ", breed, collapse = ""))

    # loop over both effects
    for (comp in l_plot_opts$vec_comparisons){
      if (pb_debug)
        qgert_log_info(plogger = lgr, ps_caller = "create_ge_compare_plot_report_gs_dereg",
                 ps_msg    = paste0(" ** Loop for comparison: ", comp, collapse = ""))

      # put together all directory names, start with GE working directory
      s_ge_dir <- file.path(s_cur_plot_root, breed, "plotDereg", comp)
      if (pb_debug)
        qgert_log_info(plogger = lgr, ps_caller = "create_ge_compare_plot_report_gs_dereg",
                 ps_msg    = paste0(" ** GE workdir: ", s_ge_dir, collapse = ""))
      # archive directory
      s_arch_dir <- file.path(s_prev_plot_root, breed, "plotDereg", comp)
      if (pb_debug)
        qgert_log_info(plogger = lgr, ps_caller = "create_ge_compare_plot_report_gs_dereg",
                 ps_msg    = paste0(" ** Archive dir: ", s_arch_dir, collapse = ""))

      # Report text appears in all reports of this trait before the plots are drawn
      s_report_text  <- glue::glue(l_plot_opts$report_text)

      if (pb_debug)
        qgert_log_info(plogger = lgr, ps_caller = "create_ge_compare_plot_report_gs_dereg",
                 ps_msg    = paste0(" ** Report text: ", s_report_text))

      # target directory
      l_arch_dir_split <- fs::path_split(s_arch_dir)
      s_trg_dir <- file.path(pn_prev_ge_label, l_arch_dir_split[[1]][length(l_arch_dir_split[[1]])])
      if (pb_debug)
        qgert_log_info(plogger = lgr, ps_caller = "create_ge_compare_plot_report_gs_dereg",
                 ps_msg    = paste0(" ** Target directory for restored plots: ", s_trg_dir))

      # specify the name of the report file
      s_rep_path <- file.path(s_ge_dir, paste0('ge_plot_report_gs_dereg_compare', comp, '_', breed, '.Rmd', collapse = ''))
      if (pb_debug)
        qgert_log_info(plogger = lgr, ps_caller = "create_ge_compare_plot_report_gs_dereg",
                 ps_msg    = paste0(" ** Path to report created: ", s_rep_path))

      # create the report
      create_ge_plot_report(ps_gedir      = s_ge_dir,
                           ps_archdir     = s_arch_dir,
                           ps_trgdir      = s_trg_dir,
                           ps_templ       = ps_template,
                           ps_report_text = s_report_text,
                           ps_rmd_report  = s_rep_path,
                           pb_debug       = pb_debug,
                           plogger        = plogger)
    }
  }

  # debugging message at the end
  if (pb_debug)
    qgert_log_info(plogger = lgr, ps_caller = "create_ge_compare_plot_report_gs_dereg",
             ps_msg    = " * End of function create_ge_compare_plot_report_gs_dereg")

  # return nothing
  return(invisible(NULL))
}

