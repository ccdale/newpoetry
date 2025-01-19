#!/bin/bash

# exit on ANY error
set -e

# find the root of this repo
gitroot=$(git rev-parse --show-toplevel 2>/dev/null);

cd $gitroot

# get the list of packages and update them all to the latest version

while read pkg; do
    echo $pkg
    poetry add ${pkg}:latest
done < <(poetry show |cut -d" " -f 1)
