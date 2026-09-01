@echo on

mkdir build
cd build

:: workaround for winflexbison problem, see https://github.com/conda-forge/winflexbison-feedstock/issues/6
set BISON_PKGDATADIR=%BUILD_PREFIX%\Library\share\winflexbison\data

:: debug
echo "=== perl ==="
perl --version

echo "=== python ==="
python --version

echo "=== cmake ==="
cmake --version

echo "=== latex ==="
latex --version

echo "=== bibtex ==="
bibtex --version

echo "=== dvips ==="
dvips --version

echo "=== bison ==="
win_bison --version

echo "=== flex ==="
win_flex --version

echo "=== dot ==="
dot -V

echo "=== ghostscript ==="
gswin64c --version

:: cmake
cmake -G "Ninja" ^
    -DCMAKE_PREFIX_PATH:PATH="%LIBRARY_PREFIX%" ^
    -DCMAKE_INSTALL_PREFIX:PATH="%LIBRARY_PREFIX%" ^
    -DCMAKE_BUILD_TYPE:STRING=Release ^
    -Dbuild_app=1 ^
    .. || exit /b 1

:: build
cmake --build . --config Release --verbose -j 1 || exit /b 1

:: install
cmake --build . --config Release --verbose -j 1 --target install || exit /b 1

:: test - xmllint, diff, perl and pdflatex are required; skip the suite if any
:: is missing. Every probe below has to land on :no_tests rather than fall out
:: of the script, because rattler-build propagates the trailing errorlevel: a
:: failed `where` would otherwise be reported as a failed build.
where xmllint || goto :no_tests
where diff || goto :no_tests
perl --version || goto :no_tests
where pdflatex.exe || goto :no_tests
ctest --output-on-failure -C Release || exit /b 1

:no_tests
exit /b 0
