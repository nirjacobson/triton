# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{11..14} )
DESCRIPTION="NVIDIA CUDA cuDNN Library"
SRC_URI="amd64? ( https://developer.download.nvidia.com/compute/cudnn/redist/cudnn/linux-x86_64/cudnn-linux-x86_64-9.14.0.64_cuda13-archive.tar.xz )
	 arm64? ( https://developer.download.nvidia.com/compute/cudnn/redist/cudnn/linux-aarch64/cudnn-linux-aarch64-9.14.0.64_cuda13-archive.tar.xz )"
RESTRICT="mirror"
LICENSE="NVIDIA-cuDNN"
KEYWORDS="amd64 arm64"
SLOT="9.14"

src_unpack() {
	default_src_unpack
}

src_install() {
	dodir /usr/local/cuda
	insinto /usr/local/cuda

	cd ${WORKDIR}/${PN}-${PV}/
	cp -R * "${ED}/usr/local/cuda/"
}
