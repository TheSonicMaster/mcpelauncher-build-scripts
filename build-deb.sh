#!/bin/bash
# Build & install Minecraft Bedrock Linux launcher from latest sources.
# This script will create a DEB (debian) package.
# This script also incorporates a fix for the license error.
#
# BSD 4-Clause License
#
# Copyright (c) 2021, The Sonic Master
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
# 1. Redistributions of source code must retain the above copyright notice, this
#    list of conditions and the following disclaimer.
#
# 2. Redistributions in binary form must reproduce the above copyright notice,
#    this list of conditions and the following disclaimer in the documentation
#    and/or other materials provided with the distribution.
#
# 3. All advertising materials mentioning features or use of this software must
#    display the following acknowledgement:
#      This product includes software developed by The Sonic Master.
#
# 4. Neither the name of the copyright holder nor the names of its
#    contributors may be used to endorse or promote products derived from
#    this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY COPYRIGHT HOLDER "AS IS" AND ANY EXPRESS OR
# IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
# MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO
# EVENT SHALL COPYRIGHT HOLDER BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
# SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
# PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
# OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
# WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
# OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
# ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#
# Exit on error.
set -e
# Print status messages in colour and in bold.
status() {
  echo -e "\e[1m\e[32m$*\e[0m"
}
status2() {
  printf "\e[1m\e[32m$*\e[0m"
}
warn() {
  echo -e "\e[1m\e[33m$*\e[0m"
}
# Initial status message.
status "==> Build DEB script for mcpelauncher to fix license error."
status "==> Copyright (c) 2021 The Sonic Master."
sleep 1
echo
# Display a warning if running as root, but don't stop the script.
if [ $EUID = 0 ]; then
  warn "==> WARNING: While no cats have been harmed, this script may contain"
  warn "==> bugs that could damage your system. Therefore, running as root is"
  warn "==> strongly discouraged. The Sonic Master assumes no responsiblity"
  warn "==> for any damage to your system as a result of usage of this script."
  sleep 3
  echo
  warn "==> Press CTRL+C to cancel, or the script will proceed in 10s..."
  sleep 10
  echo
fi
# Save the current directory so we know where to put the finished DEB package.
savedir=$(pwd)
# Change to a clean build directory.
builddir=/tmp/build$(date "+%Y%m%d%H%M%S")
mkdir -p $builddir && cd $builddir
# Set package directory.
pkgdir=/tmp/pkg$(date "+%Y%m%d%H%M%S")/mcpelauncher-thesonicmaster
# Check and set version version
status2 "==> Checking version... "
ver="$(curl -s https://www.thesonicmaster.net/software/mcpelauncher-thesonicmaster/source/latest.version)"
pkgver="$ver~$(lsb_release -sc)"
status "$ver"
# Download latest source code.
status "==> Downloading source code..."
curl -O https://www.thesonicmaster.net/software/mcpelauncher-thesonicmaster/source/mcpelauncher-thesonicmaster-$ver.tar.xz
# Extract source tarball.
status "==> Unpacking source tarball, please be patient..."
tar -xJf mcpelauncher-thesonicmaster-$ver.tar.xz
# Remove tarball to free up space.
rm mcpelauncher-thesonicmaster-$ver.tar.xz
# Change to source directory.
cd mcpelauncher-thesonicmaster-$ver
# Specify cmake options for the build.
cmake_options="-DCMAKE_INSTALL_PREFIX=/usr -DCMAKE_BUILD_TYPE=Release -Wno-dev -G Ninja"
# Build MSA.
status "==> Building MSA (for Xbox Live)..."
cd msa
mkdir build && cd build
CC=clang CXX=clang++ CFLAGS='-O3' CXXFLAGS='-O3' cmake -DENABLE_MSA_QT_UI=ON $cmake_options ..
ninja
# Install MSA.
status "==> Installing MSA..."
DESTDIR=$pkgdir ninja install
cd ../..
# Build the game launcher.
status "==> Building the game launcher..."
cd mcpelauncher
mkdir build && cd build
CC=clang CXX=clang++ CFLAGS='-O3' CXXFLAGS='-O3' cmake $cmake_options ..
ninja
# Install the game launcher.
status "==> Installing the game launcher..."
DESTDIR=$pkgdir ninja install
cd ../..
# Build the Qt GUI.
status "==> Building the Qt GUI..."
cd mcpelauncher-ui
mkdir build && cd build
CC=clang CXX=clang++ CFLAGS='-O3' CXXFLAGS='-O3' cmake $cmake_options ..
ninja
# Install the Qt GUI.
status "==> Installing the Qt GUI..."
DESTDIR=$pkgdir ninja install
# Strip unneeded debugging symbols to free up space.
status "==> Stripping executables..."
cd $pkgdir/usr/bin
strip --strip-all *
# Collect maintainer information (required for the Debian control file).
status "==> Collecting maintainer information for the package..."
warn "==> Note: This information is only used for the package metadata."
mkdir -p $pkgdir/DEBIAN
while [ -z "$name" ]; do
  read -p "Your full name (or name of organisation): " name
