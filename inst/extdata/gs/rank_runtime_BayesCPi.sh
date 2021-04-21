#!/bin/bash
###
###
###
###   Purpose:   
###   started:   2019-08-19 08:31:14 (pvr)
###
### ###################################################################### ###

set -o errexit    # exit immediately, if single command exits with non-zero status
set -o nounset    # treat unset variables as errors
set -o pipefail   # return value of pipeline is value of last command to exit with non-zero status
                  #  hence pipe fails if one command in pipe fails

# ======================================== # ======================================= #
# global constants                         #                                         #
# ---------------------------------------- # --------------------------------------- #
# prog paths                               #                                         #  
ECHO=/bin/echo                             # PATH to echo                            #
DATE=/bin/date                             # PATH to date                            #
BASENAME=/usr/bin/basename                 # PATH to basename function               #
DIRNAME=/usr/bin/dirname                   # PATH to dirname function                #
# ---------------------------------------- # --------------------------------------- #
# directories                              #                                         #
INSTALLDIR=`$DIRNAME ${BASH_SOURCE[0]}`    # installation dir of bashtools on host   #
# ---------------------------------------- # --------------------------------------- #
# files                                    #                                         #
SCRIPT=`$BASENAME ${BASH_SOURCE[0]}`       # Set Script Name variable                #
# ---------------------------------------- # --------------------------------------- #
# server name                              #                                         #
SERVER=`hostname`                          # put hostname of server in variable      #  
# ======================================== # ======================================= #

### # constants
GREPSTRING='iter 100 time to finish chain'
WORKDIR=/qualstorzws01/data_projekte/projekte/MAwidmer_twins/gs



### # ====================================================================== #
# Function definitions local to this script
#==========================================
usage () {
  local l_MSG=$1
  $ECHO "Usage Error: $l_MSG"
  $ECHO "Usage: $SCRIPT -r <run_definition>"
  $ECHO "  where    <run_definition>  --  specifies the BayesCPi run"
  $ECHO ""
  exit 1
}

### # produce a start message
start_msg () {
  $ECHO "********************************************************************************"
  $ECHO "Starting $SCRIPT at: "`$DATE +"%Y-%m-%d %H:%M:%S"`
  $ECHO "Server:  $SERVER"
  $ECHO
}

### # produce an end message
end_msg () {
  $ECHO
  $ECHO "End of $SCRIPT at: "`$DATE +"%Y-%m-%d %H:%M:%S"`
  $ECHO "********************************************************************************"
}

### # functions related to logging
log_msg () {
  local l_CALLER=$1
  local l_MSG=$2
  local l_RIGHTNOW=`$DATE +"%Y%m%d%H%M%S"`
  $ECHO "[${l_RIGHTNOW} -- ${l_CALLER}] $l_MSG"
}

### # function to get runtime of a given BayesCPi run
check_runtime () {
  local l_run=$1
  local l_rundir=`echo $l_run | sed -e "s/*//g" | sed -e "s/ //g" | tr '#' '/'`
  ### # grep for initial estimate of runtime
  if [ -f "$l_rundir/BayesCPi.log" ]
  then
    RESULTSTRING=`grep "$GREPSTRING" $l_rundir/BayesCPi.log  | cut -d ' ' -f8-13`
    # in case runtime is less then an hour, add 0 hours to output
    if [ `echo $RESULTSTRING | grep hour | wc -l` == "0" ]
    then
      echo "$l_run 0 hours $RESULTSTRING" >> $SORTOUTFILE
    else
      echo "$l_run $RESULTSTRING" >> $SORTOUTFILE
    fi  
  fi
}
### # ====================================================================== #
### # Main part of the script starts here ...
start_msg

### # ====================================================================== #
### # Use getopts for commandline argument parsing ###
### # If an option should be followed by an argument, it should be followed by a ":".
### # Notice there is no ":" after "h". The leading ":" suppresses error messages from
### # getopts. This is required to get my unrecognized option code to work.
RUNDEF=""
SORTOUTFILE="$WORKDIR/rank_runtime_BayesCPi.out"
while getopts ":r:h" FLAG; do
  case $FLAG in
    h)
      usage "Help message for $SCRIPT"
      ;;
    r)
      RUNDEF=$OPTARG
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

# Check whether required arguments have been defined
if test "$RUNDEF" == ""; then
  usage "-r <run_definition> not defined"
fi


### # change to working directory
cd $WORKDIR

### # if output file already exists, then delete it
if [ -f "$SORTOUTFILE" ]
then
  rm -rf $SORTOUTFILE
fi

### # distinguish whether $RUNDEF is a file of run definitions or just one definition
if [ -f "$RUNDEF" ]
then
  cat $RUNDEF | while read run
  do
    check_runtime $run
  done
else
  check_runtime $RUNDEF
fi

(echo "s_logfile_path <- '$SORTOUTFILE'";cat prog/get_sort_rt_list2.R) | R --vanilla --no_save


### # ====================================================================== #
### # Script ends here
end_msg



### # ====================================================================== #
### # What comes below is documentation that can be used with perldoc

: <<=cut
=pod

=head1 NAME

    - 

=head1 SYNOPSIS


=head1 DESCRIPTION

Rank BayesCPi Jobs according to estimated runtime in logfile


=head2 Requirements




=head1 LICENSE

Artistic License 2.0 http://opensource.org/licenses/artistic-license-2.0


=head1 AUTHOR

Peter von Rohr <peter.vonrohr@qualitasag.ch>


=head1 DATE

2019-08-19 08:31:14

=cut
