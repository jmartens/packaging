#!/bin/bash -e
#
# Build script for MythTV for Windows.
# Created by Lawrence Rust, lvr at softsystem dot co dot uk
#
# For use on a Linux host to cross build using the MinGW C cross compiler
# http://sourceforge.net/projects/mingw/files/Cross-Hosted%20MinGW%20Build%20Tool/
#
# or natively on Windows using the MSYS environment and MingGW from
# http://sourceforge.net/projects/mingw/files
#
# Click:
#   Automated MinGW Installer > mingw-get-inst
# Then select a version e.g.
#   mingw-get-inst-20101030 > mingw-get-inst-20101030.exe
#
# Run the installer and ensure to add:
#   C++
#   MSYS basic system
#   MinGW Developer Toolkit
#
# Start an Msys shell from the Windows desktop by clicking:
#   Start > All Programs > MinGW > MinGW Shell"
#
# Copy this script to C:\MinGW\msys\1.0\home\[username]
# At the Msys prompt enter:
#   ./mythbuild.sh

# Build type: debug|profile|release
: ${MYTHBUILD:=""}
# MythTV branch: master, fixes/0.24.  See: git branch
: ${MYTHBRANCH:=""}
# Myth code repo
: ${MYTHREPO:="http://mythtv-for-windows.googlecode.com/files"}
# Myth git repo
: ${MYTHGIT:="git://github.com/MythTV"}

# SourceForge auto mirror re-direct
: ${SOURCEFORGE:="downloads.sourceforge.net"}

# EVs defining the libraries to be installed:
: ${PTHREADS:="pthreads-w32-2-8-0-release"}
: ${PTHREADS_URL:="ftp://sourceware.org/pub/pthreads-win32/$PTHREADS.tar.gz"}
: ${ZLIB:="zlib-1.2.5"}
: ${ZLIB_URL:="http://$SOURCEFORGE/project/libpng/zlib/${ZLIB/zlib-/}/$ZLIB.tar.gz"}
: ${FREETYPE:="freetype-2.4.3"}
: ${FREETYPE_URL:="http://download.savannah.gnu.org/releases/freetype/$FREETYPE.tar.gz"}
: ${LAME:="lame-3.98.4"}
: ${LAME_URL:="http://$SOURCEFORGE/project/lame/lame/${LAME/lame-/}/$LAME.tar.gz"}
: ${WINE:="wine-1.3.6"}
: ${WINE_URL:="http://$SOURCEFORGE/project/wine/Source/$WINE.tar.bz2"}
: ${LIBEXIF:="libexif-0.6.19"}
: ${LIBEXIF_URL:="http://$SOURCEFORGE/project/libexif/libexif/${LIBEXIF/libexif-/}/$LIBEXIF.tar.bz2"}
: ${LIBOGG:="libogg-1.2.1"}
: ${LIBOGG_URL:="http://downloads.xiph.org/releases/ogg/$LIBOGG.tar.bz2"}
: ${LIBVORBIS:="libvorbis-1.3.2"}
: ${LIBVORBIS_URL:="http://downloads.xiph.org/releases/vorbis/$LIBVORBIS.tar.bz2"}
: ${FLAC:="flac-1.2.1"}
: ${FLAC_URL:="http://$SOURCEFORGE/project/flac/flac-src/$FLAC-src/$FLAC.tar.gz"}
: ${LIBCDIO:="libcdio-0.82"}
: ${LIBCDIO_URL:="ftp://mirror.cict.fr/gnu/libcdio/$LIBCDIO.tar.gz"}
: ${TAGLIB:="taglib-1.6.3"}
: ${TAGLIB_URL:="http://developer.kde.org/~wheeler/files/src/$TAGLIB.tar.gz"}
: ${FFTW:="fftw-3.2.2"}
: ${FFTW_URL:="http://www.fftw.org/$FFTW.tar.gz"}
: ${LIBSDL:="SDL-1.2.14"}
: ${LIBSDL_URL:="http://www.libsdl.org/release/$LIBSDL.tar.gz"}
: ${LIBVISUAL:="libvisual-0.4.0"}
: ${LIBVISUAL_URL:="http://$SOURCEFORGE/project/libvisual/libvisual/$LIBVISUAL/$LIBVISUAL.tar.gz"}
: ${LIBDVDCSS:="libdvdcss-1.2.10"}
: ${LIBDVDCSS_URL:="http://download.videolan.org/pub/libdvdcss/${LIBDVDCSS/libdvdcss-/}/$LIBDVDCSS.tar.bz2"}
: ${LIBXML2:="libxml2-2.7.8"}
: ${LIBXML2_URL:="ftp://xmlsoft.org/libxml2/$LIBXML2.tar.gz"}
# 16-Dec-2010 latest: mysql-5.5.8
# NB a build of mysql-5.0.89 on Linux doesn't operate with mysql 5.1 server
: ${MYSQL:="mysql-5.1.54"}
: ${MYSQL_URL:="http://mirrors.ircam.fr/pub/mysql/Downloads/MySQL-${MYSQL:6:3}/$MYSQL.tar.gz"}
# Pre-built win32 install. NB mysql-5.1 requires winXP-SP2, 5.0 works on win2k
: ${MYSQLW:="mysql-5.0.89-win32"}
: ${MYSQLW_URL:="ftp://mirrors.ircam.fr/pub/mysql/Downloads/MySQL-${MYSQLW:6:3}/${MYSQLW/mysql-/mysql-noinstall-}.zip"}
: ${QT:="qt-everywhere-opensource-src-4.7.0"}
: ${QT_URL:="http://get.qt.nokia.com/qt/source/$QT.tar.gz"}

# Windows hosted tools
: ${WINWGET:="wget-1.11.4"}
: ${WINWGET_URL:="ftp://ftp.gnu.org/gnu/wget/$WINWGET.tar.bz2"}
: ${WINUNZIP:="unz600xn"}
: ${WINUNZIP_URL:="ftp://ftp.info-zip.org/pub/infozip/win32/$WINUNZIP.exe"}
: ${WINZIP:="zip300xn"}
: ${WINZIP_URL:="ftp://ftp.info-zip.org/pub/infozip/win32/$WINZIP.zip"}
: ${WINGIT:="Git-1.7.3.1-preview20101002"}
: ${WINGIT_URL:="http://msysgit.googlecode.com/files/$WINGIT.exe"}

# Dir for myth sources
: ${MYTHDIR:=$PWD}

# Patches directory
: ${MYTHPATCHES:="$MYTHDIR/mythpatches"}

# Target system: Host|Windows
: ${MYTHTARGET:=""}

# Package debug build: yes|no|auto, auto=follow MYTHBUILD
: ${LAME_DEBUG:="auto"}
: ${FLAC_DEBUG:="no"}
: ${TAGLIB_DEBUG:="no"}
: ${FFTW_DEBUG:="no"}
: ${LIBVISUAL_DEBUG:="no"}
: ${MYSQL_DEBUG:="auto"}
: ${QT_DEBUG:="auto"}

