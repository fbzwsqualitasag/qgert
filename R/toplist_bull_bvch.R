#' ---
#' title: Create Toplists for BVCH-Bulls
#' date: 2020-08-11
#' ---
#'
#' @title Create Toplists for BVCH-Bulls
#'
#' @description
#' Based on information for the breeds consisting of input files, breed names and
#' number of records that should be listed in the toplist and a tibble with trait
#' names, the results are extracted from the input files and are then written to
#' an xlsx-file.
#'
#' @details
#'
#' @param ps_eval_label evaluation label
#' @param pl_breed_input list with input items consisting of breed names, input files and length of rankings
#' @param pb_debug flag indicating debugging mode
#' @param plogger logger object
#'
#' @example
#' \dontrun{
#' qgert::create_toplist_bvch_bull(ps_eval_label = '2008')
#' }
#' @export create_toplist_bvch_bull
create_toplist_bvch_bull <- function(ps_eval_label,
                                     pl_breed_input  = get_l_breed_input_bvch(),
                                     ptbl_trait_name = get_default_tbl_trait_name_bvch(),
                                     ps_xlsx_file    = NULL,
                                     pb_debug        = FALSE,
                                     plogger         = NULL){
  # debugging message at the beginning
  if (pb_debug) {
    if (is.null(plogger)){
      lgr <- get_qgert_logger(ps_logfile = 'toplist_bull_bvch.log', ps_level = 'INFO')
    } else {
      lgr <- plogger
    }
    qgert_log_info(plogger = lgr, ps_caller = 'create_ge_plot_report',
                   ps_msg = " Start of function toplist_bull_bvch ... ")
    qgert_log_info(plogger = lgr, ps_caller = "toplist_bull_bvch",
                   ps_msg    = paste0(" * Input files: ", pvec_input_files, collapse = " "))
  }

  # columns which are not traits
  vec_non_trait <- get_vec_non_traits()
  if (pb_debug) {
    qgert_log_info(plogger = lgr, ps_caller = 'create_ge_plot_report',
                   ps_msg = paste0(" Non-traits: ", vec_non_trait, collapse = ' '))
  }
  # getting toplist info
  l_toplist_info <- read_top_list_info3(pl_breed_input  = pl_breed_input,
                                        ptbl_trait      = ptbl_trait_name,
                                        pb_debug        = pb_debug,
                                        plogger         = plogger)

  # determine result filename
  s_xlsx_file <- ps_xlsx_file
  if (is.null(s_xlsx_file)) {
    if (is.null(ps_eval_label)) stop(" * ERROR in create_toplist_bvch_bull: evaluation label cannot be null")
    s_xlsx_file <- paste0("Toplisten_Stiere_CHbv_", ps_eval_label, ".xlsx", collapse = "")
  }
  # writing the toplist to a result file
  write_tl_xlsx(pl_toplist = l_toplist_info, ptbl_trait = ptbl_trait_name, ps_xlsx_file = s_xlsx_file)
}


