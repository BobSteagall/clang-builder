#!/bin/bash
##
##  Script: configure-clang.sh
##
##  This second-level script configures Clang, and anything else that is
##  needed to build it.
##
##- Make sure we're in the same directory as this script.
##
export TOP_DIR="$(cd "$(dirname "$0")" && pwd)"
cd $TOP_DIR

##- Get the CLANG-related variables and command-line options for this build.
##
source ./clang-build-vars.sh

##- Configure LLVM and CLANG prior for compilation.
##
if [ -n "$DO_CLANG" ]
then
    echo -n "Checking for existing CLANG build directory $CLANG_BLD_DIR... "
    if [ ! -e $CLANG_BLD_DIR ]
    then
        echo ""
        echo "Making new clang build directory..."
        mkdir -v $CLANG_BLD_DIR
    else
        echo " already exists"
    fi

    ##- Run the CLANG configure script using our customizations.
    ##
    cd $CLANG_BLD_DIR
    echo -n "Checking for CLANG CMake cache in $CLANG_BLD_DIR... "
    if [ ! -e CMakeCache.txt ]
    then
        echo ""
        echo -n "Configuring CLANG build with CMake... "

        ##- Now run the configue script.  There are several site-specific extra
        ##  options that are set, and here is why:
        ##
        ##  CXX=...  CC=...  CPP=...
        ##      These variables are ensure that compilation occurs using the
        ##      correct GCC executables
        ##
        ##  CXXFLAGS=...
        ##      This option is set to disable several annoying and meaningless
        ##      warnings and notices that are issued during the build.
        ##
        ##  --prefix=$CLANG_INSTALL_PREFIX
        ##      This is the root directory for the installation.
        ##
        ##  --with-gcc-toolchain=$GCC_INSTALL_PREFIX
        ##      This option indicates the root directory for the GCC installation
        ##      upon which this build of clang is based.
        ##
        ##  --with-extra-ld-options=-Wl,-R,$GCC_INSTALL_PREFIX/lib64
        ##      This option is set to ensure that, during the llmv and clang build,
        ##      linking occurs against the correct GCC libraries.
        ##
        if [ "$CLANG_PLATFORM" == "FreeBSD" ]
        then
            echo "for FreeBSD... "
            CXX=/usr/bin/g++                                    \
            CC=/usr/bin/gcc                                     \
            cmake $CLANG_SRC_DIR -G "Unix Makefiles"            \
                -DCMAKE_BUILD_TYPE=Release                      \
                -DCMAKE_INSTALL_PREFIX=$CLANG_INSTALL_PREFIX    \
                -DLLVM_ENABLE_WARNINGS=OFF

            $CLANG_SRC_DIR/configure            \
                --prefix=$CLANG_INSTALL_PREFIX  \
                --disable-assertions            \
                --enable-optimized              \
                --enable-targets=host           \
                --enable-cxx11                  \
                CXX=/usr/bin/c++                \
                CC=/usr/bin/cc                  \
                CPP=/usr/bin/cpp                \
                CXXFLAGS=""

        elif [ "$CLANG_PLATFORM" == "Linux" ]
        then
            echo "for Linux... "

            GCC_CXXLIBDIR="$GCC_INSTALL_PREFIX/lib64"
            GCC_CXXFLAGS="-Wno-unused-function -Wno-unused-local-typedefs   \
                          -Wno-unused-but-set-variable                      \
                          -Wno-overloaded-virtual -Wno-sign-compare         \
                          -Wno-strict-aliasing -Wno-pedantic"
            GCC_CLAGS="-Wno-implicit-function-declaration"

            CXX=$GCC_INSTALL_PREFIX/bin/g++                                     \
            CC=$GCC_INSTALL_PREFIX/bin/gcc                                      \
            cmake $CLANG_SRC_DIR -G "Unix Makefiles"                            \
                -DCMAKE_BUILD_TYPE=Release                                      \
                -DCMAKE_INSTALL_PREFIX=$CLANG_INSTALL_PREFIX                    \
                -DCMAKE_CXX_LINK_FLAGS="-Wl,-R,$GCC_CXXLIBDIR -L$GCC_CXXLIBDIR" \
                -DGCC_INSTALL_PREFIX=$GCC_INSTALL_PREFIX                        \
                -DCLANG_VENDOR="$CLANG_VENDOR"                                  \
                -DLLVM_ENABLE_WARNINGS=OFF

        fi
    else
        echo "found"
        echo "Configure has already been run for CLANG"
    fi

    echo ""
    echo "CLANG configuration completed!"
    echo ""
