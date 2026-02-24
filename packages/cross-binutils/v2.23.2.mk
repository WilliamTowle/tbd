## TBD -- "Tiny By Design" cross-binutils package

## binutils -- www.gnu.org

# binutils 2.14 is c.2003 (2.14a and later from 2011); build fails
# binutils 2.15-2.22 is c.2011
# binutils 2.20.1 build fails

CROSS_BINUTILS_VERSION=2.23.2
CROSS_BINUTILS_SRC_TARBALL=${DOWNLOAD_DIR}/b/binutils-${CROSS_BINUTILS_VERSION}.tar.bz2
CROSS_BINUTILS_SRC_CHECKSUM=4f8fa651e35ef262edc01d60fb45702e
CROSS_BINUTILS_SRC_URL=https://ftp.gnu.org/gnu/binutils/$(notdir ${CROSS_BINUTILS_SRC_TARBALL})

CROSS_BINUTILS_SRC_TREE=${STAGING_DIR}/cross-binutils-${CROSS_BINUTILS_VERSION}

ifeq (${CROSS_BINUTILS_VERSION},2.23.2)
CROSS_BINUTILS_PATCH1_FILE=${DOWNLOAD_DIR}/b/binutils-2.23.2-musl-1.patch
CROSS_BINUTILS_PATCH1_URL=https://raw.githubusercontent.com/cross-lfs/clfs-embedded/c01e552d1d5318861a6b39259167dceb7e189928/patches/$(notdir ${CROSS_BINUTILS_PATCH1_FILE})
CROSS_BINUTILS_PATCH1_CHECKSUM=dde64feb7f4cf821cbd887b53026fd67
endif


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


ifeq (${PACKAGE_DESTINATION_RULES},toolchain)
.PHONY: build-toolchain-cross-binutils

build-toolchain-cross-binutils: prepare-cross-binutils
	mkdir -p ${CROSS_BINUTILS_SRC_TREE}/$@
	[ -r ${CROSS_BINUTILS_SRC_TREE}/$@/config.status ] || { \
		printf '[%s] %s\n' $@ 'Configure...' && \
		cd ${CROSS_BINUTILS_SRC_TREE}/$@ && \
		../configure \
			--prefix=${TOOLCHAIN_DIR} \
			--build=${HOST_TRIPLET} --host=${HOST_TRIPLET} \
			--target=${TARGET_TRIPLET} \
			--with-sysroot=${TOOLCHAIN_DIR} \
			--disable-multilib --enable-shared \
			--disable-nls \
			--disable-werror ;\
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
endif
