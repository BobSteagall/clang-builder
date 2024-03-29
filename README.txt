================================================================================
 2022-08-08
 Bob Steagall
 KEWB Computing
================================================================================
This is the README file for the KEWB Clang 10.X.Y build scripts.  In the
following text, the version numbers will be referred to as 10.X.Y or 10XY,
depending on the usage and context.

In order to run these scripts, the following prerequisites must be installed:
 a. lsb_release on Linux
 b. the typical GNU build tools
 c. CMake 3.4.3 or higher
 d. Python 2.7 or higher

--------------------------------------------
1. SCRIPTS THAT PROVIDE CUSTOM BUILD OPTIONS

  * clang-build-vars.sh - This very important script sets critical environment
    variables that are used by all the other scripts.  The first few variables
    can be modified; if you think you want to modify some of these variables,
    follow the directions in the script file.


----------------------------------------------------
2. TOP-LEVEL SCRIPTS THAT PERFORM HIGH-LEVEL ACTIONS

  * build-clang.sh - This script will perform an entire build of Clang.  It
    builds the compiler first, and then the LibC++ library.  The compiler
    and library are each built by running fetch-clang.sh, unpack-clang.sh,
    configure-clang.sh, and make-clang.sh, in that order.

  * stage-clang.sh - This script installs Clang into a staging location
    specified by the build variables script (clang-build-vars.sh).  This is
    normally in the ./dist subdirectory, which serves as the staging area for
    creating a TGZ (compressed tarball) file and/or an RPM file.

  * pack-clang.sh - This script creates a compressed tarball of compiler
    files installed into the staging directory by the stage-clang.sh script.
    The resulting TGZ file will be in the ./packages subdirectory.

  * install-clang-tarball.sh - This script unpacks the TGZ file created by
    the packing script (pack-clang.sh) into the directory structure specified
    in the build variables script (clang-build-vars.sh).

  * make-clang-rpm.sh - This script creates an RPM of the compiler files
    installed into the staging directory by the stage-clang.sh script.  The
    resulting RPM file will be in the ./packages subdirectory.


-----------------------------------------------------
3. SECOND-LEVEL SCRIPTS THAT PERFORM BASIC OPERATIONS

This set of scripts performs several basic operations that are part of the
build process.  Each operation is a distinct step in that process.

  * fetch-clang.sh - This script downloads the required source tarballs from
    LLVM mirror sites.

  * unpack-clang.sh - This script unpacks the tarballs, places everything in
    the correct relative locations, and then performs any required patching.

  * configure-clang.sh - This script runs Clang's configure script from within
    the build subdirectory.  It sets several key options for building Clang,
    including some that are specified by the environment variables set in
    clang-build-vars.sh.

  * make-clang.sh - This script makes Clang from within the build subdirectory.
    By default, tt runs with -j8 (i.e., up to 8 parallel processes); you can
    change this value by modifying the CLANG_BUILD_THREADS_ARG variable defined
    in the clang-build-vars.sh script described above.

  * clean-clang.sh - This script deletes the source, build, install staging,
    and package output directories.


----------------------------------------------
4. HOW TO BUILD CLANG 10.X.Y WITH THESE SCRIPTS

(NB: In the directions below, remember to replace the 'X' with the minor
version number and the 'Y' with the patch level number!)

The process is pretty simple:

 a. Clone the git repo and checkout the clang10 branch.

    $ cd <build_dir>
    $ git clone git@gitlab.com/BobSteagall/clang-builder.git
    $ cd <build_dir>/clang-builder
    $ git checkout clang10

 b. Customize the variables exported by clang-build-vars.sh.  In particular,
    you will need to customize the first variable at the top of that file,
    CLANG_VERSION, to select the version of Clang 10.X.Y to download and build.

    $ vi ./clang-build-vars.sh

 c. Run the build-clang.sh script.

    $ ./build-clang.sh | tee build.log

    This command will build Clang and run the various unit tests that come
    with the distribution.  To build without running the tests, you can use:

    $ ./build-clang.sh -T | tee build.log

 d. If the build succeeds, and you are satisfied with the test results, run
    the stage-clang.sh script to create the installation staging area.

    $ ./stage-clang.sh

 e. If you want to create a tarball for subsequent installations:

    $ ./pack-clang.sh

    The resulting tarball will be in the ./packages subdirectory.  To install
    the tarball:

    $ sudo ./install-clang-tarball.sh

    or, alternatively:

    $ sudo tar -zxvf ./clang-builder/packages/kewb-clang10XY*.tgz -C /

    If you are satisfied that everything is working correctly, then at some
    point you may want to set ownership of the un-tarred files to root
    (replace CLANG_INSTALL_PREFIX and CLANG_INSTALL_SCRIPTS_PREFIX wit the
    values that you defined in gcc-build-vars.sh):

    $ sudo chown -R root:root $CLANG_INSTALL_PREFIX
    $ sudo chown root:root $CLANG_INSTALL_SCRIPTS_PREFIX/*clang10XY*

 f. If you want to create an RPM for subsequent installations:

    $ ./make-clang-rpm.sh -v

    The resulting RPM will be in the ./packages subdirectory.  Install it
    using RPM or YUM on the command line.

 g. That's it!


-----------------------------------------------
5. HOW TO USE THE KEWB CUSTOM CLANG 10.X.Y BUILD

Before using the compiler, some paths need to be set.  The simplest way to
do this is source the "setenv-for-clang10XY.sh" script that is installed.

 a. Source the script /usr/local/bin/setenv-for-clang-10XY.sh, which was
    installed in step 4.e or 4.f above.  For example,

        $ source /usr/local/bin/setenv-for-clang10XY.sh

-- OR --

 a. You will need to modify your PATH environment variable so that the
    directory $CLANG_INSTALL_DIR/bin appears before the directory where your
    system default compiler is installed (which is usually in /usr/bin or
    /usr/local/bin).  For example,

        $ export PATH=/usr/local/clang/10.X.Y/bin:$PATH

 b. On Linux, you will also need to modify your LD_LIBRARY_PATH environment
    variable so that the $CLANG_INSTALL_PREFIX/lib, $GCC_INSTALL_PREFIX/lib,
    and $GCC_INSTALL_PREFIX/lib64 directories appear first in the path.  For
    example,

        $ export LD_LIBRARY_PATH=/usr/local/clang/10.X.Y/lib:\
          /usr/local/gcc/9.5.0/lib:/usr/local/gcc/9.5.0/lib64:\
          $LD_LIBRARY_PATH

    On FreeBSD, it suffices to prepend LD_LIBRARY_PATH with only the
    $CLANG_INSTALL_PREFIX/lib directory.
