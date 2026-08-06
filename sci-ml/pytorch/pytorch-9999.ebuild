# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake
inherit git-r3

PYTHON_COMPAT=( python3_{11..14} )
DESCRIPTION="Pytorch machine learning library"
EGIT_REPO_URI="https://github.com/pytorch/pytorch.git"
EGIT_SUBMODULES=( '*' )
LICENSE="BSD"
KEYWORDS="amd64 arm64"
IUSE="+cuda +cudnn +vulkan +python +neon"
REQUIRED_USE="neon? ( arm64 )"
SLOT="0"
RESTRICT="network-sandbox"
BDEPEND="dev-python/typing-extensions
	 dev-python/setuptools
	 dev-python/pyyaml
	 cuda? ( x11-drivers/nvidia-drivers dev-util/nvidia-cuda )
	 cudnn? ( x11-drivers/nvidia-drivers dev-libs/nvidia-cudnn )
	 vulkan? ( media-libs/vulkan-loader dev-util/vulkan-tools )"
RDEPEND="${BDEPEND}"

PATCHES=(
	"${FILESDIR}/wrap-headers.patch"
)

src_unpack() {
	git-r3_src_unpack
}

src_configure() {
	local mycmakeargs=(
		-DCMAKE_IMAGE_PREFIX="${ED}"
		-DBUILD_TEST=OFF
	)

	if [[ ${ARCH} == arm64 ]] && ! use neon; then
		mycmakeargs+=( -DUSE_FBGEMM=OFF )
	fi

	if use python; then
		mycmakeargs+=( -DBUILD_PYTHON=ON )
	else
		mycmakeargs+=( -DBUILD_PYTON=OFF )
	fi

	if use cuda; then
		mycmakeargs+=( -DUSE_CUDA=ON )
		mycmakeargs+=( -DTORCH_CUDA_ARCH_LIST="7.5;8.0;8.6;8.9;9.0" )
		mycmakeargs+=( -DCUDA_TOOLKIT_ROOT_DIR="/usr/local/cuda" )
	else
		mycmakeargs+=( -DUSE_CUDA=OFF )
	fi

	if use cudnn; then
		mycmakeargs+=( -DUSE_CUDNN=ON )
		mycmakeargs+=( -DCUDNN_ROOT_DIR="/usr/local/cuda" )
	else
		mycmakeargs+=( -DUSE_CUDNN=OFF )
	fi

	if use vulkan; then
		mycmakeargs+=( -DUSE_VULKAN=ON )
		mycmakeargs+=( -DUSE_VULKAN_WRAPPER=OFF )
		mycmakeargs+=( -DVULKAN_INCLUDE_DIR="/usr/include/vulkan" )
		mycmakeargs+=( -DVULKAN_LIBRARY="/lib64/libvulkan.so" )
	else
		mycmakeargs+=( -DUSE_VULKAN=OFF )
	fi

	if use cuda || use cudnn; then
		export PATH="/usr/local/cuda/bin:$PATH"
		export LD_LIBRARY_PATH="/usr/local/cuda/lib64:$LD_LIBRARY_PATH"
	fi

	cmake_src_configure
}
