#!/bin/bash
#
#
#
#   Purpose:   After a gs-run is finished, this script checks whether the required files are available.
#   Author:    Peter von Rohr <peter.vonrohr@qualitasag.ch>
#
#######################################################################

set -o errexit    # exit immediately, if single command exits with non-zero status
set -o nounset    # treat unset variables as errors
set -o pipefail   # return value of pipeline is value of last command to exit with non-zero status
                  # hence pipe fails if one command in pipe fails

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
SCRIPT=$(basename ${BASH_SOURCE[0]})
SERVER=`hostname`


# functions
#==========
# produce a start message
start_msg () {
    echo "********************************************************************************"
    echo "Starting $SCRIPT at: "`date +"%Y-%m-%d %H:%M:%S"`
    echo "Server:  $SERVER"
    echo ""
}

# produce an end message
end_msg () {
    echo ""
    echo "End of $SCRIPT at: "`date +"%Y-%m-%d %H:%M:%S"`
    echo "********************************************************************************"
}

### # functions related to logging
log_msg () {
  local l_CALLER=$1
  local l_MSG=$2
  local l_RIGHTNOW=`date +"%Y%m%d%H%M%S"`
  echo "[${l_RIGHTNOW} -- ${l_CALLER}] $l_MSG"
}

usage () {
    local l_MSG=$1
    >&2 echo "Usage Error: $l_MSG"
    >&2 echo "Usage: $SCRIPT -j <job_definition>"
    >&2 echo "       where   -j <job_definition> -- job definition either via file or via directory"
    >&2 echo "  optional arguments are:"
    >&2 echo "               -a                  -- to show all jobs, whether they are finished or not"
    >&2 echo ""
    exit 1
}

# show whether result files of a given path exist or not
show_results () {
  local l_run_path=$1
  for f in ${RESULTFILES[@]}
  do
    if [ -f "$l_run_path/$f" ]
    then
      echo -n ' * FOUND '
    else
      echo -n ' * CANNOT FIND '
    fi
    echo "$l_run_path/$f"
  done
  if [ -f "$l_run_path/BayesC.log" ]
  then
    tail -3 $l_run_path/BayesC.log
    ls -la $l_run_path/BayesC.log
  fi

}

# check whether required results files are present
check_run () {
  local l_run=$1
  local l_run_path=`tr '#' '/' <<< $l_run`
  local l_show="FALSE"
  log_msg check_run "run path set to: $l_run_path"
  # check whether run_path exists, if not stop here
  if [ ! -d "$l_run_path" ]
  then
    log_msg check_run "ERROR: Cannot find run path: $l_run_path"
    exit 1
  fi
  # if all jobs should be shown, run the loop over all files
  if [ "$SHOWALLJOBS" == "TRUE" ]
  then
    show_results $l_run_path
  else
    # check whether
    for f in ${FINISHEDFILES[@]}
    do
      if [ ! -f "$l_run_path/$f" ]
      then
        l_show="TRUE"
      fi
    done
    # if not all result files that indicate a finished job are found show the results
    if [ "$l_show" == "TRUE" ]
    then
      show_results $l_run_path
    fi
  fi
}

# ======================================================================
# Main part of the script starts here ...
start_msg

# Parse and check command line arguments
#=======================================
# Use getopts for commandline argument parsing
# If an option should be followed by an argument, it should be followed by a ":".
# Notice there is no ":" after "h". The leading ":" suppresses error messages from
# getopts. This is required to get my unrecognized option code to work.
RESULTFILES=(BayesC.mrkRes1 BayesC.cgrRes1 BayesC.cgrResSamples1 BayesC.out1 BayesC.log BayesC.ghatREL1)
FINISHEDFILES=(BayesC.mrkRes1 BayesC.cgrRes1 BayesC.ghatREL1)
JOBDEF=""
SHOWALLJOBS="FALSE"
while getopts ":j:ah" FLAG; do
    case $FLAG in
        h)
            usage "Help message for $SCRIPT"
        ;;
        a) # show all jobs
            SHOWALLJOBS="TRUE"
        ;;
        j) # specify the job definiton
            JOBDEF=$OPTARG
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

# Check whether required arguments have been specified
if test "$JOBDEF" == ""; then
    usage "-j job_definition not defined"
fi



# Check evaluation directory
#===========================
dir4check=$(echo $SCRIPT_DIR | rev | cut -d/ -f1 | rev)
if test "$dir4check" != "prog"; then
    >&2 echo "Error: This shell-script is not in a directory called prog"
    exit 1
fi

EVAL_DIR=$(dirname $SCRIPT_DIR)
log_msg $SCRIPT "Setting EVAL_DIR to $EVAL_DIR and cd to it ..."
cd $EVAL_DIR


# in case where JOBDEF is a file, then loop over entries
if [ -f "$JOBDEF" ]
then
  log_msg $SCRIPT "Checking runs in jobfile: $JOBDEF ..."
  cat $JOBDEF | while read run
  do
   log_msg $SCRIPT " * run: $run ..."
   check_run $run
  done
else
  log_msg $SCRIPT " * run: $JOBDEF ..."
  check_run $JOBDEF
fi


# ======================================================================
# Script ends here
end_msg
