#!/bin/bash -e
# Build script for MythTV
# Created by Lawrence Rust, lvr at softsystem dot co dot uk
#
# For use on:
# - Windows 2k/XP/Vista/7 to build a native MythTV using the MSYS environment and MingGW
#   http://sourceforge.net/projects/mingw/files
#   # NB Min specs: 1GB (2GB for debug build) VM, physical RAM preferable, and 5GB disk
#   Click:
#     Automated MinGW Installer > mingw-get-inst
#   Then select a version e.g.
#     mingw-get-inst-20101030 > mingw-get-inst-20101030.exe
#   Run the installer and ensure to add:
#     C++
#     MSYS basic system
#     MinGW Developer Toolkit
#   Start an Msys shell from the Windows desktop by clicking:
#     Start > All Programs > MinGW > MinGW Shell"
#   Copy this script to C:\MinGW\msys\1.0\home\[username]
#   At the Msys prompt enter:
#     ./mythbuild.sh
#   or for a debug build type:
#     ./mythbuild.sh -H -d
#
# - Linux to cross build a Windows installation using the MinGW C cross compiler from
#   http://sourceforge.net/projects/mingw/files/Cross-Hosted%20MinGW%20Build%20Tool/
#   At a command prompt type:
#     ./mythbuild.sh -W
#   or for a debug build type:
#     ./mythbuild.sh -W -d
#
# - Linux to build a native MythTV.
#   At a command prompt type:
#     ./mythbuild.sh -H
#   or for a debug build type:
#     ./mythbuild.sh -H -d

readonly myname=`basename "$0"`

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

# Tools
: ${MYTHPATCHES:="mythpatches-0.24"}
: ${MYTHPATCHES_URL:="http://www.softsystem.co.uk/download/mythtv/$MYTHPATCHES.tar.bz2"}
: ${YASM:="yasm-1.1.0"}
: ${YASM_URL:="http://www.tortall.net/projects/yasm/releases/$YASM.tar.gz"}
: ${UNZIP:="unzip60"}
: ${UNZIP_URL:="ftp://ftp.info-zip.org/pub/infozip/src/$UNZIP.zip"}

# Windows hosted tools
: ${WINWGET:="wget-1.11.4"}
: ${WINWGET_URL:="ftp://ftp.gnu.org/gnu/wget/$WINWGET.tar.bz2"}
: ${WINUNZIP:="unz600xn"}
: ${WINUNZIP_URL:="ftp://ftp.info-zip.org/pub/infozip/win32/$WINUNZIP.exe"}
: ${WINZIP:="zip300xn"}
: ${WINZIP_URL:="ftp://ftp.info-zip.org/pub/infozip/win32/$WINZIP.zip"}
: ${WINGIT:="Git-1.7.3.1-preview20101002"}
: ${WINGIT_URL:="http://msysgit.googlecode.com/files/$WINGIT.exe"}
: ${WININSTALLER:="mythinstaller-win32"}
: ${WININSTALLER_URL:="http://www.softsystem.co.uk/download/mythtv/$WININSTALLER.tar.bz2"}

# Dir for myth sources
: ${MYTHDIR:=$PWD}

# Package debug build: yes|no|auto, auto=follow MYTHBUILD
: ${LAME_DEBUG:="auto"}
: ${FLAC_DEBUG:="no"}
: ${TAGLIB_DEBUG:="no"}
: ${FFTW_DEBUG:="no"}
: ${LIBVISUAL_DEBUG:="no"}
: ${MYSQL_DEBUG:="auto"}
: ${QT_DEBUG:="auto"}
# These packages are rebuilt whenever MYTHBUILD changes
readonly debug_packages="LAME FLAC TAGLIB FFTW LIBVISUAL MYSQL QT"

# Working dir for downloads & sources
if [ -d "$MYTHDIR/mythwork" ]; then
    # Backwards compatibility for v1 script
    : ${MYTHWORK:="$MYTHDIR/mythwork"}
    : ${MYTHINSTALL:="$MYTHDIR/mythbuild"}
else
    : ${MYTHWORK:="$MYTHDIR/mythbuild"}
    # prefix for package installs
    : ${MYTHINSTALL:="$MYTHDIR/mythinstall"}
fi


###############################################################
# Parse the command line
###############################################################
function myhelp() {
    echo "A script to build MythTV"
    echo "Usage: $myname [options]"
    echo "Options:"
    echo "  -b tag      Checkout MythTV branch [${MYTHBRANCH:-"fixes/0.24"}]"
    echo "  -r          Switch to release build"
    echo "  -d          Switch to debug build"
    echo "  -p <path>   Set install prefix [$MYTHINSTALL]"
    echo "  -W          Set target to Windows"
    echo "  -H          Set target to Host"
    echo "  -l          Save mythbuild.log"
    echo "  -j n        Max number of make jobs [cpus+1]"
    echo "  -s          Silent make"
    echo "  -C          Force a clean re-build"
    echo "  -R          Reverse patches applied to mythtv & mythplugins"
    echo "  -h          Display this help and exit"
    echo "  -v          Display version and exit"
    echo ""
    echo "The following shell variables are useful:"
    echo "MYTHDIR       Build tree root [current directory]"
    echo "MYTHWORK      Directory to unpack and build packages [MYTHDIR/mythbuild]"
    echo "MYTHPATCHES   Patches [$MYTHPATCHES]"
    echo "MYTHGIT       Myth git repository [$MYTHGIT]"
    echo "MYTHREPO      Primary mirror [$MYTHREPO]"
    echo "SOURCEFORGE   Sourceforge mirror [$SOURCEFORGE]"
    echo "QT            QT version [$QT]"
    echo "QT_DEBUG      QT debug build (yes|no|auto) [$QT_DEBUG]"
    echo "MYSQL         MYSQL version [$MYSQL]"
    echo "MYSQL_DEBUG   MYSQL debug build (yes|no|auto) [$MYSQL_DEBUG]"
}
function version() {
    echo "$myname version 0.2"
}
function die() {
    echo $@ >&2
    exit 1
}

