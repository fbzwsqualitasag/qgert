context("Comparison Plot Reports")
library(qgert)

test_that("Comparison plot creation works", {
  # directories for current and previous plots
  s_cur_dir <- system.file('extdata', 'curgel', package = 'qgert')
  s_prev_dir <- system.file('extdata', 'prevgel', package = 'qgert')
  s_rmd_template <- system.file('templates', 'compare_plots.Rmd.template', package = 'qgert')
  s_rmd_verified_result <- file.path(s_cur_dir, 'ge_plot_report.Rmd')
  # create temporary working directory
  s_work_root <- '.'
  s_work_dir <- file.path(s_work_root, basename(s_cur_dir))
  if (!dir.exists(s_work_dir))
    fs::dir_copy(s_cur_dir, s_work_root)

  # result of comparison plot
  s_rmd_result <- file.path(s_work_root, 'ge_plot_report.Rmd')
  create_ge_plot_report(ps_gedir        = s_work_dir,
                        ps_archdir      = s_prev_dir,
                        ps_trgdir       = "prev_comp",
                        ps_templ        = s_rmd_template,
                        ps_report_text  = '## Comparison Of Plots\nPlots on the left are from previous evaluation and on the right from current evaluation.',
                        ps_rmd_report   = s_rmd_result,
                        pb_keep_src     = TRUE,
                        pb_session_info = FALSE)
  # read result files and compare
  vec_verified_result <- readLines(con = file(s_rmd_verified_result))
  vec_rmd_result <- readLines(con = file(s_rmd_result))
  # compare
  expect_equal(vec_verified_result, vec_rmd_result)
  # cleanup
  fs::dir_delete(s_work_dir)
  fs::file_delete(s_rmd_result)
  fs::file_delete(fs::path_ext_set(fs::path_ext_remove(s_rmd_result), "pdf"))
})
