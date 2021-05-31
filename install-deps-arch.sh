#!/bin/bash
#
# Install mcpelauncher build dependencies for Arch systems.
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
# Launch pacman to install dependencies.
as_root pacman -S --needed base-devel cmake clang curl git libegl libevdev \
                           libpng libx11 libxi libzip ninja openssl protobuf \
                           qt5-base qt5-declarative qt5-quickcontrols \
                           qt5-quickcontrols2 qt5-svg qt5-tools qt5-webengine \
                           zlib --noconfirm
