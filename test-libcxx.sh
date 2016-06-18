#!/bin/bash
##
##  Script: test-libcxx.sh
##
##  This top-level script tests libc++.
##
##- Make sure we're in the same directory as this script.
##
export TOP_DIR="$(cd "$(dirname "$0")" && pwd)"
cd $TOP_DIR

##- Get the CLANG-related variables and command-line options for this build.
##
source ./clang-build-vars.sh

##- Get the compiler path.
##
source /usr/local/bin/setenv-for-clang$CLANG_TAG.sh

##- Run the LibC++ tests
##
cd $LIBCXX_SRC_DIR/test
./testit