# Working dir for downloads & sources
if [ -e "$MYTHDIR/mythwork" ]; then
    # Backwards compatibility for v1 script
    : ${MYTHWORK:="$MYTHDIR/mythwork"}
    : ${MYTHINSTALL:="$MYTHDIR/mythbuild"}
else
    : ${MYTHWORK:="$MYTHDIR/mythbuild"}
    # prefix for package installs
    : ${MYTHINSTALL:="$MYTHDIR/mythinstall"}
fi
bindir="$MYTHINSTALL/bin"
incdir="$MYTHINSTALL/include"
libdir="$MYTHINSTALL/lib"

# Mythtv win32 runtime installation built here
windir="$MYTHINSTALL/win32"

# ./configure done indicator
stampconfig="stamp.mythtv.org"
# make install done indicator
stampbuild="stampbuild.mythtv.org"


###############################################################
# Parse the command line
###############################################################
function myhelp() {
    echo "Build MythTV"
    echo "Usage: `basename $0` [options]"
    echo "Options:"
    echo "  -b tag      Checkout MythTV branch [tag]"
    echo "  -r          Switch to release build"
    echo "  -p          Switch to profile build"
    echo "  -d          Switch to debug build"
    echo "  -W          Set target to Windows"
    echo "  -H          Set target to Host"
    echo "  -j n        Max number of make jobs"
    echo "  -h          Display this help and exit"
    echo "  -v          Display version and exit"
    echo ""
    echo "The following shell variables are useful:"
    echo "MYTHDIR       Build tree root [current directory]"
    echo "MYTHPATCHES   Patches directory [MYTHDIR/mythpatches]"
    echo "MYTHWORK      Directory to unpack and build libraries [MYTHDIR/mythbuild]"
    echo "MYTHINSTALL   Directory to install libraries [MYTHDIR/mythinstall]"
    echo "MYTHGIT       Myth git repository [$MYTHGIT]"
    echo "MYTHREPO      Primary mirror [$MYTHREPO]"
    echo "SOURCEFORGE   Sourceforge mirror [$SOURCEFORGE]"
    echo "QT            QT version [$QT]"
    echo "QT_DEBUG      QT debug build [$QT_DEBUG]"
    echo "MYSQL         MYSQL version [$MYSQL]"
    echo "MYSQL_DEBUG   MYSQL debug build [$MYSQL_DEBUG]"
}
function version() {
    echo "`basename $0` version 0.1"
}
function die() {
    echo $@ >&2
    exit 1
}

# Options
while getopts ":b:dj:prhvWH" opt
do
    case "$opt" in
        b) [ "${OPTARG:0:1}" = "-" ] && die "Invalid branch tag: $OPTARG"
            MYTHBRANCH=$OPTARG ;;
        d) MYTHBUILD="debug" ;;
        j) [ $OPTARG \< 0 -o $OPTARG \> 99 ] && die "Invalid number: $OPTARG"
            [ $OPTARG -lt 1 ] && die "Invalid make jobs: $OPTARG"
            makejobs=$OPTARG ;;
        p) MYTHBUILD="profile" ;;
        r) MYTHBUILD="release" ;;
        H) MYTHTARGET="Host" ;;
        W) MYTHTARGET="Windows" ;;
        h) myhelp; exit ;;
        v) version; exit ;;
        \?) [ -n "$OPTARG" ] && die "Invalid option -$OPTARG" ;;
        :) [ -n "$OPTARG" ] && die "-$OPTARG requires an argument" ;;
        *) die "Unknown option $opt" ;;
    esac
done
shift `expr $OPTIND - 1`

