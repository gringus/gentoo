# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit elisp

DESCRIPTION="Extensible package for writing and formatting TeX files in Emacs"
HOMEPAGE="https://www.gnu.org/software/auctex/"
SRC_URI="mirror://gnu/${PN}/${P}.tar.gz"

LICENSE="GPL-3+ FDL-1.3+"
SLOT="0"
KEYWORDS="amd64 arm ~arm64 ppc ppc64 x86 ~amd64-linux ~x86-linux ~ppc-macos"
IUSE="preview-latex"

RDEPEND="
	virtual/latex-base
	preview-latex? (
		app-text/dvipng
		app-text/ghostscript-gpl
	)
"
BDEPEND="
	${RDEPEND}
"

TEXMF="/usr/share/texmf-site"

src_configure() {
	local -a myconf=(
		--with-emacs
		--with-auto-dir="${EPREFIX}/var/lib/auctex"
		--with-lispdir="${EPREFIX}${SITELISP}/${PN}"
		--with-packagelispdir="${EPREFIX}${SITELISP}/${PN}"
		--with-packagedatadir="${EPREFIX}${SITEETC}/${PN}"
		--with-texmf-dir="${EPREFIX}${TEXMF}"
		--disable-build-dir-test
		$(use_enable preview-latex preview)
	)
	econf "${myconf[@]}"
}

src_compile() {
	VARTEXFONTS="${T}/fonts" emake
}

src_install() {
	emake -j1 DESTDIR="${ED}" install
	elisp-site-file-install "${FILESDIR}/50${PN}-gentoo.el"

	if use preview-latex ; then
		elisp-site-file-install "${FILESDIR}/60${PN}-gentoo.el"
	fi

	dodoc ChangeLog* CHANGES FAQ INSTALL PROBLEMS.preview README RELEASE TODO
}

pkg_postinst() {
	use preview-latex && texmf-update

	elisp-site-regen
}

pkg_postrm() {
	use preview-latex && texmf-update

	elisp-site-regen
}
