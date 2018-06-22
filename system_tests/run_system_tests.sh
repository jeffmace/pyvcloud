#!/bin/bash
# Copyright (c) 2018 VMware, Inc. All Rights Reserved.
#
# This product is licensed to you under the
# Apache License, Version 2.0 (the "License").
# You may not use this product except in compliance with the License.
#
# This product may include a number of subcomponents with
# separate copyright notices and license terms. Your use of the source
# code for the these subcomponents is subject to the terms and
# conditions of the subcomponent's license, as noted in the LICENSE file.

# Script to run all system tests. 
#
# Usage: ./run_system_tests.sh [test1.py test2.py ...]
#
# If you give test names we'll run them.  Otherwise it defaults
# to the current stable tests. 
#
# The script requires a vcd_connection file which defaults to 
# $HOME/vcd_connection.  See vcd_connection.sample for an example. 
# You can also set it in the VCD_CONNECTION environmental variable.
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

run_system_tests() {
  # If there are tests to run use those. Otherwise use stable tests. 
  STABLE_TESTS="client_tests.py \
  idisk_tests.py \
  search_tests.py \
  vapp_tests.py \
  catalog_tests"

  if [ $# == 0 ]; then
    echo "No tests provided, will run stable list: ${STABLE_TESTS}"
    TESTS=$STABLE_TESTS
  else
    TESTS=$*
  fi

  . test-env/bin/activate
  . "$VCD_CONNECTION"

  # Prepare a test parameter file. We'll use sed to replace values and create 
  # a new file.  Note that some environmental variables may not be set in which
  # case the corresponding parameter will end up an empty string. 
  auto_base_config=${SRCROOT}/system_tests/auto.base_config.yaml
  sed -e "s/<vcd ip>/${VCD_HOST}/" \
  -e "s/30.0/${VCD_API_VERSION}/" \
  -e "s/\(sys_admin_username: \'\)administrator/\1${VCD_USER}/" \
  -e "s/<root-password>/${VCD_PASSWORD}/" \
  < ${SRCROOT}/system_tests/base_config.yaml > ${auto_base_config}
  echo "Generated parameter file: ${auto_base_config}"

  # Run the tests with the new file. From here on out all commands are logged. 
  set -x
  export VCD_TEST_BASE_CONFIG_FILE=${auto_base_config}

  cd $SRCROOT/system_tests
  python3 -m unittest $TESTS -v
}

run_system_tests_in_docker() {
  DOCKER_BUILD=`docker build -q \
    --build-arg build_user=${USER} \
    --build-arg build_uid=$(id -u) \
    --build-arg build_gid=$(id -g) \
    -f support/Dockerfile.build \
    support`
  DOCKER_IMAGE=`echo $DOCKER_BUILD | awk -F: '{print $2}'`

  docker run --rm \
    -ePYTHON3_IN_DOCKER=0 \
    -eVCD_CONNECTION=$VCD_CONNECTION \
    -v$VCD_CONNECTION:$VCD_CONNECTION \
    -v$SRCROOT:$SRCROOT \
    -w$SRCROOT \
    $DOCKER_IMAGE \
    /bin/bash -c "system_tests/run_system_tests.sh"
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
    run_system_tests_in_docker
else
    run_system_tests
fi
