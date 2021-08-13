#!/bin/bash
#
# Install mcpelauncher build dependencies for Debian systems.
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
# Exit on error
set -e
# Function to find the best way of getting root.
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
# Launch apt to install dependencies.
as_root apt install -y build-essential clang cmake gettext git \
                       libasound2 libcurl4-openssl-dev libegl1-mesa-dev \
                       libevdev-dev libpng-dev libprotobuf-dev libpulse-dev \
                       libqt5svg5-dev libssl-dev libtool libudev-dev \
                       libuv1-dev libx11-dev libxi-dev libzip-dev ninja-build \
                       protobuf-compiler qml-module-qtquick2 \
                       qml-module-qtquick-controls \
                       qml-module-qtquick-controls2 qml-module-qtquick-dialogs \
                       qml-module-qtquick-layouts qml-module-qtquick-window2 \
                       qml-module-qt-labs-folderlistmodel \
                       qml-module-qt-labs-settings qtbase5-dev \
                       qtdeclarative5-dev qttools5-dev qttools5-dev-tools \
                       qtwebengine5-dev texinfo
