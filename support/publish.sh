#!/usr/bin/env bash

SHOME=`dirname $0`
cd $SHOME

SRCROOT=`cd ..; pwd`
cd $SRCROOT

. ./support/bashMethods.sh

if [ "$PYTHON3_IN_DOCKER" != "0" ]; then
    run_in_docker support/publish.sh
else
    if [ -z "$VIRTUAL_ENV" ]; then
        . $PYVCLOUD_VENV_DIR/bin/activate
    fi
    
    python3 setup.py develop
    python3 setup.py sdist bdist_wheel
    twine upload dist/*
fi