# Arguments
[ $# -gt 0 ] && die "Excess arguments"


###############################################################
# Functions
###############################################################

# Download a file. $1= URL
function download() {
    local obj=`basename "$1"`
    echo ""
    echo "*********************************************************************"
    echo "wget $obj"
    # Try the myth code repo first, if not use the full URL
    wget "$MYTHREPO/$obj" || wget $1
}

# FTP download. $1= URL
function ftpget() {
    local host path filename
    case "$1" in
        ftp://*) ;;
        *) die "ERROR: Not an FTP URL - $1" ;;
    esac
    path=`dirname "${1#ftp://}"`
    host=${path%%/*}
    path=${path#$host}
    filename=`basename "$1"`
    echo ""
    echo "*********************************************************************"
    echo "ftp ftp://$host/$path/$filename"
    ftp.exe -n $host <<-EOF
		user anonymous mythbuildw32@$HOSTNAME
		cd $path
		binary
		passive
		get $filename
		quit
	EOF
}

# Display a timed message. $1= seconds $2= message
function pause() {
    local seconds
    echo ""
    echo "*********************************************************************"
    if [ $1 -eq 0 ]; then
        read -p "$2" || echo ""
    else
        for (( seconds=$1 ; seconds > 0 ; --seconds )) do
            printf -v prompt "\r$2(%3u)" $seconds
            read -t 1 -p "$prompt" && break || true
        done
        [ $seconds -le 0 ] && echo ""
    fi
    echo ""
}

function pausecont() {
	local component=${2:-`basename $PWD`}
    pause ${1:-30} "Press [Return] to make ${component:0:26} or [Control-C] to abort "
}

# Display a banner. $1= message
function banner() {
    echo ""
    echo "*********************************************************************"
    echo "${1:0:80}"
    echo "*********************************************************************"
    echo ""
}

# Unpack an archive. $1= filename
function unpack() {
    echo "Extracting `basename "$1"` ..."
    case "$1" in
        *.tar.gz) tar -zxf "$1" ;;
        *.tar.bz2) tar -jxf "$1" ;;
        *.zip) unzip -a -q "$1" ;;
        *) die "ERROR: Unknown archive type $1" ;;
    esac
}

# Apply patches to a component.  $1= component name
function dopatches() {
    local i ret=0 p patched
    for i in $MYTHPATCHES/$1/*.diff ; do
        if [ -e "$i" ]; then
            p=`basename "$i" ".diff"`
            patched="patch-$p.applied"
            if [ ! -e "$patched" ]; then
                echo "Applying patch $1/`basename $i`"
                patch -p1 -i "$i"
                touch "$patched"
                let ++ret
            fi
        fi
    done
    return $ret
}

# Download a git repo. $1= URL $2= dir
function gitclone() {
    banner "git clone $@"
    git clone $@
}

# Get the current git branch. $1= path to .git
function gitbranch() {
    [ ! -d "$1/.git" ] && return 1
    git --git-dir="$1/.git" branch --no-color|grep "^\*"|cut -c 3-
}

# make distclean
function make_distclean() {
    echo "make distclean..."
    $make -s -k distclean >/dev/null 2>&1
}


###############################################################
# Installation check
###############################################################

# Myth build type
case "$MYTHBUILD" in
    "") if [ -e "$MYTHDIR/mythtv/mythtv/$stampconfig.debug" -o \
             -e "$MYTHDIR/mythtv/mythplugins/$stampconfig.debug" ]; then
            MYTHBUILD="debug"
        elif [ -e "$MYTHDIR/mythtv/mythtv/$stampconfig.profile" -o \
               -e "$MYTHDIR/mythtv/mythplugins/$stampconfig.profile" ]; then
            MYTHBUILD="profile"
        else
            MYTHBUILD="release"
        fi
    ;;
    debug|release|profile) ;;
    *) die "Invalid MYTHBUILD=$MYTHBUILD" ;;
esac


# Myth branch
: ${MYTHBRANCH:=`gitbranch "$MYTHDIR/mythtv"`}
: ${MYTHBRANCH:="fixes/0.24"}


# Determine build type
stamptarget="$MYTHINSTALL/target"
if [ "$MSYSTEM" = "MINGW32" ]; then
    # Native Windows
    xprefix=""
    bprefix=""
    MYTHTARGET="Windows"
else
    if [ -z "$MYTHTARGET" ]; then
        [ -e "$stamptarget-Host" ] && MYTHTARGET="Host" || MYTHTARGET="Windows"
    fi
    case "$MYTHTARGET" in
    Windows|windows) # Cross compile to Windows
        MYTHTARGET="Windows"
        if [ -z "$xprefix" ]; then
            if which i586-mingw32msvc-gcc >/dev/null 2>&1 ; then
                xprefix="i586-mingw32msvc"
            elif which i586-pc-mingw32-gcc >/dev/null 2>&1 ; then
                xprefix="i586-pc-mingw32"
            elif which i686-pc-mingw32-gcc >/dev/null 2>&1 ; then
                xprefix="i686-pc-mingw32"
            elif xcc=`locate "/usr/bin/i*mingw32*-gcc"` ; then
                xprefix=`basename "${xcc%-gcc}"`
            else
                echo "ERROR: need mingw for cross compiling."
                echo "Try: sudo apt-get install mingw32"
                exit 1
            fi
        fi
        bprefix=`gcc -dumpmachine`
        ;;
    Host|host) # Native build
        MYTHTARGET="Host"
        xprefix=""
        bprefix=""
        ;;
    *) die "Unsupported target system: $MYTHTARGET" ;;
    esac
fi

if [ ! -e "$stamptarget-$MYTHTARGET" ]; then
    # Clean re-build
    reconfig="yes"
    rm -rf "$MYTHINSTALL"
    mkdir -p "$MYTHINSTALL"
    touch "$stamptarget-$MYTHTARGET"
fi


# Verify patches are present
if [ ! -d "$MYTHPATCHES" ]; then
    echo "WARNING: The patch directory $MYTHPATCHES is missing."
    echo "         No patches will be applied.  The build may fail."
    read -p "Press [Return] to continue or [Control-C] to abort: "
fi


# Display Myth branch & build type and wait for OK
banner "Building MythTV branch $MYTHBRANCH ($MYTHBUILD) for $MYTHTARGET"
read -p "Press [Return] to continue or [Control-C] to abort: "
echo ""

# Change to the working dir
mkdir -p "$MYTHWORK"
cd "$MYTHWORK"


###############################################################
# Check for & install required tools
###############################################################

# Check make
! make --version >/dev/null && die "ERROR: make not found."

# Parallel make
if [ -n "$NUMBER_OF_PROCESSORS" ]; then
    cpus=$NUMBER_OF_PROCESSORS
elif [ -e "/proc/cpuinfo" ]; then
    cpus=`grep -c processor /proc/cpuinfo`
else
    cpus=1
fi
[ -n "$makejobs" ] && [ $cpus -gt $makejobs ] && cpus=$makejobs
if [ $cpus -gt 1 ]; then
    make="make -j $(($cpus +1))"
else
    make="make"
fi

# Check the C compiler exists
if ! ${xprefix:+$xprefix-}gcc --version >/dev/null 2>&1 ; then
    die "ERROR: The C compiler ${xprefix:+$xprefix-}gcc was not found."
fi

# Apply the mingw <float.h> patch for Qt
# Qt tools/qlocale.cpp:6628: error: ‘_clear87’ was not declared in this scope
# Qt tools/qlocale.cpp:6629: error: ‘_control87’ was not declared in this scope
# $1= sudo
# $2.. patch args
function patchmingw() {
    local gccversion=`${xprefix:+$xprefix-}gcc -dumpversion`
    local path1 path2
    local dosudo=$1
    shift

    case "$xprefix" in
        i586-mingw32msvc)
            path1="/usr/$xprefix/include"
            path2="/usr/lib/gcc/$xprefix/$gccversion/include"
        ;;
        i586-pc-mingw32)
            path1="/usr/$xprefix/sys-root/mingw/include"
            path2="/usr/lib/gcc/$xprefix/$gccversion/include"
        ;;
        i686-pc-mingw32)
            path1="/usr/$xprefix/sys-root/mingw/include"
            path2="/usr/lib64/gcc/$xprefix/$gccversion/include"
        ;;
        *mingw*)
            echo "WARNING: Guessing include paths"
            path1="/usr/${xprefix:+$xprefix/}include"
            path2="/usr/lib/gcc/${xprefix:+$xprefix/}$gccversion/include"
        ;;
        *) die "patchmingw compiler not supported: $xprefix" ;;
    esac

	$dosudo patch -p0 $@ <<-EOF
		--- $path1/float.h	2009-06-30 10:32:33.000000000 +0200
		+++ $path1/float.h	2010-11-03 22:55:07.000000000 +0100
		@@ -16,7 +16,7 @@
		  *
		  */
		 
		-#include_next<float.h>
		+
		 
		 #ifndef _MINGW_FLOAT_H_
		 #define _MINGW_FLOAT_H_
		--- $path2/float.h	2010-01-03 02:57:35.000000000 +0100
		+++ $path2/float.h	2010-01-03 02:57:35.000000000 +0100
		@@ -27,6 +27,7 @@
		 /*
		  * ISO C Standard:  5.2.4.2.2  Characteristics of floating types <float.h>
		  */
		+#include_next<float.h>
		 
		 #ifndef _FLOAT_H___
		 #define _FLOAT_H___
	EOF
}

if [ "$MYTHTARGET" = "Windows" ]; then
    # Check if the mingw <float.h> patch for Qt is required
    if ! ${xprefix:+$xprefix-}gcc -c -x c++ - -o /dev/null >/dev/null 2>&1 <<-EOF
		#include <float.h>
		int main(void){ _clear87(); _control87(0,0); return 0; }
		EOF
    then
        echo ""
        echo "The $xprefix <float.h> header must be patched to compile Qt."
        while read -p "Do you wish to apply this patch (sudo is required) [Yn] " ; do
            case "$REPLY" in
                n|no|N) echo "NOTE: Qt may not build."; break ;;
                y|yes|Y|"")
                    patchmingw "" -s --dry-run && patchmingw "sudo" || \
                        { echo ""; \
                        echo "WARNING: The patch failed. Qt may not build."; \
                        read -p "Press [Return] to continue or [Control-C] to abort "; }
                    break
                ;;
            esac
        done
    fi
