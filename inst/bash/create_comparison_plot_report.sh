#!/bin/bash
#' ---
#' title: Create Comparison Plot Report
#' date:  2021-08-18 15:56:16
#' author: Peter von Rohr
#' ---
#' ## Purpose
#' Seamless creation of comparison plot reports
#'
#' ## Description
#' Wrapper script for R-function to create comparison plot reports
#'
#' ## Details
#' This script takes two directories as arguments and calls the R-function to create a comparison plot report.
#'
#' ## Example
#' ./create_comparison_plot_report.sh -l <left_dir> -r <right_dir> -o <output_path>
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
SCRIPT=`$BASENAME ${BASH_SOURCE[0]}`       # Set Script Name variable                #
SERVER=`hostname`                          # put hostname of server in variable      #



#' ## Functions
#' The following definitions of general purpose functions are local to this script.
#'
#' ### Usage Message
#' Usage message giving help on how to use the script.
#+ usg-msg-fun, eval=FALSE
usage () {
  local l_MSG=$1
  $ECHO "Usage Error: $l_MSG"
  $ECHO "Usage: $SCRIPT -l <left_dir> -r <right_dir> -o <output_path>"
  $ECHO "  where -l <left_dir>     --              directory with plots shown in the left column of the report ..."
  $ECHO "        -r <right_dir>    --              directory with plots shown in the right column of the report ..."
  $ECHO "        -o <output_path>  --  (optional)  specify alternative output path for report ..."
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
LEFTDIR=""
RIGHTDIR=""
OUTPATH=""
while getopts ":l:r:o:h" FLAG; do
  case $FLAG in
    h)
      usage "Help message for $SCRIPT"
      ;;
    l)
      if test -d $OPTARG; then
        LEFTDIR=$OPTARG
      else
        usage "$OPTARG isn't a valid left-directory"
      fi
      ;;
    r)
      if test -d $OPTARG; then
        RIGHTDIR=$OPTARG
      else
        usage "$OPTARG isn't a valid right-directory"
      fi
      ;;
    o)
      OUTPATH=$OPTARG
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
if test "$LEFTDIR" == ""; then
  usage "-l <left_dir> not defined"
fi
if test "$RIGHTDIR" == ""; then
  usage "-r <right_dir> not defined"
fi



#' ## Report Generation
#' The two directories are used to call the R-function to create the comparison plot report
#+ generate-report
log_msg $SCRIPT " * Left directory: $LEFTDIR ..."
log_msg $SCRIPT " * Right directory: $RIGHTDIR ..."
R -e "qgert::create_comparison_plot_report(ps_right_dir = '$RIGHTDIR', ps_left_dir = '$LEFTDIR', ps_out_path = '$OUTPATH')"



#' ## End of Script
#+ end-msg, eval=FALSE
end_msg

