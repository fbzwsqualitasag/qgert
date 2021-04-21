#!/bin/bash
#' ---
#' title: Split gsRuns-List Sorted According To Run-Time
#' date:  2019-10-30 06:48:21
#' author: Peter von Rohr
#' ---
#' ## Purpose
#' The file gsRuns.txt contains all runs for the gs effect estimation. This file is
#' called the gsRuns-list. In order to run estimation of effects and reliablities
#' in parallel, the complete gsRuns-list is split into batches. This distribution
#' of jobs into batches is done according to the predicted runtimes from previous
#' estimation runs.
#'
#' ## Description
#' {Write a paragraph about how the problems are solved.}
#'
#' ## Bash Settings
#+ bash-env-setting, eval=FALSE
set -o errexit    # exit immediately, if single command exits with non-zero status
set -o nounset    # treat unset variables as errors
set -o pipefail   # return value of pipeline is value of last command to exit with non-zero status
                  # hence pipe fails if one command in pipe fails

#' ## Global Constants
#' This section stores the directory of this script, the name of this script and the
#' hostname in a variable. Both variables are important for logfiles to be able to
#' trace back which output was produced by which script and on which server.
#+ script-files, eval=FALSE
SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
SCRIPT=$(basename ${BASH_SOURCE[0]})
SERVER=`hostname`


#' ## Functions
#' The following definitions of general purpose functions are local to this script.
#'
#' ### Start Message
#' The following function produces a start message showing the time
#' when the script started and on which server it was started.
#+ start-msg-fun, eval=FALSE
start_msg () {
    echo "********************************************************************************"
    echo "Starting $SCRIPT at: "`date +"%Y-%m-%d %H:%M:%S"`
    echo "Server:  $SERVER"
    echo ""
}

#' ### End Message
#' This function produces a message denoting the end of the script including
#' the time when the script ended. This is important to check whether a script
#' did run successfully to its end.
#+ end-msg-fun, eval=FALSE
end_msg () {
    echo ""
    echo "End of $SCRIPT at: "`date +"%Y-%m-%d %H:%M:%S"`
    echo "********************************************************************************"
}

#' ### Log Message
#' Log messages formatted similarly to log4r are produced.
#+ log-msg-fun, eval=FALSE
log_msg () {
  local l_CALLER=$1
  local l_MSG=$2
  local l_RIGHTNOW=`date +"%Y%m%d%H%M%S"`
  echo "[${l_RIGHTNOW} -- ${l_CALLER}] $l_MSG"
}

#' ### Usage Message
#' Usage message giving help on how to use the script.
#+ usage-msg-fun, eval=FALSE
usage () {
    local l_MSG=$1
    >&2 echo "Usage Error: $l_MSG"
    >&2 echo "Usage: $SCRIPT -g <gs_runs_list> "
    >&2 echo "  where -g <gs_runs_list>   --  specifies the gsRuns-list to be split"
    >&2 echo "        -d <log_dir>        --  either log directory or run label, e.g. 1904"
    >&2 echo "        -n <nr_split>       --  number of splits"
    >&2 echo "  optional arguments are"
    >&2 echo "        -k                  --  keep sorted outputfile of runtimes"
    >&2 echo "        -l <log_file>       --  alternative name for logfile"
    >&2 echo "        -m <missing_place>  --  runs with no logfile placed first instead of last"
    >&2 echo "        -v                  --  run in verbose mode"
    >&2 echo ""
    exit 1
}

#' ### Check Runtime For A Compute-Job
#' In the specified logfile, the function greps for the specified
check_runtime () {
  local l_run=$1
  local l_rundir=`echo $l_run | sed -e "s/*//g" | sed -e "s/ //g" | tr '#' '/'`
  local l_logpath=''
  ### # set the path to the log file
  if [ -f "$LOGDIR/$l_rundir/$LOGFILE" ]
  then
    l_logpath=$LOGDIR/$l_rundir/$LOGFILE
    ### # grep for initial estimate of runtime
    RESULTSTRING=`grep "$GREPSTRING" $l_logpath  | cut -d ' ' -f8-13`
  elif [ -f "$LOGDIR/$l_rundir/${LOGFILE}.gz" ]
  then
    l_logpath=$LOGDIR/$l_rundir/${LOGFILE}.gz
    ### # grep for initial estimate of runtime
    RESULTSTRING=`zgrep "$GREPSTRING" $l_logpath  | cut -d ' ' -f8-13`
  else
    log_msg 'check_runtime' "CANNOT FIND PATH to logfile: $LOGDIR/$l_rundir/$LOGFILE"
    if [ "$MISSING" == "first" ]
    then
      RESULTSTRING='9999 hours 00 minutes 00 seconds'
    else
      RESULTSTRING='0 hours 00 minutes 00 seconds'
    fi
  fi
  # check resultstring
  if [ "$VERBOSE" == 'TRUE' ];then log_msg 'check_runtime' "Result-string: $RESULTSTRING";fi
  # in case runtime is less then an hour, add 0 hours to output
  if [ `echo $RESULTSTRING | grep hour | wc -l` == "0" ]
  then
    echo "$l_run 0 hours $RESULTSTRING" >> $SORTOUTFILE
  else
    echo "$l_run $RESULTSTRING" >> $SORTOUTFILE
  fi
}

#' ## Main Body of Script
#' The main body of the script starts here.
#+ start-msg, eval=FALSE
start_msg

