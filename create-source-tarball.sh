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
# Download repo function.
download() {
  mkdir -p $1
  cd $1
  git init
  git remote add origin $2
  git fetch origin $3
  git reset --hard FETCH_HEAD
  git submodule update --init --recursive
  cd ..
}
# TODO: Add more comments.
savedir="$(pwd)"
tmpdir="$(mktemp -d)"
ver=$(date "+%Y%m%d")
wdir=mcpelauncher-thesonicmaster-$ver
mkdir -p $tmpdir/$wdir
cd $tmpdir/$wdir
status "==> Retrieving upstream sources..."
curl -s https://raw.githubusercontent.com/ChristopherHX/linux-packaging-scripts/main/msa.commit > msa.commit; echo >> msa.commit
curl -s https://raw.githubusercontent.com/ChristopherHX/linux-packaging-scripts/main/mcpelauncher.commit > mcpelauncher.commit; echo >> mcpelauncher.commit
curl -s https://raw.githubusercontent.com/ChristopherHX/linux-packaging-scripts/main/mcpelauncher-ui.commit > mcpelauncher-ui.commit; echo >> mcpelauncher-ui.commit
download msa https://github.com/minecraft-linux/msa-manifest.git $(cat msa.commit)
download mcpelauncher https://github.com/minecraft-linux/mcpelauncher-manifest.git $(cat mcpelauncher.commit)
download mcpelauncher-ui https://github.com/minecraft-linux/mcpelauncher-ui-manifest.git $(cat mcpelauncher-ui.commit)
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
sed -i "s/The Launcher has trouble to verify that you own the Game on Google Play. You may need to buy the Game. If you own the game on the Play Store on the signed in account try sign out, sign in again and accept the Tos Prompt. If you won't accept the Google Play Terms of Service Window inside the Launcher after sign in you cannot play the Game./Hi there\! You're seeing this message because the upstream developers recently updated the launcher to prevent you from playing if you don't own Minecraft on Google Play. Fortunately, you're using The Sonic Master's fork, therefore the license error is removed and you can simply close this message and carry on. Have a nice day\! :)/" mcpelauncher-ui/mcpelauncher-ui-qt/qml/LauncherMain.qml
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