fi

##- Configure LIBC++ for compilation.
##
cd $TOP_DIR
if [ -n "$DO_CXXLIB" ]
then
    if [ ! -e $CLANG_BLD_DIR/bin/clang ]
    then
        echo "missing built clang/clang++...  you need to re-make clang..."
        exit 1
    fi

    cd $LIBCXX_BLD_DIR
    echo -n "Checking for LIBC++ CMake cache in $LIBCXX_BLD_DIR..."
    if [ ! -e CMakeCache.txt ]
    then
        echo ""
        echo "Configuring LIBC++ build with CMake... "

        ##- Now run the configure script.  There are several site-specific
        ##  extra options that are set, and here is why:
        ##
        ##  CXX=...  CC=...
        ##      These environment variables are set to ensure that libc++
        ##      compilation occurs using the correct Clang executables
        ##
        ##  -DLIBCXX_CXX_ABI=libcxxrt|libstdc++|libsuppc++
        ##      This option indicate the runtime ABI support library that we
        ##      want libc++ to use.
        ##
        ##  -DLIBCXX_CXX_ABI_INCLUDE_PATHS="$.."
        ##      This option indicates the location of the c++ ABI header files.
        ##
        ##  -DCMAKE_INSTALL_PREFIX=$CLANG_INSTALL_PREFIX
        ##      This option indicates the directory where libc++ is to be
        ##      installed.
        ##
        if [ "$CLANG_PLATFORM" == "FreeBSD" ]
        then
            echo "for FreeBSD... "
            CC=$CLANG_BLD_DIR/bin/clang                                 \
            CXX=$CLANG_BLD_DIR/bin/clang++                              \
            cmake -G "Unix Makefiles"                                   \
                -DLIBCXX_CXX_ABI=libcxxrt                               \
                -DLIBCXX_CXX_ABI_INCLUDE_PATHS="/usr/include/c++/v1"    \
                -DCMAKE_BUILD_TYPE=Release                              \
                -DCMAKE_INSTALL_PREFIX=$CLANG_INSTALL_PREFIX            \
                -DLLVM_PATH="$CLANG_SRC_DIR"                            \
                $LIBCXX_SRC_DIR

        elif [ "$CLANG_PLATFORM" == "Linux" ]
        then
            echo "for Linux... "
            echo "GCC include path for ABI is: $GCC_CXX_ABI_INC_PATH"

            ##- Build the makefile that makes libc++.
            ##
            CC=$CLANG_BLD_DIR/bin/clang                                 \
            CXX=$CLANG_BLD_DIR/bin/clang++                              \
            cmake -G "Unix Makefiles"                                   \
                -DLIBCXX_CXX_ABI=$GCC_CXX_ABI                           \
                -DLIBCXX_CXX_ABI_INCLUDE_PATHS="$GCC_CXX_ABI_INC_PATH"  \
                -DCMAKE_BUILD_TYPE=Release                              \
                -DCMAKE_INSTALL_PREFIX=$CLANG_INSTALL_PREFIX            \
                -DLIBCXX_INCLUDE_TESTS=ON                               \
                -DLLVM_PATH="$CLANG_SRC_DIR"                            \
                $LIBCXX_SRC_DIR
        fi
    else
        echo " found"
        echo "Configure has already been run for LIBC++"
    fi

    echo ""
    echo "LIBC++ configuration completed!"
    echo ""
fi
