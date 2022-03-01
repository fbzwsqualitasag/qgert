###
###
###
###    Purpose:   Collection Of Functions Returning Global Constants
###    started:   2019-10-14 (pvr)
###
### ################################################################### ###

## -- Default Plot Options for different traits --- ###

#' @title Default Plot Options For FBK
#'
#' @description
#' Return a list with specific defaults and constants that are used
#' to produce the plot comparison report for the trait group
#' Fruchtbarkeit (FBK).
#'
get_default_plot_opts_fbk <- function(){
  # return list of default options
  return(list(ge_dir_stem     = "/qualstorzws01/data_zws/fbk/work",
              arch_dir_stem   = "/qualstorzws01/data_archiv/zws",
              rmd_templ       = system.file("templates/compare_plots.Rmd.template", package = 'qgert'),
              rmd_report_stem = "ge_plot_report_fbk",
              vec_breed       = c("bv", "rh"),
              vec_sex         = c("Bull", "Cow")))
}


## -- Defaults for ND

#' @title Default Plot Options For ND
#'
#' @description
#' Return a list with specific defaults and constants that are used
#' to produce the comparison plot report for the trait group
#' Nutzungsdauer (ND).
#'
get_default_plot_opts_nd <- function(){
  # return list of default options
  return(list(ge_dir_stem     = "/qualstorzws01/data_zws/nd/work",
              arch_dir_stem   = "/qualstorzws01/data_archiv/zws",
              rmd_templ       = system.file("templates/compare_plots.Rmd.template", package = 'qgert'),
              rmd_report_stem = "ge_plot_report_nd",
              vec_breed       = c("bv", "rh"),
              report_text     = paste0('## Comparison Of Plots\nPlots compare estimates of Nutzungsdauer (ND) for breed {breed}',
                                       ' between GE-run {pn_prev_ge_label}',
                                       ' on the left and the current GE-run {pn_cur_ge_label}',
                                       ' on the right.', collapse = "")))
}


## -- Defaults for MAR

#' @title Default Plot Options For MAR
#'
#' @description
#' Return a list with specific defaults and constants that are used
#' to produce the comparison plot report for the trait group
#' Mastitisresistenz (MAR).
#'
get_default_plot_opts_mar <- function(){
  # return list of default options
  return(list(ge_dir_stem     = "/qualstorzws01/data_zws/health/mar/work",
              arch_dir_stem   = "/qualstorzws01/data_archiv/zws",
              rmd_templ       = system.file("templates/compare_plots.Rmd.template", package = 'qgert'),
              rmd_report_stem = "ge_plot_report_mar",
              vec_breed       = c("bv", "rh"),
              vec_sex         = c("Bull", "Cow"),
              report_text     = paste0('## Comparison Of Plots\nPlots compare estimates of Mastitisresistance (MAR) for {tolower(sex)}',
                                       ' of breed {breed}',
                                       ' between GE-run {pn_prev_ge_label}',
                                       ' on the left and the current GE-run {pn_prev_ge_label}',
                                       ' on the right.', collapse = "")))
}


## -- Defaults for LBE

#' @title Default Plot Options For LBE
#'
#' @description
#' Return a list with specific defaults and constants that are used
#' to produce the comparison plot report for the trait group
#' Lineare Beschreibung (LBE).
#'
get_default_plot_opts_lbe <- function(){
  # return list of default options
  return(list(ge_dir_stem     = "/qualstorzws01/data_zws/lbe/work",
              arch_dir_stem   = "/qualstorzws01/data_archiv/zws",
              rmd_templ       = system.file("templates/compare_plots.Rmd.template", package = 'qgert'),
              rmd_report_stem = "ge_plot_report_lbe",
              vec_breed       = c("bv", "je", "rh"),
              vec_sex         = c("Bull", "Cow"),
              report_text     = paste0('## Comparison Of Plots\nPlots compare estimates of Lineare Beschreibung (LBE) for {tolower(sex)}',
                                       ' of breed {breed}',
                                       ' between GE-run {pn_prev_ge_label}',
                                       ' on the left and the current GE-run {pn_cur_ge_label}',
                                       ' on the right.', collapse = "")))
}


