#!/bin/bash
# Uninstall the mcpelauncher that has been installed from the build script.
# Note: This script does not remove data. Run remove-data.sh for that.
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
# Uninstall components.
status "==> Uninstalling the launcher..."
as_root rm -f /usr/local/bin/msa-daemon
as_root rm -f /usr/local/bin/msa-ui-qt
as_root rm -f /usr/local/bin/mcpelauncher-client
as_root rm -f /usr/local/bin/mcpelauncher-error
as_root rm -f /usr/local/bin/mcpelauncher-ui-qt
as_root rm -f /usr/local/bin/mcpelauncher-webview
as_root rm -rf /usr/local/share/mcpelauncher
as_root rm -f /usr/local/share/applications/mcpelauncher-ui-qt.desktop
as_root rm -f /usr/local/share/pixmaps/mcpelauncher-ui-qt.png
status "==> Launcher uninstalled successfully."
