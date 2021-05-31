#!/bin/bash
#
# Uninstalls the mcpelauncher that has been built from source.
# THIS DOES NOT REMOVE INSTALLED DEB/AUR PACKAGES!
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
status "==> Source-built launcher uninstalled successfully."
status "==> Note: Doesn't uninstall installed DEB or AUR package."