## -- Defaults for LBE_RH

#' @title Default Plot Options For LBE_RH
#'
#' @description
#' Return a list with specific defaults and constants that are used
#' to produce the comparison plot report for the trait group
#' Lineare Beschreibung for RH (LBE_RH).
#'
get_default_plot_opts_lbe_rh <- function(){
  # return list of default options
  return(list(ge_dir_stem     = "/qualstorzws01/data_zws/lbe_rh/work",
              arch_dir_stem   = "/qualstorzws01/data_archiv/zws",
              rmd_templ       = system.file("templates/compare_plots.Rmd.template", package = 'qgert'),
              rmd_report_stem = "ge_plot_report_lbe_rh",
              vec_breed       = c("rh"),
              vec_sex         = c("Bull", "Cow"),
              report_text     = paste0('## Comparison Of Plots\nPlots compare estimates of Lineare Beschreibung for RH (LBE_RH) for {tolower(sex)}',
                                       ' of breed {breed}',
                                       ' between GE-run {pn_prev_ge_label}',
                                       ' on the left and the current GE-run {pn_cur_ge_label}',
                                       ' on the right.', collapse = '')))
}


## -- Defaults for PROD

#' @title Default Plot Options For PROD
#'
#' @description
#' Return a list with specific defaults and constants that are used
#' to produce the comparison plot report for the trait group
#' Production (PROD).
#'
get_default_plot_opts_prod <- function(){
  # return list of default options
  return(list(ge_dir_stem     = "/qualstorzws01/data_zws/prod/work",
              arch_dir_stem   = "/qualstorzws01/data_archiv/zws",
              rmd_templ       = system.file("templates/compare_plots.Rmd.template", package = 'qgert'),
              rmd_report_stem = "ge_plot_report_prod",
              vec_breed       = c("bv", "je", "rh"),
              vec_sex         = c("Bull", "Cow"),
              report_text     = paste0('## Comparison Of Plots\nPlots compare estimates of Production (PROD) for {tolower(sex)}',
                                       ' of breed {breed}',
                                       ' between GE-run {pn_prev_ge_label}',
                                       ' on the left and the current GE-run {pn_cur_ge_label}',
                                       ' on the right.', collapse = '')))
}


## -- Defaults for VRDGGOZW

#' @title Default Plot Options For VRDGGOZW
#'
#' @description
#' Return a list with specific defaults and constants that are used
#' to produce the comparison plot report for genomic breeding values
#' (VRDGGOZW).
#'
get_default_plot_opts_vrdggozw <- function(){
  # return list of default options
  return(list(ge_dir_stem     = '/qualstorzws01/data_zws/calcVRDGGOZW/result',
              arch_dir_stem   = '/qualstorzws01/data_archiv/zws',
              rmd_templ       = system.file('templates/compare_plots.Rmd.template', package = 'qgert'),
              rmd_report_stem = 'ge_plot_report_vrdggozw',
              vec_breed       = c('bv', 'ob', 'rh', 'sf', 'si', 'lm'),
              vec_zw_type     = c('VRZW', 'DGZW', 'GOZW'),
              report_text     = '## Comparison Of Plots\nPlots compare estimates of ZW-type {zwt} for breed {breed} between GE-run {pn_prev_ge_label} on the left and the current GE-run {pn_cur_ge_label} on the right.'))
}


## -- Defaults for VRDGGOZW_PROV

#' @title Default Plot Options For VRDGGOZW_PROV
#'
#' @description
#' Return a list with specific defaults and constants that are used
#' to produce the comparison plot report for preliminary genomic breeding values
#' (VRDGGOZW_PROV) based on previous run ITB_BVs.
#'
get_default_plot_opts_vrdggozw_prov <- function(){
  # return list of default options
  return(list(ge_dir_stem     = '/qualstorzws01/data_projekte/projekte/calcVRDGGOZW/result',
              arch_dir_stem   = '/qualstorzws01/data_archiv/zws',
              rmd_templ       = system.file('templates/compare_plots.Rmd.template', package = 'qgert'),
              rmd_report_stem = 'ge_plot_report_vrdggozw_prov',
              vec_breed       = c('bv', 'ob', 'rh', 'sf', 'si', 'lm'),
              vec_zw_type     = c('VRZW', 'DGZW', 'GOZW'),
              report_text     = '## Comparison Of Plots\nPlots compare estimates of ZW-type {zwt} for breed {breed} between GE-run {pn_prev_ge_label} on the left and the current GE-run {pn_cur_ge_label} on the right.'))
}