#' ## Parse and check command line arguments
#' Use getopts for commandline argument parsing
#' If an option should be followed by an argument, it should be followed by a ":".
#' Notice there is no ":" after "h". The leading ":" suppresses error messages from
#' getopts. This is required to get my unrecognized option code to work.
#+ getopts-parsing, eval=FALSE
GSSORTEDSTEM='gsSortedRuns.txt'
GSRUNSLIST=''
KEEPOUT='FALSE'
LOGDIR=''
LOGFILE='BayesC.log'
MISSING='last'
NRSPLIT=""
VERBOSE='FALSE'
while getopts ":d:g:kl:m:n:o:vh" FLAG; do
    case $FLAG in
        h)
            usage "Help message for $SCRIPT"
        ;;
        d)
            LOGDIR=$OPTARG
        ;;
        g)
            GSRUNSLIST=$OPTARG
        ;;
        k)
            KEEPOUT='TRUE'
        ;;
        l)
            LOGFILE=$OPTARG
        ;;
        m)
            MISSING=$OPTARG
        ;;
        n)
            NRSPLIT=$OPTARG
        ;;
        o)
            GSSORTEDSTEM=$OPTARG
        ;;
        v)
            VERBOSE='TRUE'
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

#' ## Check whether required arguments have been specified
#+ argument-test, eval=FALSE
if test "$GSRUNSLIST" == ""; then
    usage "-g <gs_runs_list> not defined"
fi
if test "$LOGDIR" == ""; then
    usage "-d <log_dir> not defined"
fi
if test "$NRSPLIT" == ""; then
    usage "-n <nr_split> not defined"
fi


#' ## Check evaluation directory
#+ dir-check, eval=FALSE
dir4check=$(echo $SCRIPT_DIR | rev | cut -d/ -f1 | rev)
if test "$dir4check" != "prog"; then
    >&2 echo "Error: This shell-script is not in a directory called prog"
    exit 1
fi

#' assign evaluation directory and change dir to it
#+ assign-eval-dir, eval=FALSE
EVAL_DIR=$(dirname $SCRIPT_DIR)
cd $EVAL_DIR
WORK_DIR=$EVAL_DIR/work


#' ## Check Log-directory
#' In case the the specified log_dir is not a directory, we assume that
#' it is a gs-run label and from that we construct a logdir in the
#' archive.
#+ log-dir
if [ ! -d "$LOGDIR" ]
then
  LOGDIR=/qualstorzws01/data_archiv/zws/$LOGDIR/gs
  if [ "$VERBOSE" == 'TRUE' ];then log_msg $SCRIPT "Re-setting log_dir to: $LOGDIR";fi
fi

#' ## Create SNP.bin file
#' For each breed one gs-run job must be specified to get the binary version of the input
#+ create-snp-bin
if [ -f "${GSRUNSLIST}.snpBin" ]
then
  rm ${GSRUNSLIST}.snpBin
fi
breeds=$(cut -d "#" -f 3 $GSRUNSLIST | sort -u)
for breed in $breeds; do
  grep "#$breed#" $GSRUNSLIST | grep eff | head -1 >> $WORK_DIR/${GSSORTEDSTEM}.snpBin
done
grep -v -f $WORK_DIR/${GSSORTEDSTEM}.snpBin $GSRUNSLIST > ${GSRUNSLIST}.no_snpBin

#' ## Extraction of Runtimes
#' The name of the output file for all runtimes is defined and the
#' the string which indicates the line to be extracted is given.
#+ def-out-file
SORTOUTFILE="$EVAL_DIR/work/rank_gsRuns_runtime.out"
GREPSTRING='iter 100 time to finish chain'

#' in case the output file already exists from a previous run, it is deleted
if [ -f "$SORTOUTFILE" ]
then
  rm -rf $SORTOUTFILE
fi

#' The following chunk allows to run the runtime extraction for a single
#' job or for a list of jobs given in $GSRUNSLIST
if [ -f "${GSRUNSLIST}.no_snpBin" ]
then
  cat ${GSRUNSLIST}.no_snpBin | while read run
  do
    if [ "$VERBOSE" == 'TRUE' ];then log_msg $SCRIPT "Checking runtime for: $run";fi
    check_runtime $run
  done
else
  log_msg $SCRIPT "CANNOT find runlist file: ${GSRUNSLIST}.no_snpBin ==> Stop here"
  exit 1
fi

#' ## Calling R-function to Produce Splits
#' The R-function split_gsruns_sorted_rt() is called to produce the splits of the gs-jobs
#+ split-jobs-with-r
R -e "qgert::split_gsruns_sorted_rt(ps_rt_in_file = '$SORTOUTFILE', ps_out_dir = '$WORK_DIR', pn_nr_split = $NRSPLIT, ps_out_file_stem = '$GSSORTEDSTEM')"


#' ## Cleaning Up Outputfile
#' In case the -k option was not specified, the output is removed
#+ clean-up-output
if [ "$KEEPOUT" == "FALSE" ]
then
  if [ "$VERBOSE" == 'TRUE' ];then log_msg $SCRIPT "Removing: ${GSRUNSLIST}.no_snpBin ...";fi
  rm -rf ${GSRUNSLIST}.no_snpBin
  if [ "$VERBOSE" == 'TRUE' ];then log_msg $SCRIPT "Removing: $SORTOUTFILE ...";fi
  rm -rf $SORTOUTFILE
fi


#' ## End of Script
#+ end-msg, eval=FALSE
end_msg

