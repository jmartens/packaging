# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-plugins/mythvideo/mythvideo-0.21_p17595.ebuild,v 1.1 2008/08/01 16:35:22 cardoe Exp $

EAPI="2"

MYTHTV_VERSION="v0.24-150-g08a8a65"
MYTHTV_BRANCH="fixes/0.24"
MYTHTV_REV="08a8a65535638de185e68f76898c118161d4bf88"
MYTHTV_SREV="08a8a65"

inherit mythtv-plugins eutils

DESCRIPTION="Video player module for MythTV."
IUSE=""
KEYWORDS="amd64 x86 ~ppc"

RDEPEND="media-tv/mythtv[python]
        dev-python/mysql-python
		dev-python/pycurl
		dev-python/oauth
        dev-python/lxml
		"
DEPEND=""

src_prepare() {
	if use experimental
	then
		true;
	fi
}

src_install() {
	mythtv-plugins_src_install
}

pkg_postinst() {
	true
}
