#!/usr/bin/env bash
set -e

SHOME=`dirname $0`
cd $SHOME

SRCROOT=`cd ..; pwd`
cd $SRCROOT

exec_tox() {
    . test-env/bin/activate
    pip3 install -r test-requirements.txt
    tox -e flake8
}

exec_tox_in_docker() {
    DOCKER_BUILD=`docker build -q \
        --build-arg build_user=${USER} \
        --build-arg build_uid=$(id -u) \
        --build-arg build_gid=$(id -g) \
        -f support/Dockerfile.build \
        support`
    DOCKER_IMAGE=`echo $DOCKER_BUILD | awk -F: '{print $2}'`
    
    docker run --rm \
        -ePYTHON3_IN_DOCKER=0 \
        -v$SRCROOT:$SRCROOT \
        -w$SRCROOT \
        $DOCKER_IMAGE \
        /bin/bash -c "support/tox.sh"
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
    exec_tox_in_docker
else
    exec_tox
fi