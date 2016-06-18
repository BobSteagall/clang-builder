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
    echo -n "Checking for existing clang build directory $CLANG_BLD_DIR... "
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
    echo -n "Checking for CLANG configuration log in $CLANG_BLD_DIR... "
    if [ ! -e config.log ]
    then
        echo ""
        echo -n "Running CLANG configure script "

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
            $CLANG_SRC_DIR/configure                                        \
                --prefix=$CLANG_INSTALL_PREFIX                              \
                --disable-assertions                                        \
                --enable-optimized                                          \
                --enable-targets=host                                       \
                --enable-cxx11                                              \
                --with-gcc-toolchain=$GCC_INSTALL_PREFIX                    \
                --with-extra-ld-options=-Wl,-R,$GCC_INSTALL_PREFIX/lib64    \
                CXX=$GCC_INSTALL_PREFIX/bin/g++                             \
                CC=$GCC_INSTALL_PREFIX/bin/gcc                              \
                CPP=$GCC_INSTALL_PREFIX/bin/cpp                             \
                CXXFLAGS="-Wno-unused-function -Wno-unused-local-typedefs -Wno-unused-but-set-variable -Wno-overloaded-virtual -Wno-sign-compare"
        fi
    else
        echo "found"
        echo "Configure has already been run for CLANG"
    fi

    echo ""
    echo "CLANG configuration completed!"
    echo ""
fi

##- Configure LIBCXX for compilation.
##
cd $TOP_DIR
if [ -n "$DO_CXXLIB" ]
then
    if [ ! -e $CLANG_BLD_DIR/Release/bin/clang ]
    then
        echo "missing build clang/clang++...  need to re-make clang..."
        exit 1
    fi

    cd $LIBCXX_BLD_DIR
    echo -n "Checking for libc++ CMake cache in $LIBCXX_BLD_DIR..."
    if [ ! -e CMakeCache.txt ]
    then
        echo ""
        echo "Running libc++ configure script... "

        ##- Now run the configue script.  There are several site-specific
        ##  extra options that are set, and here is why:
        ##
        ##  CXX=...  CC=...
        ##      These environment variables are set to ensure that
        ##      compilation occurs using the correct CLANG executables
        ##
        ##  -DLIBCXX_CXX_ABI=libcxxrt/libstdc++/libsuppc++
        ##      This option is set to indicate that we want to use the LLVM
        ##      libc++abi library as the runtime ABI support library.
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
            CC=$CLANG_BLD_DIR/Release/bin/clang                         \
            CXX=$CLANG_BLD_DIR/Release/bin/clang++                      \
            cmake -G "Unix Makefiles"                                   \
                -DLIBCXX_CXX_ABI=libcxxrt                               \
                -DLIBCXX_CXX_ABI_INCLUDE_PATHS="/usr/include/c++/v1"    \
                -DCMAKE_BUILD_TYPE=Release                              \
                -DCMAKE_INSTALL_PREFIX=$CLANG_INSTALL_PREFIX            \
                $LIBCXX_SRC_DIR

        elif [ "$CLANG_PLATFORM" == "Linux" ]
        then
            echo "for Linux... "

            ##- Get the location of the system headers for this GCC distribution; the
            ##  ABI headers are usually in the first two directories.
            ##
            GCC_DIRS=`echo | $GCC_BIN -Wp,-v -x c++ - -fsyntax-only 2>&1 | grep "^ /"`
            GCC_DIR_ARR=( $GCC_DIRS )
            GCC_DIR0=`readlink -f ${GCC_DIR_ARR[0]}`
            GCC_DIR1=`readlink -f ${GCC_DIR_ARR[1]}`
            GCC_INC_PATH="$GCC_DIR0;$GCC_DIR1"

            echo "GCC include path for ABI is: $GCC_INC_PATH"

            ##- Build the makefile that makes libc++.
            ##
            CC=$CLANG_BLD_DIR/Release/bin/clang                 \
            CXX=$CLANG_BLD_DIR/Release/bin/clang++              \
            cmake -G "Unix Makefiles"                           \
                -DLIBCXX_CXX_ABI=libstdc++                      \
                -DLIBCXX_CXX_ABI_INCLUDE_PATHS="$GCC_INC_PATH"  \
                -DCMAKE_BUILD_TYPE=Release                      \
                -DCMAKE_INSTALL_PREFIX=$CLANG_INSTALL_PREFIX    \
                $LIBCXX_SRC_DIR

            ##- Check to see if this is a newer GCC that defines the member function
            ##  __pbase_type_info::__pointer_catch() in the cxxabi.h header file.  If
            ##  it is, we're going to insert conditional compilation directives to
            ##  ensure that the Clang compiler does not see this definition.  This
            ##  fixup can only be performed after the cmake command above, which is
            ##  why it's here instead of in unpack-clang.ch.
            ##
            cd $LIBCXX_BLD_DIR/include
            LINE1=`egrep -n 'inline.+__pbase_type_info[[:space:]]*::' cxxabi.h`

            if [ -n "$LINE1" ]
            then
                LINE1=`echo $LINE1 | cut -f 1 -d ':'`
                LINE2=$(($LINE1 + 7))

                cp -pv cxxabi.h cxxabi.h-orig
                sed "${LINE2}i #endif"            cxxabi.h     > cxxabi.h.tmp
                sed "${LINE1}i #ifndef __clang__" cxxabi.h.tmp > cxxabi.h
                rm cxxabi.h.tmp
            fi
        fi
    else
        echo " found"
        echo "Configure has already been run for libc++"
    fi

    echo ""
    echo "LIBC++ configuration completed!"
    echo ""
fi
