## TBD -- "Tiny By Design" cross-binutils package

## binutils -- www.gnu.org

ifeq ($(filter cross-binutils,${ALL_PACKAGES}),)
CROSS_BINUTILS_VERSION=2.21.1
CROSS_BINUTILS_SRC_TARBALL=${DOWNLOAD_DIR}/b/binutils-${CROSS_BINUTILS_VERSION}.tar.bz2
CROSS_BINUTILS_SRC_CHECKSUM=bde820eac53fa3a8d8696667418557ad
CROSS_BINUTILS_SRC_URL=https://ftp.gnu.org/gnu/binutils/$(notdir ${CROSS_BINUTILS_SRC_TARBALL})

CROSS_BINUTILS_SRC_TREE=${STAGING_DIR}/build-binutils-${CROSS_BINUTILS_VERSION}


.PHONY: prepare-cross-binutils

prepare-cross-binutils: | ${DOWNLOAD_DIR} ${STAGING_DIR}
	$(call download_file,$(CROSS_BINUTILS_SRC_TARBALL),$(CROSS_BINUTILS_SRC_URL),$(CROSS_BINUTILS_SRC_CHECKSUM))
ifneq (${CROSS_BINUTILS_PATCH1_FILE},)
	$(call download_file,$(CROSS_BINUTILS_PATCH1_FILE),$(CROSS_BINUTILS_PATCH1_URL),$(CROSS_BINUTILS_PATCH1_CHECKSUM))
endif
	[ -r ${CROSS_BINUTILS_SRC_TREE}/README ] || { \
		printf '[%s] %s\n' $@ 'Extract/patch...' && \
		$(call extract_archive,$(CROSS_BINUTILS_SRC_TREE),$(CROSS_BINUTILS_SRC_TARBALL)) && \
		cd ${CROSS_BINUTILS_SRC_TREE} && \
		for DIR in bfd gas ; do cd $${DIR} && sed -i 's/rc=\$$\$$?;/[ $$$$? -eq 127 ] \&\& rc=0 || rc=$$$$?;/' Makefile.in && cd - ; done && \
		( [ -z "${CROSS_BINUTILS_PATCH1_FILE}" ] || patch -Np1 -i ${CROSS_BINUTILS_PATCH1_FILE} ) ;\
		}


.PHONY: build-toolchain-cross-binutils

build-toolchain-cross-binutils: prepare-cross-binutils
	mkdir -p ${CROSS_BINUTILS_SRC_TREE}/$@
	[ -r ${CROSS_BINUTILS_SRC_TREE}/$@/config.status ] || { \
		printf '[%s] %s\n' $@ 'Configure...' && \
		cd ${CROSS_BINUTILS_SRC_TREE}/$@ && \
		../configure -v \
			--prefix=${TOOLCHAIN_DIR} \
			--build=${HOST_TRIPLET} --host=${HOST_TRIPLET} \
			--target=${TARGET_TRIPLET} \
			--with-sysroot=${TOOLCHAIN_DIR} \
			--disable-multilib --enable-shared \
			--disable-nls --disable-werror ;\
		}
	[ -r ${CROSS_BINUTILS_SRC_TREE}/$@/ld/ld-new ] || { \
		printf '[%s] %s\n' $@ 'Build...' && \
		cd ${CROSS_BINUTILS_SRC_TREE}/$@ && \
		make $(shell [ "`which makeinfo`" ] || echo 'MAKEINFO=/bin/true' ) ;\
		}


.PHONY: install-toolchain-cross-binutils

install-toolchain-cross-binutils: build-toolchain-cross-binutils
#ifeq ($(filter-out 4.2%,${CROSS_GCC_VERSION}),)	# specific point releases
	[ -r ${TOOLCHAIN_DIR}/bin/${TARGET_TRIPLET}-ld ] || { \
		printf '[%s] %s\n' $@ 'Install...' && \
		( cd ${CROSS_BINUTILS_SRC_TREE}/$(patsubst install-%,build-%,$@) && make install $(shell [ "`which makeinfo`" ] || echo 'MAKEINFO=/bin/true') ) ;\
		( cd ${TOOLCHAIN_DIR}/bin ;\
			for F in ar as ld nm objcopy objdump ranlib strip ; do \
				 [ -r ${TARGET_TRIPLET}-k$${F} ] || ln -sf ${TARGET_TRIPLET}-$${F} ${TARGET_TRIPLET}-k$${F} || { printf '%s: %s\n' $(firstword ${MAKEFILE_LIST}) "symlink failed for F=$${F}" ; false ;} ;\
			 done ;\
		) ;\
		}
#else
#	[ -r ${TOOLCHAIN_DIR}/bin/${TARGET_TRIPLET}-kld ] || { \
#		printf '[%s] %s\n' $@ 'Install...' && \
#		( cd ${CROSS_BINUTILS_SRC_TREE}/$(patsubst install-%,build-%,$@) && make install $(shell [ "`which makeinfo`" ] || echo 'MAKEINFO=/bin/true') ) ;\
#		}
#endif
ALL_PACKAGES+=cross-binutils
endif