fi

# Need wget http://www.gnu.org/software/wget/ to download everything
if ! which wget >/dev/null 2>&1 ; then
    [ "$MSYSTEM" != "MINGW32" ] && die "ERROR: wget not found"
    # No wget so use ftp to download the wget source
    if ! which ftp >/dev/null 2>&1 ; then
        echo "There is no FTP client so you must manually install wget from:"
        echo "  http://$SOURCEFORGE/gnuwin32/wget-1.11.4-1-setup.exe"
        echo "Run the installer and then add wget to the PATH:"
        echo "  Start > My Computer > RightClick: Properties"
        echo "  Tab: Advanced > Click: Environment Variables > Click: New"
        echo "  PATH=C:\Program Files\GnuWin32\bin"
        echo "Then restart any shells."
        exit 1
    fi
    name=$WINWGET; url=$WINWGET_URL; arc=`basename "$url"`
    [ ! -e "$arc" ] && ftpget $url
    [ ! -d $name ] && unpack $arc
    banner "Building $name"
    pushd $name >/dev/null
    cmd /c "configure.bat --mingw"
    cd src
    $make
    cp -p wget.exe /usr/bin/
    popd >/dev/null
fi

# Need unzip for mysql
if ! which unzip >/dev/null 2>&1 ; then
    [ "$MSYSTEM" != "MINGW32" ] && die "ERROR: unzip not installed"
    name=$WINUNZIP; url=$WINUNZIP_URL; arc=`basename "$url"`
    [ ! -e "$arc" ] && download "$url"
    banner "Installing $name..."
    ./$arc -d "$name"
    cp -p "$name/unzip.exe" /usr/bin/
fi

# Need zip to create install archive
if ! which zip >/dev/null 2>&1 ; then
    [ "$MSYSTEM" != "MINGW32" ] && die "ERROR: zip not installed"
    name=$WINZIP; url=$WINZIP_URL; arc=`basename "$url"`
    [ ! -e "$arc" ] && download "$url"
    banner "Installing $name..."
    unzip -d "$name" "$arc"
    cp -p "$name/zip.exe" /usr/bin/
fi

# Need git to get myth sources
if ! which git >/dev/null 2>&1 ; then
    [ "$MSYSTEM" != "MINGW32" ] && "ERROR: git not installed";
    gitexe="c:\Program Files\Git\bin\git.exe"
    gitexe32="C:\Program Files (x86)\Git\bin\git.exe"
    if [ ! -e "$gitexe" -a ! -e "$gitexe32" ]; then
        name=$WINGIT; url=$WINGIT_URL; arc=`basename "$url"`
        [ ! -e "$arc" ] && download "$url"
        banner "Installing $name..."
        ./$arc
    fi
    [ -e "$gitexe32" ] && gitexe="$gitexe32"
    args='$@'
    cat >/usr/bin/git <<-EOF
		#!/bin/sh
		"$gitexe" $args
	EOF
    if ! git --version >/dev/null ; then
        rm /usr/bin/git
        echo "Although $WINGIT was installed, the git program cannot be found."
        echo "You must add the directory containing git.exe to PATH and restart this script."
        exit 1
    fi
fi


###############################################################
# Start of build
###############################################################

mkdir -p "$bindir" "$incdir" "$libdir"

# Set PATH for configure scripts needing freetype-config & taglib-config sh scripts
export PATH="$bindir:$PATH"

# Set the pkg-config default directory
export PKG_CONFIG_PATH="$libdir/pkgconfig"
mkdir -p "$PKG_CONFIG_PATH"


# Build and install a library
# $1= lib name
# $2...= optional configure args
function build() {
    local lib=$1
    shift
    local liburl=${lib}_URL
    local libcfg=${lib}_CFG
    local name=${!lib}
    local url=${!liburl}
    local arc=`basename $url`

    # Download
    [ ! -e "$arc" ] && download "$url"

    banner "Building $name"

    # Unpack
    [ ! -d "$name" ] && unpack "$arc"

    # Patch
    pushd "$name" >/dev/null
    dopatches "$name" || rm -f "$stampbuild" "$stampconfig"
    [ -n "$reconfig" ] && rm -f "$stampbuild" "$stampconfig"

    # configure
    if [ ! -e "$stampconfig" -o -n "${!libcfg}" -o ! -e "Makefile" ]; then
        rm -f "$stampconfig"
        [ -e Makefile ] && make_distclean || true
        set -x
        ./configure -q "--prefix=$MYTHINSTALL" ${xprefix:+--host=$xprefix} \
            ${bprefix:+--build=$bprefix} $@ ${!libcfg}
        set +x
        pausecont
        touch "$stampconfig"
        rm -f "$stampbuild"
    fi

    # make
    stampinstall="$MYTHINSTALL/installed-$name"
    if [ ! -e "$stampbuild" ] ; then
        $make
        touch "$stampbuild"
        rm -f "$stampinstall"
    fi

    # install
    if [ ! -e "$stampinstall" ]; then
        $make -s install
        touch "$stampinstall"
    fi
    popd >/dev/null
}

# Test if building debug version of package
# $1= package name
function isdebug() {
    local tag=${1}_DEBUG
    local dbg=${!tag}
    case "$dbg" in
        n|no|N|NO|"") return 1 ;;
        y|yes|Y|YES) return 0 ;;
        auto) [ "$MYTHBUILD" = "debug" ] && return 0 || return 1 ;;
        *) die "Invalid $tag=$dbg" ;;
    esac
}

###############################################################################
# Install pthreads - http://sourceware.org/pthreads-win32/
if [ "$MYTHTARGET" = "Windows" ]; then
    comp=PTHREADS; compurl=${comp}_URL; compcfg=${comp}_CFG
    name=${!comp}; url=${!compurl}; arc=`basename $url`
    stampinstall="$MYTHINSTALL/installed-$name"

    [ ! -e "$arc" ] && download "$url"
    banner "Building $name"
    [ ! -d "$name" ] && unpack "$arc"
    pushd "$name" >/dev/null
    dopatches "$name" || rm -f "$stampbuild"
    [ -n "$reconfig" ] && rm -f "$stampbuild"
    if [ ! -e "$stampbuild" ] ; then
        $make -s -f GNUmakefile ${xprefix:+CROSS=$xprefix-} clean > /dev/null 2>&1
        $make -f GNUmakefile ${xprefix:+CROSS=$xprefix-} GC ${!compcfg}
        touch "$stampbuild"
        rm -f "$stampinstall"
    fi
    if [ ! -e "$stampinstall" ]; then
        cp -p libpthreadGC2.a "$libdir/libpthread.a"
        cp -p pthreadGC2.dll "$bindir/"
        cp -p sched.h semaphore.h pthread.h "$incdir/"
        touch "$stampinstall"
    fi
    popd >/dev/null
fi

