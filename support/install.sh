#!/usr/bin/env bash

SHOME=`dirname $0`
cd $SHOME

SRCROOT=`cd ..; pwd`
cd $SRCROOT

install() {
    python3 --version

    rm -rf test-env
    python3 -m venv test-env

    . test-env/bin/activate
    pip3 install -r requirements.txt
    python setup.py install
}

install_in_docker() {
    docker run --rm \
    -v$SRCROOT:$SRCROOT \
    -w$SRCROOT \
    python:3 /bin/bash -c "\
    support/install.sh"
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

if [ "$PYTHON3_IN_DOCKER" != "" ]; then
    install_in_docker
else
    install
fi