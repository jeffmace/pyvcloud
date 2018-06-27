#!/usr/bin/env bash
set -e

SHOME=`dirname $0`
cd $SHOME

SRCROOT=`cd ..; pwd`
cd $SRCROOT

. ./support/bashMethods.sh

if [ "$PYTHON3_IN_DOCKER" != "0" ]; then
    run_in_docker support/install.sh
else
    python3 --version

    rm -rf $PYVCLOUD_VENV
    python3 -m venv $PYVCLOUD_VENV

    . $PYVCLOUD_VENV/bin/activate
    pip3 install -r requirements.txt
    python setup.py install
fi