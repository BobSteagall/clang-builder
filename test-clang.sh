#!/bin/bash
##
##  Script: test-clang.sh
##
##  This top-level script tests the Clang compiler (clang).
##
##- Make sure we're in the same directory as this script.
##
export TOP_DIR="$(cd "$(dirname "$0")" && pwd)"
cd $TOP_DIR

##- Get the CLANG-related variables and command-line options for this build.
##
source ./clang-build-vars.sh

##- Run the LLVM and CLANG tests
##
cd $CLANG_BLD_DIR
make check-clang
