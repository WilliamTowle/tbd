## TBD -- "Tiny By Design" cross-gcc package

## gcc -- www.gnu.org

# gcc 4.1.2-4.2.4 is c.2007/8
# gcc 4.3.0-4.3.6 is c.2008-2011


# [2025-05-26] v4.2.x "build/genmodes: not found"

ifeq ($(filter cross-gcc,${ALL_PACKAGES}),)
CROSS_GCC_VERSION=4.7.3
CROSS_GCC_SRC_TARBALL=${DOWNLOAD_DIR}/g/gcc-${CROSS_GCC_VERSION}.tar.bz2
CROSS_GCC_SRC_CHECKSUM=86f428a30379bdee0224e353ee2f999e
CROSS_GCC_SRC_URL=https://ftp.gnu.org/gnu/gcc/gcc-${CROSS_GCC_VERSION}/$(notdir ${CROSS_GCC_SRC_TARBALL})
CROSS_GCC_SRC_TREE=${STAGING_DIR}/cross-gcc-${CROSS_GCC_VERSION}


ifneq ($(filter 4.7.%,${CROSS_GCC_VERSION}),)
# Patches and dependencies for gcc 4.7.x - gmp, mpc, mpfr
CROSS_GCC_PATCH1_FILE=${DOWNLOAD_DIR}/g/gcc-4.7.3-musl-1.patch
CROSS_GCC_PATCH1_URL=https://raw.githubusercontent.com/cross-lfs/clfs-embedded/c01e552d1d5318861a6b39259167dceb7e189928/patches/$(notdir ${CROSS_GCC_PATCH1_FILE})
CROSS_GCC_PATCH1_CHECKSUM=5b43765740ca9865b8afe3cc945a3f5d

CROSS_GCC_GMP_VERSION=4.3.2
CROSS_GCC_GMP_SRC_TARBALL=${DOWNLOAD_DIR}/g/gmp-${CROSS_GCC_GMP_VERSION}.tar.gz
CROSS_GCC_GMP_SRC_CHECKSUM=2a431d487dfd76d0f618d241b1e551cc
CROSS_GCC_GMP_SRC_URL=https://ftp.gnu.org/gnu/gmp/$(notdir ${CROSS_GCC_GMP_SRC_TARBALL})

CROSS_GCC_MPC_VERSION=1.0.1
CROSS_GCC_MPC_SRC_TARBALL=${DOWNLOAD_DIR}/m/mpc-${CROSS_GCC_MPC_VERSION}.tar.gz
CROSS_GCC_MPC_SRC_CHECKSUM=b32a2e1a3daa392372fbd586d1ed3679
CROSS_GCC_MPC_SRC_URL=https://ftp.gnu.org/gnu/mpc/$(notdir ${CROSS_GCC_MPC_SRC_TARBALL})

CROSS_GCC_MPFR_VERSION=2.4.2
CROSS_GCC_MPFR_SRC_TARBALL=${DOWNLOAD_DIR}/m/mpfr-${CROSS_GCC_MPFR_VERSION}.tar.bz2
CROSS_GCC_MPFR_SRC_CHECKSUM=89e59fe665e2b3ad44a6789f40b059a0
CROSS_GCC_MPFR_SRC_URL=https://ftp.gnu.org/gnu/mpfr/$(notdir ${CROSS_GCC_MPFR_SRC_TARBALL})
endif	## gcc 4.7.x configuration


.PHONY: prepare-cross-gcc

prepare-cross-gcc: | ${DOWNLOAD_DIR} ${STAGING_DIR}
	$(call download_file,$(CROSS_GCC_SRC_TARBALL),$(CROSS_GCC_SRC_URL),$(CROSS_GCC_SRC_CHECKSUM))
ifneq (${CROSS_GCC_PATCH1_FILE},)
	$(call download_file,$(CROSS_GCC_PATCH1_FILE),$(CROSS_GCC_PATCH1_URL),$(CROSS_GCC_PATCH1_CHECKSUM))
endif
ifneq (${CROSS_GCC_GMP_VERSION},)
	$(call download_file,$(CROSS_GCC_GMP_SRC_TARBALL),$(CROSS_GCC_GMP_SRC_URL),$(CROSS_GCC_GMP_SRC_CHECKSUM))
endif
ifneq (${CROSS_GCC_MPC_VERSION},)
	$(call download_file,$(CROSS_GCC_MPC_SRC_TARBALL),$(CROSS_GCC_MPC_SRC_URL),$(CROSS_GCC_MPC_SRC_CHECKSUM))
endif
ifneq (${CROSS_GCC_MPFR_VERSION},)
	$(call download_file,$(CROSS_GCC_MPFR_SRC_TARBALL),$(CROSS_GCC_MPFR_SRC_URL),$(CROSS_GCC_MPFR_SRC_CHECKSUM))
