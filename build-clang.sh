#!/bin/bash
##
##  Script: build-clang.sh
##
##  This top-level script drives the overall process of compiling and testing
##  the Clang distribution.
##
##- Make sure we're in the same directory as this script.
##
export TOP_DIR="$(cd "$(dirname "$0")" && pwd)"
cd $TOP_DIR

##- Get the CLANG-related variables and command-line options for this build.
##
source ./clang-build-vars.sh

##- Fetch the various pieces required to build LLVM, CLANG, and LIBCXX.
##
./fetch-clang.sh

##- Unpack, configure, and build LLVM and CLANG.
##
if [ -n "$DO_CLANG" ]
then
    ./unpack-clang.sh -c
    ./configure-clang.sh -c
    ./make-clang.sh -c
fi

##- Unpack, configure, and build LIBCXX
##
if [ -n "$DO_CXXLIB" ]
then
    ./unpack-clang.sh -l
    ./configure-clang.sh -l
    ./make-clang.sh -l
fi

./test-clang.sh
