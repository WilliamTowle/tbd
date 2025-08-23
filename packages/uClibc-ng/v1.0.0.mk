## TBD -- "Tiny By Design" musl package

## uclibc-ng -- https://uclibc-ng.org/

CROSS_UCLIBC_VERSION=1.0.0
CROSS_UCLIBC_SRC_TARBALL=${DOWNLOAD_DIR}/u/uClibc-ng-${CROSS_UCLIBC_VERSION}.tar.bz2
CROSS_UCLIBC_SRC_CHECKSUM=98ab4861e63454942055873a73e9e50f
CROSS_UCLIBC_SRC_URL=https://downloads.uclibc-ng.org/releases/${CROSS_UCLIBC_VERSION}/$(notdir ${CROSS_UCLIBC_SRC_TARBALL})
CROSS_UCLIBC_SRC_TREE=${STAGING_DIR}/build-uclibc-ng-${CROSS_UCLIBC_VERSION}


.PHONY: prepare-uclibc

prepare-cross-uclibc:
	$(call download_file,$(CROSS_UCLIBC_SRC_TARBALL),$(CROSS_UCLIBC_SRC_URL),$(CROSS_UCLIBC_SRC_CHECKSUM))
	[ -r ${CROSS_UCLIBC_SRC_TREE}/README ] || { \
		printf '[%s] %s\n' $@ 'Extract...' && \
		$(call extract_archive,$(CROSS_UCLIBC_SRC_TREE),$(CROSS_UCLIBC_SRC_TARBALL)) ;\
	}


ifeq (${PACKAGE_DESTINATION_RULES},toolchain)
.PHONY: build-cross-uclibc

build-cross-uclibc: prepare-cross-uclibc
	@printf '%s %s: %s\n' $(lastword ${MAKEFILE_LIST}) $@ "Reached at `date +'%X, %F'`"
	mkdir -p ${CROSS_UCLIBC_SRC_TREE}/$@
	( cd ${CROSS_UCLIBC_SRC_TREE}/$@ && [ -r ./Makefile ] || ln -sf ../* ./ )
	[ -r ${CROSS_UCLIBC_SRC_TREE}/$@/.config ] || { \
		printf '[%s] %s\n' $@ 'Configure...' && \
		cd ${CROSS_UCLIBC_SRC_TREE}/$@ && \
		( \
		 echo 'TARGET_ARCH="'${TARGET_ARCH}'"' ;\
		 echo 'TARGET_'${TARGET_ARCH}'=y' ;\
		 echo 'CROSS_COMPILER_PREFIX="'${TARGET_TRIPLET}'-"' ;\
		 \
		 echo 'KERNEL_HEADERS="'${TOOLCHAIN_DIR}'/usr/include/"' ;\
		 echo 'SHARED_LIB_LOADER_PREFIX="/lib"' ;\
		 echo 'DEVEL_PREFIX="/usr"' ;\
		 echo 'RUNTIME_PREFIX="/"' ;\
		 \
		 echo 'DO_C99_MATH=y' ;\
		 echo 'UCLIBC_SUSV3_LEGACY=y' ;\
		 echo 'UCLIBC_SUSV4_LEGACY=y' \
		) > .config && \
		yes '' | make HOSTCC=/usr/bin/gcc oldconfig ;\
	}
	[ -r ${CROSS_UCLIBC_SRC_TREE}/$@/lib/crtn.o ] || { \
		printf '[%s] %s\n' $@ 'Build...' && \
		cd ${CROSS_UCLIBC_SRC_TREE}/$@ && \
		make ;\
	}


.PHONY: install-cross-uclibc

install-cross-uclibc: build-cross-uclibc
	[ -r ${TOOLCHAIN_DIR}/lib/libuClibc-${CROSS_UCLIBC_VERSION}.so ] || { \
		printf '[%s] %s\n' $@ 'Install...' && \
		cd ${CROSS_UCLIBC_SRC_TREE}/$(patsubst install-%,build-%,$@) && \
		make PREFIX=${TOOLCHAIN_DIR}'/' install_dev ;\
	}
endif
