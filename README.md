# mcpelauncher-build-scripts
Build scripts for mcpelauncher-thesonicmaster, The Sonic Master's fork of the
Minecraft Bedrock Linux Launcher that fixes the license error. For more
information about this project, visit https://mcpelauncher.thesonicmaster.net.
# Retrieving the scripts
```
git clone https://github.com/TheSonicMaster/mcpelauncher-build-scripts.git
cd mcpelauncher-build-scripts
```
# Dependencies for building
**Note: Not required if building the Snap package.**
## On Debian/Ubuntu
```
./install-deps-debian.sh
```
### Fix for Ubuntu 18.04
Ubuntu 18.04 has some outdated software, so the above script won't satisfy all
the dependencies. To satisfy the rest, run the following commands:

**NOTE: DO NOT RUN THESE COMMANDS ON VERSIONS NEWER THAN 18.04. IT MAY BREAK
YOUR SYSTEM**

1. Newer version of Clang:
```
sudo apt remove --autoremove clang
sudo apt install clang-10
sudo ln -sf clang-10 /usr/bin/clang
sudo ln -sf clang++-10 /usr/bin/clang++
```
2. Newer version of CMake:
```
sudo apt remove --autoremove cmake
curl -LOs https://github.com/Kitware/CMake/releases/download/v3.20.5/cmake-3.20.5-linux-x86_64.tar.gz
sudo tar --no-same-owner -xf cmake-3.20.5-linux-x86_64.tar.gz -C /usr/local --strip-components=1
rm cmake-3.20.5-linux-x86_64.tar.gz
```
3. Extra Qt package required:
```
sudo apt install qt5-default
```
## Other distros
You need the following software:

- Standard build tools
- [alsa-lib (libasound2)](https://www.alsa-project.org)
- [Clang](https://clang.llvm.org/) (>= 7.0.0) (or GCC but **ONLY** if GCC has been built **WITHOUT** `--enable-default-pie`)
- [CMake](https://cmake.org/) (>= 3.11)
- [libcurl](https://curl.se/libcurl/)
- [libegl (libglvnd)](https://github.com/NVIDIA/libglvnd)
- [libevdev](https://www.freedesktop.org/software/libevdev/doc/latest/)
- [libpng](http://www.libpng.org/pub/png/libpng.html)
- [libuv](https://libuv.org/)
- [libzip](https://libzip.org/)
- [Ninja](https://ninja-build.org/)
- [OpenSSL](https://www.openssl.org/) (>= 1.1)
- [Protobuf](https://developers.google.com/protocol-buffers/)
- [PulseAudio](https://www.freedesktop.org/wiki/Software/PulseAudio/)
- [Qt5 development libraries](https://www.qt.io/) (>= 5.9)
- [Xorg development libraries](https://xorg.freedesktop.org/)
- [zlib](https://zlib.net/)

# Building packages
## AppImage
Note: AppImage developers recommend building on the oldest Ubuntu version which
is still supported. At the time of writing, this is Ubuntu 18.04 LTS.
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
