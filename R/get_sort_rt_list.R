#' ---
#' title: Sort a List of gsRuns According To Their Runtime
#' date:  "2019-10-30"
#' ---
#'
#' @title Split GsRuns According to Sorted Runtimes
#'
#' @description
#' Given an input file of runtimes per gs-jobs, the list of gs-jobs
#' will be sorted and output in a given number of splits of the
#' complete number of gs-jobs.
#'
#' @param ps_rt_in_file     gs-job runtime input file
#' @param ps_out_dir        output directory where the splitted jobs should be written to
#' @param pn_nr_split       number of splitted job files.
#' @param ps_out_file_stem  stem of output filename
#'
#' @export split_gsruns_sorted_rt
#' @examples
#' \dontrun{
#' split_gsruns_sorted_rt(ps_rt_in_file = "work/rank_gsRuns_runtime.out", ps_out_dir = "work", pn_nr_split = 10)
#' }
split_gsruns_sorted_rt <- function(ps_rt_in_file, ps_out_dir, pn_nr_split, ps_out_file_stem = 'gsSortedRuns.txt'){
  # read run-time input file
  tbl_runtime <- readr::read_delim(file = ps_rt_in_file, delim = " ", col_names = FALSE)
  # second column must be numeric
  tbl_runtime$X2 <- as.numeric(tbl_runtime$X2)
  # sort using dplyr::arrange
  tbl_sorted_rt <- dplyr::arrange(tbl_runtime, desc(X2))
  # create splits
  n_nr_jobs <- nrow(tbl_sorted_rt)
  # number of gs-jobs per split
  n_nr_jobs_per_split <- floor(n_nr_jobs / pn_nr_split) + 1
  # number of full loops
  n_nr_full_loops <- floor(n_nr_jobs / n_nr_jobs_per_split)
  # loop and produce split files
  for (i in 1:n_nr_full_loops){
    cat(paste0(tbl_sorted_rt[((i-1) * n_nr_jobs_per_split + 1):(i*n_nr_jobs_per_split),]$X1, collapse = "\n"), "\n",
        file = file.path(ps_out_dir, paste0(ps_out_file_stem, '.', i)), sep = '')
  }
  # put remaining in last file, if needed
  if ((n_nr_full_loops*n_nr_jobs_per_split) < n_nr_jobs){
    cat(paste0(tbl_sorted_rt[(n_nr_full_loops*n_nr_jobs_per_split + 1):n_nr_jobs,]$X1, collapse = "\n"), "\n",
        file = file.path(ps_out_dir, paste0(ps_out_file_stem, '.', (n_nr_full_loops+1))), sep = '')
  }
}
