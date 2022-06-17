#!/bin/bash

if [ "$(uname)" == "Darwin" ]; then
  # See https://conda-forge.org/docs/maintainer/knowledge_base.html#newer-c-features-with-old-sdk
  export CXXFLAGS="${CXXFLAGS} -D_LIBCPP_DISABLE_AVAILABILITY"
fi

mkdir build && cd build
cmake ${CMAKE_ARGS} \
	-DCMAKE_INSTALL_PREFIX=$PREFIX          \
	-DCMAKE_BUILD_TYPE=Release              \
	..
make
if [[ "${CONDA_BUILD_CROSS_COMPILATION}" != "1" ]]; then
make tests
fi
make install
