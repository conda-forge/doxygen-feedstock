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
    .. || exit /b 1

:: build
cmake --build . --config Release --verbose || exit /b 1

:: install
cmake --build . --config Release --verbose --target install || exit /b 1

:: test - xmllint, diff and perl are required
where xmllint || goto :eof
where diff || goto :eof
perl --version || goto :eof
where pdflatex.exe
if %errorlevel% equ 0 ctest --output-on-failure -C Release
