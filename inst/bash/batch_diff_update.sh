#!/bin/bash
#' ---
#' title: Batch Diff Between Files in Source and Target Paths
#' date:  2019-10-28 16:54:43
#' author: Peter von Rohr
#' ---
#' ## Purpose
#' Get differences between files in a source directory path and a target path.
#' When running in update mode move files that are different between source and
#' target from source to target.
#'
#' ## Description
#' In a loop over all files in the source directory, files with the same name
#' in the target directory are searched and the diff between the source and the
#' target version is computed. When specifying the update mode with the -u
#' commandline switch, the user is asked whether the target version of the file
#' should be updated with the source version.
#'
#' ## Bash Settings
#+ bash-env-setting, eval=FALSE
# set -o errexit   # with diff, this option cannot be used.
# set -o nounset    # treat unset variables as errors
# set -o pipefail   # return value of pipeline is value of last command to exit with non-zero status
                  # hence pipe fails if one command in pipe fails

#' ## Global Constants
#+ script-files, eval=FALSE
SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
SCRIPT=$(basename ${BASH_SOURCE[0]})
SERVER=`hostname`


#' ## Functions
#' The following function definitions are local to this script.
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

#' produce an end message
#+ end-msg-fun, eval=FALSE
end_msg () {
    echo ""
    echo "End of $SCRIPT at: "`date +"%Y-%m-%d %H:%M:%S"`
    echo "********************************************************************************"
}

#' Functions related to logging
#+ log-msg-fun, eval=FALSE
log_msg () {
  local l_CALLER=$1
  local l_MSG=$2
  local l_RIGHTNOW=`date +"%Y%m%d%H%M%S"`
  echo "[${l_RIGHTNOW} -- ${l_CALLER}] $l_MSG"
}

#' Usage message
#+ usage-msg-fun, eval=FALSE
usage () {
    local l_MSG=$1
    >&2 echo "Usage Error: $l_MSG"
    >&2 echo "Usage: $SCRIPT -s <source_path> -t <target_path> -u"
    >&2 echo "  where -s <source_path>  --  source path which determines which files are checked"
    >&2 echo "        -t <target_path>  --  target path to where source files are compared to"
    >&2 echo "  optional arguments are"
    >&2 echo "        -u                --  switch that does the update"
    >&2 echo ""
    exit 1
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
SRCPATH=""
TRGPATH=""
RUNUPDATE="FALSE"
while getopts ":s:t:uh" FLAG; do
    case $FLAG in
        h)
            usage "Help message for $SCRIPT"
        ;;
        s)
            if test -d $OPTARG; then
              SRCPATH=$OPTARG
            else
              usage "$OPTARG is not a valid source directory"
            fi
        ;;
        t)
            if test -d $OPTARG; then
              TRGPATH=$OPTARG
            else
              usage "$OPTARG is not a valid target directory"
            fi
        ;;
        u)
            RUNUPDATE="TRUE"
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
#' Source path and target path cannot be undefined and must
#' be specified as existing directories. The existence check
#' is done above during the commandline arguments parsing.
#+ argument-test, eval=FALSE
if test "$SRCPATH" == ""; then
    usage "-s <source_path> not defined"
fi
if test "$TRGPATH" == ""; then
    usage "-t <target_path> not defined"
fi


#' ## Source Path File Check
#' ### Build List of Source Files
#' We start by collecting all files in the source path into a list.
#' With this we can avoid the double read-statments, one that reads
#' the files names from the ls-output and one that reads the user-input.
#+ file-list
srcfiles=()
# ls -1 $SRCPATH | while read f
# do
  # log_msg $SCRIPT "Add source file $f to list ..."
  # srcfiles+=( ${f} )
# done
while read fle
do
  log_msg $SCRIPT "Add source file $fle to list ..."
  srcfiles+=( ${fle} )
done < <(ls -1 $SRCPATH)


#' ### Loop Over Source Files
#' Loop over all files in source path directory and compare them to
#' the files with the same name in the target directory, if such a
#' file exists in the target directory, otherwise it is noted with
#' a log-message. When running in update mode, the user is asked
#' whether the target file should be updated with the source version
#' of the file.
#+ check-src
INPUTANSWER=""
for i in ${!srcfiles[@]}
do
  f=${srcfiles[i]}
  log_msg $SCRIPT "Checking source path file: $f"
  if [ -f "$TRGPATH/$f" ]
  then
    log_msg $SCRIPT "Difference between $f in $SRCPATH and $TRGPATH ..."
    diff $SRCPATH/$f $TRGPATH/$f
  else
    log_msg $SCRIPT "CANNOT find $f in $TRGPATH"
  fi
  if [ "$RUNUPDATE" == "TRUE" ] && [ `diff $SRCPATH/$f $TRGPATH/$f | wc -l` != "0" ]
  then
    log_msg $SCRIPT "Ask for user input ..."
    read -p " * Update $f from $SRCPATH to $TRGPATH [y/n]: " INPUTANSWER
    if [ "$INPUTANSWER" == "y" ]
    then
      log_msg $SCRIPT "Updating $f from $SRCPATH to $TRGPATH ..."
      cp -p $SRCPATH/$f $TRGPATH
    fi
  fi
done


#' ## End of Script
#+ end-msg, eval=FALSE
end_msg
