# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{11..14} )

inherit cmake
inherit git-r3
inherit python-r1

DESCRIPTION="Pytorch machine learning library"
EGIT_REPO_URI="https://github.com/pytorch/pytorch.git"
EGIT_SUBMODULES=( '*' )
LICENSE="BSD"
KEYWORDS="amd64 arm64"
IUSE="+cuda +cudnn +vulkan +python +neon"
REQUIRED_USE="neon? ( arm64 )
	      ${PYTHON_DEPS}"
SLOT="0"
RESTRICT="network-sandbox"
BDEPEND="dev-python/typing-extensions
	 dev-python/setuptools
	 dev-python/pyyaml
	 cuda? ( x11-drivers/nvidia-drivers dev-util/nvidia-cuda )
	 cudnn? ( x11-drivers/nvidia-drivers dev-libs/nvidia-cudnn )
	 vulkan? ( media-libs/vulkan-loader dev-util/vulkan-tools )"
RDEPEND="${BDEPEND}
	 python? ( ${PYTHON_DEPS} )
	 dev-libs/protobuf
	 dev-libs/libfmt
"

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

	if use python; then
		python_export PYTHON_INCLUDE_DIRS PYTHON_LIBRARIES

		mycmakeargs+=( -DPYTHON_EXECUTABLE="${PYTHON}" )
		mycmakeargs+=( -DPYTHON_INCLUDE_DIR="${PYTHON_INCLUDE_DIRS}" )
		mycmakeargs+=( -DPYTHON_LIBRARY="${PYTHON_LIBRARIES}" )
	fi

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

src_install() {
	cmake_src_install

	rm -rf "${ED}/usr/lib64/cmake/protobuf"
	rm -rf "${ED}/usr/lib64/cmake/fmt"
	rm -rf "${ED}/usr/lib64/pkgconfig/protobuf.pc"
	rm -rf "${ED}/usr/lib64/pkgconfig/protobuf-lite.pc"
	rm -rf "${ED}/usr/lib64/pkgconfig/fmt.pc"
	rm -rf "${ED}/usr/lib64/cmake/pkgconfig/fmt.pc"
	rm -rf "${ED}/usr/include/google/protobuf"
	rm -rf "${ED}/usr/include/fmt"
	rm -rf "${ED}/usr/include/pybind11"
	rm -rf "${ED}/usr/bin/protoc"

	python_optimize "${ED}/usr/lib/${EPYTHON}/site-packages"
}
