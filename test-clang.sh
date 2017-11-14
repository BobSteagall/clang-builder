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

if [ "$CLANG_PLATFORM" == "Linux" ]
then
    export LD_LIBRARY_PATH=$GCC_INSTALL_PREFIX/lib:$GCC_INSTALL_PREFIX/lib64
    echo "ldpath for testing is $LD_LIBRARY_PATH"
fi

##- Run the LLVM and CLANG tests
##
if [ -n "$DO_CLANG" ]
then
    cd $CLANG_BLD_DIR
    $CLANG_MAKE check-clang -k $CLANG_BUILD_THREADS_ARG
fi

if [ -n "$DO_CXXLIB" ]
then
    cd $LIBCXX_BLD_DIR
    $CLANG_MAKE check-libcxx -k $CLANG_BUILD_THREADS_ARG
fi