###############################################################################
# Install zlib - http://www.zlib.net/
if [ "$MYTHTARGET" = "Windows" ]; then
    comp=ZLIB; compurl=${comp}_URL; compcfg=${comp}_CFG
    name=${!comp}; url=${!compurl}; arc=`basename $url`
    stampinstall="$MYTHINSTALL/installed-$name"

    [ ! -e "$arc" ] && download "$url"
    banner "Building $name"
    [ ! -d "$name" ] && unpack "$arc"
    pushd "$name" >/dev/null
    dopatches "$name" || rm -f "$stampbuild"
    [ -n "$reconfig" ] && rm -f "$stampbuild"
    if [ ! -e "$stampbuild" ] ; then
        $make -f win32/Makefile.gcc clean
        $make -f win32/Makefile.gcc ${xprefix:+PREFIX=$xprefix-} SHARED_MODE=1
        touch "$stampbuild"
        rm -f "$stampinstall"
    fi
    if [ ! -e "$stampinstall" ]; then
        $make -s -f win32/Makefile.gcc \
            "BINARY_PATH=$bindir" "INCLUDE_PATH=$incdir" "LIBRARY_PATH=$libdir" \
            SHARED_MODE=1 install
        touch "$stampinstall"
    fi
    popd >/dev/null
fi

###############################################################################
# Install freetype - http://savannah.nongnu.org/projects/freetype/
build FREETYPE

###############################################################################
# Install lame - http://lame.sourceforge.net/index.php
isdebug LAME && debug="--enable-debug=norm" || debug="--disable-debug"
build LAME $debug

###############################################################################
# Install libxml2 - http://xmlsoft.org
build LIBXML2

###############################################################################
# DirectX - http://msdn.microsoft.com/en-us/directx/
if [ "$MYTHTARGET" = "Windows" ]; then
    name=$WINE; url=$WINE_URL; arc=`basename $url`
    stampinstall="$MYTHINSTALL/installed-$name"

    [ ! -e "$arc" ] && download "$url"
    banner "Installing DirectX headers from $name"
    [ ! -d "$name" ] && unpack "$arc"
    pushd "$name" >/dev/null
    dopatches "$name" || true
    if [ ! -e "$stampinstall" ]; then
        cp -p "include/dsound.h" "$incdir/"
        touch "$stampinstall"
    fi
    popd >/dev/null
fi

###############################################################################
# Install libexif - http://libexif.sourceforge.net/
# For MythGallery
build LIBEXIF

###############################################################################
# Install libogg - http://www.xiph.org/ogg/
# For MythMusic
build LIBOGG

###############################################################################
# Install libvorbis - http://www.xiph.org/vorbis/
# For MythMusic
build LIBVORBIS

###############################################################################
# Install flac - http://flac.sourceforge.net/
# For MythMusic
isdebug FLAC && debug="--enable-debug" || debug="--disable-debug"
# --disable-cpplibs 'cos examples/cpp/encode/file/main.cpp doesn't #include <string.h> for memcmp
build FLAC --disable-cpplibs $debug

###############################################################################
# Install libcdio - http://www.gnu.org/software/libcdio/
# For MythMusic
# --disable-joliet or need iconv
build LIBCDIO --disable-joliet

###############################################################################
# Install taglib - http://freshmeat.net/projects/taglib
# For MythMusic
isdebug TAGLIB && debug="--enable-debug=yes" || debug="--disable-debug"
# Including path to zlib causes link to fail 'cos needs dll
#CPPFLAGS=-I"$incdir" LDFLAGS=-L"$libdir" \
build TAGLIB $debug

###############################################################################
# Install fftw - http://www.fftw.org/
# For MythMusic
isdebug FFTW && debug="--enable-debug" || debug="--disable-debug"
[ ! -e "$libdir/libfftw3.a" ] && rm -f $FFTW/$stampconfig
build FFTW --enable-threads $debug
# Single precision
[ ! -e "$libdir/libfftw3f.a" ] && rm -f $FFTW/$stampconfig
build FFTW --enable-threads --enable-float $debug

###############################################################################
# Install libsdl - http://www.libsdl.org/
# For MythMusic, needed by libvisual
#CPPFLAGS=-I"$incdir" LDFLAGS=-L"$libdir" \
build LIBSDL

###############################################################################
# Install libvisual - http://libvisual.sourceforge.net/
# For MythMusic
isdebug LIBVISUAL && debug="--enable-debug" || debug="--disable-debug"
build LIBVISUAL --disable-threads $debug

###############################################################################
# Install libdvdcss - http://www.videolan.org/developers/libdvdcss.html
# For MythVideo
# NB need LDFLAGS=-no-undefined to enable dll creation
LDFLAGS=-no-undefined build LIBDVDCSS

###############################################################################
# Install MySQL - http://mysql.com/
if [ "$MYTHTARGET" = "Windows" ]; then
    name=$MYSQLW; url=$MYSQLW_URL; arc=`basename $url`
    stampinstall="$MYTHINSTALL/installed-$name"
    [ ! -e "$arc" ] && download "$url"
    banner "Installing $name"
    [ ! -d "$name" ] && unpack "$arc"
    pushd "$name" >/dev/null
    dopatches "$name" || true
    # Debug build asserts at libmysql.c line 4314: param_>buffer_length != 0
    # Triggered from mythmusic::Playlist::loadPlaylist(backup_playlist_storage)
    # and mythvideo/browse if the query returns a zero length blob.
    #isdebug MYSQL && MYSQLW_LIB="lib/debug" || MYSQLW_LIB="lib/opt"
    MYSQLW_LIB="lib/opt"
    if [ ! -e "$stampinstall" ]; then
        cd "$bindir"
        cp -p $MYTHWORK/$MYSQLW/scripts/mysql_config.pl mysql_config
        chmod +x mysql_config || true
        cd "$incdir"
        ln -f -s $MYTHWORK/$MYSQLW/include/ mysql
        cd "$libdir"
        ln -f -s "$MYTHWORK/$MYSQLW/$MYSQLW_LIB/mysqlclient.lib" .
        cp -p "$MYTHWORK/$MYSQLW/$MYSQLW_LIB/libmysql.lib" .
        # For mythzoneminder
        cp -p "$MYTHWORK/$MYSQLW/$MYSQLW_LIB/libmysql.lib" libmysql.a
        touch "$stampinstall"
    fi
    popd >/dev/null
else
    if isdebug MYSQL ; then
        # BUG: debug build of mysql 5.1.54 enables -Werror which errors with
        # gcc 4.4.5 so disable those warnings...
        export CFLAGS="-Wno-unused-result -Wno-unused-function"
        debug="--with-debug"
    else
        debug="--without-debug"
    fi
    build MYSQL --enable-thread-safe-client \
        --without-server --without-docs --without-man $debug
    # v5.0 --without-extra-tools --without-bench
    unset CFLAGS
fi

###############################################################################
# Build Qt - http://get.qt.nokia.com/
###############################################################################
comp=QT; compurl=${comp}_URL; compcfg=${comp}_CFG
name=${!comp}; url=${!compurl}; arc=`basename $url`
stampinstall="$MYTHINSTALL/installed-$name"