## -- Defaults for ITB

#' @title Default Plot Options For ITB
#'
#' @description
#' Return a list with specific defaults and constants that are used
#' to produce the comparison plot report for the trait group
#' Interbull (ITB).
#'
get_default_plot_opts_itb <- function(){
  # return list of default options
  return(list(ge_dir_stem     = "/qualstorzws01/data_zws/itb/work",
              arch_dir_stem   = "/qualstorzws01/data_archiv/zws",
              rmd_templ       = system.file("templates/compare_plots.Rmd.template", package = 'qgert'),
              rmd_report_stem = "ge_plot_report_itb",
              vec_breed       = c("bv", "je", "rh"),
              report_text     = paste0('## Comparison Of Plots\nPlots compare estimates of Interbull (ITB) for breed {breed}',
                                       ' between GE-run {pn_prev_ge_label}',
                                       ' on the left and the current GE-run {pn_cur_ge_label}',
                                       ' on the right.', collapse = '')))
}


## -- Defaults for CNVRH

#' @title Default Plot Options For CNVRH
#'
#' @description
#' Return a list with specific defaults and constants that are used
#' to produce the comparison plot report for the trait group
#' Interbull (CNVRH).
#'
get_default_plot_opts_cnvrh <- function(){
  # return list of default options
  return(list(ge_dir_stem     = "/qualstorzws01/data_zws/convert/work",
              arch_dir_stem   = "/qualstorzws01/data_archiv/zws",
              rmd_templ       = system.file("templates/compare_plots.Rmd.template", package = 'qgert'),
              rmd_report_stem = "ge_plot_report_cnvrh",
              vec_breed       = c("rh"),
              report_text     = paste0('## Comparison Of Plots\nPlots compare estimates of converted cow proofs (CNVRH) for breed {breed}',
                                       ' between GE-run {pn_prev_ge_label}',
                                       ' on the left and the current GE-run {pn_cur_ge_label}',
                                       ' on the right.', collapse = '')))
}


#' @title Default Plot Options For GAL
#'
#' @description
#' Return a list with specific defaults and constants that are used
#' to produce the plot comparison report for the trait group
#' Geburtsablauf (GAL).
#'
get_default_plot_opts_gal <- function(){
  # return list of default options
  return(list(ge_dir_stem     = "/qualstorzws01/data_zws/gal/work",
              arch_dir_stem   = "/qualstorzws01/data_archiv/zws",
              rmd_templ       = system.file("templates/compare_plots.Rmd.template", package = 'qgert'),
              rmd_report_stem = "ge_plot_report_gal",
              vec_breed       = c("bv", "rh"),
              gebv_subdir     = c("YearMinus0"),
              garch_subdir    = c("YearMinus0"),
              vec_comparisons = c("Direkt", "Maternal"),
              report_text     = paste0('## Comparison Of Plots\n',
                                       'Plots compare estimates of Geburtsablauf (gal) for effect {comp}',
                                       ' of breed {breed}',
                                       ' between GE-run {pn_prev_ge_label}',
                                       ' on the left and the current GE-run {pn_cur_ge_label}',
                                       ' on the right.', collapse = '')))
}


