#!/bin/bash
#
# Install mcpelauncher build dependencies for Debian systems.
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
as_root apt install -y build-essential clang cmake gettext git libasound2 \
                       libcurl4-openssl-dev libegl1-mesa-dev libevdev-dev \
                       libpng-dev libprotobuf-dev libpulse-dev libqt5svg5-dev \
                       libssl-dev libtool libudev-dev libuv1-dev libx11-dev \
                       libxi-dev libzip-dev ninja-build protobuf-compiler \
                       qml-module-qtquick2 qml-module-qtquick-controls \
                       qml-module-qtquick-controls2 qml-module-qtquick-dialogs \
                       qml-module-qtquick-layouts qml-module-qtquick-window2 \
                       qml-module-qt-labs-folderlistmodel \
                       qml-module-qt-labs-settings qtbase5-dev \
                       qtdeclarative5-dev qttools5-dev qttools5-dev-tools \
                       qtwebengine5-dev texinfo