if isdebug QT ; then
    debug="debug"
    # BUG: debug build with i586-mingw32msvc-gcc version 4.2.1 fails due to
    # multiple definitions of inline functions like powf conflicting with stdlibc++
    # Workaround: set CXXFLAGS=-O1 before configuring Qt
    export CXXFLAGS="${CXXFLAGS:+$CXXFLAGS }-O1"
else
    debug="release"
fi

# Create a mkspecs tailored for the xprefix of the cross tool
function mkspecs() {
    # mkspecs name
    qtXplatform="win32-g++linux"
    rm -rf "mkspecs/$qtXplatform"
    mkdir -p "mkspecs/$qtXplatform"
    cp -f "mkspecs/win32-g++/qplatformdefs.h" "mkspecs/$qtXplatform/"
    cat > "mkspecs/$qtXplatform/qmake.conf" <<-EOF
		#
		# qmake configuration for cross building with Mingw on Linux
		#
		
		MAKEFILE_GENERATOR	= MINGW
		TARGET_PLATFORM		= win32
		TEMPLATE            = app
		CONFIG              += qt warn_on release link_prl copy_dir_files debug_and_release debug_and_release_target precompile_header
		QT                  += core gui
		DEFINES             += UNICODE QT_LARGEFILE_SUPPORT
		QMAKE_INCREMENTAL_STYLE = sublib
		QMAKE_COMPILER_DEFINES  += __GNUC__ WIN32
		QMAKE_EXT_OBJ       = .o
		QMAKE_EXT_RES       = _res.o
		
		include(../common/g++.conf)
		include(../common/unix.conf)
		
		QMAKE_RUN_CC		= \$(CC) -c \$(CFLAGS) \$(INCPATH) -o \$obj \$src
		QMAKE_RUN_CC_IMP	= \$(CC) -c \$(CFLAGS) \$(INCPATH) -o \$@ \$<
		QMAKE_RUN_CXX		= \$(CXX) -c \$(CXXFLAGS) \$(INCPATH) -o \$obj \$src
		QMAKE_RUN_CXX_IMP	= \$(CXX) -c \$(CXXFLAGS) \$(INCPATH) -o \$@ \$<
		
		##########################################
		# Mingw customization of g++.conf
		QMAKE_CC                = ${xprefix:+$xprefix-}gcc
		QMAKE_CXX               = ${xprefix:+$xprefix-}g++
		QMAKE_CFLAGS_SHLIB	=
		QMAKE_CFLAGS_STATIC_LIB	=
		QMAKE_CFLAGS_THREAD     += -D_REENTRANT
		QMAKE_CXXFLAGS_SHLIB	=
		QMAKE_CXXFLAGS_STATIC_LIB =
		QMAKE_CXXFLAGS_THREAD	+= \$\$QMAKE_CFLAGS_THREAD
		QMAKE_CXXFLAGS_RTTI_ON	= -frtti
		QMAKE_CXXFLAGS_RTTI_OFF	= -fno-rtti
		QMAKE_CXXFLAGS_EXCEPTIONS_ON = -fexceptions -mthreads
		QMAKE_CXXFLAGS_EXCEPTIONS_OFF = -fno-exceptions
		
		QMAKE_LINK              = ${xprefix:+$xprefix-}g++
		QMAKE_LINK_SHLIB        = ${xprefix:+$xprefix-}g++
		QMAKE_LINK_C            = ${xprefix:+$xprefix-}gcc
		QMAKE_LINK_C_SHLIB      = ${xprefix:+$xprefix-}gcc
		QMAKE_LFLAGS            = -enable-stdcall-fixup -Wl,-enable-auto-import -Wl,-enable-runtime-pseudo-reloc
		QMAKE_LFLAGS_EXCEPTIONS_ON = -mthreads
		QMAKE_LFLAGS_EXCEPTIONS_OFF =
		QMAKE_LFLAGS_RELEASE	+= -Wl,-s
		QMAKE_LFLAGS_DEBUG      =
		QMAKE_LFLAGS_CONSOLE	+= -Wl,-subsystem,console
		QMAKE_LFLAGS_WINDOWS	+= -Wl,-subsystem,windows
		QMAKE_LFLAGS_DLL        += -shared
		QMAKE_LFLAGS_PLUGIN     += -shared
		
		QMAKE_LINK_OBJECT_MAX	= 30
		QMAKE_LINK_OBJECT_SCRIPT= object_script
		
		##########################################
		# mingw target
		QMAKE_INCDIR            =
		QMAKE_LIBDIR            += \$\$[QT_INSTALL_LIBS]
		QMAKE_INCDIR_QT         = \$\$[QT_INSTALL_HEADERS]
		QMAKE_LIBDIR_QT         = \$\$[QT_INSTALL_LIBS]
		
		QMAKE_INCDIR_X11        =
		QMAKE_LIBDIR_X11        =
		QMAKE_INCDIR_OPENGL     =
		QMAKE_LIBDIR_OPENGL     =
		QMAKE_INCDIR_OPENGL_ES1 =
		QMAKE_LIBDIR_OPENGL_ES1 =
		QMAKE_INCDIR_OPENGL_ES2 =
		QMAKE_LIBDIR_OPENGL_ES2 =
		QMAKE_LIBS_X11          =
		QMAKE_LIBS_X11SM        =
		
		QMAKE_LIBS              =
		QMAKE_LIBS_CORE         = -lkernel32 -luser32 -lshell32 -luuid -lole32 -ladvapi32 -lws2_32
		QMAKE_LIBS_GUI          = -lgdi32 -lcomdlg32 -loleaut32 -limm32 -lwinmm -lwinspool -lws2_32 -lole32 -luuid -luser32 -ladvapi32
		QMAKE_LIBS_OPENGL       = -lglu32 -lopengl32 -lgdi32 -luser32
		QMAKE_LIBS_OPENGL_QT    =
		QMAKE_LIBS_NETWORK      = -lws2_32
		QMAKE_LIBS_COMPAT       = -ladvapi32 -lshell32 -lcomdlg32 -luser32 -lgdi32 -lws2_32
		QMAKE_LIBS_QT_ENTRY     = -lmingw32 -lqtmain
		
		# Linux hosted Qt cross tools
		QMAKE_MOC               = \$\$[QT_INSTALL_BINS]/moc
		QMAKE_UIC               = \$\$[QT_INSTALL_BINS]/uic
		QMAKE_IDC               = \$\$[QT_INSTALL_BINS]/idc
		
		# Linux hosted Mingw tools
		#QMAKE_AR                = ${xprefix:+$xprefix-}ar cqs
		QMAKE_LIB               = ${xprefix:+$xprefix-}ar -ru
		QMAKE_OBJCOPY           = ${xprefix:+$xprefix-}objcopy
		QMAKE_RANLIB            = ${xprefix:+$xprefix-}ranlib
		QMAKE_STRIP             = ${xprefix:+$xprefix-}strip
		QMAKE_STRIPFLAGS_LIB    += --strip-unneeded
		QMAKE_RC                = ${xprefix:+$xprefix-}windres
		#QMAKE_IDL               = midl
		
		# Linux hosted coreutils
		QMAKE_TAR               = tar -cf
		QMAKE_GZIP              = gzip -9f
		QMAKE_ZIP               = zip -r -9
		
		QMAKE_COPY              = cp -f
		QMAKE_COPY_FILE         = \$(COPY)
		QMAKE_COPY_DIR          = \$(COPY) -r
		QMAKE_MOVE              = mv -f
		QMAKE_DEL_FILE          = rm -f
		QMAKE_DEL_DIR           = rmdir
		QMAKE_CHK_DIR_EXISTS    = test -d
		QMAKE_MKDIR             = mkdir -p
		QMAKE_INSTALL_FILE      = install -m 644 -p
		QMAKE_INSTALL_PROGRAM   = install -m 755 -p
		
		load(qt_config)
	EOF
}

