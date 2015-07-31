#!/bin/bash
# gen-gcov-data.sh - (C) Dave Jones
# http://codemonkey.org.uk/2015/05/04/kernel-code-coverage-brain-dump/

obj=$(echo "$1" | sed 's/\.c/\.o')
if [ ! -f $obj ]; then
    exit;
fi

pwd=$(pwd)
dirname=$(dirname $1)
gcovfn=$(echo "$(basename $1)" | sed 's/\.c/\.gcda/')
if [ -f /sys/kernel/debug/gcov$pwd/$dirname/$gcovfn ]; then
    cp /sys/kernel/debug/gcov$pwd//$dirname/$gcovfn $dirname
    gcov -f -r -o $1 $obj

    if [ -f $(basename $1).gcov ]; then
	mv $(basename $1).gcov $dirname
    fi
else
    echo "no gcov data for /sys/kernel/debug/gcov$pwd/$dirname/$gcovfn"
fi
