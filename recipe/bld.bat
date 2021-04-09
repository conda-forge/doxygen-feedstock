@echo on

mkdir build
cd build

:: workaround for winflexbison problem, see https://github.com/conda-forge/winflexbison-feedstock/issues/6
set BISON_PKGDATADIR=%BUILD_PREFIX%\Library\share\winflexbison\data

:: cmake
cmake -G "Ninja" ^
    -DCMAKE_INSTALL_PREFIX:PATH="%LIBRARY_PREFIX%" ^
    -DCMAKE_BUILD_TYPE:STRING=Release ^
    .. || goto :eof

:: build
cmake --build . --config Release -j %CPU_COUNT% || goto :eof

:: test - xmllint, diff and perl are required
where xmllint || goto :eof
where diff || goto :eof
perl --version || goto :eof
ctest --output-on-failure -C Release || goto :eof

:: install
cmake --build . --config Release --target install || goto :eof
