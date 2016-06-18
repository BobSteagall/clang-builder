#!/bin/bash
##
##  make-clang-rpm.sh
##
##  This top-level script makes an RPM from the files installed into the
##  staging directory.
##
##- Make sure we're in the same directory as this script.
##
set -x
TOP_DIR="$(cd "$(dirname "$0")" && pwd)"
cd $TOP_DIR

##- Get the Clang-related variables for this build.
##
export NO_PARSE_OPTS="NO_PARSE"
source ./clang-build-vars.sh

GCC_TAG=
RELEASE_VERSION="0"
WORK_DIR=$TOP_DIR/packages
RPM_QUIET="--quiet"
CP="cp"
MKDIR="mkdir -p"

function usage ()
{
    echo "usage: make-clang-rpm.sh [-w <work_root_dir>]"
    echo "                         [-v]"
    exit 1
}

##- Parse and validate required  command-line arguments.
##
echo $*
while getopts ":w:v" opt
do
    case $opt in
        w ) WORK_DIR=`readlink -f $OPTARG`
            ;;
        v ) RPM_QUIET=""
            CP="cp -v"
            MKDIR="mkdir -pv"
            ;;
        * ) usage
            exit 1 ;;
    esac
done
shift $((OPTIND - 1))

if [ -z "$CLANG_VERSION" ]; then
    echo "clang version not specified"
    usage
fi

if [ -z "$RELEASE_VERSION" ]; then
    echo "RPM release number not specified"
    usage
fi

BO_ROOT_DIR=`readlink -f $CLANG_STAGEDIR`

if [ -x $BO_ROOT_DIR/$CLANG_INSTALL_RELDIR/bin/clang ]; then
    echo "Found Clang $CLANG_VERSION in $BO_ROOT_DIR/$CLANG_INSTALL_RELDIR"
else
    echo "Clang $CLANG_VERSION was not found"
    exit 1
fi

if [ -d $WORK_DIR ]; then
    echo "Using $WORK_DIR as work directory"
else
    echo "Attempting to make work directory $WORK_DIR"
    mkdir -p $WORK_DIR

    if [ -d $WORK_DIR ]; then
        echo "Using $WORK_DIR as work directory"
    else
        echo "Invalid work directory $WORK_DIR"
        exit 1
    fi
fi

##- Retrieve useful information about the platform.
##
PLATFORM_INFO=(`$TOP_DIR/system-type.sh -f`)
PLATFORM_OS=${PLATFORM_INFO[0]}
PLATFORM_NAME=${PLATFORM_INFO[1]}
PLATFORM_ARCH=${PLATFORM_INFO[4]}
PLATFORM_DESC=${PLATFORM_INFO[5]}

if [ "$PLATFORM_OS" = "FreeBSD" ] && [ "$PLATFORM_ARCH" = "amd64" ]; then
    PLATFORM_ARCH=x86_64
fi

##- Form the release string (e.g., 3.el6 or 1.bsd10).
##
RPM_RELEASE=${RELEASE_VERSION}.${PLATFORM_DESC}

##- Copy the spec file into the SPECS directory for rpmbuild to use.
##
$MKDIR $WORK_DIR/SPECS

SPEC_FILE=$WORK_DIR/SPECS/clang$CLANG_TAG.spec
$CP $TOP_DIR/clang.spec $SPEC_FILE

##- Determine the output directory.
##
OUTPUT_DIR=$WORK_DIR

##- Each Linux build of Clang depends on a specific version of GCC.  If we're
##  on Linux, then figure out what that is.
##
if [ "$PLATFORM_OS" = "Linux" ]; then
    GCC_VERSION=`$BO_ROOT_DIR/$CLANG_INSTALL_RELDIR/bin/clang -v 2>&1   \
                | grep "Selected GCC"                                   \
                | grep -o "/[0-9]\.[0-9]\.[0-9]$"                       \
                | tr -d '/' `
    GCC_TAG=`echo $GCC_VERSION | tr -d .`
else
    GCC_VERSION="0.0.0"
    GCC_TAG="000"
fi

##- Define the build command.
##
function rpmcmd ()
{
    rpmbuild -bb $RPM_QUIET                                 \
    --define "build_root_dir $BO_ROOT_DIR"                  \
    --define "clang_install_prefix $CLANG_INSTALL_PREFIX"   \
    --define "clang_install_reldir $CLANG_INSTALL_RELDIR"   \
    --define "clang_tag $CLANG_TAG"                         \
    --define "clang_version $CLANG_VERSION"                 \
    --define "clang_rpm_release $RPM_RELEASE"               \
    --define "gcc_tag $GCC_TAG"                             \
    --define "gcc_version $GCC_VERSION"                     \
    --define "product_arch $PLATFORM_ARCH"                  \
    --define "product_os $PLATFORM_OS"                      \
    --define "_topdir $WORK_DIR"                            \
    --define "_tmppath $WORK_DIR/TMP"                       \
    --define "_rpmdir $OUTPUT_DIR"                          \
    --define "_build_name_fmt %%{NAME}-%%{RELEASE}.%%{ARCH}.rpm" \
    $SPEC_FILE
}

echo "Building Clang RPM using"
echo "   CLANG_VERSION = $CLANG_VERSION"
echo "   CLANG_TAG     = $CLANG_TAG"
echo "   RPM_RELEASE   = $RPM_RELEASE"
echo "   PRODUCT_ARCH  = $PLATFORM_ARCH"
echo "   PRODUCT_OS    = $PLATFORM_OS"

if [ "$PLATFORM_OS" = "Linux" ]; then
    echo "   GCC_VERSION   = $GCC_VERSION"
    echo "   GCC_TAG       = $GCC_TAG"
fi

rpmcmd

exit 0
