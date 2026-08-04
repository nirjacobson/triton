# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{11..14} )
DESCRIPTION="NVIDIA CUDA Toolkit"
SRC_URI="
		amd64? ( https://developer.download.nvidia.com/compute/cuda/13.3.1/local_installers/cuda_13.3.1_610.43.02_linux.run -> cuda.run )
		arm64? ( https://developer.download.nvidia.com/compute/cuda/13.3.1/local_installers/cuda_13.3.1_610.43.02_linux_sbsa.run -> cuda.run )"

S="${WORKDIR}/${PN}-${PV%_*}"
LICENSE="MPL-2.0 GPL-2 LGPL-2.1"
KEYWORDS="~amd64 ~arm64"

src_unpack() {
	local _lp_dir="${WORKDIR}/language_packs"
	local _src_file

	if [[ ! -d "${_lp_dir}" ]] ; then
		mkdir "${_lp_dir}" || die
	fi

	./${A[0]} --extract="${WORKDIR}"
}

src_prepare() {
	
}

src_configure() {
	
}

src_compile() {
	
}

src_test() {
}

src_install() {
	cd ${WORKDIR}/cuda*
	mkdir /usr/local/cuda
	for y in `find . -maxdepth 1 -type d`; do rsync -avz "$y/" /usr/local/cuda; done
}

pkg_postinst() {
	
}