done
while [ -z "$email" ]; do
  read -p "Email address: " email
done
# Collect other package info needed for the control file.
status "==> Collecting system/software info for the package..."
# Set correct architecture (only x86 and x86_64 currently supported).
case $(uname -m) in
  x86_64) arch=amd64 ;;
  i?86) arch=i386 ;;
esac
# Set correct dependencies for the package.
case $arch in
  amd64) libdir=/usr/lib/x86_64-linux-gnu ;;
  i?86) libdir=/usr/lib/i386-linux-gnu ;;
esac
if [ -f $libdir/libzip.so.4 ]; then
  libzip=libzip4
elif [ -f $libdir/libzip.so.5 ]; then
  libzip=libzip5
else
  warn "==> Correct libzip version not found. Dependency will be excluded."
fi
if [ -f $libdir/libprotobuf.so.10 ]; then
  protobuf=libprotobuf10
elif [ -f $libdir/libprotobuf.so.17 ]; then
  protobuf=libprotobuf17
elif [ -f $libdir/libprotobuf.so.23 ]; then
  protobuf=libprotobuf23
else
  warn "==> Correct protobuf version not found. Dependency will be excluded."
fi
# Calculate package size.
cd $pkgdir
size=$(du -k usr | tail -n1 | sed 's/usr//')
# Write Debian control file (metadata of the package).
status "==> Writing control file..."
cat > $pkgdir/DEBIAN/control << END
Package: mcpelauncher-thesonicmaster
Version: $pkgver
Architecture: $arch
Depends: libc6, libssl1.1, libcurl4, libqt5widgets5, libqt5webenginewidgets5, libstdc++6, libx11-6, zlib1g, libpng16-16, libevdev2, libudev1, $libzip, libuv1, libqt5quick5, libqt5svg5, libqt5quickcontrols2-5, libqt5quicktemplates2-5, libqt5concurrent5, $protobuf, qml-module-qtquick2, qml-module-qtquick-layouts, qml-module-qtquick-controls, qml-module-qtquick-controls2, qml-module-qtquick-window2, qml-module-qtquick-dialogs, qml-module-qtwebengine, qml-module-qt-labs-settings, qml-module-qt-labs-folderlistmodel
Maintainer: $name <$email>
Installed-Size: $size
Section: custom
Priority: optional
Homepage: https://www.thesonicmaster.net/software/mcpelauncher-thesonicmaster
Description: Minecraft Bedrock Edition Linux launcher with license error fixed.
END
# Create package.
status "==> Building DEB package..."
cd $pkgdir/..
dpkg-deb --build mcpelauncher-thesonicmaster mcpelauncher-thesonicmaster_${pkgver}_${arch}.deb
mv mcpelauncher-thesonicmaster_${pkgver}_${arch}.deb $savedir
# Clean up.
status "==> Cleaning up..."
rm -rf $builddir $pkgdir
status "==> Debian package successfully created."
