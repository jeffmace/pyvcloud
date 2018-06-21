#!/usr/bin/env bash

SHOME=`dirname $0`
cd $SHOME

SRCROOT=`cd ..; pwd`
cd $SRCROOT

python setup.py develop
python setup.py sdist bdist_wheel
twine upload dist/*
