#'
#'
#'
#'
#'
#' Read Logfile
#' 
#' Path to cumulated logfile is set by shell script
#s_proj_dir <- here::here()
#s_logfile_path <- file.path(s_proj_dir, "inst/extdata/rank_runtime_BayesCPi.log") 

tbl_runtime <- readr::read_delim(file = s_logfile_path, delim = " ", col_names = FALSE)

# second column must be numeric
tbl_runtime$X2 <- as.numeric(tbl_runtime$X2)

# sort using dplyr::arrange
tbl_sorted_rt <- dplyr::arrange(tbl_runtime, desc(X2))

# create new sorted run lists
(n_rec_rt <- nrow(tbl_sorted_rt))
n_eff_group_size <- 2
n_nr_loop <- floor(n_rec_rt / n_eff_group_size)

for (i in 1:n_nr_loop){
  # i <- 1
  vec_cur_eff_recs <- tbl_sorted_rt[((i-1) * n_eff_group_size + 1):(i*n_eff_group_size),]$X1
  vec_cur_rel_recs <- gsub(pattern = 'eff', replacement = 'rel', vec_cur_eff_recs, fixed = TRUE)
  cat(paste0(c(vec_cur_eff_recs, vec_cur_rel_recs), collapse = "\n"), "\n", file = paste0("work/gsSortedRuns.txt.", i))
}


