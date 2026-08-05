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
IUSE="+cuda +cudnn +vulkan +python"
SLOT="0"
RESTRICT="network-sandbox"
BDEPEND="cuda? ( x11-drivers/nvidia-drivers dev-util/nvidia-cuda )
	 cudnn? ( x11-drivers/nvidia-drivers dev-libs/nvidia-cudnn )
	 vulkan? ( media-libs/vulkan-loader dev-util/vulkan-tools )"
RDEPEND="${BDEPEND}"

src_unpack() {
	git-r3_src_unpack
}

src_configure() {
	export BUILD_TEST=OFF

	if use python; then
		export BUILD_PYTHON=ON
	else
		export BUILD_PYTON=OFF
	fi

	if use cuda; then
		export USE_CUDA=ON
		export TORCH_CUDA_ARCH_LIST="7.5;8.0;8.6;8.9;9.0"
		export CUDA_TOOLKIT_ROOT_DIR="/usr/local/cuda"
	else
		export USE_CUDA=OFF
	fi

	if use cudnn; then
		export USE_CUDNN=ON
		export CUDNN_ROOT_DIR="/usr/local/cuda"
	else
		export USE_CUDNN=OFF
	fi

	if use vulkan; then
		export USE_VULKAN=ON
		export USE_VULKAN_WRAPPER=OFF
		export VULKAN_INCLUDE_DIR="/usr/include/vulkan"
		export VULKAN_LIBRARY="/lib64/libvulkan.so"
	else
		export USE_VULKAN=OFF
	fi

	if use cuda || use cudnn; then
		export PATH="$CUDA_TOOLKIT_ROOT_DIR/bin:$PATH"
		export LD_LIBRARY_PATH="$CUDA_TOOLKIT_ROOT_DIR/lib64:$LD_LIBRARY_PATH"
	fi

	cmake_src_configure
}