# Options
while getopts ":b:dj:lsp:rhvCHWR" opt
do
    case "$opt" in
        b) [ "${OPTARG:0:1}" = "-" ] && die "Invalid branch tag: $OPTARG"
            MYTHBRANCH=$OPTARG ;;
        d) MYTHBUILD="debug" ;;
        r) MYTHBUILD="release" ;;
        j) [ $OPTARG \< 0 -o $OPTARG \> 99 ] && die "Invalid number: $OPTARG"
            [ $OPTARG -lt 1 ] && die "Invalid make jobs: $OPTARG"
            makejobs=$OPTARG ;;
        p) [ -d "$OPTARG" ] && MYTHINSTALL=$OPTARG || die "No such directory: $OPTARG" ;;
        s) makeflags="-s" ;;
        l) logging="yes" ;;
        C) cleanbuild="yes" ;;
        H) MYTHTARGET="Host" ;;
        W) MYTHTARGET="Windows" ;;
        R) unpatch="yes" ;;
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

# Display a timed message
# $1= seconds $2= message
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

# Print message and timed wait
# $1=seconds, $2=message
function pausecont() {
    local msg=$2
    if [ -z "$msg" ]; then
    	local pkg=`basename "$PWD"`
        msg="Press [Return] to make ${pkg:0:26} or [Control-C] to abort "
    fi
    pause ${1:-60} "$msg"
}

# Display a banner
# $1= message
function banner() {
    echo ""
    echo "*********************************************************************"
    echo "${1:0:80}"
    echo "*********************************************************************"
    echo ""
}

# Unpack an archive
# $1= filename
function unpack() {
    echo "Extracting `basename "$1"` ..."
    case "$1" in
        *.tar.gz) tar -zxf $@ ;;
        *.tar.bz2) tar -jxf $@ ;;
        *.zip) unzip -a -q $@ ;;
        *) die "ERROR: Unknown archive type $1" ;;
    esac
}

