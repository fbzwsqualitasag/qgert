###
###
###
###   Purpose:   Generic function to create a comparison plot report
###   started:   2019-10-14 (pvr)
###
### ########################################################## ###

## -- Generic Comparison Plot Creator Function

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

