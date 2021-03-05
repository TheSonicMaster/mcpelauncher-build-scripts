#!/bin/bash
# Build & install Minecraft Bedrock Linux launcher from latest sources.
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
status_warn() {
  echo -e "\e[1m\e[33m$*\e[0m"
}
# Find the best way of gaining root.
as_root() {
  if [ $EUID = 0 ]; then
    $*
  elif [ -x /usr/bin/sudo ]; then
    sudo $*
  elif [ -x /usr/local/bin/sudo ]; then
    sudo $*
  else
    su -c "$*"
  fi
}
# Download a repo.
download() {
  if [ ! -z $2 ]; then
    git clone --recursive -b $2 $1
  else
    git clone --recursive $1
  fi
}
# Initial status message.
status "==> Build script for mcpelauncher to fix license error."
status "==> Copyright (c) 2021 The Sonic Master."
sleep 1
echo
# Display a warning if running as root, but don't stop the script.
if [ $EUID = 0 ]; then
  status_warn "==> WARNING: While it isn't malware, this script may contain"
  status_warn "==> bugs that could damage your system. Therefore, running as"
  status_warn "==> root is strongly discouraged. The Sonic Master assumes no"
  status_warn "==> responsiblity for any damage to your system as a result of"
  status_warn "==> usage of this script."
  sleep 3
  echo
  status_warn "==> Press CTRL+C to cancel, or the script will proceed in 10s..."
  sleep 10
  echo
fi
# Change to a clean build directory.
builddir=/tmp/build$(date "+%Y%m%d%H%M%S")
mkdir -p $builddir && cd $builddir
# Download latest sources.
status "==> Downloading sources..."
download https://github.com/minecraft-linux/msa-manifest.git
download https://github.com/minecraft-linux/mcpelauncher-manifest.git ng
download https://github.com/minecraft-linux/mcpelauncher-ui-manifest.git ng
# Specify cmake options for the build.
cmake_options="-DCMAKE_BUILD_TYPE=Release -Wno-dev -G Ninja"
# Build MSA.
status "==> Building MSA (for Xbox Live)..."
cd msa-manifest
mkdir build && cd build
CC=clang CXX=clang++ cmake -DENABLE_MSA_QT_UI=ON $cmake_options ..
ninja
# Install MSA.
status "==> Installing MSA..."
as_root ninja install
cd ../..
# Build the game launcher.
status "==> Building the game launcher..."
cd mcpelauncher-manifest
# Fix the license error.
sed -i 's/\!forceGooglePlayStoreUnverified.get()/true/' mcpelauncher-client/src/main.cpp
sed -i 's/\!forceAmazonAppStoreUnverified.get()/true/' mcpelauncher-client/src/main.cpp
mkdir build && cd build
CC=clang CXX=clang++ cmake $cmake_options ..
ninja
# Install the game launcher.
status "==> Installing the game launcher..."
as_root ninja install
cd ../..
# Build the Qt GUI.
status "==> Building the Qt GUI..."
cd mcpelauncher-ui-manifest
mkdir build && cd build
CC=clang CXX=clang++ cmake $cmake_options ..
ninja
# Install the Qt GUI.
status "==> Installing the Qt GUI..."
as_root ninja install
# Strip unneeded debugging symbols to free up space.
status "==> Stripping executables..."
cd /usr/local/bin
as_root strip --strip-all msa* mcpelauncher*
# Clean up.
status "==> Cleaning up..."
rm -rf $builddir
status "==> Successfully built and installed the launcher."