#' @title Default Plot Options For GS DEREG
#'
#' @description
#' Return a list with specific defaults and constants that are used
#' to produce the plot comparison report for the de/regression (GS DEREG).
#'
get_default_plot_opts_gs_dereg <- function(){
  # return list of default options
  return(list(ge_dir_stem     = "/qualstorzws01/data_zws/gs/work",
              arch_dir_stem   = "/qualstorzws01/data_archiv/zws",
              rmd_templ       = system.file("templates/compare_plots.Rmd.template", package = 'qgert'),
              rmd_report_stem = "ge_plot_report_gs_dereg",
              vec_breed       = c("bv", "ob", "rh", "sf", "si"),
              vec_comparisons = c("full", "reduced"),
              report_text     = paste0('## Comparison Of Plots\n',
                                       'Plots compare de-regressed values for effect {comp}',
                                       ' of breed {breed}',
                                       ' between GE-run {pn_prev_ge_label}',
                                       ' on the left and the current GE-run {pn_cur_ge_label}',
                                       ' on the right.', collapse = '')))
}

#' @title Default Plot Options For CAS
#'
#' @description
#' Return a list with specific defaults and constants that are used
#' to produce the plot comparison report for the de/regression (CAS).
#'
get_default_plot_opts_cas <- function(){
  # return list of default options
  return(list(ge_dir_stem     = "/qualstorzws01/data_zws/cas/work",
              arch_dir_stem   = "/qualstorzws01/data_archiv/zws",
              rmd_templ       = system.file("templates/compare_plots.Rmd.template", package = 'qgert'),
              rmd_report_stem = "ge_plot_report_cas",
              vec_breed       = c("bv", "rh"),
              vec_sex         = c("Bull", "Cow")))
}

## -- Defaults for WEANING ---------------------------------------------------

#' @title Default Plot Options For WEANING
#'
#' @description
#' Return a list with specific defaults and constants that are used
#' to produce the comparison plot report for the trait group
#' WEANING.
#'
get_default_plot_opts_weaning <- function(){
  # return list of default options
  return(list(ge_dir_stem     = "/qualstorzws01/data_zws/vms/work/AG",
              arch_dir_stem   = "/qualstorzws01/data_archiv/zws",
              rmd_templ       = system.file("templates/compare_plots.Rmd.template", package = 'qgert'),
              rmd_report_stem = "ge_plot_report_weaning",
              report_text     = paste0('## Comparison Of Plots\nPlots compare estimates of Weaning',
                                       ' between GE-run {pn_prev_ge_label}',
                                       ' on the left and the current GE-run {pn_cur_ge_label}',
                                       ' on the right.', collapse = '')))
}


## -- Defaults for CALVING BEEF ---------------------------------------------------

#' @title Default Plot Options For CALVING BEEF
#'
#' @description
#' Return a list with specific defaults and constants that are used
#' to produce the comparison plot report for the trait group
#' CALVING BEEF
#'
get_default_plot_opts_calving_beef <- function(){
  # return list of default options
  return(list(ge_dir_stem     = "/qualstorzws01/data_zws/vms/work/GA_BEEF",
              arch_dir_stem   = "/qualstorzws01/data_archiv/zws",
              rmd_templ       = system.file("templates/compare_plots.Rmd.template", package = 'qgert'),
              rmd_report_stem = "ge_plot_report_calving_beef",
              report_text     = paste0('## Comparison Of Plots\nPlots compare estimates of Calving Beef',
                                       ' between GE-run {pn_prev_ge_label}',
                                       ' on the left and the current GE-run {pn_cur_ge_label}',
                                       ' on the right.', collapse = '')))
}

## -- Defaults for CALVING DAIRY ---------------------------------------------------

#' @title Default Plot Options For CALVING DAIRY
#'
#' @description
#' Return a list with specific defaults and constants that are used
#' to produce the comparison plot report for the trait group
#' CALVING DAIRY
#'
get_default_plot_opts_calving_dairy <- function(){
  # return list of default options
  return(list(ge_dir_stem     = "/qualstorzws01/data_zws/vms/work/GA_DAIRY",
              arch_dir_stem   = "/qualstorzws01/data_archiv/zws",
              rmd_templ       = system.file("templates/compare_plots.Rmd.template", package = 'qgert'),
              rmd_report_stem = "ge_plot_report_calving_dairy",
              report_text     = paste0('## Comparison Of Plots\nPlots compare estimates of Calving Dairy',
                                       ' between GE-run {pn_prev_ge_label}',
                                       ' on the left and the current GE-run {pn_cur_ge_label}',
                                       ' on the right.', collapse = '')))
}

