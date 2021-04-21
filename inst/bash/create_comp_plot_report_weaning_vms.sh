#!/bin/bash
#' ---
#' title: Create Comparison Plot Report
#' date:  2020-09-28 16:43:33
#' author: Sophie Kunz
#' ---
#' ## Purpose
#' This shell script is a wrapper to the R-package `qgert` which creates the comparison
#' plot reports. There is a separate shell script for every trait-group. The trait
#' group is determined by the variable `TRAIT` defined below.
#'
#' ## Description
#' The wrapper sets a number of variables that define the input parameters for report
#' creator function inside of the R-package `qgert`. The R-function call is done via
#' Rscript -e which takes a string that contains the function call.
#'
#' ## Set Directives
#' General behavior of the script is driven by the following settings
#+ bash-env-setting, eval=FALSE
set -o errexit    # exit immediately, if single command exits with non-zero status
set -o nounset    # treat unset variables as errors
set -o pipefail   # return value of pipeline is value of last command to exit with non-zero status
                  #  hence pipe fails if one command in pipe fails


#' ## Global Constants
#' ### Paths to shell tools
#+ shell-tools, eval=FALSE
ECHO=/bin/echo                             # PATH to echo                            #
DATE=/bin/date                             # PATH to date                            #
MKDIR=/bin/mkdir                           # PATH to mkdir                           #
BASENAME=/usr/bin/basename                 # PATH to basename function               #
DIRNAME=/usr/bin/dirname                   # PATH to dirname function                #

#' ### Directories
#' Installation directory of this script
#+ script-directories, eval=FALSE
INSTALLDIR=`$DIRNAME ${BASH_SOURCE[0]}`    # installation dir of bashtools on host   #

#' ### Files
#' This section stores the name of this script and the
#' hostname in a variable. Both variables are important for logfiles to be able to
#' trace back which output was produced by which script and on which server.
#+ script-files, eval=FALSE
SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
SCRIPT=`$BASENAME ${BASH_SOURCE[0]}`       # Set Script Name variable                #
SERVER=`hostname`                          # put hostname of server in variable      #

#' ### Trait
#' The trait abbreviation used in this comparison plot report
#+ trait-abbrev
TRAIT=weaning

#' ## Functions
#' The following definitions of general purpose functions are local to this script.
#'
#' ### Usage Message
#' Usage message giving help on how to use the script.
#+ usg-msg-fun, eval=FALSE
usage () {
  local l_MSG=$1
  $ECHO "Usage Error: $l_MSG"
  $ECHO "Usage: $SCRIPT -c <current_evaluation_label> -p <previous_evaluation_label>"
  $ECHO "  where -c <current_evaluation_label>  --  label of current evaluation, given by %YY%mm of publication date"
  $ECHO "        -p <previous_evaluation_label>  -- label of previous evaluation"
  $ECHO "        -u                              -- optional argument to force update of R-package"
  $ECHO "        -b <specific_breed>             -- specify a single breed, can eiter be {bv, je, rh}"
  $ECHO ""
  exit 1
}

#' ### Start Message
#' The following function produces a start message showing the time
#' when the script started and on which server it was started.
#+ start-msg-fun, eval=FALSE
start_msg () {
  $ECHO "********************************************************************************"
  $ECHO "Starting $SCRIPT at: "`$DATE +"%Y-%m-%d %H:%M:%S"`
  $ECHO "Server:  $SERVER"
  $ECHO
}

#' ### End Message
#' This function produces a message denoting the end of the script including
#' the time when the script ended. This is important to check whether a script
#' did run successfully to its end.
#+ end-msg-fun, eval=FALSE
end_msg () {
  $ECHO
  $ECHO "End of $SCRIPT at: "`$DATE +"%Y-%m-%d %H:%M:%S"`
  $ECHO "********************************************************************************"
}

