#!/usr/bin/env bash

SHOME=`dirname $0`
cd $SHOME

SRCROOT=`cd ..; pwd`
cd $SRCROOT

rm -rf build dist *.egg-info .tox
find . -name '*.pyc' -delete
find . -name '*.log' -delete
