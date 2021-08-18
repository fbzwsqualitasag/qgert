###
###
###
###   Purpose:   Generic function to create a comparison plot report
###   started:   2019-10-14 (pvr)
###
### ########################################################## ###

## --- Comparison Plot Report Creator Function For Genetic Evaluations --------

#' @title Create Report With Plots From Two GE Periods
#'
#' @description
#' Based on a Rmarkdown Template (ps_templ) document all plots
#' in given GE directory (ps_gedir) are taken. For a given plot
#' in directory ps_gedir, a corresponding plot with the same
#' filename is searched in an archive directory (ps_archdir).
#' If such a plot is found, the two corresponding plots are
#' shown side-by-side in the generated Rmarkdown report.
#'
#' @param ps_gedir  directory with plots of current GE round
#' @param ps_archdir  archive directory with plots from previous GE
#' @param ps_trgdir    target directory where plot files from archive are extracted, relative to ps_gedir
#' @param ps_templ  path to Rmarkdown template file
#' @param ps_report_text text that is included in the report before plotting
#' @param ps_rmd_report name of report source file
#' @param pb_keep_src should Rmd source be kept
#' @param pb_session_info should session_info be included
#' @param pb_debug flag indicating whether debug info is printed
#' @param plogger log4r logger object
#'
#' @examples
#' \dontrun{
#' create_ge_plot_report(ps_gedir     = "{path to comparison dir}",
#'                     ps_archdir     = "{path to archive dir}",
#'                     ps_trgdir      = "1904/compareBull",
#'                     ps_templ       = "inst/templates/compare_plots.Rmd.template",
#'                     ps_report_text = "## Comparison Of Plots\nPlots compare estimates ...",
#'                     ps_rmd_report  = 'ge_plot_report.Rmd',
#'                     pb_debug       = TRUE)
#'
#' }
#' @export create_ge_plot_report
create_ge_plot_report <- function(ps_gedir,
                                  ps_archdir,
                                  ps_trgdir,
                                  ps_templ,
                                  ps_report_text,
                                  ps_rmd_report   = 'ge_plot_report.Rmd',
                                  pb_keep_src     = FALSE,
                                  pb_session_info = TRUE,
                                  pb_debug        = FALSE,
                                  plogger         = NULL){

  if (pb_debug) {
    if (is.null(plogger)){
      lgr <- get_qgert_logger(ps_logfile = 'create_ge_plot_report.log', ps_level = 'INFO')
    } else {
      lgr <- plogger
    }
    qgert_log_info(plogger = lgr, ps_caller = 'create_ge_plot_report', ps_msg = " * Starting create_ge_plot_report ... ")
  }

  # ps_gedir and ps_archdir must esits
  if (!dir.exists(ps_gedir))
    stop("[ERROR -- create_ge_plot_report] Cannot find plot directory: ", ps_gedir, "\n")

  if (!dir.exists(ps_archdir))
    stop("[ERROR -- create_ge_plot_report] Cannot find archive directory: ", ps_archdir, "\n")

  # ps_templ must exist
  if (!file.exists(ps_templ))
    stop("[ERROR -- create_ge_plot_report] Cannot find Rmd template: ", ps_templ, "\n")

  # target directory should be relative to ps_gedir
  if (fs::is_absolute_path(path = ps_trgdir))
    stop("[ERROR -- create_ge_plot_report] Target directory: ", ps_trgdir, " must be relative to ps_gedir: ", ps_gedir, "\n")
  # append ps_trgdir to ps_gedir
  s_trgdir <- file.path(ps_gedir, ps_trgdir)
  if (pb_debug)
    qgert_log_info(plogger = lgr, ps_caller = 'create_ge_plot_report',
                   ps_msg = paste0(" * Absolute target directory: ", s_trgdir))

  # get the root subdirectory in ps_gedir where ps_trgdir is added
  s_trgroot <- file.path(ps_gedir, fs::path_split(ps_trgdir)[[1]][1])
  if (pb_debug)
    qgert_log_info(plogger = lgr, ps_caller = 'create_ge_plot_report',
                   ps_msg = paste0(" * Target root directory: ", s_trgroot))

  # if the ps_trgdir does not exist, create it
  if (!dir.exists(s_trgdir)) {
    if (pb_debug)
      qgert_log_info(plogger = lgr, ps_caller = 'create_ge_plot_report',
                     ps_msg = paste0(" * Create target directory: ",s_trgdir))
    dir.create(path = s_trgdir, recursive = TRUE)
  }

  # if target directory could not be created, stop here
  if (!dir.exists(s_trgdir))
    stop("[ERROR -- create_ge_plot_report] Cannot create target directory: ", s_trgdir, "\n")

  # if the pdf report and the rmd sources exist, delete them first
  s_pdf_report <- fs::path_ext_set(fs::path_ext_remove(ps_rmd_report), "pdf")
  if (file.exists(s_pdf_report)){
    fs::file_delete(s_pdf_report)
    if (pb_debug)
      qgert_log_info(plogger = lgr, ps_caller = 'create_ge_plot_report',
                     ps_msg = paste0(" * Deleted existing pdf report: ", s_pdf_report))
  }
  # remove existing tex sources
  s_tex_report <- fs::path_ext_set(fs::path_ext_remove(ps_rmd_report), "tex")
  if (file.exists(s_tex_report)){
    fs::file_delete(s_tex_report)
    if (pb_debug)
      qgert_log_info(plogger = lgr, ps_caller = 'create_ge_plot_report',
                     ps_msg = paste0(" * Deleted existing tex report sources: ", s_tex_report))
  }
  # remove existing rmd source
  if (file.exists(ps_rmd_report)){
    fs::file_delete(ps_rmd_report)
    if (pb_debug)
      qgert_log_info(plogger = lgr, ps_caller = 'create_ge_plot_report',
                     ps_msg = paste0(" * Deleted existing rmd report source: ", ps_rmd_report))
  }

  # start with a new rmd rouce report by renaming the template into the result report
  file.copy(from = ps_templ, to = ps_rmd_report)

  # add the report text to the report
  cat(ps_report_text, "\n\n", file = ps_rmd_report, append = TRUE)

  # extract plot files from current ps_gedir
  vec_plot_files_ge <- list.files(ps_gedir, pattern = "\\.png$|\\.pdf$", full.names = TRUE)
  if (pb_debug){
         qgert_log_info(plogger = lgr, ps_caller = 'create_ge_plot_report',
                        ps_msg = paste0("Plot files in ", ps_gedir))
    print(vec_plot_files_ge)
  }
  # loop over plot files and get corresponding plot file from previous ge, if it exists
  for (f in vec_plot_files_ge){
    if (pb_debug)
      qgert_log_info(plogger = lgr, ps_caller = 'create_ge_plot_report',
                     ps_msg = paste0(" * Plot file: ", f))
    # write the chunk start into the report file
    cat("\n```{r, echo=FALSE, fig.show='hold', out.width='50%'}\n", file = ps_rmd_report, append = TRUE)
    # check whether corresponding plot file existed in archive
    bnf <- basename(f)
    # path to unzipped plot file in archive
    bnfarchpath <- file.path(ps_archdir, bnf)
    # gzipped plotfile
    bnfgz <- paste(bnf, "gz", sep = ".")
    # path to gzipped plotfile in archive
    bnfgzarchpath <- file.path(ps_archdir, bnfgz)
    # path to plotfile in target directory
    bnftrgpath <- file.path(s_trgdir, bnf)
    ### # TODO: the following can be refactored into functions that copy and gunzip archive files
    if (file.exists(bnfgzarchpath)){
      if (pb_debug)
        qgert_log_info(plogger = lgr, ps_caller = 'create_ge_plot_report',
                       ps_msg = paste0(" * Found archived plot file: ", bnfgz, " in ", ps_archdir))
      # copy file from archive
      if (pb_debug)
        qgert_log_info(plogger = lgr, ps_caller = 'create_ge_plot_report',
                       ps_msg = paste0(" * Copy from: ", bnfgzarchpath, " to ", s_trgdir))
      file.copy(from = bnfgzarchpath, to = s_trgdir)
      bnfgztrgpath <- file.path(s_trgdir, bnfgz)
      if (!file.exists(bnftrgpath)){
        if (pb_debug)
          qgert_log_info(plogger = lgr, ps_caller = 'create_ge_plot_report',
                         ps_msg = paste0(" * Unzip: ", bnfgztrgpath))
        R.utils::gunzip(bnfgztrgpath)
      } else {
        if (pb_debug)
          qgert_log_info(plogger = lgr, ps_caller = 'create_ge_plot_report',
                         ps_msg = paste0(" * File: ", bnftrgpath, " already exists"))
      }
      ### # Include extracted file into the report
      cat(paste0("knitr::include_graphics(path = '", bnftrgpath, "')\n", collapse = ""), file = ps_rmd_report, append = TRUE)
    } else if (file.exists(bnfarchpath)) {
      if (pb_debug)
        qgert_log_info(plogger = lgr, ps_caller = 'create_ge_plot_report',
                       ps_msg = paste0(" * Found archived plot file: ", bnf, " in ", ps_archdir))
      # copy file from archive
      if (pb_debug)
        qgert_log_info(plogger = lgr, ps_caller = 'create_ge_plot_report',
                       ps_msg = paste0(" * Copy from: ", bnfarchpath, " to ", s_trgdir))
      file.copy(from = bnfarchpath, to = s_trgdir)
      ### # Include extracted file into the report
      cat(paste0("knitr::include_graphics(path = '", bnftrgpath, "')\n", collapse = ""), file = ps_rmd_report, append = TRUE)
    } else {
      if (pb_debug)
        qgert_log_info(plogger = lgr, ps_caller = 'create_ge_plot_report',
                       ps_msg = paste0(" * Cannot find archived plot file: ", bnfgz, " in ", ps_archdir))
    }
    # include current plot file into report
    cat(paste0("knitr::include_graphics(path = '", f, "')\n", collapse = ""), file = ps_rmd_report, append = TRUE)
    # write junk end into report
    cat("```\n\n", file = ps_rmd_report, append = TRUE)
  }
  if (pb_session_info){
    # finally include session info into the report
    cat("\n```{r}\n sessioninfo::session_info()\n```\n\n", file = ps_rmd_report, append = TRUE)
  }
  # render the generated Rmd file
  rmarkdown::render(input = ps_rmd_report)

  # remove report sources
  if (!pb_keep_src){
    if (pb_debug)
      qgert_log_info(plogger = lgr, ps_caller = 'create_ge_plot_report',
                     ps_msg = paste0(" * Removing report rmd source ", ps_rmd_report))
    if (file.exists(ps_rmd_report)) fs::file_delete(ps_rmd_report)
    if (pb_debug)
      qgert_log_info(plogger = lgr, ps_caller = 'create_ge_plot_report',
                     ps_msg = paste0(" * Removing report tex source ", s_tex_report))
    if (file.exists(s_tex_report)) fs::file_delete(s_tex_report)
  }

  # remove target root dir
  if (pb_debug)
    qgert_log_info(plogger = lgr, ps_caller = 'create_ge_plot_report',
                   ps_msg = paste0(" * Delete target root directory: ", s_trgroot))
  if (dir.exists(s_trgroot)) fs::dir_delete(path = s_trgroot)

  if (pb_debug)
    qgert_log_info(plogger = lgr, ps_caller = 'create_ge_plot_report',
                   ps_msg = paste0(" * End of create_ge_plot_report"))

  # return nothing
  return(invisible(NULL))
}


