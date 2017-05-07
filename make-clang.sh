#!/bin/bash
##
##  Script: make-clang.sh
##
##  This second-level script compiles Clang and any supporting sources.
##
##- Make sure we're in the same directory as this script.
##
export TOP_DIR="$(cd "$(dirname "$0")" && pwd)"
cd $TOP_DIR

##- Get the CLANG-related variables and command-line options for this build.
##
source ./clang-build-vars.sh

##- Make LLVM and CLANG.
##
if [ -n "$DO_CLANG" ]
then
    echo "Starting CLANG build..."
    cd $CLANG_BLD_DIR

    $CLANG_MAKE $CLANG_BUILD_THREADS_ARG

    echo "CLANG build completed!"
    echo ""
fi

##- Make LIBCXX
##
cd $TOP_DIR
if [ -n "$DO_CXXLIB" ]
then
    PATH=$CLANG_BLD_DIR/bin:$PATH
    clang++ -v

    echo "Starting LIBC++ build..."
    cd $LIBCXX_BLD_DIR
    VERBOSE=1 $CLANG_MAKE

    echo ""
    echo "LIBC++ build completed!"
    echo ""
fi
