## TBD -- "Tiny By Design" common configuration

PACKAGE_DIR=${TOPLEV}/packages
OUTPUT_DIR=${TOPLEV}
DOWNLOAD_DIR=${OUTPUT_DIR}/downloads
STAGING_DIR=${OUTPUT_DIR}/staging
TOOLCHAIN_DIR=${CURDIR}/toolchain

HOST_CPU=$(shell uname -m)
#HOST_TRIPLET=$(shell gcc -dumpmachine | sed 's/^\([^-]*\).*-\([^-]*-[^-]*.\)$$/\1-unknown-\2/')
HOST_TRIPLET=$(shell gcc -dumpmachine | sed 's/^\([^-]*\).*-\([^-]*-[^-]*.\)$$/\1-pc-\2/')

#TARGET_CPU=i686
TARGET_CPU=$(shell uname -m)
TARGET_ARCH=$(shell echo ${TARGET_CPU} | sed 's/i[4-6]86/i386/' )
TARGET_LIBC=musl
TARGET_TRIPLET=${TARGET_CPU}-custom-linux-${TARGET_LIBC}


export PATH:=${TOOLCHAIN_DIR}/bin:${PATH}

ALL_COMPONENTS=toolchain rootfs
ALL_PACKAGES=
