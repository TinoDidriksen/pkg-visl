install_dep cg3
/opt/mxe/usr/i686-w64-mingw32.shared/qt5/bin/qmake cg3ide.pro PREFIX=/opt/osx

mkdir -pv /opt/osx-pkg/$PKG_NAME/opt/osx/bin
rsync -av /opt/osx/bin /opt/osx-pkg/$PKG_NAME/opt/osx/
rsync -av /opt/mxe/usr/i686-w64-mingw32.shared/qt5/plugins/platforms /opt/osx-pkg/$PKG_NAME/opt/osx/bin/