#' --- Writing TopList To xlsx ----------------------------------------------- #
#'
#' @title Write Toplist Information to xlsx
#'
#' @description
#' The extracted toplist information is written to an xlsx file.
#'
#' @param pl_toplist list with top list information
#' @param ptbl_trait tibble with trait name
#' @param ps_xlsx_file name of result file
write_tl_xlsx <- function(pl_toplist, ptbl_trait, ps_xlsx_file = "example.xlsx"){
  ### # extract trait abbreviations
  vec_det_traits <- ptbl_trait$Abk
  ### # vector of the breeds is taken from names of pl_toplist
  vec_breed <- names(pl_toplist)
  ### # create a new workbook
  wb <- openxlsx::createWorkbook()
  ### # add a table for the first trait
  for (ctridx in seq_along(vec_det_traits)){
    s_cur_trait <- vec_det_traits[ctridx]
    cat(" * Current trait: ", s_cur_trait, "\n")
    openxlsx::addWorksheet(wb, s_cur_trait)
    ### # writing the data, start with trait name
    n_cur_start_row <- 2
    openxlsx::writeData(wb = wb, sheet = s_cur_trait, s_cur_trait, startCol = 1, startRow = n_cur_start_row)
    ### # increment start row
    n_cur_start_row <- n_cur_start_row + 1
    ### # write first block of data for first breed
    for (cbidx in seq_along(vec_breed)){
      s_cur_breed <- vec_breed[cbidx]
      cat(" ** Current breed: ", s_cur_breed, "\n")
      tbl_cur_tab <- pl_toplist[[s_cur_breed]][[s_cur_trait]]
      if (!is.null(tbl_cur_tab)){
        cat("    ==> tibble found\n")
        ### # write data frame for current breed
        openxlsx::writeData(wb = wb, sheet = s_cur_trait, tbl_cur_tab, startCol = 1, startRow = n_cur_start_row)
        ### # if we are not writing the last breed and the next breed also has toplist info, increment start row for second breed
        if (cbidx < length(vec_breed) && !is.null(pl_toplist[[vec_breed[cbidx+1]]][[s_cur_trait]])){
          n_cur_start_row <- n_cur_start_row + nrow(tbl_cur_tab) + 3
          openxlsx::writeData(wb = wb, sheet = s_cur_trait, vec_breed[cbidx + 1], startCol = 1, startRow = n_cur_start_row)
          n_cur_start_row <- n_cur_start_row + 2
        }
      }
    }
  }

  ## Save workbook to working directory
  openxlsx::saveWorkbook(wb, file = ps_xlsx_file, overwrite = TRUE)
  ### # return nothing
  return(invisible(TRUE))
}

#' --- Reading TopList Input ------------------------------------------------- #
#'
#' @title Read Toplist Input From CSV-Files
#'
#' @description
#' The content of the csv-files are read into a tibble and all tibbles are
#' combined into a list.
#'
#' @details
#' This function assumes that there is a separate csv-file for each breed.
#'
#' @param pl_breed_input list with input information about breeds
#' @param ptbl_trait tibble with trait information
#' @param pb_debug flag for debugging mode
#' @param plogger logger object
#'
#' @return list of toplist input
read_top_list_info3 <- function(pl_breed_input,
                                ptbl_trait,
                                pvec_resultcols = get_vec_resultcols_bvch(),
                                pb_debug        = FALSE,
                                plogger         = NULL){
  # debugging message at the beginning
  if (pb_debug) {
    if (is.null(plogger)){
      lgr <- get_qgert_logger(ps_logfile = 'read_top_list_info3.log', ps_level = 'INFO')
    } else {
      lgr <- plogger
    }
    qgert_log_info(plogger = lgr, ps_caller = 'read_top_list_info3',
                   ps_msg = " Start of function read_top_list_info3 ... ")
    qgert_log_info(plogger = lgr, ps_caller = "read_top_list_info3",
                   ps_msg    = paste0(" * Input files: ", pvec_input_files, collapse = " "))
  }
  ### # output some parameter info
  if (pb_debug) {
    qgert_log_info(plogger = lgr, ps_caller = 'read_top_list_info3',
                   ps_msg = paste0(" breeds:\n", pl_breed_input$breeds, collapse = ' '))
    qgert_log_info(plogger = lgr, ps_caller = 'read_top_list_info3',
                   ps_msg = paste0(" input files:\n", pl_breed_input$inputfiles, collapse = ' '))
    qgert_log_info(plogger = lgr, ps_caller = 'read_top_list_info3',
                   ps_msg = paste0(" number of top candidates:\n", pl_breed_input$numbertop, collapse = ' '))
  }
  # vector of trait abbreviations
  vec_trait <- ptbl_trait$Abk
  if (pb_debug) {
      qgert_log_info(plogger = lgr, ps_caller = 'read_top_list_info3',
                     ps_msg = paste0(" traits: \n", vec_trait, collapse = ' '))
  }
  # list of sort criteria
  l_sort <- lapply(1:nrow(ptbl_trait), function(x) return(c(ptbl_trait$Abk[x], ptbl_trait$Secondary[x])) )
  names(l_sort) <- ptbl_trait$Abk

  ### # initialize final result
  l_final_result <- NULL
  ### # loop over breeds and do the extraction
  for (nbidx in seq_along(pl_breed_input$breeds)){
    ### # read current input file
    tbl_cur_tl <- readr::read_csv2(file = pl_breed_input$inputfiles[nbidx])
    ### # extract the current result
    l_cur_result <- lapply(l_sort, function(x) {
      if (x[1] %in% names(tbl_cur_tl)){
        tbl_cur_trait <- dplyr::bind_cols(tibble::tibble(Rang = 1:pl_breed_input$numbertop[nbidx]),
                                          tbl_cur_tl[order(tbl_cur_tl[[x[1]]], tbl_cur_tl[[x[2]]], decreasing = TRUE),
                                                     c(pvec_resultcols, x[1])][1:pl_breed_input$numbertop[nbidx],])
        names(tbl_cur_trait)[ncol(tbl_cur_trait)] <- ptbl_trait[ptbl_trait$Abk == x[1],]$Name
        return(tbl_cur_trait)
      } else {
        return(NULL)
      }})
    names(l_cur_result) <- vec_trait
    ### # add current result to final result
    l_final_result <- c(l_final_result, list(l_cur_result))
  }
  ### # use the breeds as names for the final result list
  names(l_final_result) <- pl_breed_input$breeds
  ### # return list of final results
  return(l_final_result)
}


