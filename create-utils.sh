#!/bin/sh

# General build dependencies: gawk grep lz4 zstd curl gcc make autoconf
# 	libtool pkgconf libcap fuse2 (or fuse3) lzo xz zlib findutils musl
#	kernel-headers-musl sed
#
# Dwarfs build dependencies: fuse2 (or fuse3) openssl jemalloc
# 	xxhash boost lz4 xz zstd libarchive libunwind google-glod gtest fmt
#	gflags double-conversion cmake ruby-ronn libevent libdwarf git utf8cpp
#

set -eu

export CC=clang
export CXX=clang++
export CFLAGS="-O3 -flto"
export CXXFLAGS="${CFLAGS}"
export LDFLAGS="-Wl,-O1,--sort-common,--as-needed"

rm -rf ./build-utils || true
mkdir -p ./build-utils/utils
cp ./init.c ./build-utils/init.c
cd ./build-utils

# Download patched bubblewrap (allows launching appimages inside conty)
wget "https://bin.ajam.dev/x86_64_Linux/bwrap-patched" -O ./utils/bwrap

# get the rest of utils
wget "https://bin.ajam.dev/x86_64_Linux/bash" -O ./utils/bash
wget "https://bin.ajam.dev/x86_64_Linux/Baseutils/busybox/busybox" -O ./utils/busybox
wget "https://bin.ajam.dev/x86_64_Linux/Baseutils/unionfs-fuse/unionfs" -O ./utils/unionfs
wget "https://bin.ajam.dev/x86_64_Linux/Baseutils/unionfs-fuse3/unionfs" -O ./utils/unionfs3
wget "https://bin.ajam.dev/x86_64_Linux/dwarfs-tools" -O ./utils/dwarfs-tools
ln -s dwarfs-tools ./utils/dwarfs
ln -s dwarfs-tools ./utils/mkdwarfs
ln -s dwarfs-tools ./utils/dwarfsextract
chmod +x ./utils/*

if [ ! -f utils/ld-linux-x86-64.so.2 ]; then
	cp -L /lib64/ld-linux-x86-64.so.2 utils
fi

find utils -type f -exec strip --strip-unneeded {} \; 2>/dev/null

init_program_size=50000
conty_script_size="$(($(stat -c%s ../conty-start.sh)+2000))"
bash_size="$(stat -c%s ./utils/bash)"

sed -i "s/#define SCRIPT_SIZE 0/#define SCRIPT_SIZE ${conty_script_size}/g" init.c
sed -i "s/#define BASH_SIZE 0/#define BASH_SIZE ${bash_size}/g" init.c
sed -i "s/#define PROGRAM_SIZE 0/#define PROGRAM_SIZE ${init_program_size}/g" init.c

musl-gcc -o init -static init.c
strip --strip-unneeded init

padding_size="$((init_program_size-$(stat -c%s init)))"
if [ "${padding_size}" -gt 0 ]; then
	dd if=/dev/zero of=padding bs=1 count="${padding_size}" >/dev/null 2>&1
	cat init padding > init_new
	rm -f init padding
	mv init_new init
fi

mv ./init ./utils
tar -zvcf utils_dwarfs.tar.gz utils
mv utils_dwarfs.tar.gz "../"
cd "../"
rm -rf ./build-utils
echo "All Done!"