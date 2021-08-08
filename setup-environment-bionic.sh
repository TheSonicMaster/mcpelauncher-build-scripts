#!/bin/bash
# Prepare Ubuntu 18.04 for building mcpelauncher-thesonicmaster AppImage.
#
# Copyright (C) 2021 The Sonic Master
#
# This program is free software: you can redistribute it and/or modify it under
# the terms of the GNU General Public License as published by the Free Software
# Foundation, either version 3 of the License, or (at your option) any later
# version.
#
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE. See the GNU General Public License for more
# details.
#
# You should have received a copy of the GNU General Public License along with
# this program. If not, see <https://www.gnu.org/licenses/>.
#
# Exit on error.
set -e
# Display coloured messages.
status() {
  echo -e "\e[1m\e[32m$*\e[0m"
}
status2() {
  printf "\e[1m\e[32m$*\e[0m"
}
warn() {
  echo -e "\e[1m\e[33m$*\e[0m"
}
error() {
  echo -e "\e[1m\e[31m$*\e[0m" >&2
}
# Exit if not running as root.
if [ $EUID -ne 0 ]; then
  error "==> Error: This script must be run as root."
# Initial warning.
warn "==> WARNING: THIS SCRIPT MUST ONLY BE RUN IN A VM OR A DOCKER CONTAINER!"
warn "==> WARNING: RUNNING IT ON A REAL SYSTEM MAY RESULT IN A BROKEN SYSTEM!"
warn "\n==> PRESS CTRL+C TO CANCEL, OR THE SCRIPT WILL PROCEED IN 10 SECONDS... "
sleep 10
echo
# Set up CFLAGS and CXXFLAGS, but don't override user-defined flags.
# '-Os' option tells the compiler to optimise for size.
if [ -z "$CFLAGS" ]; then
  export CFLAGS="-Os"
fi
if [ -z "$CXXFLAGS" ]; then
  export CXXFLAGS="-Os"
fi
# '-s' option ensures the resulting binaries/libraries are stripped.
if [ -z "$LDFLAGS" ]; then
  export LDFLAGS="-s"
else
  export LDFLAGS="$LDFLAGS -s"
fi
# Change to a temporary working directory.
workingdir="$(mktemp -d)"
cd $workingdir
# Ensure the system is up to date first.
status "==> Ensuring system is up-to-date..."
apt-get update
apt-get full-upgrade -y
# Install repo dependencies.
status "==> Installing repo dependencies..."
apt-get install -y build-essential clang-10 gettext git libasound2 libegl1-mesa-dev libevdev-dev libpulse-dev libtool libudev-dev libuv1-dev libx11-dev libxi-dev libzip-dev ninja-build squashfs-tools texinfo wget xz
# Ensure clang can be found.
ln -sf clang-10 /usr/bin/clang
ln -sf clang++-10 /usr/bin/clang
# Install CMake.
status "==> Downloading and installing CMake..."
wget https://github.com/Kitware/CMake/releases/download/v3.21.0/cmake-3.21.0-linux-x86_64.tar.gz
tar --no-same-owner -xf cmake-3.21.0-linux-x86_64.tar.gz -C /usr/local --strip-components=1
# Build and install OpenSSL.
status "==> Building and installing OpenSSL..."
wget https://www.openssl.org/source/openssl-1.1.1k.tar.gz
tar --no-same-owner -xf openssl-1.1.1k.tar.gz
cd openssl-1.1.1k
./config --prefix=/usr/local --openssldir=/usr/local/etc/ssl shared
make -j$(nproc)
make install
cd ..
# Build and install curl.
status "==> Building and installing curl..."
wget https://github.com/curl/curl/releases/download/curl-7_78_0/curl-7.78.0.tar.xz
tar --no-same-owner -xf curl-7.78.0.tar.xz
cd curl-7.78.0
./configure --prefix=/usr/local --with-openssl
make -j$(nproc)
make install
cd ..
# Build and install libpng.
status "==> Building and installing libpng..."
wget https://downloads.sourceforge.net/libpng/libpng-1.6.37.tar.xz
wget https://downloads.sourceforge.net/sourceforge/libpng-apng/libpng-1.6.37-apng.patch.gz
tar --no-same-owner -xf libpng-1.6.37.tar.xz
cd libpng-1.6.37
# Patch to support APNG (animated PNG) functionality in libpng.
gzip -cd ../libpng-1.6.37-apng.patch.gz | patch -p1
./configure --prefix=/usr/local
make -j$(nproc)
make install
cd ..
status "==> Building and installing protobuf..."
wget https://github.com/protocolbuffers/protobuf/releases/download/v3.17.3/protobuf-cpp-3.17.3.tar.gz
tar --no-same-owner -xf protobuf-cpp-3.17.3.tar.gz
cd protobuf-3.17.3
./configure --prefix=/usr/local
make -j$(nproc)
make install
cd ..
# Download and install Qt.
status "==> Downloading and installing Qt..."
wget https://github.com/TheSonicMaster/qt-x86_64-linux-binaries/releases/download/5.15.2/qt-5.15.2-linux-x86_64.tar.xz
tar --no-same-owner -xf qt-5.15.2-linux-x86_64.tar.xz -C /usr/local --strip-components=2
# Run 'ldconfig' to ensure all the newly installed libraries can be found.
ldconfig
status "==> Environment setup complete."
