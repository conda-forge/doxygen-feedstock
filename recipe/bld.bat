mkdir build
cd build

:: workaround for winflexbison problem, see https://github.com/conda-forge/winflexbison-feedstock/issues/6
set BISON_PKGDATADIR=%BUILD_PREFIX%\Library\share\winflexbison\data

:: cmake
cmake -G "Ninja" ^
    -DCMAKE_INSTALL_PREFIX:PATH="%PREFIX%" ^
    -DCMAKE_BUILD_TYPE:STRING=Release ^
    .. || goto :eof

:: build
cmake --build . --config Release -j %CPU_COUNT% || goto :eof

:: test
ctest -C Release || goto :eof

:: install
cmake --build . --config Release --target install || goto :eof
