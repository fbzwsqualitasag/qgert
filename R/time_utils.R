#' ---
#' title: "Computing Utilities With Date-Times"
#' date: "2020-02-06"
#' author: "Peter von Rohr"
#' ---
#'
#' ## Disclaimer
#' This file was added because the function is considered useful and it was
#' nowhere else to put it. Hence with this, we believe it could be carried
#' along and used in other places.
#'
#'
#' @title Compute Age in Days
#'
#' @description
#' By default the age in days is computed. If age on different date should be
#' computed use pdate_today with a different values. In case you want to get
#' a real number as the age, then use pb_floor = FALSE.
#'
#' @details
#' The function is based on https://stackoverflow.com/questions/14454476/get-the-difference-between-dates-in-terms-of-weeks-months-quarters-and-years
#'
#' @param pdate_birth date of birth
#' @param pdate_today todays date
#' @param pb_floor should age in days be rounded down
#' @return age in days
#' @export age_in_days
age_in_days <- function(pdate_birth,
                        pdate_today = lubridate::today(),
                        pb_floor    = TRUE){
  result_age <- lubridate::interval(start = pdate_birth, end = pdate_today) / lubridate::duration(num = 1, units = "days")
  if (pb_floor){
    return(as.integer(floor(result_age)))
  }
  return(result_age)

}






