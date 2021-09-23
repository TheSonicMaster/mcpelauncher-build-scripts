#!/bin/bash
#
# Build & install mcpelauncher-thesonicmaster from latest sources.
# For more information about mcpelauncher-thesonicmaster, see
# https://mcpelauncher-thesonicmaster.sourceforge.io
#
# This script will retrieve the upstream sources, apply the necessary changes,
# then compress everything into a tarball.
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
# Colourful messages function.
status() {
  echo -e "\e[1m\e[32m$*\e[0m"
}
# TODO: Add more comments.
savedir="$(pwd)"
tmpdir="$(mktemp -d)"
ver=$(date "+%Y%m%d")
wdir=mcpelauncher-thesonicmaster-$ver
mkdir -p $tmpdir/$wdir
cd $tmpdir/$wdir
status "==> Retrieving upstream sources..."
git clone --recursive https://github.com/minecraft-linux/msa-manifest.git msa
git clone --recursive -b ng https://github.com/minecraft-linux/mcpelauncher-manifest.git mcpelauncher
git clone --recursive -b ng https://github.com/minecraft-linux/mcpelauncher-ui-manifest.git mcpelauncher-ui
status "==> Applying changes for mcpelauncher-thesonicmaster..."
sed -i "s/\!forceGooglePlayStoreUnverified.get()/true/" mcpelauncher/mcpelauncher-client/src/main.cpp
sed -i "s/\!forceAmazonAppStoreUnverified.get()/true/" mcpelauncher/mcpelauncher-client/src/main.cpp
sed -i "s/\"Unknown OpenSource Build\"/\"${ver} \(The Sonic Master\)\"/" mcpelauncher-ui/mcpelauncher-ui-qt/main.cpp
sed -i "/LAUNCHER_ENABLE_GOOGLE_PLAY_LICENCE_CHECK true CACHE STRING/d" mcpelauncher-ui/mcpelauncher-ui-qt/CMakeLists.txt
sed -i "/\!enabled: \!LAUNCHER_ENABLE_GOOGLE_PLAY_LICENCE_CHECK/d" mcpelauncher-ui/mcpelauncher-ui-qt/qml/LauncherLogin.qml
sed -i "s/LAUNCHER_ENABLE_GOOGLE_PLAY_LICENCE_CHECK ? \"Use .apk (Removed due to piracy)\" : //" mcpelauncher-ui/mcpelauncher-ui-qt/qml/LauncherLogin.qml
sed -i "s/Use .apk/Sideload versions/" mcpelauncher-ui/mcpelauncher-ui-qt/qml/LauncherLogin.qml
sed -i "s/apkImportHelper.pickFile()/Qt.openUrlExternally(\"https:\/\/go.thesonicmaster.net\/mcpe-sideload\")/" mcpelauncher-ui/mcpelauncher-ui-qt/qml/LauncherLogin.qml
sed -i "s/Get help/Walkthrough video/" mcpelauncher-ui/mcpelauncher-ui-qt/qml/LauncherLogin.qml
sed -i "s/https:\/\/mcpelauncher.readthedocs.io\/en\/latest\/index.html/https:\/\/www.youtube.com\/watch?v=VkxW9IMatfU/" mcpelauncher-ui/mcpelauncher-ui-qt/qml/LauncherLogin.qml
sed -i "s/To use this launcher, you must purchase Minecraft on Google Play and sign in./This is The Sonic Master's fork of the Minecraft Bedrock Linux launcher which fixes the license error.\\n\\nTo use this launcher, you must purchase Minecraft on Google Play and sign in. Alternatively, you can install The Sonic Master's sideload versions. Click on 'Walthrough video' if unsure on how to do this./" mcpelauncher-ui/mcpelauncher-ui-qt/qml/LauncherLogin.qml
sed -i "s/Import .apk/Download Sideload Versions/" mcpelauncher-ui/mcpelauncher-ui-qt/qml/LauncherSettingsVersions.qml
sed -i "s/apkImportWindow.pickFile()/Qt.openUrlExternally(\"https:\/\/go.thesonicmaster.net\/mcpe-sideload\")/" mcpelauncher-ui/mcpelauncher-ui-qt/qml/LauncherSettingsVersions.qml
sed -i "/LAUNCHER_ENABLE_GOOGLE_PLAY_LICENCE_CHECK/d" mcpelauncher-ui/mcpelauncher-ui-qt/qml/LauncherSettingsVersions.qml
sed -i "s/The Launcher has trouble to verify that you own the Game on Google Play. You may need to buy the Game. If you own the game on the Play Store on the signed in account try sign out, sign in again and accept the Tos Prompt. If you won't accept the Google Play Terms of Service Window inside the Launcher after sign in you cannot play the Game./This is not an error. Everything is working correctly\! Simply close this dialog and carry on.../" mcpelauncher-ui/mcpelauncher-ui-qt/qml/LauncherMain.qml
status "==> Finishing up..."
echo $ver > version.txt
curl -s https://raw.githubusercontent.com/TheSonicMaster/mcpelauncher-build-scripts/main/LICENSE > LICENSE
cd ..
status "==> Creating tarball..."
tar -cJvf $wdir.tar.xz $wdir
mv $wdir.tar.xz "$savedir"
cd "$savedir"
status "==> Generating sha256sum..."
sha256sum $wdir.tar.xz > $wdir.tar.xz.sha256
echo $ver > latest.version
rm -rf $tmpdir
status "==> Finished! Output tarball written to $wdir.tar.xz."
