# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{11..14} )
DISTUTILS_USE_PEP17=no

inherit cmake
inherit distutils-r1
inherit git-r3
inherit python-r1

DESCRIPTION="Pytorch machine learning library"
EGIT_REPO_URI="https://github.com/pytorch/pytorch.git"
EGIT_SUBMODULES=( '*' )
LICENSE="BSD"
KEYWORDS="amd64 arm64"
IUSE="+cuda +cudnn +vulkan +python +neon"
REQUIRED_USE="neon? ( arm64 )"
SLOT="0"
RESTRICT="network-sandbox"
BDEPEND="dev-python/uv
         dev-python/typing-extensions
	 dev-python/setuptools
	 dev-python/pyyaml
	 dev-python/scikit-build-core
	 cuda? ( x11-drivers/nvidia-drivers dev-util/nvidia-cuda )
	 cudnn? ( x11-drivers/nvidia-drivers dev-libs/nvidia-cudnn )
	 vulkan? ( media-libs/vulkan-loader dev-util/vulkan-tools )"
RDEPEND="dev-python/typing-extensions
	 dev-python/setuptools
	 dev-python/pyyaml
	 cuda? ( x11-drivers/nvidia-drivers dev-util/nvidia-cuda )
	 cudnn? ( x11-drivers/nvidia-drivers dev-libs/nvidia-cudnn )
	 vulkan? ( media-libs/vulkan-loader dev-util/vulkan-tools )
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
	(:)
}

python_compile() {
	export CMAKE_IMAGE_PREFIX="${ED}"
	export BUILD_TEST=OFF
	export BUILD_TORCH=ON

	if [[ ${ARCH} == arm64 ]] && ! use neon; then
		export USE_FBGEMM=OFF
	fi

	if use python; then
		export PYTHON_EXECUTABLE="${PYTHON}"
		export PYTHON_INCLUDE_DIR="${PYTHON_INCLUDE_DIRS}"
		export PYTHON_LIBRARY="${PYTHON_LIBRARIES}"
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
		export PATH="/usr/local/cuda/bin:$PATH"
		export LD_LIBRARY_PATH="/usr/local/cuda/lib64:$LD_LIBRARY_PATH"
	fi

	cd "${S}"
	pip install . --no-build-isolation -v --no-cache-dir --root "${ED}"
}

src_compile() {
	python_foreach_impl python_compile
}

python_install() {
	export WHEEL_PATH=$(find /var/tmp/portage/sci-ml/pytorch-9999/temp -name '*.whl')

	einfo "Installing ${WHEEL_PATH##*/} for ${EPYTHON}"
	"${EPYTHON}" -m gpep517 install-wheel \
		--destdir="${BUID_DIR}/install" \
		--interpreter="${PYTHON}" \
		--prefix="${EPREFIX}/usr" \
		--optimize-all \
		"${WHEEL_PATH}"

	python_optimize "${ED}/usr/lib/${EPYTHON}/site-packages/"
}

src_install() {
	python_foreach_impl python_install

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
}