endif
	[ -r ${CROSS_GCC_SRC_TREE}/README ] || { \
		printf '[%s] %s\n' $@ 'Extract/patch...' && \
		$(call extract_archive,$(CROSS_GCC_SRC_TREE),$(CROSS_GCC_SRC_TARBALL)) && \
		cd ${CROSS_GCC_SRC_TREE} && \
		( [ -z "${CROSS_GCC_PATCH1_FILE}" ] || patch -Np1 -i ${CROSS_GCC_PATCH1_FILE} ) && \
		case ${CROSS_GCC_VERSION} in \
		4.2.*|4.3.*|4.4.*) \
			cd ${CROSS_GCC_SRC_TREE} ;\
			[ -r gcc/toplev.h.OLD ] || mv gcc/toplev.h gcc/toplev.h.OLD ;\
			cat gcc/toplev.h.OLD \
				| sed '/VERSION >= 3004/,/VERSION >= 3004/ { /^extern inline int/ s/^/#if 0\n/ ; /^}/ s/$$/\n#endif/ }' \
				> gcc/toplev.h \
		;; \
		esac ;\
		}
ifneq (${CROSS_GCC_GMP_VERSION},)
	[ -r ${CROSS_GCC_SRC_TREE}/gmp/README ] || { \
		$(call extract_archive,$(CROSS_GCC_SRC_TREE)/gmp,$(CROSS_GCC_GMP_SRC_TARBALL)) ;\
		}
	case ${CROSS_GCC_GMP_VERSION} in \
	4.3.2) \
		cd ${CROSS_GCC_SRC_TREE}/gmp &&\
		[ -r acinclude.m4.OLD ] || mv acinclude.m4 acinclude.m4.OLD ;\
		cat acinclude.m4.OLD \
			| sed '/GMP_PROG_CC_FOR_BUILD$$/,/^EOF$$/ { /<<EOF$$/ s/$$/\n\#include <stdlib.h>/ }' \
			| sed '/GMP_PROG_EXEEXT_FOR_BUILD$$/,/^EOF$$/ { /<<EOF$$/ s/$$/\n\#include <stdlib.h>/ }' \
			| sed '/GMP_C_FOR_BUILD_ANSI$$/,/^EOF$$/ { /<<EOF$$/ s/$$/\n\#include <stdlib.h>/ }' \
			| sed '/GMP_CHECK_LIBM_FOR_BUILD$$/,/^EOF$$/ { /<<EOF$$/ s/$$/\n\#include <stdlib.h>\n\#include <math.h>/ }' \
			> acinclude.m4 && \
		autoconf \
	;; \
	esac
endif
ifneq (${CROSS_GCC_MPC_VERSION},)
	[ -r ${CROSS_GCC_SRC_TREE}/mpc/README ] || { \
		$(call extract_archive,$(CROSS_GCC_SRC_TREE)/mpc,$(CROSS_GCC_MPC_SRC_TARBALL)) ;\
		}
endif
ifneq (${CROSS_GCC_MPFR_VERSION},)
	[ -r ${CROSS_GCC_SRC_TREE}/mpfr/README ] || { \
		$(call extract_archive,$(CROSS_GCC_SRC_TREE)/mpfr,$(CROSS_GCC_MPFR_SRC_TARBALL)) ;\
		}
endif


.PHONY: build-toolchain-cross-gcc

build-toolchain-cross-gcc: prepare-cross-gcc
	mkdir -p ${CROSS_GCC_SRC_TREE}/$@
	[ -r ${CROSS_GCC_SRC_TREE}/$@/config.log ] || { \
		printf '[%s] %s\n' $@ 'Configure...' && \
		cd ${CROSS_GCC_SRC_TREE}/$@ && \
		CFLAGS='-fpermissive' \
		../configure \
			--prefix=${TOOLCHAIN_DIR} \
			--build=${HOST_TRIPLET} --host=${HOST_TRIPLET} \
			--target=${TARGET_TRIPLET} \
			--with-sysroot=${TOOLCHAIN_DIR} \
			--without-headers --with-newlib \
			--disable-shared \
			--disable-decimal-float --disable-libgomp \
			--disable-libmudflap \
			--disable-libquadmath \
			--disable-libssp --disable-threads \
			--enable-languages=c --enable-clocale=musl --disable-__cxa_atexit \
			--disable-multilib \
			--disable-nls ;\
		}
	[ -r ${CROSS_GCC_SRC_TREE}/$@/gcc/include-fixed/README ] || { \
		printf '[%s] %s\n' $@ 'Build...' && \
		cd ${CROSS_GCC_SRC_TREE}/$@ && \
		make all ;\
		}

.PHONY: install-toolchain-cross-gcc

install-toolchain-cross-gcc: build-toolchain-cross-gcc
	[ -r ${TOOLCHAIN_DIR}/bin/${TARGET_TRIPLET}-gcc ] || { \
		printf '[%s] %s\n' $@ 'Install...' && \
		cd ${CROSS_GCC_SRC_TREE}/$(patsubst install-%,build-%,$@) && \
		make install && \
		cd ${TOOLCHAIN_DIR}/bin && \
		ln -sf ${TARGET_TRIPLET}-gcc-${CROSS_GCC_VERSION} ${TARGET_TRIPLET}-gcc ;\
		}
ALL_PACKAGES+=cross-gcc
endif
