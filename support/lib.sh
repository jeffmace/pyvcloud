PYVCLOUD_VENV_DIR=${PYVCLOUD_VENV_DIR:-test-env}

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

set_vcd_connection() {
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
            exit 1
        fi
    fi
}

run_in_docker() {
    DOCKER_BUILD=`docker build -q \
        --build-arg build_user=${USER} \
        --build-arg build_uid=$(id -u) \
        --build-arg build_gid=$(id -g) \
        -f support/Dockerfile.build \
        support`
    DOCKER_IMAGE=`echo $DOCKER_BUILD | awk -F: '{print $2}'`

    VCD_ARGS=""
    if [ "$VCD_CONNECTION" != "" ]; then
        VCD_ARGS="-eVCD_CONNECTION=$VCD_CONNECTION -v$VCD_CONNECTION:$VCD_CONNECTION"
    fi

    docker run --rm \
        -ePYTHON3_IN_DOCKER=0 \
        -ePYVCLOUD_VENV_DIR=$PYVCLOUD_VENV_DIR \
        $VCD_ARGS \
        -v$SRCROOT:$SRCROOT \
        -w$SRCROOT \
        $DOCKER_IMAGE \
        /bin/bash -c "$*"

    EC=$?
    if [ $EC -ne 0 ]; then
        exit $EC
    fi
}