## ---- Generic Form of Comparison Plot Report Generator -----------------------


#' Create Generic Form of Comparison Plot Report
#'
#' @description
#' Given two directories with analogous plots, a comparison plot report is
#' created. The comparison plot report shows pairs of analogous plots side-by-side
#' in the report. Analogous plots can be plots of the same quantities at
#' different time points. Analogous plots are identified by the same name of
#' the plot file. Plots in the directory ps_current_dir are shown on the right-hand
#' side and plots from the directory ps_previous_dir are shown on the left-hand
#' side.
#'
#' @details
#' The report generator starts by retrieving all plot files from ps_current_dir
#' and from ps_previous_dir. Then it determines the intersection between the
#' file-names and the two difference sets. In loops over all the sets, the plots
#' are integrated into the report.
#'
#' @param ps_right_dir directory of plots shown on the right-hand-side in the report
#' @param ps_left_dir directory of plots shown on the left-hand-side in the report
#' @param ps_tmpl_path path to Rmd template file
#' @param ps_diagram_na_path path to diagram to be included to stand for missing diagram
#' @param ps_report_text Report text
#' @param pl_repl_value list of replacement values for placeholders
#' @param ps_out_path Path to report putput file
#' @param pb_keep_src flag to keep source files
#' @param pb_session_info add session info to report
#' @param pb_force overwrite existing report, if it exists
#' @param pb_debug flag to add debugging info
#' @param plogger log4r logger object
#'
#'
#' @examples
#' \dontrun{
#' dir1 <- system.file("extdata", "curgel", package = "qgert")
#' dir2 <- system.file("extdata", "prevpath", package = "qgert")
#' create_comparison_plot_report(ps_right_dir = dir1, ps_left_dir = dir2)
#' }
#' @export create_comparison_plot_report
create_comparison_plot_report <- function(ps_right_dir,
                                          ps_left_dir,
                                          ps_tmpl_path       = system.file("templates", "generic_comparison_plot_report.Rmd.template", package = "qgert"),
                                          ps_diagram_na_path = system.file("templates", "Diagram_NA.pdf", package = "qgert"),
                                          ps_report_text     = NULL,
                                          pl_repl_value      = NULL,
                                          ps_out_path        = "generic_comparison_plot_report.Rmd",
                                          pb_keep_src        = FALSE,
                                          pb_session_info    = FALSE,
                                          pb_force           = FALSE,
                                          pb_debug           = FALSE,
                                          plogger            = NULL){
  # debug and logging
  if (pb_debug) {
    if (is.null(plogger)){
      lgr <- get_qgert_logger(ps_logfile = 'create_comparison_plot_report.log', ps_level = 'INFO')
    } else {
      lgr <- plogger
    }
    qgert_log_info(plogger = lgr, ps_caller = 'create_comparison_plot_report', ps_msg = " * Starting create_comparison_plot_report ... ")
  }

  # check whether ps_right_dir and ps_left_dir exist
  if (!dir.exists(ps_right_dir)) stop(" *** ERROR create_comparison_plot_report(): CANNOT FIND ps_right_dir: ", ps_right_dir)
  if (!dir.exists(ps_left_dir)) stop(" *** ERROR create_comparison_plot_report(): CANNOT FIND ps_left_dir: ", ps_left_dir)
  # list of plot files from ps_right_dir
  vec_plot_current <- list.files(path = ps_right_dir, pattern = "\\.png$|\\.pdf$")
  vec_plot_previous <- list.files(path = ps_left_dir, pattern = "\\.png$|\\.pdf$")
  if (pb_debug){
    qgert_log_info(plogger = lgr, ps_caller = 'create_comparison_plot_report', ps_msg = "List of current plot files: ")
    print(vec_plot_current)
    qgert_log_info(plogger = lgr, ps_caller = 'create_comparison_plot_report', ps_msg = "List of previous plot files: ")
    print(vec_plot_previous)
  }

  # check whether old report file exists
  if (file.exists(ps_out_path)){
    if (pb_force){
      unlink(ps_out_path)
    } else {
      stop(" *** ERROR create_comparison_plot_report: Old report exists, specify pb_force to overwrite ...")
    }
  }

  # check whether directory of ps_out_path exists
  s_out_dir <- dirname(ps_out_path)
  if (!dir.exists(s_out_dir)) dir.create(path = s_out_dir, recursive = TRUE)

  # check file extension of ps_out_path
  if (tolower(fs::path_ext(ps_out_path)) == "rmd"){
    s_out_path <- ps_out_path
  } else {
    s_out_path <- paste0(ps_out_path, ".Rmd")
  }


  # get replacement values to be inserted in template
  l_repl_value_default <- get_generic_comparison_plot_report_default_replacement_values()
  l_repl_value_default[["ps_current_plot_dir"]] <- ps_right_dir
  l_repl_value_default[["ps_previous_plot_dir"]] <- ps_left_dir
  if (is.null(pl_repl_value)){
    l_repl_value <- l_repl_value_default
  } else {
    l_repl_value <- pl_repl_value
    l_repl_value <- merge_list_to_default(pl_base = l_repl_value, pl_default = l_repl_value_default)
  }

  # prepare report template
  if (pb_debug) qgert_log_info(plogger = lgr, ps_caller = "create_comparison_plot_report", ps_msg = paste0("Reading template from: ", ps_tmpl_path))
  con_tmpl <- file(description = ps_tmpl_path)
  vec_tmpl <- readLines(con = file(ps_tmpl_path))
  close(con = con_tmpl)
  s_tmpl <- paste0(vec_tmpl, collapse = "\n")
  if (pb_debug) qgert_log_info(plogger = lgr, ps_caller = "create_comparison_plot_report", ps_msg = paste0("Template text: ", s_tmpl))
  s_report_result <- string_replace(ps_tmpl = s_tmpl, pl_repl_value = l_repl_value)
  if (pb_debug) qgert_log_info(plogger = lgr, ps_caller = "create_comparison_plot_report", ps_msg = paste0("Result text: ", s_report_result))

  # add report text if there is any
  if (!is.null(ps_report_text))
    s_report_result <- paste0(s_report_result, "\n\n", ps_report_text, collapse = "")

  # loop over plot files and add R-code chunks to result string
  for (idx in seq_along(vec_plot_current)){
    s_cur_plot_file <- vec_plot_current[idx]
    if (pb_debug) qgert_log_info(plogger = lgr, ps_caller = "create_comparison_plot_report", ps_msg = paste0(" Current plot file: ", s_cur_plot_file))
    # path to current plot file
    s_cur_plot_path <- file.path(ps_right_dir, s_cur_plot_file)
    if (pb_debug) qgert_log_info(plogger = lgr, ps_caller = "create_comparison_plot_report", ps_msg = paste0(" Current plot from: ", s_cur_plot_path))
    if (!file.exists(s_cur_plot_path)) stop(" *** ERROR [create_comparison_plot_report]: CANNOT FIND current plot path: ", s_cur_plot_path)

    # path to previous plot file
    s_prev_plot_path <- file.path(ps_left_dir, s_cur_plot_file)
    if (pb_debug) qgert_log_info(plogger = lgr, ps_caller = "create_comparison_plot_report", ps_msg = paste0(" Previous plot from: ", s_prev_plot_path))
    if (!file.exists(s_prev_plot_path)) s_prev_plot_path <- ps_diagram_na_path

    # add code chunk to result string
    if (pb_debug) qgert_log_info(plogger = lgr, ps_caller = "create_comparison_plot_report", ps_msg = " * Adding R-code chunks for including diagrams ...")
    s_report_result <- paste0(s_report_result, "\n\n### ", s_cur_plot_file, "\n\n```{r, echo=FALSE, fig.show='hold', out.width='50%'}\n", collapse = "")
    s_report_result <- paste0(s_report_result, "knitr::include_graphics(path = '", s_prev_plot_path, "')\n", collapse = "")
    s_report_result <- paste0(s_report_result, "knitr::include_graphics(path = '", s_cur_plot_path, "')\n", collapse = "")
    s_report_result <- paste0(s_report_result, "```\n\n", collapse = "")

  }
  # add plots which are in ps_left_dir, but not in ps_right_dir
  vec_both_dir <- intersect(vec_plot_current, vec_plot_previous)
  vec_previous_only <- setdiff(vec_plot_previous, vec_both_dir)
  if (length(vec_previous_only) > 0L){
    for (idx in seq_along(vec_previous_only)){
      s_cur_plot_file <- vec_previous_only[idx]
      s_cur_plot_path <- ps_diagram_na_path
      s_prev_plot_path <- file.path(ps_left_dir, s_cur_plot_file)
      if (pb_debug) qgert_log_info(plogger = lgr, ps_caller = "create_comparison_plot_report", ps_msg = paste0(" Previous plot from: ", s_prev_plot_path))
      if (!file.exists(s_prev_plot_path)) stop(" *** ERROR [create_comparison_plot_report]: CANNOT FIND previous plot path: ", s_prev_plot_path)
      # add code chunk to result string
      if (pb_debug) qgert_log_info(plogger = lgr, ps_caller = "create_comparison_plot_report", ps_msg = " * Adding R-code chunks for including diagrams ...")
      s_report_result <- paste0(s_report_result, "\n\n### ", s_cur_plot_file, "\n\n```{r, echo=FALSE, fig.show='hold', out.width='50%'}\n", collapse = "")
      s_report_result <- paste0(s_report_result, "knitr::include_graphics(path = '", s_prev_plot_path, "')\n", collapse = "")
      s_report_result <- paste0(s_report_result, "knitr::include_graphics(path = '", s_cur_plot_path, "')\n", collapse = "")
      s_report_result <- paste0(s_report_result, "```\n\n", collapse = "")
    }
  }
  # add session info, if specified
  if (pb_session_info){
    if (pb_debug) qgert_log_info(plogger = lgr, ps_caller = "create_comparison_plot_report", ps_msg = " * Adding session info ...")

    # finally include session info into the report
    s_report_result <- paste0(s_report_result, "\n\n```{r}\n sessioninfo::session_info()\n```\n\n", collapse = "")
  }
  # write result to file
  if (pb_debug) qgert_log_info(plogger = lgr, ps_caller = "create_comparison_plot_report", ps_msg = paste0(" * Writing result string to file: ", s_out_path))
  cat(s_report_result, "\n", file = s_out_path)

  # render the report
  if (pb_debug) qgert_log_info(plogger = lgr, ps_caller = "create_comparison_plot_report", ps_msg = paste0(" * Rendering output from file: ", s_out_path))
  rmarkdown::render(input = s_out_path)


  # return nothing
  return(invisible(TRUE))
}


