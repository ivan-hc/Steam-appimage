#!/usr/bin/env bash
set -e

# An example of steam packaging in a RunImage container

if [ ! -x 'runimage' ]; then
	echo '== download base RunImage'
	curl -o runimage -L "https://github.com/VHSgunzo/runimage/releases/download/continuous/runimage-$(uname -m)"
	chmod +x runimage
fi

run_install() {
	set -e

	INSTALL_PKGS=(
		steam egl-wayland vulkan-radeon lib32-vulkan-radeon vulkan-tools
		vulkan-intel lib32-vulkan-intel vulkan-nouveau lib32-vulkan-nouveau
		lib32-libpipewire libpipewire pipewire
		lib32-libpipewire libpulse lib32-libpulse vkd3d lib32-vkd3d wget
		vulkan-mesa-layers lib32-vulkan-mesa-layers freetype2 lib32-freetype2 fuse2
		yad mangohud lib32-mangohud gamescope gamemode zenity-gtk3 steam-screensaver-fix
	)

	echo '== checking for updates'
	rim-update

	echo '== install packages'
	pac --needed --noconfirm -S "${INSTALL_PKGS[@]}"

	echo '== install glibc with patches for Easy Anti-Cheat (optionally)'
	yes|pac -S glibc-eac lib32-glibc-eac

	echo '== install debloated packages for space saving (optionally)'
	LLVM="https://github.com/pkgforge-dev/llvm-libs-debloated/releases/download/continuous/llvm-libs-mini-x86_64.pkg.tar.zst"
	OPUS="https://github.com/pkgforge-dev/llvm-libs-debloated/releases/download/continuous/opus-nano-x86_64.pkg.tar.zst"
	wget --retry-connrefused --tries=30 "$LLVM" -O ./llvm-libs.pkg.tar.zst
	wget --retry-connrefused --tries=30 "$OPUS" -O ./opus-nano.pkg.tar.zst
	pac -U --noconfirm ./*.pkg.tar.zst
	rm -f ./*.pkg.tar.zst

	echo '== shrink (optionally)'
	pac -Rsndd --noconfirm wget gocryptfs jq \
		gnupg webkit2gtk-4.1 perl vulkan-tools
	rim-shrink --all
	pac -Rsndd --noconfirm binutils svt-av1


	pac -Qi | awk -F': ' '/Name/ {name=$2}
	/Installed Size/ {size=$2}
	name && size {print name, size; name=size=""}' \
		| column -t | grep MiB | sort -nk 2

	VERSION=$(pacman -Q steam | awk 'NR==1 {print $2; exit}')
	echo "$VERSION" > ~/version
	cp /usr/share/icons/hicolor/256x256/apps/steam.png ~/
	cp /usr/share/applications/steam.desktop ~/

	# Use host xdg-open
	ln -sf /var/host/bin/xdg-open /usr/bin/xdg-open

	# allow steam to run as root
	sed -i 's|"$(id -u)" == "0"|"$(id -u)" == "69"|' /usr/lib/steam/bin_steam.sh

	echo '== create RunImage config for app (optionally)'
	cat <<- 'EOF' > "$RUNDIR/config/Run.rcfg"
	RIM_CMPRS_LVL="${RIM_CMPRS_LVL:=22}"
	RIM_CMPRS_BSIZE="${RIM_CMPRS_BSIZE:=25}"
	RIM_HOST_XDG_OPEN="${RIM_HOST_XDG_OPEN:=1}"
	RIM_SYS_NVLIBS="${RIM_SYS_NVLIBS:=1}"
	RIM_NVIDIA_DRIVERS_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/runimage_nvidia"
	RIM_SHARE_ICONS="${RIM_SHARE_ICONS:=1}"
	RIM_SHARE_FONTS="${RIM_SHARE_FONTS:=1}"
	RIM_SHARE_THEMES="${RIM_SHARE_THEMES:=1}"
	RIM_AUTORUN=steam-screensaver-fix-runtime
	EOF

	echo '== Build new DwarFS runimage with zstd 22 lvl and 24 block size'
	rim-build -s steam.RunImage
}
export -f run_install

##########################

# enable OverlayFS mode, disable Nvidia driver check and run install steps
RIM_OVERFS_MODE=1 RIM_NO_NVIDIA_CHECK=1 ./runimage bash -c run_install
./steam.RunImage --runtime-extract
rm -f ./steam.RunImage

mv ./RunDir ./AppDir
mv ./AppDir/Run ./AppDir/AppRun

mv ~/steam.desktop ./AppDir
mv ~/steam.png     ./AppDir
sed -i '30i\StartupWMClass=steam' ./AppDir/steam.desktop

# steam-runtime is gone and now the script is called steam
# make a wrapper symlink since steam-screensaver-fix hasn't updated to that
ln -s ./steam ./AppDir/rootfs/usr/bin/steam-runtime || true
ln -s ./steam ./AppDir/rootfs/usr/bin/steam-native || true

# debloat
rm -rfv ./AppDir/sharun/bin/chisel \
	./AppDir/rootfs/usr/lib*/libgo.so* \
	./AppDir/rootfs/usr/lib*/libgphobos.so* \
	./AppDir/rootfs/usr/lib*/libgfortran.so* \
	./AppDir/rootfs/usr/bin/rsvg-convert \
	./AppDir/rootfs/usr/bin/rav1e \
	./AppDir/rootfs/usr/bin/rsvg-convert \
	./AppDir/rootfs/usr/*/*pacman* \
	./AppDir/rootfs/usr/share/gir-1.0 \
	./AppDir/rootfs/var/lib/pacman \
	./AppDir/rootfs/etc/pacman* \
	./AppDir/rootfs/usr/share/licenses \
	./AppDir/rootfs/usr/share/terminfo \
	./AppDir/rootfs/usr/share/icons/AdwaitaLegacy \
	./AppDir/rootfs/usr/lib/udev/hwdb.bin

VERSION="$(cat ~/version)"
export ARCH="$(uname -m)"
UPINFO="gh-releases-zsync|$(echo "$GITHUB_REPOSITORY" | tr '/' '|')|latest|*squashfs-$ARCH.AppImage.zsync"

# make appimage with type2-runtime
# remove this if libappimage ever adopts support for dwarfs
APPIMAGETOOL="https://github.com/AppImage/appimagetool/releases/download/continuous/appimagetool-x86_64.AppImage"
wget --retry-connrefused --tries=30 "$APPIMAGETOOL" -O ./appimagetool
chmod +x ./appimagetool
./appimagetool --comp zstd \
	--mksquashfs-opt -Xcompression-level --mksquashfs-opt 22 \
	--mksquashfs-opt -b --mksquashfs-opt 1M \
	-n -u "$UPINFO" "$PWD"/AppDir "$PWD"/Steam-"$VERSION"-anylinux.squashfs-"$ARCH".AppImage

# make appimage with uruntime
UPINFO="gh-releases-zsync|$(echo "$GITHUB_REPOSITORY" | tr '/' '|')|latest|*dwarfs-$ARCH.AppImage.zsync"
URUNTIME="https://github.com/VHSgunzo/uruntime/releases/latest/download/uruntime-appimage-dwarfs-$ARCH"

wget --retry-connrefused --tries=30 "$URUNTIME" -O ./uruntime
chmod +x ./uruntime

# Add udpate info to runtime
echo "Adding update information \"$UPINFO\" to runtime..."
./uruntime --appimage-addupdinfo "$UPINFO"

echo "Generating AppImage..."
./uruntime --appimage-mkdwarfs -f \
	--set-owner 0 --set-group 0 \
	--no-history --no-create-timestamp \
	--compression zstd:level=22 -S26 -B8 \
	--header uruntime \
	-i ./AppDir -o Steam-"$VERSION"-anylinux.dwarfs-"$ARCH".AppImage

zsyncmake *dwarfs*.AppImage -u *dwarfs*.AppImage
echo "All Done!"
