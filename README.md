# mcpelauncher-build-scripts
Build scripts for mcpelauncher-thesonicmaster, The Sonic Master's fork of the
Minecraft Bedrock Linux Launcher that fixes the license error. For more
information about this project, visit https://mcpelauncher.thesonicmaster.net.
# Retrieving the scripts
```
git clone https://github.com/TheSonicMaster/mcpelauncher-build-scripts.git
cd mcpelauncher-build-scripts
```
# Installing build dependencies (not needed if building AUR or Snap package)
## On Debian/Ubuntu
```
./install-deps-debian.sh
```
## On Arch Linux
```
./install-deps-arch.sh
```
## Other distros
You need the following software:

- Standard build tools
- [Clang](https://clang.llvm.org/)
- [CMake](https://cmake.org/)
- [libcurl](https://curl.se/libcurl/)
- [libegl (libglvnd)](https://github.com/NVIDIA/libglvnd)
- [libevdev](https://www.freedesktop.org/software/libevdev/doc/latest/)
- [libpng](http://www.libpng.org/pub/png/libpng.html)
- [libzip](https://libzip.org/)
- [Ninja](https://ninja-build.org/)
- [OpenSSL](https://www.openssl.org/)
- [Protobuf](https://developers.google.com/protocol-buffers/)
- [Qt5 development libraries](https://www.qt.io/)
- [Xorg development libraries](https://xorg.freedesktop.org/)
- [zlib](https://zlib.net/)

# Building (Install dependencies as outlined above first)
## AppImage
Note: Still experimental. It may randomly fail. For best results, compile on
Ubuntu with an official Qt5 installation (not using the distro's Qt5 packages).
```
./build-appimage.sh
```
This will produce `mcpelauncher-thesonicmaster-<ver>-<arch>.AppImage`.
Execute the AppImage to run it.
## Debian package
```
./build-deb.sh
```
This will produce `mcpelauncher-thesonicmaster_<ver>~<os-codename>_<arch>.deb`.
Install it with `sudo apt install ./<filename>.deb`.
## AUR package
```
makepkg -sc
```
This will produce `mcpelauncher-thesonicmaster-<ver>-<arch>.pkg.tar.zst`.
Install it with `sudo pacman -U ./<filename>.pkg.tar.zst`.
## Snap package
If this is your first time building a Snap package, you have to setup Snapcraft
first. This only has to be done once, it can be skipped for subsequent builds:
```
sudo snap install --classic snapcraft
sudo snap install multipass
```
Now you can build the Snap package with the following command:
```
snapcraft
```
This will produce `mcpelauncher-thesonicmaster_<ver>_<arch>.snap`.
Install it with `sudo snap install --dangerous <filename>.snap`.
