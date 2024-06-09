#!/bin/bash

set -e

# see if the script is being run from a symlink
if [ -L $0 ]; then
    SCRIPTPATH=$(dirname $(readlink $0))
else
    SCRIPTPATH=$(dirname $0)
fi

# check we have a name for the new package
if [ -z "$1" ]; then
    echo "Usage: $(basename "$0") packagename"
    exit 1
fi

# friendly variable name
pkgname=$1

# get the path to this script
# SCRIPTPATH="$( cd "$(dirname "$0")" ; pwd )"
# echo $SCRIPTPATH
# exit 0

# change to the directory of this script
cd $SCRIPTPATH

# go up one directory
cd ..

# delete any previous build directory
rm -rf build

# create a new build directory
mkdir build

# set a rooot for the build
root=$(pwd)/build

# create the package layout
echo "Creating package layout for $pkgname"
mkdir -p $root/$pkgname/{$pkgname,tests}

# populate the package layout
echo "Populating package layout for $pkgname"
for f in Makefile .gitignore; do
    cp $f $root/$pkgname/
done
echo "# $pkgname" > $root/$pkgname/README.md

cat << EOINIT > $root/$pkgname/$pkgname/__init__.py
__appname__ = "$pkgname"
__version__ = "0.1.0"
EOINIT

cat << EOMAIN > $root/$pkgname/main.py
import sys

from ccaerrors import errorExit, errorNotify, errorRaise
import ccalogging

import $pkgname
from $pkgname import __appname__, __version__

ccalogging.setDebug()
# ccalogging.setInfo()
ccalogging.setConsoleOut()
log = ccalogging.log


def main():
    try:
        log.info(f"{__appname__} v{__version__}")
    except Exception as e:
        errorExit(sys.exc_info()[2], e)


if __name__ == "__main__":
    main()
EOMAIN

cat << EOTEST > $root/$pkgname/tests/test_$pkgname.py
from $pkgname import __appname__, __version__

def test_$pkgname():
    assert __appname__ == "$pkgname"

def test_version():
    assert __version__ == "0.1.0"
EOTEST

cat << EOTMAIN > $root/$pkgname/tests/test_main.py
import pytest

import main
from $pkgname import __appname__, __version__


def test_main(caplog):
    main.main()
    assert f"{__appname__} v{__version__}" in caplog.text
EOTMAIN

touch $root/$pkgname/tests/__init__.py

# create the pyproject.toml file
echo "Creating pyproject.toml for $pkgname"
sed "s/packagename/$pkgname/" pyproject.toml > $root/$pkgname/pyproject.toml

for dep in ccalogging ccaerrors pytest pytest-cov flake8 black isort; do
    v=$(scripts/getLatestVersion.py $dep)
    sed -i "s/^$dep = \"\^[0-9.]\+\"$/$dep = \"^$v\""/ $root/$pkgname/pyproject.toml
done

# bung it all in a zip file
echo "Zipping up ..."
zipfn="/tmp/${pkgname}.zip"
cd ${root}
zip -r ${zipfn} .

echo "Extracting new package at ${HOME}/src/${pkgname}"
cd ${HOME}/src
unzip ${zipfn}

echo "Cleaning up"
rm ${zipfn}

echo "Installing ..."
cd ${HOME}/src/${pkgname}
git init
make install
make test

echo
echo "New project in ${HOME}/src/${pkgname}"
echo
