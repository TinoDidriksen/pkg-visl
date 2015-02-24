./cmake.sh -DCMAKE_TOOLCHAIN_FILE=/opt/mxe/usr/i686-w64-mingw32.shared/share/cmake/mxe-conf.cmake --prefix=/opt/win32
export DLLS="icudt54.dll icuin54.dll icuio54.dll icuuc54.dll $DLLS"
