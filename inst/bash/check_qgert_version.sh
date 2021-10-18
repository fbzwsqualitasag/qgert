#!/bin/bash
#' ---
#' title: Check Version of QGERT
#' date:  2021-10-18 09:02:24
#' author: Peter von Rohr
#' ---
#' ## Purpose
#' Seamless check of package version
#'
#' ## Description
#' Checking installed version of R-package qgert
#'
#' ## Details
#' Use of R-function 'packageVersion()'
#'
#' ## Example
#' ./inst/bash/check_qgert_version -sh -m dom -u zws -i sizws
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
  $ECHO "Usage: $SCRIPT -a -m <server_name> -u <user_name> -i <instance_name>"
  $ECHO "  where -a                   --  optional, run update on all servers"
  $ECHO "        -m <server_name>     --  optional, run package update on single server"
  $ECHO "        -u <user_name>       --  optional username to run update on"
  $ECHO "        -i <instance_name>   --  optional singularity instance name"
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


#' ### Package Version Check From Container
#' Package version is checked from inside of container
#+ check-pkg-version-simg-fun
check_pkg_version_simg () {
  R -e "packageVersion('qgert')"
}

#' ### Package Version Check From Host
#' Check package version from host
#+ check-pkg-version-simg-host-fun
check_pkg_version_simg_host () {
  singularity exec instance://$SIMGINSTANCENAME R -e "packageVersion('qgert')"
}

#' ### Main Version Check
#' Package version check depending on server and whether on host or in container
#+ check-pkg-version-fun
check_pkg_version () {
  local l_SERVER=$1
  log_msg 'check_pkg_version' "Running update on $l_SERVER"
  if [ "$l_SERVER" == "$SERVER" ]
  then
    # check whether we run in container
    if [ `env | grep -i singularity | wc -l` -gt 0 ]
    then
      check_pkg_version_simg
    else
      check_pkg_version_simg_host
    fi
  else
    SIMG_CMD="singularity exec instance://$SIMGINSTANCENAME R -e 'packageVersion(\"qgert\")'"
    ssh ${USERNAME}@$l_SERVER "$SIMG_CMD"
  fi

}

#' ## Main Body of Script
#' The main body of the script starts here with a start script message.
#+ start-msg, eval=FALSE
start_msg

#' ## Getopts for Commandline Argument Parsing
#' If an option should be followed by an argument, it should be followed by a ":".
#' Notice there is no ":" after "h". The leading ":" suppresses error messages from
#' getopts. This is required to get my unrecognized option code to work.
#+ getopts-parsing, eval=FALSE
SERVERS=(beverin castor dom eiger niesen speer titlis)
SERVERNAME=""
USERNAME=zws
SIMGINSTANCENAME=sizws
RUNONALLSERVERS=FALSE
while getopts ":ai:m:u:h" FLAG; do
  case $FLAG in
    h)
      usage "Help message for $SCRIPT"
      ;;
    a)
      RUNONALLSERVERS='TRUE'
      ;;
    i)
      SIMGINSTANCENAME=$OPTARG
      ;;
    m)
      SERVERNAME=$OPTARG
      ;;
    u)
      USERNAME=$OPTARG
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

#' ## Run Updates
#' Decide whether to run the update on one server or on all servers on the list
#+ server-update
if [ "$SERVERNAME" != "" ]
then
  log_msg "$SCRIPT" " * Upate on given server: $SERVERNAME ..."
  check_pkg_version $SERVERNAME
else
  if [ "$RUNONALLSERVERS" == 'TRUE' ]
  then
    log_msg "$SCRIPT" " * Upate on all servers ..."
    for s in ${SERVERS[@]}
    do
      check_pkg_version $s
      sleep 2
    done
  else
    log_msg "$SCRIPT" " * No servername and no option -a ..."
  fi
fi



#' ## End of Script
#' This is the end of the script with an end-of-script message.
#+ end-msg, eval=FALSE
end_msg

