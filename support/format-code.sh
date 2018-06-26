#!/usr/bin/env bash
set -e

SHOME=`dirname $0`
cd $SHOME

SRCROOT=`cd ..; pwd`
cd $SRCROOT

yapf -i pyvcloud/vcd/*.py
flake8 pyvcloud/vcd/*.py