## -- Defaults for CARCASS_SMK ---------------------------------------------------

#' @title Default Plot Options For CARCASS_SMK
#'
#' @description
#' Return a list with specific defaults and constants that are used
#' to produce the comparison plot report for the trait group
#' CARCASS_SMK
#'
get_default_plot_opts_carcass_smk <- function(){
  # return list of default options
  return(list(ge_dir_stem     = "/qualstorzws01/data_zws/vms/work/FLP_BK",
              arch_dir_stem   = "/qualstorzws01/data_archiv/zws",
              rmd_templ       = system.file("templates/compare_plots.Rmd.template", package = 'qgert'),
              rmd_report_stem = "ge_plot_report_carcass_smk",
              report_text     = paste0('## Comparison Of Plots\nPlots compare estimates of Carcass-BK',
                                       ' between GE-run {pn_prev_ge_label}',
                                       ' on the left and the current GE-run {pn_cur_ge_label}',
                                       ' on the right.', collapse = '')))
}

## -- Defaults for CARCASS_SMN ---------------------------------------------------

#' @title Default Plot Options For CARCASS_SMN
#'
#' @description
#' Return a list with specific defaults and constants that are used
#' to produce the comparison plot report for the trait group
#' CARCASS
#'
get_default_plot_opts_carcass_smn <- function(){
  # return list of default options
  return(list(ge_dir_stem     = "/qualstorzws01/data_zws/vms/work/FLP_NB",
              arch_dir_stem   = "/qualstorzws01/data_archiv/zws",
              rmd_templ       = system.file("templates/compare_plots.Rmd.template", package = 'qgert'),
              rmd_report_stem = "ge_plot_report_carcass_smn",
              report_text     = paste0('## Comparison Of Plots\nPlots compare estimates of Carcass-NB',
                                       ' between GE-run {pn_prev_ge_label}',
                                       ' on the left and the current GE-run {pn_cur_ge_label}',
                                       ' on the right.', collapse = '')))
}

## -- Defaults for CARCASS_SMT ---------------------------------------------------

#' @title Default Plot Options For CARCASS_SMT
#'
#' @description
#' Return a list with specific defaults and constants that are used
#' to produce the comparison plot report for the trait group
#' CARCASS
#'
get_default_plot_opts_carcass_smt <- function(){
  # return list of default options
  return(list(ge_dir_stem     = "/qualstorzws01/data_zws/vms/work/FLP_BT",
              arch_dir_stem   = "/qualstorzws01/data_archiv/zws",
              rmd_templ       = system.file("templates/compare_plots.Rmd.template", package = 'qgert'),
              rmd_report_stem = "ge_plot_report_carcass_smt",
              report_text     = paste0('## Comparison Of Plots\nPlots compare estimates of Carcass-BT',
                                       ' between GE-run {pn_prev_ge_label}',
                                       ' on the left and the current GE-run {pn_cur_ge_label}',
                                       ' on the right.', collapse = '')))
}

## --- Defaults for TEM BV ----------------------------------------------------
#'
#' @title Default Plot Options For TEM BV
#'
#' @description
#' Return a list with specific defaults and constants that are used
#' to produce the comparison plot report for the trait group
#' TEM BV
#'
get_default_plot_opts_tem_bv <- function() {
  # return defaults
  return(list(ge_dir_stem     = "/qualstorzws01/data_zws/tem/work",
              arch_dir_stem   = "/qualstorzws01/data_archiv/zws",
              rmd_templ       = system.file("templates/compare_plots.Rmd.template", package = 'qgert'),
              rmd_report_stem = "ge_plot_report_tem_bv",
              vec_breed       = c("bv"),
              vec_sex         = c("Bull", "Cow"),
              report_text     = paste0('## Comparison Of Plots\nPlots compare estimates of Milking Temperament for BV (TEM_BV) for {tolower(sex)}',
                                       ' of breed {breed}',
                                       ' between GE-run {pn_prev_ge_label}',
                                       ' on the left and the current GE-run {pn_cur_ge_label}',
                                       ' on the right.', collapse = '')))
}
