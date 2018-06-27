#!/usr/bin/env bash
set -e

SHOME=`dirname $0`
cd $SHOME

SRCROOT=`cd ..; pwd`
cd $SRCROOT

#!/usr/bin/env bash
set -e

SHOME=`dirname $0`
cd $SHOME

SRCROOT=`cd ..; pwd`
cd $SRCROOT

. ./support/bashMethods.sh

if [ "$PYTHON3_IN_DOCKER" != "0" ]; then
    run_in_docker support/tox.sh
else
    if [ -z "$VIRTUAL_ENV" ]; then
        . $PYVCLOUD_VENV/bin/activate
    fi
    
    pip3 install -r test-requirements.txt
    tox -e flake8
fi