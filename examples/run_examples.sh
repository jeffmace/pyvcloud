#!/bin/bash
# 
# Script to run all samples in order. 
#
# Usage: ./run_samples.sh [vcd_connection_file]
#
# where vcd_connection_file sets environmental variables to define the vCD 
# server connection. See vcd_connection.sample for the format. 
#
set -e

SHOME=`dirname $0`
cd $SHOME

SRCROOT=`cd ..; pwd`
cd $SRCROOT

# Get connection information.  If provided the file name must be absolute. 

if [ -n "$1" ]; then
  VCD_CONNECTION=$1
fi

if [ -z "$VCD_CONNECTION" ]; then
  VCD_CONNECTION=$HOME/vcd_connection
  if [ -e $HOME/vcd_connection ]; then
    echo "Using default vcd_connection file location: $VCD_CONNECTION"
  else
    echo "Must have $VCD_CONNECTION or give alternative file as argument"
    exit 0
  fi
fi

run_examples() {
  . test-env/bin/activate
  . "$VCD_CONNECTION"

  # Prepare a sample tenant yaml file by cat'ing so that environment variables
  # fill in. 
  eval "cat <<EOF
  $(<$SRCROOT/examples/tenant.yaml)
  EOF
  " 2> /dev/null > sample-test-tenant.yaml

  # From here on out all commands are logged. 
  set -x
  python3 examples/system-info.py ${VCD_HOST} ${VCD_ORG} ${VCD_USER} ${VCD_PASSWORD}
  python3 examples/tenant-remove.py sample-test-tenant.yaml
  python3 examples/tenant-onboard.py sample-test-tenant.yaml
  python3 examples/list-vapps.py ${VCD_HOST} Test1 user1 secret VDC-A
  python3 examples/list-vdc-resources.py ${VCD_HOST} Test1 user1 secret
}

run_examples_in_docker() {
  docker run --rm \
  -ePYTHON3_IN_DOCKER=0 \
  -eVCD_CONNECTION=$VCD_CONNECTION \
  -v$VCD_CONNECTION:$VCD_CONNECTION \
  -v$SRCROOT:$SRCROOT \
  -w$SRCROOT \
  -u`id -u`:`id -g` \
  python:3 /bin/bash -c "\
  examples/run_examples.sh"
}

if [ "$PYTHON3_IN_DOCKER" == "" ]; then
    PYTHON3_PATH=`which python3 | cat`
    PIP3_PATH=`which pip3 | cat`

    if [ "$PYTHON3_PATH" == "" ]; then
        PYTHON3_IN_DOCKER=1
    fi

    if [ "$PIP3_PATH" == "" ]; then
        PYTHON3_IN_DOCKER=1
    fi
fi

if [ "$PYTHON3_IN_DOCKER" == "" ]; then
    PYTHON3_IN_DOCKER=0
fi

if [ "$PYTHON3_IN_DOCKER" != "0" ]; then
    run_examples_in_docker
else
    run_examples
fi