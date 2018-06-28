#!/usr/bin/env bash
set -e

SHOME=`dirname $0`
cd $SHOME

SRCROOT=`cd ..; pwd`
cd $SRCROOT

. ./support/lib.sh

if [ "$PYTHON3_IN_DOCKER" != "0" ]; then
    run_in_docker support/format-code.sh
else
    if [ -z "$VIRTUAL_ENV" ]; then
        . $PYVCLOUD_VENV_DIR/bin/activate
    fi
    
    yapf -i pyvcloud/vcd/*.py
    flake8 pyvcloud/vcd/*.py
fi
