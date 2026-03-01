## TBD -- "Tiny By Design" cross-gcc package

## gcc -- www.gnu.org


ifeq ($(filter cross-gcc,${ALL_PACKAGES}),)
CROSS_GCC_VERSION=4.3.6
CROSS_GCC_SRC_TARBALL=${DOWNLOAD_DIR}/g/gcc-${CROSS_GCC_VERSION}.tar.bz2
CROSS_GCC_SRC_CHECKSUM=55ddf934bc9f8d1eaff7a77e7d598a85
CROSS_GCC_SRC_URL=https://ftp.gnu.org/gnu/gcc/gcc-${CROSS_GCC_VERSION}/$(notdir ${CROSS_GCC_SRC_TARBALL})
CROSS_GCC_SRC_TREE=${STAGING_DIR}/build-gcc-${CROSS_GCC_VERSION}


#ifneq ($(filter 4.3.%,${CROSS_GCC_VERSION}),)
# [gcc 4.3.x] "Building GCC requires GMP 4.1+ and MPFR 2.3.0+."
CROSS_GCC_GMP_VERSION=4.3.2
CROSS_GCC_GMP_SRC_TARBALL=${DOWNLOAD_DIR}/g/gmp-${CROSS_GCC_GMP_VERSION}.tar.gz
CROSS_GCC_GMP_SRC_CHECKSUM=2a431d487dfd76d0f618d241b1e551cc
CROSS_GCC_GMP_SRC_URL=https://ftp.gnu.org/gnu/gmp/$(notdir ${CROSS_GCC_GMP_SRC_TARBALL})

CROSS_GCC_MPFR_VERSION=2.4.2
CROSS_GCC_MPFR_SRC_TARBALL=${DOWNLOAD_DIR}/m/mpfr-${CROSS_GCC_MPFR_VERSION}.tar.bz2
CROSS_GCC_MPFR_SRC_CHECKSUM=89e59fe665e2b3ad44a6789f40b059a0
CROSS_GCC_MPFR_SRC_URL=https://ftp.gnu.org/gnu/mpfr/$(notdir ${CROSS_GCC_MPFR_SRC_TARBALL})
#endif	# 4.3.x dependencies


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


.PHONY: build-toolchain-cross-kgcc

build-toolchain-cross-kgcc: prepare-cross-gcc
	mkdir -p ${CROSS_GCC_SRC_TREE}/$@
	[ -r ${CROSS_GCC_SRC_TREE}/$@/config.log ] || { \
		printf '[%s] %s\n' $@ 'Configure...' && \
		cd ${CROSS_GCC_SRC_TREE}/$@ && \
		../configure \
			--prefix=${TOOLCHAIN_DIR} \
			--program-transform-name='s%^%'${TARGET_TRIPLET}'-k%' \
			--build=${HOST_TRIPLET} --host=${HOST_TRIPLET} \
			--target=${TARGET_TRIPLET} \
			--with-sysroot=${TOOLCHAIN_DIR} \
			--without-headers --with-newlib \
			--disable-multilib \
			--disable-shared \
			--disable-threads \
			--disable-decimal-float --disable-libgomp \
			--disable-libmudflap \
			--disable-libquadmath \
			--disable-libssp \
			--enable-languages=c --disable-__cxa_atexit \
			--disable-nls --disable-werror ;\
		}
	[ -r ${CROSS_GCC_SRC_TREE}/$@/gcc/include-fixed/README ] || { \
		printf '[%s] %s\n' $@ 'Build...' && \
		cd ${CROSS_GCC_SRC_TREE}/$@ && \
		make all-gcc ;\
		}

.PHONY: install-toolchain-cross-kgcc

install-toolchain-cross-kgcc: build-toolchain-cross-kgcc
	[ -r ${TOOLCHAIN_DIR}/bin/${TARGET_TRIPLET}-kgcc ] || { \
		printf '[%s] %s\n' $@ 'Install...' && \
		cd ${CROSS_GCC_SRC_TREE}/$(patsubst install-%,build-%,$@) && \
		make install-gcc ;\
		}


.PHONY: build-cross-libgcc