#' ### Log Message
#' Log messages formatted similarly to log4r are produced.
#+ log-msg-fun, eval=FALSE
log_msg () {
  local l_CALLER=$1
  local l_MSG=$2
  local l_RIGHTNOW=`$DATE +"%Y%m%d%H%M%S"`
  $ECHO "[${l_RIGHTNOW} -- ${l_CALLER}] $l_MSG"
}


#' ## Main Body of Script
#' The main body of the script starts here.
#+ start-msg, eval=FALSE
start_msg

#' ## Getopts for Commandline Argument Parsing
#' If an option should be followed by an argument, it should be followed by a ":".
#' Notice there is no ":" after "h". The leading ":" suppresses error messages from
#' getopts. This is required to get my unrecognized option code to work.
#+ getopts-parsing, eval=FALSE
CURGE=""
PREVGE=""
PACKAGEUPDATE=""
while getopts ":c:p:uh" FLAG; do
  case $FLAG in
    h) # produce usage message
      usage "Help message for $SCRIPT"
      ;;
    c) # specify label of current GE
      CURGE=$OPTARG
      ;;
    p) # specify label of previous GE
      PREVGE=$OPTARG
      ;;
    u) # specify whether update of package zwsroutine is needed
      PACKAGEUPDATE=TRUE
      ;;
    :)
      usage "-$OPTARG requires an argument"
      ;;
    ?)
      usage "Invalid command line argument (-$OPTARG) found"
      ;;
  esac
done

shift $((OPTIND-1))  #This tells getopts to move on to the next argument.

#' ## Checks for Command Line Arguments
#' The following statements are used to check whether required arguments
#' have been assigned with a non-empty value
#+ argument-test, eval=FALSE
if test "$CURGE" == ""; then
  usage "-c <current_ge_label> not defined"
fi

if test "$PREVGE" == ""; then
  usage "-p <previous_ge_label> not defined"
fi


#' ## Creation of comparison plot reports
#' This is the beginning of the main part of the creation of the comparison plot reports.
#' After setting directory variables, the parameter file of the current evaluation run
#' is sourced to get all variables from the input parameters.
#+ dir-settings
EVAL_DIR=$(dirname $SCRIPT_DIR)
PROG_DIR=$EVAL_DIR/prog
PAR_DIR=$EVAL_DIR/par
log_msg $SCRIPT 'Basic directories and source parameters set'
log_msg $SCRIPT "EVAL_DIR=$EVAL_DIR"
log_msg $SCRIPT "PROG_DIR=$PROG_DIR"
log_msg $SCRIPT "PAR_DIR=$PAR_DIR"

#' The current working directory is changed to the evaluation directory
#+ cd-eval-dir
cd $EVAL_DIR

#' ### R-Package Check
#' Before running the report creation, we check whether the required R-packages are installed
#+ r-package-check
Rscript -e 'vec_req_cran_pkg <- c("devtools", "R.utils", "fs");vec_pkgidx_to_install <- (!is.element(vec_req_cran_pkg, installed.packages()));install.packages(vec_req_cran_pkg[vec_pkgidx_to_install], lib = "/home/zws/lib/R/library", repos="https://cran.rstudio.com")'

#' ### Update
#' In case package update was specified, then update, otherwise only if package is not available
#+ update-qgert
if [ "$PACKAGEUPDATE" == "TRUE" ]
then
  # update anyway
  Rscript -e 'devtools::install_github("pvrqualitasag/qgert", lib = "/home/zws/lib/R/library")'
else
  # check whether qgert are installed
  Rscript -e 'if (!is.element("qgert", installed.packages())) devtools::install_github("pvrqualitasag/qgert", lib = "/home/zws/lib/R/library")'
fi

#' ## Report Creation
#' The report for the specified trait is created.
#+ create-report
Rscript -e "qgert::create_ge_compare_plot_report_${TRAIT}(pn_cur_ge_label=${CURGE}, pn_prev_ge_label = ${PREVGE})"


#' ## End of Script
#+ end-msg, eval=FALSE
end_msg

