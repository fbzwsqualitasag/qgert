context("Generic Comparison Plot Report")
library(qgert)

test_that("check generic comparison plot report result", {
  # set directory constants
  s_right_dir <- system.file("extdata", "curpath", package = "qgert")
  s_left_dir <- system.file("extdata", "prevpath", package = "qgert")
  # set path to verified result
  s_verified_test_result_dir <- system.file('extdata', 'verified_test_result', package = 'qgert')
  s_rmd_verified_result <- file.path(s_verified_test_result_dir, 'compare_plot_report.Rmd')
  # output path for rmd result
  s_out_path <- "test_compare_plot_report/compare_plot_report.Rmd"
  s_pdf_path <- paste0(fs::path_ext_remove(s_out_path), ".pdf")
  # create comparison plot report
  qgert::create_comparison_plot_report(ps_right_dir = s_right_dir,
                                       ps_left_dir = s_left_dir,
                                       pl_repl_value = list(title         = "Test Generic Comparison Plot Report",
                                                            author        = "Peter von Rohr",
                                                            date          = "2021-08-18",
                                                            output_format = "pdf_document"),
                                       ps_report_text = "## Comparison Plots\n The following plots show comparisons between four subsequent evaluations plus two arbitrarily chosen plots taken from templates of RMarkdown documents.",
                                       ps_out_path = s_out_path)
  # read generated Rmd file
  con_rmd_result <- file(description = s_out_path)
  vec_rmd_result <- readLines(con = con_rmd_result)
  close(con = con_rmd_result)
  # read verified result
  con_verified_rmd <- file(description = s_rmd_verified_result)
  vec_verified_rmd <- readLines(con = con_verified_rmd)
  close(con = con_verified_rmd)

  # check
  expect_equal(vec_rmd_result, vec_verified_rmd)

  # check that pdf output exists
  expect_true(file.exists(s_pdf_path))

  # clean up
  s_out_dir <- dirname(s_out_path)
  if (s_out_dir != "."){
    fs::dir_delete(path = s_out_dir)
  } else {
    fs::file_delete(path = s_out_path)
    fs::file_delete(path = s_pdf_path)
  }

})
