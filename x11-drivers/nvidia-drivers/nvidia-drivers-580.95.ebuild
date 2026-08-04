# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit flag-o-matic
inherit git-r3

PYTHON_COMPAT=( python3_{11..14} )
DESCRIPTION="NVIDIA Drivers"
SRC_URI="amd64? ( https://us.download.nvidia.com/XFree86/Linux-x86_64/580.95.05/NVIDIA-Linux-x86_64-580.95.05.run )
	 arm64? ( https://us.download.nvidia.com/XFree86/aarch64/580.95.05/NVIDIA-Linux-aarch64-580.95.05.run )"
RESTRICT="mirror"
case ${ARCH} in
	amd64)
		EGIT_REPO_URI="https://github.com/NVIDIA/open-gpu-kernel-modules.git"
		EGIT_COMMIT="580.95"
		;;
	arm64)
		EGIT_REPO_URI="https://github.com/mariobalanica/open-gpu-kernel-modules.git"
		EGIT_BRANCH="non-coherent-arm-fixes"
		;;
esac
LICENSE="MIT"
KEYWORDS="amd64 arm64"
SLOT="580.95"

src_prepare() {
	filter-ldflags "-Wl,--as-needed"
	filter-ldflags "-Wl,-O*"
	filter-ldflags "-Wl,-z,pack-relative-relocs*"

	default
}

src_unpack() {
	git-r3_src_unpack
	cp "${DISTDIR}/${A[0]}" "${WORKDIR}/"
        chmod +x "${WORKDIR}/${A[0]}"
        mkdir "${WORKDIR}/${PN}-${PV}"

	cd "${WORKDIR}"
	./${A[0]} -x
}

src_compile() {
	emake modules
}

src_install() {
	mkdir -p ${ED}/usr/{lib,lib64,bin}
	mkdir "${ED}/usr/lib/firmware"

	cd ${WORKDIR}/NVIDIA*580.95.05
	cp -rf firmware "{ED}/usr/lib/"
	cp *.so.* "${ED}/usr/lib64/"
	cp *.sh "${ED}/usr/bin/"
	cp mkprecompiled "${ED}/usr/bin/"
	cp nvidia-* "${ED}/usr/bin/"
	cp *.bin *.icd "${ED}/usr/lib/firmware/"
	cp -rf systemd "${ED}/lib/"

	emake modules_install INSTALL_MOD_PATH="${ED}"
}
