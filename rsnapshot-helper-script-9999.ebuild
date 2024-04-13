# Copyright 2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit git-r3

DESCRIPTION="A helper script for rsnapshot that works similar to anacron"
HOMEPAGE="https://github.com/elcarlosIII/rsnapshot-helper-script"
EGIT_REPO_URI="https://github.com/elcarlosIII/rsnapshot-helper-script.git"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"

DEPEND="app-backup/rsnapshot"
RDEPEND="${DEPEND}"
BDEPEND=""

src_install() {
	dobin backup.sh
	keepdir /var/spool/rsnapshot
}
