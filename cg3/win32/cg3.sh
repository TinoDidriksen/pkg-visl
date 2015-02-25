./cmake.sh -DCMAKE_TOOLCHAIN_FILE=/opt/mxe/usr/i686-w64-mingw32.shared/share/cmake/mxe-conf.cmake --prefix=/opt/win32
mkdir -p /opt/win32-pkg/$PKG_NAME/opt/win32/bin/
ln -s vislcg3.exe /opt/win32-pkg/$PKG_NAME/opt/win32/bin/cg3.exe
export EXTRA_DEPS="icudt54.dll icuin54.dll icuio54.dll icuuc54.dll $EXTRA_DEPS"