#' --- Determine Trait Names -------------------------------------------------- #
#'
#' @title Default Trait Information
#'
#' @description
#' The default version of trait information is read from a csv-file in the package.
#' If different traits must be considered, then they have to be specified explicitly
#' in the top creation function.
#'
#'
#' @return Tibble with default information on traits for bvch
get_default_tbl_trait_name_bvch <- function(){
  s_trait_name_file <- system.file("extdata", "toplist_bvch", "tl_trait_names.csv", package = 'qgert')
  if (!file.exists(s_trait_name_file)) stop(" * ERROR in get_default_tbl_trait_name_bvch: cannot find trait name file: ", s_trait_name_file)
  tbl_trait_name <- readr::read_csv(file = s_trait_name_file)
  return(tbl_trait_name)
}



#' --- Defaults and Constants ------------------------------------------------- #
#'
#'
#' @title Vector of Non-Trait Columns
#'
#' @description
#' This function returns a fixed vector of columns that are not treated as
#' traits.
#'
#' @return Vector of column names that are not to be treated as traits
get_vec_non_traits <- function() {
  return(c("Tiername", "TVD-Nr", "Anbieter"))
}


#'
#' @title Default Result Columns
#'
#' @description
#' The default for the columns shown in the result xlsx file.
#'
#' @return The columns in the result file
get_vec_resultcols_bvch <- function(){
  return(setdiff(get_vec_non_traits(), "Anbieter"))
}

#'
#' @title Breed Input for Breed BVCH
#'
#' @description
#' This function tries to return reasonable default values for the information
#' about the breeds.
#'
#' @details
#' If nothing is specified, the toplist input is taken from the extdata directory
#' of the package. Hence this is only to be used for testing.
#'
#' @return List of information about breeds
get_l_breed_input_bvch <- function(){
  s_data_dir <- system.file("extdata","toplist_bvch", package = 'qgert')
  vec_data_files <- sapply(c('Toplisten_Stiere_BV.csv','Toplisten_Stiere_OB.csv'),
                           function(x) file.path(s_data_dir,x), USE.NAMES = FALSE)
  vec_non_trait <- get_vec_non_traits()
  return(list(breeds     = c("BV", "OB"),
              inputfiles = vec_data_files,
              numbertop  = c(12, 5)))
}