build-cross-libgcc: prepare-cross-gcc
	@printf '%s %s: %s\n' $(lastword ${MAKEFILE_LIST}) $@ "Reached at `date +'%X, %F'`"
	mkdir -p ${CROSS_GCC_SRC_TREE}/$@
	[ -r ${CROSS_GCC_SRC_TREE}/$@/config.log ] || { \
		printf '[%s] %s\n' $@ 'Configure...' && \
		cd ${CROSS_GCC_SRC_TREE}/$@ && \
		  ../configure -v \
			--prefix=${TOOLCHAIN_DIR} \
			--program-transform-name='s%^%'${TARGET_TRIPLET}'-k%' \
			--build=${HOST_TRIPLET} --host=${HOST_TRIPLET} \
			--target=${TARGET_TRIPLET} \
			--with-sysroot=${TOOLCHAIN_DIR} \
			--without-headers --with-newlib \
			--disable-multilib \
			--disable-shared \
			--disable-threads \
			--disable-decimal-float \
			--disable-libgomp \
			--disable-libmudflap \
			--disable-libquadmath \
			--disable-libssp \
			--enable-languages=c --disable-__cxa_atexit \
			--disable-nls --disable-werror ;\
		}
	[ -r ${CROSS_GCC_SRC_TREE}/$@/gcc/libgcc.a ] || { \
		printf '[%s] %s\n' $@ 'Build...' && \
		cd ${CROSS_GCC_SRC_TREE}/$@ && \
		make $(shell echo 'enable_shared=no' >/dev/null) all-target-libgcc ;\
		}


.PHONY: install-cross-libgcc

install-cross-libgcc: build-cross-libgcc
	[ -r ${TOOLCHAIN_DIR}/lib/gcc/${TARGET_TRIPLET}/${CROSS_GCC_VERSION}/libgcc.a ] || { \
		printf '[%s] %s\n' $@ 'Install...' && \
		cd ${CROSS_GCC_SRC_TREE}/$(patsubst install-%,build-%,$@) && \
		make install-target-libgcc ;\
		}


.PHONY: build-cross-gcc

build-cross-gcc: prepare-cross-gcc
	@printf '%s %s: %s\n' $(lastword ${MAKEFILE_LIST}) $@ "Reached at `date +'%X, %F'`"
	mkdir -p ${CROSS_GCC_SRC_TREE}/$@
	[ -r ${CROSS_GCC_SRC_TREE}/$@/config.log ] || { \
		printf '[%s] %s\n' $@ 'Configure...' && \
		cd ${CROSS_GCC_SRC_TREE}/$@ && \
		  ../configure -v \
			--prefix=${TOOLCHAIN_DIR} \
			--program-transform-name='s%^%'${TARGET_TRIPLET}'%' \
			--build=${HOST_TRIPLET} --host=${HOST_TRIPLET} \
			--target=${TARGET_TRIPLET} \
			--with-sysroot=${TOOLCHAIN_DIR} \
			$(shell echo "--with-headers=${TOOLCHAIN_DIR}/usr/include" >/dev/null) \
			--disable-multilib \
			--disable-shared \
			--disable-threads \
			--disable-decimal-float \
			--disable-libgomp \
			--disable-libmudflap \
			--disable-libquadmath \
			--disable-libssp \
			--enable-languages=c --enable-clocale=uclibc --disable-__cxa_atexit \
			--disable-nls --disable-werror ;\
		}
	[ -r ${CROSS_GCC_SRC_TREE}/$@/gcc/include-fixed/README ] || { \
		printf '[%s] %s\n' $@ 'Build...' && \
		cd ${CROSS_GCC_SRC_TREE}/$@ && \
		make all ;\
		}


.PHONY: install-cross-gcc

install-cross-gcc: build-cross-gcc
	[ -r ${TOOLCHAIN_DIR}/bin/${TARGET_TRIPLET}-gcc ] || { \
		printf '[%s] %s\n' $@ 'Install...' && \
		cd ${CROSS_GCC_SRC_TREE}/$(patsubst install-%,build-%,$@) && \
		make install && \
		cd ${TOOLCHAIN_DIR}/bin && \
		ln -sf ${TARGET_TRIPLET}-gcc-${CROSS_GCC_VERSION} ${TARGET_TRIPLET}-gcc ;\
		}
ALL_PACKAGES+=cross-gcc
endif
