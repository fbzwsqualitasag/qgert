### #
### #
### #
### #   Purpose:   Functions Related to Logging
### #   started:   2019-10-03 (pvr)
### #
### # ############################################## ###

#' @title Create log4r Logger for package
#'
#' @param ps_logfile name of the logfile
#' @param ps_level logger level
#'
#' @return qgert_logger
#' @export get_qgert_logger
#'
#' @examples
#' \dontrun{
#' qgert_logger <- get_qgert_logger()
#' }
get_qgert_logger <- function(ps_logfile = 'qgert.log', ps_level = 'FATAL'){
  qgert_logger <- log4r::create.logger(logfile = ps_logfile, level = ps_level)
  return(qgert_logger)
}


#' @title Wrapper for log4r info
#'
#' @param plogger log4r logger object
#' @param ps_caller function from which we are called
#' @param ps_msg logging message
#'
#' @export qgert_log_info
#'
#' @examples
#' \dontrun{
#' qgert_logger <- get_qgert_logger()
#' qgert_log_level(qgert_logger, 'INFO')
#' qgert_log_info(qgert_logger, 'Examples', 'test message')
#' }
qgert_log_info <- function(plogger, ps_caller, ps_msg){
  s_msg <- paste0(ps_caller, ' -- ', ps_msg, collapse = '')
  log4r::info(logger = plogger, message = s_msg)
}


#' @title Wrapper for log4r debug
#'
#' @param plogger log4r logger object
#' @param ps_caller function from which we are called
#' @param ps_msg logging message
#'
#' @export qgert_log_debug
#'
#' @examples
#' \dontrun{
#' qgert_logger <- get_qgert_logger()
#' qgert_log_level(qgert_logger, 'DEBUG')
#' qgert_log_debug(qgert_logger, 'Examples', 'test message')
#' }
qgert_log_debug <- function(plogger, ps_caller, ps_msg){
  s_msg <- paste0(ps_caller, ' -- ', ps_msg, collapse = '')
  log4r::debug(logger = plogger, message = s_msg)
}


#' @title Wrapper for log4r warn
#'
#' @param plogger log4r logger object
#' @param ps_caller function from which we are called
#' @param ps_msg logging message
#'
#' @export qgert_log_warn
#'
#' @examples
#' \dontrun{
#' qgert_logger <- get_qgert_logger()
#' qgert_log_level(qgert_logger, 'WARN')
#' qgert_log_warn(qgert_logger, 'Examples', 'test message')
#' }
qgert_log_warn <- function(plogger, ps_caller, ps_msg){
  s_msg <- paste0(ps_caller, ' -- ', ps_msg, collapse = '')
  log4r::warn(logger = plogger, message = s_msg)
}


#' @title Wrapper for log4r error
#'
#' @param plogger log4r logger object
#' @param ps_caller function from which we are called
#' @param ps_msg logging message
#'
#' @export qgert_log_error
#'
#' @examples
#' \dontrun{
#' qgert_logger <- get_qgert_logger()
#' qgert_log_level(qgert_logger, 'ERROR')
#' qgert_log_error(qgert_logger, 'Examples', 'test message')
#' }
qgert_log_error <- function(plogger, ps_caller, ps_msg){
  s_msg <- paste0(ps_caller, ' -- ', ps_msg, collapse = '')
  log4r::error(logger = plogger, message = s_msg)
}


#' @title Wrapper for log4r fatal
#'
#' @param plogger log4r logger object
#' @param ps_caller function from which we are called
#' @param ps_msg logging message
#'
#' @export qgert_log_fatal
#'
#' @examples
#' \dontrun{
#' qgert_logger <- get_qgert_logger()
#' qgert_log_level(qgert_logger, 'FATAL')
#' qgert_log_fatal(qgert_logger, 'Examples', 'test message')
#' }
qgert_log_fatal <- function(plogger, ps_caller, ps_msg){
  s_msg <- paste0(ps_caller, ' -- ', ps_msg, collapse = '')
  log4r::fatal(logger = plogger, message = s_msg)
}


#' @title Wrapper to set the level of a logger
#'
#' @param plogger log4r logger object
#' @param ps_level new level of plogger
#'
#' @export qgert_log_level
#'
#' @examples
#' \dontrun{
#' qgert_logger <- get_qgert_logger()
#' qgert_log_level(qgert_logger, 'INFO')
#' }
qgert_log_level <- function(plogger, ps_level = c('DEBUG', 'INFO', 'WARN', 'ERROR', 'FATAL')){
  if (!missing(ps_level) & length(ps_level) > 1) stop(" *** ERROR in level(): only one 'level' allowed.")
  ps_level <- match.arg(ps_level)
  log4r::level(plogger) <- ps_level
}
