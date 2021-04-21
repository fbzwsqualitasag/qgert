#!/bin/bash
#' ---
#' title: Create TopLists BVCH
#' date:  2020-09-23 17:38:15
#' author: Peter von Rohr
#' ---
#' ## Purpose
#' Creation of xlsx-file with Bull-Toplists for BVCH
#'
#' ## Description
#' Wrapper script to create the xlsx-file with the Bull-Toplists for BVCH.
#'
#' ## Details
#' This script is a wrapper that calls the R-function create_toplist_bvch_bull().
#'
#' ## Example
#' ./create_tl_bvch -c 2008 -d fendt
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



#' ## Functions
#' The following definitions of general purpose functions are local to this script.
#'
#' ### Usage Message
#' Usage message giving help on how to use the script.
#+ usg-msg-fun, eval=FALSE
usage () {
  local l_MSG=$1
  $ECHO "Usage Error: $l_MSG"
  $ECHO "Usage: $SCRIPT -c <current_ge_label> -d <database_instance> -i <input_files>"
  $ECHO "  where -c <current_ge_label>   --  label of current genetic evaluation"
  $ECHO "        -d <database_instance>  --  name of the database instance from where input was exported"
  $ECHO "        -i <input_files>        --  input files as space separated string (optional)"
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

#' ### Create Dir
#' Specified directory is created, if it does not yet exist
#+ check-exist-dir-create-fun
check_exist_dir_create () {
  local l_check_dir=$1
  if [ ! -d "$l_check_dir" ]
  then
    log_msg check_exist_dir_create "CANNOT find directory: $l_check_dir ==> create it"
    $MKDIR -p $l_check_dir
  fi

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
CURRENTGE=''
DBINSTANCE='fendt'
DBEXDIR=''
INPUTFILES=(Toplisten_Stiere_BV.csv Toplisten_Stiere_OB.csv)
INPUTSTRING=''
while getopts ":c:d:i:h" FLAG; do
  case $FLAG in
    h)
      usage "Help message for $SCRIPT"
      ;;
    c)
      CURRENTGE=$OPTARG
      ;;
    d)
      DBINSTANCE=$OPTARG
      ;;
    i)
      INPUTSTRING=$OPTARG
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
if test "$CURRENTGE" == ""; then
  usage "-c <current_ge_label> not defined"
fi
if test "$DBINSTANCE" == ""; then
  usage "-d <database_instance> not defined"
fi


#' ## Check evaluation directory
#' This script must be run out of a subdirectory called 'prog'.
#+ dir-check, eval=FALSE
dir4check=$(echo $SCRIPT_DIR | rev | cut -d/ -f1 | rev)
if test "$dir4check" != "prog"; then
   >&2 echo "Error: This shell-script is not in a directory called prog"
   exit 1
fi

#' ## Change to evaluation directory
#' assign evaluation directory and change dir to it
#+ assign-eval-dir, eval=FALSE
EVAL_DIR=$(dirname $SCRIPT_DIR)
cd $EVAL_DIR


#' ## Data Exchange
#' Define data exchange directories
if [ "$DBINSTANCE" == 'rapid' ]
then
  DBEXDIR=/qualstorora01/argus/qualitas/zws
else
  DBEXDIR=/qualstororatest01/argus_${DBINSTANCE}/qualitas/zws
fi
log_msg "$SCRIPT" " * Database Exchange Dir: $DBEXDIR ..."


#' ## Check Inputfiles
#' Check whether input files are specified via -i
#+ check-input-files
if [ "$INPUTSTRING" != '' ]
then
  INPUTFILES=($INPUTSTRING)
fi
log_msg "$SCRIPT" " * Input files ..."
for i in "${INPUTFILES[@]}"
do
  echo $i
done


#' ## Get Input Data
#' First check whether data directory exist, if not create them
#+ check-create-datadir
DATADIR=$EVAL_DIR/data/$CURRENTGE
check_exist_dir_create $DATADIR


#' ## Copy Data
#' Input data is copied from database exchange directory. At the same time, the
#' input argument for the R-function 'create_toplist_bvch_bull' is created.
#+ copy-data
RINPUTARG="'"
for i in "${INPUTFILES[@]}"
do
  log_msg "$SCRIPT" " * Copy $i to $DATADIR ... "
  cp $DBEXDIR/$i $DATADIR
  if [ "$RINPUTARG" == "'" ]
  then
    RINPUTARG=${RINPUTARG}"$DATADIR/$i'"
  else
    RINPUTARG="${RINPUTARG}, '$DATADIR/$i'"
  fi
done
log_msg "$SCRIPT" " * R input argument: $RINPUTARG ..."

#' ## Result Directory
#' Check whether result directory exists, if not create it
#+ check-result-dir
RESULTDIR=$EVAL_DIR/work/bv/$CURRENTGE
check_exist_dir_create $RESULTDIR


#' ## Create Toplists
#' Toplists are created by a call to the R-function 'create_toplist_bvch_bull'.
#+ create-toplists
RESULTFILE="$RESULTDIR/Toplisten_Stiere_CHbv_${CURRENTGE}.xlsx"
log_msg "$SCRIPT" " * Resultfile: $RESULTFILE ..."
R -e "qgert::create_toplist_bvch_bull(ps_eval_label = '$CURRENTGE', pl_breed_input = list(breeds = c('BV', 'OB'), inputfiles = c($RINPUTARG), numbertop  = c(12, 5)), ps_xlsx_file = '$RESULTFILE')"


#' ## End of Script
#+ end-msg, eval=FALSE
end_msg

