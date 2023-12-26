#!/bin/bash

if [[ "$target_platform" == osx-* ]]; then
    CXXFLAGS="${CXXFLAGS} -D_LIBCPP_DISABLE_AVAILABILITY"
fi

mkdir build && cd build
cmake ${CMAKE_ARGS} -LAH -G"$CMAKE_GENERATOR" \
	-DCMAKE_PREFIX_PATH=${PREFIX} \
	-DCMAKE_INSTALL_PREFIX=${PREFIX} \
	-DCMAKE_BUILD_TYPE=Release \
	-Dbuild_app=1 \
	..

make -j${CPU_COUNT}
if [[ "${CONDA_BUILD_CROSS_COMPILATION}" != "1" || "${CMAKE_CROSSCOMPILING_EMULATOR}" != "" ]]; then
  make tests
fi
make install
