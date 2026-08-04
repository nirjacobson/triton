# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{11..14} )
DESCRIPTION="NVIDIA CUDA Toolkit"
SRC_URI="amd64? ( https://developer.download.nvidia.com/compute/cuda/13.3.1/local_installers/cuda_13.3.1_610.43.02_linux.run )
	 arm64? ( https://developer.download.nvidia.com/compute/cuda/13.3.1/local_installers/cuda_13.3.1_610.43.02_linux_sbsa.run )"
RESTRICT="mirror"
LICENSE="NVIDIA-CUDA"
KEYWORDS="amd64 arm64"
SLOT="13"

src_unpack() {
	cp "${DISTDIR}/${A[0]}" "${WORKDIR}/"
	chmod +x "${WORKDIR}/${A[0]}"
	.${WORKDIR}/${A[0]} --extract="${WORKDIR}"
}

src_install() {
	dodir /usr/local/cuda
	insinto /usr/local/cuda

	cd ${WORKDIR}/cuda*
	for y in `find . -maxdepth 1 -type d`; do
		doins -r "$y"
	done
}
