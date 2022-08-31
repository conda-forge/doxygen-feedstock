#!/bin/bash

mkdir build && cd build
cmake ${CMAKE_ARGS} -LAH -G"$CMAKE_GENERATOR" \
	-DCMAKE_PREFIX_PATH=${PREFIX} \
	-DCMAKE_INSTALL_PREFIX=${PREFIX} \
	-DCMAKE_BUILD_TYPE=Release              \
	..
make
if [[ "${CONDA_BUILD_CROSS_COMPILATION}" != "1" ]]; then
make tests
fi
make install
