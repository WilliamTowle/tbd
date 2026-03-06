## TBD -- "Tiny By Design" uClibc-ng package

## uclibc (versions to 0.9.33.2) -- https://uclibc.org/
## uclibc-ng (versions from 1.0.0) -- https://uclibc-ng.org/

ifeq ($(filter uclibc,${ALL_PACKAGES}),)
COMMON_UCLIBC_VERSION=1.0.0
COMMON_UCLIBC_SRC_TARBALL=${DOWNLOAD_DIR}/u/uClibc-ng-${COMMON_UCLIBC_VERSION}.tar.bz2
COMMON_UCLIBC_SRC_CHECKSUM=98ab4861e63454942055873a73e9e50f
COMMON_UCLIBC_SRC_URL=https://downloads.uclibc-ng.org/releases/${COMMON_UCLIBC_VERSION}/$(notdir ${COMMON_UCLIBC_SRC_TARBALL})
COMMON_UCLIBC_SRC_TREE=${STAGING_DIR}/common-uclibc-ng-${COMMON_UCLIBC_VERSION}


.PHONY: prepare-common-uclibc

prepare-common-uclibc: | ${DOWNLOAD_DIR} ${STAGING_DIR}
	$(call download_file,$(COMMON_UCLIBC_SRC_TARBALL),$(COMMON_UCLIBC_SRC_URL),$(COMMON_UCLIBC_SRC_CHECKSUM))
	[ -r ${COMMON_UCLIBC_SRC_TREE}/README ] || { \
		printf '[%s] %s\n' $@ 'Extract...' && \
		$(call extract_archive,$(COMMON_UCLIBC_SRC_TREE),$(COMMON_UCLIBC_SRC_TARBALL)) ;\
	}


.PHONY: build-cross-uclibc

build-cross-uclibc: prepare-common-uclibc
	@printf '%s %s: %s\n' $(lastword ${MAKEFILE_LIST}) $@ "Reached at `date +'%X, %F'`"
	mkdir -p ${COMMON_UCLIBC_SRC_TREE}/$@
	( cd ${COMMON_UCLIBC_SRC_TREE}/$@ && [ -r ./Makefile ] || ln -sf ../* ./ )
	[ -r ${COMMON_UCLIBC_SRC_TREE}/$@/.config ] || { \
		printf '[%s] %s\n' $@ 'Configure...' && \
		cd ${COMMON_UCLIBC_SRC_TREE}/$@ && \
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
	[ -r ${COMMON_UCLIBC_SRC_TREE}/$@/lib/crtn.o ] || { \
		printf '[%s] %s\n' $@ 'Build...' && \
		cd ${COMMON_UCLIBC_SRC_TREE}/$@ && \
		make ;\
	}


.PHONY: install-cross-uclibc

install-cross-uclibc: build-cross-uclibc
	[ -r ${TOOLCHAIN_DIR}/lib/libuClibc-${COMMON_UCLIBC_VERSION}.so ] || { \
		printf '[%s] %s\n' $@ 'Install...' && \
		cd ${COMMON_UCLIBC_SRC_TREE}/$(patsubst install-%,build-%,$@) && \
		make PREFIX=${TOOLCHAIN_DIR}'/' install_dev ;\
	}


.PHONY: build-target-uclibc

build-target-uclibc: prepare-common-uclibc
	@printf '%s %s: %s\n' $(firstword ${MAKEFILE_LIST}) $@ "Reached at `date +'%X, %F'`"
	mkdir -p ${COMMON_UCLIBC_SRC_TREE}/$@
	( cd ${COMMON_UCLIBC_SRC_TREE}/$@ && [ -r ./Makefile ] || ln -sf ../* ./ )
	[ -r ${COMMON_UCLIBC_SRC_TREE}/$@/.config ] || { \
		printf '[%s] %s\n' $@ 'Configure...' && \
		cd ${COMMON_UCLIBC_SRC_TREE}/$@ && \
		cp ../build-cross-uclibc/.config ./ ;\
	}
	[ -r ${COMMON_UCLIBC_SRC_TREE}/$@/lib/crtn.o ] || { \
		printf '[%s] %s\n' $@ 'Build...' && \
		cd ${COMMON_UCLIBC_SRC_TREE}/$@ && \
		make ;\
	}


.PHONY: install-target-uclibc

install-target-uclibc: build-target-uclibc
	[ -r ${PACKAGE_DESTDIR}/lib/libuClibc-${COMMON_UCLIBC_VERSION}.so ] || { \
		printf '[%s] %s\n' $@ 'Install...' && \
		cd ${COMMON_UCLIBC_SRC_TREE}/$(patsubst install-%,build-%,$@) && \
		make PREFIX=${PACKAGE_DESTDIR}'/' install_runtime && \
		case ${COMMON_UCLIBC_VERSION} in \
		1.0.0) \
			[ ! -e $(PACKAGE_DESTDIR)/lib/ld64-uClibc.so.1 ] || ( cd $(PACKAGE_DESTDIR)/lib && ln -sf ld64-uClibc.so.1 ld64-uClibc.so.0 ) && \
			[ ! -e $(PACKAGE_DESTDIR)/lib/ld-uClibc.so.1 ] || ( cd $(PACKAGE_DESTDIR)/lib && ln -sf ld-uClibc.so.1 ld-uClibc.so.0 ) ;;\
		esac ;\
	}
ALL_PACKAGES+=uclibc
endif