# Apply patches to a component
# $1= component name
function dopatches() {
    local i ret=0 p patched
    for i in $MYTHDIR/$MYTHPATCHES/$1/*.diff ; do
        if [ -r "$i" ]; then
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

# Undo patches to a component
# $1= component name
function undopatches() {
    local i p patched
    for i in $MYTHDIR/$MYTHPATCHES/$1/*.diff ; do
        if [ -r "$i" ]; then
            p=`basename "$i" ".diff"`
            patched="patch-$p.applied"
            if [ -e "$patched" ]; then
                echo "Reversing patch $1/`basename $i`"
                patch -p1 -R -E -i "$i" || true
                rm -f "$patched"
            fi
        fi
    done
}

# Download a git repo
# $1= URL $2= dir
function gitclone() {
    banner "git clone $*"
    git clone $@
}

# Get the current git branch
# $1= path to .git
function gitbranch() {
    [ ! -d "$1/.git" ] && return 1
    git --git-dir="$1/.git" branch --no-color|grep "^\*"|cut -c 3-
}

# make distclean
function make_distclean() {
    echo "make distclean..."
    $make -s -k distclean >/dev/null 2>&1 || true
    return 0
}

# make uninstall
function make_uninstall() {
    echo "make uninstall..."
    $make -s -k uninstall >/dev/null 2>&1 || true
    return 0
}

# Test if building debug version of package
# $1= package name
function isdebug() {
    local tag=${1}_DEBUG
    local dbg=${!tag}
    case "$dbg" in
        auto) [ "$MYTHBUILD" = "debug" ] && return 0 || return 1 ;;
        y|yes|Y|YES) return 0 ;;
        n|no|N|NO) return 1 ;;
        "") return 2 ;;
        *) die "Invalid $tag=$dbg" ;;
    esac
}

# Test for altivec instructions
function isAltivec() {
    [ -r "/proc/cpuinfo" ] && grep -i "altivec" /proc/cpuinfo >/dev/null
}

# Recursive file listing
# $1= prefix
function listfiles() {
    local d=$1 n
    for n in *; do
        if [ -d "$n" ]; then
            pushd "$n" >/dev/null
            listfiles "$d$n\\"
            popd >/dev/null
        else
            echo "$d$n"
        fi
    done
}

# Make installed stamp filename
# $1= package
function installed() {
    echo "$MYTHWORK/installed-$1"
}


###############################################################
# Installation check
###############################################################

readonly bindir="$MYTHINSTALL/bin"
readonly incdir="$MYTHINSTALL/include"
readonly libdir="$MYTHINSTALL/lib"
readonly windir="$MYTHINSTALL/win32"

# ./configure done indicator
readonly stampconfig="stamp.mythtv.org"
# make install done indicator
readonly stampbuild="stampbuild.mythtv.org"

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
case "$MYTHBRANCH" in
    master*) : ${MYTHVER:="master"} ;;
    fixes/*) : ${MYTHVER:=${MYTHBRANCH/fixes\//}} ;;
    *) : ${MYTHVER:=""} ;;
esac


# Determine build type
readonly stamptarget="$MYTHWORK/target"
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
                echo "ERROR: need mingw for cross compiling to Windows."
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


# Redirect output to log file as if invoked by: mythbuild.sh 2>&1 | tee -a mythbuild.log
if [ "$logging" = "yes" ]; then
    pipe=`mktemp -u`
    mkfifo "$pipe"
    trap "rm -f $pipe" EXIT
    tee -a "${myname%.sh}.log" < "$pipe" &
    exec > "$pipe" 2>&1
fi


if [ "$unpatch" = "yes" ]; then
    banner "Reversing all MythTV branch $MYTHBRANCH patches."
    read -p "Press [Return] to continue or [Control-C] to abort: "
    if [ -d "$MYTHDIR/mythtv/mythtv" ]; then
        cd "$MYTHDIR/mythtv/mythtv"
        rm -f $stampconfig*
        [ -d "$MYTHDIR/$MYTHPATCHES" ] && undopatches "mythtv${MYTHVER:+-$MYTHVER}"
    fi
    if [ -d "$MYTHDIR/mythtv/mythplugins" ]; then
        cd "$MYTHDIR/mythtv/mythplugins"
        rm -f $stampconfig*
        [ -d "$MYTHDIR/$MYTHPATCHES" ] && undopatches "mythplugins${MYTHVER:+-$MYTHVER}"
    fi
    exit
fi


# Display Myth branch & build type and wait for OK
banner "Building MythTV branch '$MYTHBRANCH' ($MYTHBUILD) for $MYTHTARGET"
[ "$cleanbuild" = "yes" ] && echo "WARNING: All packages will be rebuilt from scratch."
read -p "Press [Return] to continue or [Control-C] to abort: "
echo ""

# Change to the working dir
mkdir -p "$MYTHWORK"
cd "$MYTHWORK"


# Check for clean re-build
if [ "$cleanbuild" = "yes" ]; then
    echo "Clean rebuild"
    rm -rf "$MYTHINSTALL/"
    for d in $MYTHWORK/* ; do [ -d "$d" ] && rm -rf "$d" ; done
    rm "$stamptarget-$MYTHTARGET"
fi


# Test if changing target
if [ ! -e "$stamptarget-$MYTHTARGET" ]; then
    echo "Reconfiguring all packages"
    rm -f $( installed '*')
    rm -f $stamptarget-*
    touch "$stamptarget-$MYTHTARGET"
    readonly reconfig="yes"
fi


# Ensure packages are rebuilt if their debug status has changed
for name in $debug_packages LIBXML2 ; do
    pkg=${!name}
    if isdebug $name; then
        [ ! -e "$MYTHWORK/$pkg/$stampconfig.debug" ] && rm -f $MYTHWORK/$pkg/$stampconfig*
    elif [ "$?" = "1" ]; then
        [ ! -e "$MYTHWORK/$pkg/$stampconfig.release" ] && rm -f $MYTHWORK/$pkg/$stampconfig*
    else
        [ ! -e "$MYTHWORK/$pkg/$stampconfig" ] && rm -f $MYTHWORK/$pkg/$stampconfig*
    fi
done


###############################################################
# Check for & install required tools
###############################################################

mkdir -p "$bindir" "$incdir" "$libdir"

# Set PATH for configure scripts needing freetype-config & taglib-config sh scripts
export PATH="$bindir:$PATH"

# Check make
! make --version >/dev/null && die "ERROR: make not found."

# Parallel make
if [ -n "$NUMBER_OF_PROCESSORS" ]; then
    cpus=$NUMBER_OF_PROCESSORS
elif [ -r "/proc/cpuinfo" ]; then
    cpus=`grep -c processor /proc/cpuinfo`
else
    cpus=1
fi
[ -n "$makejobs" ] && [ $cpus -gt $makejobs ] && cpus=$makejobs
if [ $cpus -gt 1 ]; then
    make="make $makeflags -j $(($cpus +1))"
else
    make="make $makeflags"
fi

# Check the C compiler exists
if ! ${xprefix:+$xprefix-}gcc --version >/dev/null 2>&1 ; then
    die "ERROR: The C compiler ${xprefix:+$xprefix-}gcc was not found."
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
    pushd "$name" >/dev/null
    cmd /c "configure.bat --mingw"
    cd src
    $make
    cp -p wget.exe /usr/bin/
    popd >/dev/null
fi

# Get the patches
pushd "$MYTHDIR" >/dev/null
name=$MYTHPATCHES; url=$MYTHPATCHES_URL; arc=`basename "$url"`
[ ! -e "$arc" ] && { download "$url"; rm -rf "$name"; }
if [ ! -d "$name" ]; then
    banner "Installing $name..."
    unpack "$arc"
    echo "Patches updated.  Refreshing all packages"
    clean="yes"
fi
popd >/dev/null

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

# Need unzip for mysql
if [ "$MYTHTARGET" = "Windows" ] && ! which unzip >/dev/null 2>&1 ; then
    [ "$MSYSTEM" != "MINGW32" ] && die "ERROR: unzip not installed. Try: sudo apt-get install unzip"
    name=$WINUNZIP; url=$WINUNZIP_URL; arc=`basename "$url"`
    [ ! -e "$arc" ] && download "$url"
    banner "Installing $name..."
    ./$arc -d "$name"
    cp -p "$name/unzip.exe" /usr/bin/
fi

# Need zip to create install archive
if [ "$MYTHTARGET" = "Windows" ] && ! which zip >/dev/null 2>&1 ; then
    [ "$MSYSTEM" != "MINGW32" ] && die "ERROR: zip not installed. Try: sudo apt-get install zip"
    name=$WINZIP; url=$WINZIP_URL; arc=`basename "$url"`
    [ ! -e "$arc" ] && download "$url"
    banner "Installing $name..."
    unzip -d "$name" "$arc"
    cp -p "$name/zip.exe" /usr/bin/
fi

# unzip - http://www.info-zip.org
# Build custom SFXWiz32.exe with autorun & bugfix for mythinstaller
if [ "$MYTHTARGET" = "Windows" ] ; then
    name=$UNZIP; url=$UNZIP_URL; arc=`basename "$url"`
    [ ! -e "$arc" ] && download "$url"
    banner "Building $name..."
    [ "$clean" = "yes" ] && rm -rf "$name"
    [ ! -d "$name" ] && unpack "$arc"
    pushd "$name" >/dev/null
    # BUG: SFXWiz32.exe fails with insufficient memory in init
    dopatches "$name" || rm -f Makefile
    if [ ! -e Makefile ]; then
        cp -f win32/Makefile.gcc Makefile
        set -x
        $make ${xprefix:+CC=$xprefix-gcc} \
            ${xprefix:+AR=$xprefix-ar} \
            ${xprefix:+RC=$xprefix-windres} \
            LOCAL_UNZIP="-DCHEAP_SFX_AUTORUN" \
            guisfx
        set +x
    fi
    popd >/dev/null
fi

# Need git to get myth sources
if ! which git >/dev/null 2>&1 ; then
    [ "$MSYSTEM" != "MINGW32" ] && die "ERROR: git not installed. Try: sudo apt-get install git-core";
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

readonly arch=$( [ "$MYTHTARGET" = "Windows" ] && echo "i686" || uname -m)
case $arch in
    i?86)
        # Need YASM for FFMpeg - http://www.tortall.net/projects/yasm
        if ! which yasm >/dev/null 2>&1 ; then
            name=$YASM; url=$YASM_URL; arc=`basename "$url"`
            [ ! -e "$arc" ] && download "$url"
            banner "Building $name..."
            [ ! -d "$name" ] && unpack "$arc"
            pushd "$name" >/dev/null
            ./configure -q "--prefix=$MYTHINSTALL"
            $make
            $make -s install
            popd >/dev/null
        fi
    ;;
    ppc)
        # To run mythtv need to build all shared libs withoot R_PPC_REL24 relocations.
        # 24-bit (4*16Meg) limit to pc relative addresses causes ld.so to fail
        export CFLAGS="-fPIC $CFLAGS"
        export CXXFLAGS="-fPIC $CXXFLAGS"
        export LDFLAGS="-fPIC $LDFLAGS"
    ;;
esac


###############################################################
# Start of build
###############################################################

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
    local libdbg=${lib}_DEBUGFLAG
    local name=${!lib}
    local url=${!liburl}
    local arc=`basename "$url"`

    # Debug build?
    local buildtag="" debugflag=""
    if isdebug $lib ; then
        buildtag="debug"
        debugflag=${!libdbg}
    elif [ "$?" = "1" ]; then
        buildtag="release"
    fi
    local stampconfigtag="$stampconfig${buildtag:+.$buildtag}"

    # Download
    [ ! -e "$arc" ] && download "$url"

    banner "Building $name${buildtag:+ ($buildtag)}"

    [ "$clean" = "yes" ] && rm -rf "$name"

    # Unpack
    [ ! -d "$name" ] && unpack "$arc"

    # Patch
    pushd "$name" >/dev/null
    dopatches "$name" || rm -f "$stampbuild" "$stampconfigtag"

    # Force configure if clean re-build
    [ -n "$reconfig" ] && rm -f "$stampbuild" "$stampconfigtag"

    # configure
    if [ ! -e "$stampconfigtag" -o -n "${!libcfg}" -o ! -e "Makefile" ]; then
        rm -f "$stampconfigtag"
        [ -e Makefile ] && make_distclean || true
        set -x
        ./configure -q "--prefix=$MYTHINSTALL" ${xprefix:+--host=$xprefix} \
            ${bprefix:+--build=$bprefix} $debugflag $@ ${!libcfg}
        set +x
        pausecont
        touch "$stampconfigtag"
        rm -f "$stampbuild"
    fi

    # make
    stampinstall="$( installed $name)"
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

###############################################################################
# Install pthreads - http://sourceware.org/pthreads-win32/
if [ "$MYTHTARGET" = "Windows" ]; then
    comp=PTHREADS; compurl=${comp}_URL; compcfg=${comp}_CFG
    name=${!comp}; url=${!compurl}; arc=`basename "$url"`
    stampinstall="$( installed $name)"

    [ ! -e "$arc" ] && download "$url"
    banner "Building $name"
    [ "$clean" = "yes" ] && rm -rf "$name"
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
        #cp -p libpthreadGC2.a "$libdir/libpthread.a"
        cp -p libpthreadGC2.a "$libdir/"
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
    name=${!comp}; url=${!compurl}; arc=`basename "$url"`
    stampinstall="$( installed $name)"

    [ ! -e "$arc" ] && download "$url"
    banner "Building $name"
    [ "$clean" = "yes" ] && rm -rf "$name"
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
LAME_DEBUGFLAG="--enable-debug=norm"
build LAME

###############################################################################
# Install libxml2 - http://xmlsoft.org
# BUG building with MSys get error in testThreads.c line 110
# And also on Fedora 14 32/64 bit
#build LIBXML2 $( [ "$MSYSTEM" = "MINGW32" ] && echo "--without-threads")
build LIBXML2 --without-threads
#build LIBXML2 --with-minimum --with-output

###############################################################################
# DirectX - http://msdn.microsoft.com/en-us/directx/
if [ "$MYTHTARGET" = "Windows" ]; then
    name=$WINE; url=$WINE_URL; arc=`basename "$url"`
    stampinstall="$( installed $name)"

    [ ! -e "$arc" ] && download "$url"
    banner "Installing DirectX headers from $name"
    [ "$clean" = "yes" ] && rm -rf "$name"
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
# --disable-cpplibs 'cos examples/cpp/encode/file/main.cpp doesn't #include <string.h> for memcmp
FLAC_DEBUGFLAG="--enable-debug"
# Need to set LD_LIBRARY_PATH so ld.so can find libogg when configure runs ogg test
LD_LIBRARY_PATH="$( [ "$MYTHTARGET" = "Host" ] && echo "${libdir}:" )$LD_LIBRARY_PATH" \
build FLAC --disable-cpplibs $( isAltivec || echo "--disable-altivec")

###############################################################################
# Install libcdio - http://www.gnu.org/software/libcdio/
# For MythMusic
# --disable-joliet or need iconv
build LIBCDIO --disable-joliet

###############################################################################
# Install taglib - http://freshmeat.net/projects/taglib
# For MythMusic
TAGLIB_DEBUGFLAG="--enable-debug=yes"
# Including path to zlib causes link to fail 'cos needs dll
#CPPFLAGS="-I$incdir $CPPFLAGS" LDFLAGS="-L$libdir $LDFLAGS" \
build TAGLIB

###############################################################################
# Install fftw - http://www.fftw.org/
# For MythMusic
FFTW_DEBUGFLAG="--enable-debug"
[ ! -e "$libdir/libfftw3.a" ] && rm -f $MYTHWORK/$FFTW/$stampconfig*
build FFTW --enable-threads $( isAltivec || echo "--disable-altivec")
# Single precision
[ ! -e "$libdir/libfftw3f.a" ] && rm -f $MYTHWORK/$FFTW/$stampconfig*
build FFTW --enable-threads --enable-float $( isAltivec || echo "--disable-altivec")

###############################################################################
# Install libsdl - http://www.libsdl.org/
# For MythMusic, needed by libvisual
#CPPFLAGS="-I$incdir $CPPFLAGS" LDFLAGS="-L$libdir $LDFLAGS" \
build LIBSDL --disable-video-ps3 $( isAltivec || echo "--disable-altivec")

###############################################################################
# Install libvisual - http://libvisual.sourceforge.net/
# For MythMusic
LIBVISUAL_DEBUGFLAG="--enable-debug"
build LIBVISUAL --disable-threads

###############################################################################
# Install libdvdcss - http://www.videolan.org/developers/libdvdcss.html
# For MythVideo
# NB need LDFLAGS=-no-undefined to enable dll creation
LDFLAGS="-no-undefined $LDFLAGS" build LIBDVDCSS

###############################################################################
# Install MySQL - http://mysql.com/
if [ "$MYTHTARGET" = "Windows" ]; then
    name=$MYSQLW; url=$MYSQLW_URL; arc=`basename "$url"`
    stampinstall="$( installed $name)"
    [ ! -e "$arc" ] && download "$url"
    banner "Installing $name"
    [ "$clean" = "yes" ] && rm -rf "$name"
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
    MYSQL_DEBUGFLAG="--with-debug"
    # BUG: debug build of mysql 5.1.54 enables -Werror which errors with
    # gcc 4.4.5 so disable those warnings...
    CFLAGS="-Wno-unused-result -Wno-unused-function $CFLAGS" \
    build MYSQL --enable-thread-safe-client \
        --without-server --without-docs --without-man
    # v5.0 --without-extra-tools --without-bench
fi

###############################################################################
# Build Qt - http://get.qt.nokia.com/
###############################################################################
comp=QT; compurl=${comp}_URL; compcfg=${comp}_CFG
name=${!comp}; url=${!compurl}; arc=`basename "$url"`
stampinstall="$( installed $name)"

cxxflags_save=$CXXFLAGS
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
banner "Building $name ($debug)"
[ "$clean" = "yes" ] && rm -rf "$name"
[ ! -d "$name" ] && unpack "$arc"
pushd "$name" >/dev/null
dopatches "$name" || rm -f "$stampbuild" $stampconfig*
[ -n "$reconfig" ] && rm -f "$stampbuild" $stampconfig*
if [ ! -e "$stampconfig.$debug" -o -n "${!compcfg}" -o ! -e Makefile ]; then
    rm -f $stampconfig*
    [ -n "$xprefix" ] && mkspecs
    [ -e Makefile ] &&  echo "make confclean..." && $make confclean >/dev/null 2>&1 || true
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
        # BUG: The mysql plugin refs mysqlclient in $libdir/mysql, which is added
        # by mysql_config to LFLAGS. However, at runtime ld.so also needs to find
        # it but Qt only sets rpath to $libdir so add an explicit rpath
        [ -z "$xprefix" ] && args="$args -R $libdir/mysql"
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
    banner "Installing $QT ($debug)"
    $make -s install
    touch "$stampinstall"
fi
popd >/dev/null
isdebug QT && export CXXFLAGS=$cxxflags_save

###############################################################################
###############################################################################
# Build MythTV - http://www.mythtv.org/
###############################################################################
###############################################################################
cd "$MYTHDIR"
name="mythtv"
[ ! -d $name ] && gitclone -b $MYTHBRANCH "$MYTHGIT/$name.git" $name
pushd "$name" >/dev/null

if [ "$MYTHBRANCH" != $( gitbranch .) ]; then
    banner "Switching to $name branch $MYTHBRANCH"

    branch=`gitbranch "$MYTHDIR/mythtv"`}
    case "$branch" in
        fixes/*) branch=${branch/fixes\//} ;;
        *) ;;
    esac

    pushd mythtv >/dev/null
    [ -e config.mak ] && make_uninstall || true
    undopatches "mythtv-$branch" || true
    rm -f $stampconfig*
    popd >/dev/null

    pushd mythplugins >/dev/null
    [ -e Makefile ] && make_uninstall || true
    undopatches "mythplugins-$branch" || true
    rm -f $stampconfig*
    popd >/dev/null

    status=$( git status -s)
    if [ -n "$status" ]; then
        echo "WARNING: You requested to switch branches but have uncommited changes."
        echo "WARNING: Proceeding will discard those changes."
        read -p "Press [Return] to continue or [Control-C] to abort: "
        #pause 60 "Press [Return] to continue or [Control-C] to abort: "
    fi

    git clean -f -d -x >/dev/null
    git checkout -f "$MYTHBRANCH"
elif [ "$clean" = "yes" ]; then
    git clean -f -d -x >/dev/null
    git checkout .
fi

mythtag=$( git describe)

pushd "$name" >/dev/null
banner "Building $name branch $MYTHBRANCH ($MYTHBUILD)"
dopatches "$name${MYTHVER:+-$MYTHVER}" || rm -f $stampconfig*
[ -n "$reconfig" ] && rm -f $stampconfig*
if [ ! -e "$stampconfig${MYTHBUILD:+.$MYTHBUILD}" -o -n "$MYTHTV_CFG" \
        -o ! -e "config.h" -o ! -e "Makefile" ]; then
    rm -f $stampconfig*
    [ -e config.mak ] && { make_uninstall; make_distclean; } || true

    [ "$MYTHTARGET" = "Windows" ] && rprefix="." || rprefix=".."
    [ -n "$xprefix" ] && cpu="--cpu=pentium3" || cpu="--cpu=host"
    # Mac B/W G3: MYTHTV_CFG="--cpu=g3" Install: libxxf86vm-dev libxv-dev libasound2-dev

    args="--sysinclude=$incdir \
        --extra-cflags=-I$incdir --extra-cxxflags=-I$incdir --extra-libs=-L$libdir \
        --disable-avdevice --disable-avfilter \
        --enable-libfftw3 --disable-directfb --disable-joystick-menu"
    if [ "$MYTHTARGET" = "Windows" ]; then
        args="$args --disable-lirc --disable-symbol-visibility"
    fi

    set -x
    ./configure "--prefix=$MYTHINSTALL" "--runprefix=$rprefix" \
        "--qmake=$MYTHWORK/$QT/bin/qmake" \
        ${xprefix:+--enable-cross-compile} \
        ${xprefix:+--cross-prefix=$xprefix-} \
        ${xprefix:+--target_os=mingw32} \
        ${xprefix:+--arch=x86} $cpu \
        $args --compile-type=$MYTHBUILD $MYTHTV_CFG
    set +x
    # So LD_LIBRARY_PATH can override rpath, set RUNPATH
    [ "$MYTHTARGET" != "Windows" ] && cat >> config.mak <<< QMAKE_LFLAGS+="-Wl,--enable-new-dtags"
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
banner "Installing $name ($MYTHBUILD)"
$make -s install
popd >/dev/null

###############################################################################
# Build MythPlugins - http://www.mythtv.org/
name="mythplugins"
pushd "$name" >/dev/null
banner "Building $name branch $MYTHBRANCH ($MYTHBUILD)"
dopatches "$name${MYTHVER:+-$MYTHVER}" || rm -f $stampconfig*
[ -n "$reconfig" ] && rm -f $stampconfig*
if [ ! -e "$stampconfig${MYTHBUILD:+.$MYTHBUILD}" -o -n "$MYTHPLUGINS_CFG" \
        -o ! -e "config.pro" -o ! -e "Makefile" ]; then
    rm -f $stampconfig*
    [ -e Makefile ] && { make_uninstall; make_distclean; } || true
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
banner "Installing $name ($MYTHBUILD)"
$make -s install
popd >/dev/null ; # mythtv/mythplugins

popd >/dev/null ; # mythtv

###############################################################################
# Build MythThemes
name="myththemes"
[ ! -d $name ] && gitclone -b $MYTHBRANCH "$MYTHGIT/$name.git" $name
pushd "$name" >/dev/null

if [ "$MYTHBRANCH" != $( gitbranch .) ]; then
    banner "Switching to $name branch $MYTHBRANCH"
    git clean -f -d -x >/dev/null
    git checkout -f "$MYTHBRANCH"
elif [ "$clean" = "yes" ]; then
    git clean -f -d -x >/dev/null
    git checkout .
fi

banner "Building $name branch $MYTHBRANCH"
dopatches "$name${MYTHVER:+-$MYTHVER}" || rm -f "mythconfig.mak"
[ -n "$reconfig" ] && rm -f "mythconfig.mak"
if [ ! -e "mythconfig.mak" ]; then
    [ -e Makefile ] && { make_uninstall; make_distclean; } || true
    ./configure "--prefix=$MYTHINSTALL" --qmake="$MYTHWORK/$QT/bin/qmake"
fi
$make
banner "Installing $name"
$make -s install
popd >/dev/null

###############################################################################
# Build MythInstaller
if [ "$MYTHTARGET" = "Windows" ]; then
    name=$WININSTALLER; url=$WININSTALLER_URL; arc=`basename "$url"`
    [ ! -e "$arc" ] && download "$url" || true
    [ ! -d "$name" -a -e "$arc" ] && unpack "$arc"
    if [ -d "$name" ]; then
        pushd "$name" >/dev/null
        banner "Building $name"
        [ ! -e setup.exe ] && $make ${xprefix:+PREFIX=$xprefix-}
        popd >/dev/null
    fi
fi


###############################################################################
# Create the installation
###############################################################################
mythlibs="myth mythdb mythfreemheg mythmetadata mythtv mythui mythupnp mythlivemedia mythhdhomerun"
ffmpeglibs="mythavcodec mythavcore mythavformat mythavutil mythswscale mythpostproc"
xtralibs="xml2 freetype mp3lame dvdcss exif ogg vorbis vorbisenc tag cdio cdio_cdda cdio_paranoia visual-0.4"
QTDLLS="QtCore QtGui QtNetwork QtOpenGL QtSql QtSvg QtWebKit QtXml Qt3Support"

if [ "$MYTHTARGET" = "Windows" ]; then
    banner "Building MythTV $MYTHTARGET runtime in $windir"
    rm -rf "$windir"
    mkdir -p "$windir"
    pushd "$windir" >/dev/null

    # Myth binaries
    ln -s $bindir/myth*.exe .
    for lib in $mythlibs ; do
        ln -s $bindir/lib$lib-?.??.dll .
    done

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
    shopt -s extglob
    for lib in $ffmpeglibs ; do
        file="$bindir/lib$lib-@(?|??).dll"
        ln -s $file .
    done

    # External libs
    for lib in $xtralibs ; do
        file="$bindir/lib$lib-*.dll"
        ln -s $file .
    done

    # Windows only libs
    ln -s $bindir/SDL.dll .
    ln -s $bindir/pthreadGC2.dll .
    #ln -s $bindir/zlib1.dll .
    [ -r libdvdcss-2.dll ] && ln -s libdvdcss-2.dll libdvdcss.dll

    # QT
    isdebug QT && v="d4" || v="4"
    if [ "$MSYSTEM" == "MINGW32" ]; then
        for dll in $QTDLLS ; do
            ln -s $MYTHWORK/$QT/bin/$dll$v.dll .
        done
        ln -s $MYTHWORK/$QT/plugins/* .
    else
        for dll in $QTDLLS ; do
            ln -s $bindir/$dll$v.dll .
        done
        ln -s $MYTHINSTALL/plugins/* .
    fi

    # MySQL for QT plugin
    ln -s $MYTHWORK/$MYSQLW/$MYSQLW_LIB/libmysql.dll .

    # Myth plugins
    mkdir -p lib
    ln -s $libdir/mythtv/ lib/
    mkdir -p share
    ln -s $MYTHINSTALL/share/mythtv/ share/

    if [ -d "$MYTHDIR/mythinstaller-win32" ]; then
        # Installer
        cp "$MYTHDIR/mythinstaller-win32/mythtv.inf" .
        listfiles >> mythtv.inf
        ln -s "$MYTHDIR/mythinstaller-win32/setup.exe" .
    fi

    popd >/dev/null

    # Create archive
    archive="mythtv-$mythtag-w32"
    [ "$MYTHBUILD" != "release" ] && archive="$archive-$MYTHBUILD"
    archive="$MYTHDIR/$archive.zip"
    banner "Building MythTV archive `basename "$archive" .zip`"
    pushd "$windir" >/dev/null

    [ -e "$archive" ] && mv -f "$archive" "${archive%.zip}-bak.zip"
    zip -9 -r -q "$archive" *

    if [ -e "setup.exe" ]; then
        # Set autorun comment:
        zip -z "$archive" >/dev/null <<<\$AUTORUN\$\>setup.exe
        # Make self extracting archive
        for sfx in "$MYTHWORK/$UNZIP/SFXWiz32.exe" "$MYTHWORK/$UNZIP/unzipsfx.exe" ; do
            if [ -r "$sfx" ]; then
                [ -e "${archive%.zip}.exe" ] && mv -f "${archive%.zip}.exe" "${archive%.zip}-bak.exe"
                cat "$sfx" "$archive" > "${archive%.zip}.exe"
                rm -f "$archive"
            fi
        done
    fi

    popd >/dev/null
else
    # Build list of files for host installation archive
    pushd "$MYTHINSTALL" >/dev/null
    files=""

    # Myth binaries
    for bin in bin/myth* ; do
        [ -x "$bin" ] && files="$files $bin"
    done

    for lib in $mythlibs ; do
        files="$files lib/lib$lib-?.??.so.?"
    done

    shopt -s extglob
    for lib in $ffmpeglibs ; do
        files="$files lib/lib$lib.so.@(?|??)"
    done

    # External libs
    for lib in $xtralibs ; do
        files="$files lib/lib$lib.so.@(?|??)"
    done

    # Special libs
    files="$files lib/libSDL*.so.@(?|??)"

    # QT
    for lib in $QTDLLS ; do
        files="$files lib/lib$lib.so.?"
    done
    files="$files plugins"

    # MySQL for QT plugin
    files="$files lib/mysql/libmysqlclient_r.so.@(?|??)"

    # Myth plugins
    files="$files lib/mythtv share/mythtv"
    [ -d "lib/perl" ] && files="$files lib/perl"
    [ -d "share/perl" ] && files="$files share/perl"
    [ -d "lib/python2.6" ] && files="$files lib/python2.6"

    # Create host installation archive
    archive="mythtv${mythtag:+-$mythtag}-$arch"
    [ "$MYTHBUILD" != "release" ] && archive="$archive-$MYTHBUILD"
    archive="$MYTHDIR/$archive.tar.bz2"
    banner "Building MythTV archive `basename "$archive"`"
    [ -e "$archive" ] && mv -f "$archive" "${archive%.tar.bz2}-bak.tar.bz2"
    tar -v --owner nobody --group nogroup -hjcf "$archive" $files
    popd >/dev/null
fi

banner "Finished"

echo "To run a myth program, such as mythfrontend, enter:"
if [ "$MSYSTEM" = "MINGW32" ]; then
    echo "$windir/mythfrontend"
    echo ""
    echo "Persisent settings are stored in c:\Documents and Settings\[user]\.mythtv"
    echo "To use a different location prepend MYTHCONFDIR=<path>"
elif [ "$MYTHTARGET" = "Windows" ]; then
    echo "wine $windir/mythfrontend -p"
    echo ""
    echo "Click 'Set configuration manually'"
    echo "On the page 'Database Configuration 2/2' set 'Use a custom identifier...'"
    echo "Enter a name, e.g. wine, otherwise the host's settings will be used."
    echo ""
    echo "Persisent settings are stored in c:/users/[name]/.xmyth"
    echo "To use a different location prepend MYTHCONFDIR=z:<path>"
else
    echo "$bindir/mythfrontend"
    echo ""
    echo "If the installtion is moved from $MYTHINSTALL then prepend:"
    echo "LD_LIBRARY_PATH=\"<path>/lib:<path>/lib/mysql\" QT_PLUGIN_PATH=\"<path>/plugins\""
    echo ""
    echo "Persisent settings are stored in ~/.xmyth"
    echo "To use a different location prepend MYTHCONFDIR=path"
fi

echo ""
echo "To simplify setting up and running MythTV on Linux or Windows, get this script:"
echo "wget http://www.softsystem.co.uk/download/mythtv/mythrun && chmod +x mythrun"
echo "Run mythfrontend: ./mythrun fe"
echo "Run mythbackend: ./mythrun be"
echo "Run mythtv-setup: ./mythrun setup"