[ ! -e "$arc" ] && download "$url"
banner "Building $name"
[ ! -d "$name" ] && unpack "$arc"
pushd "$name" >/dev/null
dopatches "$name" || rm -f "$stampbuild" $stampconfig*
[ -n "$reconfig" ] && rm -f "$stampbuild" "$stampconfig"
if [ ! -e "$stampconfig.$debug" -o -n "${!compcfg}" -o ! -e Makefile ]; then
    rm -f $stampconfig*
    [ -n "$xprefix" ] && mkspecs
    [ -e Makefile ] && $make confclean >/dev/null 2>&1 || true
    args="-opensource -confirm-license \
        ${qtXplatform:+-xplatform $qtXplatform} \
        -$debug -fast -nomake examples -nomake demos -nomake tools \
        -no-scripttools -no-declarative -no-phonon \
        -no-sql-sqlite -no-sql-odbc -plugin-sql-mysql -I $incdir/mysql"
    if [ "$MSYSTEM" = "MINGW32" ]; then
        set -x
        cmd /c "configure.exe $args -L `pwd -W`/../$MYSQLW/lib/opt -l mysql ${!compcfg}"
        set +x
    else
        set -x
        ./configure -prefix $MYTHINSTALL $args -mysql_config $bindir/mysql_config \
            -no-javascript-jit -no-reduce-exports ${!compcfg}
        set +x 
    fi
    pausecont
    touch "$stampconfig.$debug"
    rm -f "$stampbuild"
fi
function helpQt() {
    echo ""
    echo "ERROR: make failed."
    if [ "$MSYSTEM" = "MINGW32" ]; then
        echo "Sometimes this is due to a VM shortage:"
        echo "  make.exe: *** couldn't commit memory for cygwin heap, Win32 error 487"
        echo "If so then ensure that you have at least 1GB of VM and restart this script."
    fi
    exit 1
}
if [ ! -e "$stampbuild" ] ; then
    $make || helpQt
    touch "$stampbuild"
    rm -f "$stampinstall"
fi
if [ "$MSYSTEM" != "MINGW32" -a ! -e "$stampinstall" ]; then
    banner "Installing $QT"
    $make -s install
    touch "$stampinstall"
fi
popd >/dev/null
unset CXXFLAGS

###############################################################################
###############################################################################
# Build MythTV - http://www.mythtv.org/
###############################################################################
###############################################################################
cd "$MYTHDIR"
name="mythtv"
[ ! -d $name ] && gitclone -b $MYTHBRANCH "$MYTHGIT/$name.git" $name
pushd $name >/dev/null

if [ "$MYTHBRANCH" != `gitbranch .` ]; then
    banner "Switching to $name branch $MYTHBRANCH"
    status=`git status -s`
    if [ -n "$status" ]; then
        echo "WARNING: You requested to switch branches but have uncommited changes."
        echo "WARNING: Proceeding will discard those changes."
        read -p "Press [Return] to continue or [Control-C] to abort: "
    fi
    git clean -f -d -x >/dev/null
    git checkout -f "$MYTHBRANCH"
fi

mythtag=`git describe --dirty`

