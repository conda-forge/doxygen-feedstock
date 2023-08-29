@echo on

mkdir build
cd build

:: workaround for winflexbison problem, see https://github.com/conda-forge/winflexbison-feedstock/issues/6
set BISON_PKGDATADIR=%BUILD_PREFIX%\Library\share\winflexbison\data

:: debug
echo "=== perl ===";
perl --version;
echo "=== python ===";
python --version;
echo "=== cmake ===";
cmake --version;
echo "=== latex ===";
Try {
    latex --version;
}
Catch {
    echo "latex not found";
}
echo "=== bibtex ===";
Try {
    bibtex --version;
}
Catch {
    echo "bibtex not found";
}
echo "=== dvips ===";
Try {
    dvips --version;
}
Catch {
    echo "dvips not found";
}
echo "=== bison ===";
win_bison --version;
echo "=== flex ===";
win_flex --version;
echo "=== dot ===";
dot -V;
echo "=== ghostscript ===";
gswin64c --version;

:: cmake
cmake -G "Ninja" ^
    -DCMAKE_PREFIX_PATH:PATH="%LIBRARY_PREFIX%" ^
    -DCMAKE_INSTALL_PREFIX:PATH="%LIBRARY_PREFIX%" ^
    -DCMAKE_BUILD_TYPE:STRING=Release ^
    .. || goto :eof

:: build
cmake --build . --config Release || goto :eof

:: install
cmake --build . --config Release --target install || goto :eof

:: test - xmllint, diff and perl are required
where xmllint || goto :eof
where diff || goto :eof
perl --version || goto :eof
where pdflatex.exe
if %errorlevel% equ 0 ctest --output-on-failure -C Release