case "$MYTHBRANCH" in
    master*) : ${MYTHVER:="master"} ;;
    fixes/*) : ${MYTHVER:=${MYTHBRANCH/fixes\//}} ;;
    *) : ${MYTHVER:=""} ;;
esac

pushd $name >/dev/null
banner "Building $name"
dopatches "$name${MYTHVER:+-$MYTHVER}" || rm -f $stampconfig*
[ -n "$reconfig" ] && rm -f $stampconfig*
if [ ! -e "$stampconfig${MYTHBUILD:+.$MYTHBUILD}" -o -n "$MYTHTV_CFG" \
        -o ! -e "config.h" -o ! -e "Makefile" ]; then
    rm -f $stampconfig*
    [ -e config.mak ] && make_distclean || true
    if [ -n "$xprefix" ]; then
        cpu="pentium3"
        rprefix="."
    else
        cpu="host"
        rprefix=".."
    fi
    if [ "$MYTHTARGET" = "Windows" ]; then
        args="--disable-lirc --disable-hdhomerun --disable-firewire --disable-iptv --disable-joystick-menu"
        # TODO Until configure uses pkg-config to detect libxml2 it must be set here
        [ "$MYTHBRANCH" = "master" ] && args="$args --libxml2-path=$incdir/libxml2"
    else
        args="--disable-joystick-menu"
    fi
    set -x
    ./configure "--prefix=$MYTHINSTALL" "--runprefix=$rprefix" \
        "--qmake=$MYTHWORK/$QT/bin/qmake" \
        ${xprefix:+--enable-cross-compile} \
        ${xprefix:+--cross-prefix=$xprefix-} \
        ${xprefix:+--target_os=mingw32} \
        ${xprefix:+--arch=x86} \
        --cpu=$cpu \
        "--sysinclude=$incdir" \
        "--extra-cflags=-I$incdir" "--extra-cxxflags=-I$incdir" \
        "--extra-ldflags=-L$libdir" \
        --enable-libfftw3 \
        --disable-avdevice --disable-avfilter --disable-directfb \
        $args --compile-type=$MYTHBUILD $MYTHTV_CFG
    set +x
    pausecont
    touch "$stampconfig${MYTHBUILD:+.$MYTHBUILD}"
fi
function helpmyth() {
    echo ""
    echo "ERROR: make failed."
    if [ "$MSYSTEM" == "MINGW32" ]; then
        echo "Sometimes this is due to an internal compiler fault in:"
        echo "  external/ffmpeg/libavacodec/imgconvert.c"
        echo "If so then it can help to restart the system and run this script again."
    fi
    exit 1
}
$make || helpmyth
banner "Installing $name"
$make -s install
popd >/dev/null

###############################################################################
# Build MythPlugins - http://www.mythtv.org/
name="mythplugins"
pushd $name >/dev/null
banner "Building $name"
dopatches "$name${MYTHVER:+-$MYTHVER}" || rm -f $stampconfig*
[ -n "$reconfig" ] && rm -f $stampconfig*
if [ ! -e "$stampconfig${MYTHBUILD:+.$MYTHBUILD}" -o -n "$MYTHPLUGINS_CFG" \
        -o ! -e "config.pro" -o ! -e "Makefile" ]; then
    rm -f $stampconfig*
    [ -e Makefile ] && make_distclean || true
    # NB patches reqd for mytharchive & mythzoneminder
    #plugins="--disable-mytharchive --disable-mythzoneminder"
    if ! isdebug QT ; then
        # mythnews, mythweather & mythnetvision require debug build of Qt in .pro file
        plugins="$plugins --disable-mythnews --disable-mythweather --disable-mythnetvision"
    fi
    [ "$MYTHTARGET" = "Windows" ] && args="--disable-dcraw" || args=""
    set -x
    ./configure "--prefix=$MYTHINSTALL" \
        "--qmake=$MYTHWORK/$QT/bin/qmake" \
        "--sysroot=$MYTHINSTALL" \
        ${xprefix:+--cross-prefix=$xprefix-} \
        ${xprefix:+--targetos=MINGW32} \
        --enable-all $plugins \
        --enable-libvisual --enable-fftw \
        $args --compile-type=$MYTHBUILD $MYTHPLUGINS_CFG
    set +x
    pausecont
    touch "$stampconfig${MYTHBUILD:+.$MYTHBUILD}"
fi
$make
banner "Installing $name"
$make -s install
popd >/dev/null ; # mythtv/mythplugins

popd >/dev/null ; # mythtv

###############################################################################
# Build MythThemes
name="myththemes"
[ ! -d $name ] && gitclone -b $MYTHBRANCH "$MYTHGIT/$name.git" $name
pushd $name >/dev/null

if [ "$MYTHBRANCH" != `gitbranch .` ]; then
    banner "Switching to $name branch $MYTHBRANCH"
    git clean -f -d -x >/dev/null
    git checkout -f "$MYTHBRANCH"
fi

banner "Building $name"
dopatches "$name${MYTHVER:+-$MYTHVER}" || rm -f "mythconfig.mak"
[ -n "$reconfig" ] && rm -f "mythconfig.mak"
if [ ! -e "mythconfig.mak" ]; then
    [ -e Makefile ] && make_distclean || true
    ./configure "--prefix=$MYTHINSTALL" --qmake="$MYTHWORK/$QT/bin/qmake"
fi
$make
banner "Installing $name"
$make -s install
popd >/dev/null


###############################################################################
# Create the Windows installation
###############################################################################
if [ "$MYTHTARGET" = "Windows" ]; then
    banner "Building MythTV $MYTHTARGET runtime in $windir"
    rm -rf "$windir"
    mkdir -p "$windir"
    pushd "$windir" >/dev/null

    # Myth binaries
    ln -s $bindir/myth*.exe .
    ln -s $bindir/libmyth-?.??.dll $bindir/libmythdb-?.??.dll \
        $bindir/libmythfreemheg-?.??.dll $bindir/libmythmetadata-?.??.dll \
        $bindir/libmythtv-?.??.dll $bindir/libmythui-?.??.dll \
        $bindir/libmythupnp-?.??.dll .
    mkdir -p share
    ln -s $MYTHINSTALL/share/mythtv/ share/
    mkdir -p lib
    ln -s $libdir/mythtv/ lib/

    # Mingw runtime
    if [ "$MSYSTEM" == "MINGW32" ]; then
        mingw="/mingw//bin"
        ln -s $mingw/libstdc++-*.dll $mingw/libgcc_s_dw2-*.dll .
    elif [ -e "/usr/share/doc/mingw32-runtime/mingwm10.dll.gz" ]; then
        cp -p "/usr/share/doc/mingw32-runtime/mingwm10.dll.gz" .
        gunzip "mingwm10.dll.gz"
    elif [ -d "/usr/$xprefix/sys-root/mingw/bin/" ]; then
        ln -s /usr/$xprefix/sys-root/mingw/bin/mingwm??.dll .
        ln -s /usr/$xprefix/sys-root/mingw/bin/libstdc++-?.dll .
        ln -s /usr/$xprefix/sys-root/mingw/bin/libgcc_s_sjlj-?.dll .
    elif dll=`locate "/usr/*mingw*.dll"` ; then
        ln -s `echo "$dll" | tr "\n" " "` .
    else
        echo "WARNING: Mingw32 runtime dll's not found."
        read -p "Press [Return] to continue: "
    fi

    # FFmpeg
    ln -s $bindir/libmythavcodec-??.dll $bindir/libmythavcore-?.dll \
        $bindir/libmythavformat-??.dll $bindir/libmythavutil-??.dll \
        $bindir/libmythswscale-?.dll $bindir/libmythpostproc-??.dll .

    # Libs for Myth
    ln -s $bindir/libxml2-?.dll $bindir/libfreetype-?.dll $bindir/libmp3lame-?.dll $bindir/pthreadGC2.dll .

    # QT
    QTDLLS="QtCore QtGui QtNetwork QtOpenGL QtSql QtSvg QtWebKit QtXml Qt3Support"
    isdebug QT && ext="d4.dll" || ext="4.dll"
    if [ "$MSYSTEM" == "MINGW32" ]; then
        for dll in $QTDLLS ; do
            ln -s "$MYTHWORK/$QT/bin/$dll$ext" .
        done
        ln -s $MYTHWORK/$QT/plugins/* .
    else
        for dll in $QTDLLS ; do
            ln -s "$bindir/$dll$ext" .
        done
        ln -s $MYTHINSTALL/plugins/* .
    fi

    # MySQL for QT plugin
    ln -s $MYTHWORK/$MYSQLW/$MYSQLW_LIB/libmysql.dll .

    # For mythvideo plugin
    ln -s $bindir/libdvdcss-?.dll .

    # For mythgallery plugin
    ln -s $bindir/libexif-??.dll .
    if [ "$MSYSTEM" == "MINGW32" ]; then
        ln -s $mingw/libiconv-?.dll $mingw/libintl-?.dll .
    fi

    # For mythmusic plugin
    ln -s $bindir/libogg-?.dll $bindir/libvorbis-?.dll \
        $bindir/libvorbisenc-?.dll $bindir/libtag-?.dll .
    ln -s $bindir/libcdio-??.dll $bindir/libcdio_cdda-?.dll \
        $bindir/libcdio_paranoia-?.dll .
    ln -s $bindir/libvisual-0.4-?.dll $bindir/SDL.dll .

    popd >/dev/null

    archive="$MYTHINSTALL/mythtv-w32-$mythtag.zip"
    banner "Building MythTV $MYTHTARGET archive `basename $archive`"
    [ -e "$archive" ] && mv -f "$archive" "${archive%.zip}-bak.zip"
    pushd "$windir" >/dev/null
    zip -9 -r -q "$archive" *
    popd >/dev/null
fi

banner "Finished"
