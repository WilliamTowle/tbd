## TBD -- "Tiny By Design" uClibc package

## uclibc -- https://uclibc.org/

# NB. possible invalid binaries with gcc5+ -- see crosstool-ng.github.io
# Forked as uClibc-ng v1.0.0 c. 2015 -- see https://uclibc-ng.org/

#|ifneq (${TOOLCHAIN_UCLIBC_VERSION},)
ifeq ($(filter uclibc,${ALL_PACKAGES}),)
COMMON_UCLIBC_VERSION=0.9.33.2
COMMON_UCLIBC_SRC_TARBALL=${DOWNLOAD_DIR}/u/uClibc-${COMMON_UCLIBC_VERSION}.tar.bz2
COMMON_UCLIBC_SRC_CHECKSUM=a338aaffc56f0f5040e6d9fa8a12eda1
COMMON_UCLIBC_SRC_URL=https://uclibc.org/downloads/$(notdir ${COMMON_UCLIBC_SRC_TARBALL})
COMMON_UCLIBC_SRC_TREE=${STAGING_DIR}/common-uclibc-${COMMON_UCLIBC_VERSION}


.PHONY: prepare-common-uclibc

prepare-common-uclibc: | ${DOWNLOAD_DIR} ${STAGING_DIR}
	$(call download_file,$(COMMON_UCLIBC_SRC_TARBALL),$(COMMON_UCLIBC_SRC_URL),$(COMMON_UCLIBC_SRC_CHECKSUM))
	[ -r ${COMMON_UCLIBC_SRC_TREE}/README ] || { \
		printf '[%s] %s\n' $@ 'Extract...' && \
		$(call extract_archive,$(COMMON_UCLIBC_SRC_TREE),$(COMMON_UCLIBC_SRC_TARBALL)) ;\
	}


.PHONY: build-cross-uclibc-startfiles

build-cross-uclibc-startfiles: prepare-common-uclibc
	@printf '%s %s: %s\n' $(lastword ${MAKEFILE_LIST}) $@ "Reached at `date +'%X, %F'`"
	mkdir -p ${COMMON_UCLIBC_SRC_TREE}/$@
	( cd ${COMMON_UCLIBC_SRC_TREE}/$@ && [ -r ./Makefile ] || ln -sf ../* ./ )
	[ -r ${COMMON_UCLIBC_SRC_TREE}/$@/.config ] || { \
		printf '[%s] %s\n' $@ 'Configure...' && \
		cd ${COMMON_UCLIBC_SRC_TREE}/$@ && \
		( \
		 echo 'TOOLCHAIN_ARCH="'${TARGET_ARCH}'"' ;\
		 echo 'TARGET_'${TARGET_ARCH}'=y' ;\
		 echo 'CROSS_COMPILER_PREFIX="'${TARGET_TRIPLET}'-k"' ;\
		 \
		 echo 'KERNEL_HEADERS="'${TOOLCHAIN_DIR}'/usr/include/"' ;\
		 echo 'SHARED_LIB_LOADER_PREFIX="/lib"' ;\
		 echo 'DEVEL_PREFIX="/"' ;\
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
		make headers startfiles ;\
	}


.PHONY: install-cross-uclibc-startfiles

install-cross-uclibc-startfiles: build-cross-uclibc-startfiles
	[ -r ${TOOLCHAIN_DIR}/lib/crt1.o ] || { \
		printf '[%s] %s\n' $@ 'Install...' && \
		cd ${COMMON_UCLIBC_SRC_TREE}/$(patsubst install-%,build-%,$@) && \
		make PREFIX=${TOOLCHAIN_DIR}'/usr/' install_headers && \
		make PREFIX=${TOOLCHAIN_DIR}'/' install_startfiles ;\
	}


.PHONY: build-cross-uclibc-libc

build-cross-uclibc-libc: prepare-common-uclibc
	@printf '%s %s: %s\n' $(lastword ${MAKEFILE_LIST}) $@ "Reached at `date +'%X, %F'`"
	mkdir -p ${COMMON_UCLIBC_SRC_TREE}/$@
	( cd ${COMMON_UCLIBC_SRC_TREE}/$@ && [ -r ./Makefile ] || ln -sf ../* ./ )
	[ -r ${COMMON_UCLIBC_SRC_TREE}/$@/.config ] || { \
		printf '[%s] %s\n' $@ 'Configure...' && \
		cd ${COMMON_UCLIBC_SRC_TREE}/$@ && \
		cp ../build-cross-uclibc-startfiles/.config ./ ;\
	}
	[ -r ${COMMON_UCLIBC_SRC_TREE}/$@/lib/crtn.o ] || { \
		printf '[%s] %s\n' $@ 'Build...' && \
		cd ${COMMON_UCLIBC_SRC_TREE}/$@ && \
		make ;\
	}


.PHONY: install-cross-uclibc-libc

install-cross-uclibc-libc: build-cross-uclibc-libc
	[ -r ${TOOLCHAIN_DIR}/lib/libc.a ] || { \
		printf '[%s] %s\n' $@ 'Install...' && \
		cd ${COMMON_UCLIBC_SRC_TREE}/$(patsubst install-%,build-%,$@) && \
		make PREFIX=${TOOLCHAIN_DIR}'/' install ;\
	}


.PHONY: build-target-uclibc

build-target-uclibc: prepare-common-uclibc
	@printf '%s %s: %s\n' $(firstword ${MAKEFILE_LIST}) $@ "Reached at `date +'%X, %F'`"
	mkdir -p ${COMMON_UCLIBC_SRC_TREE}/$@
	( cd ${COMMON_UCLIBC_SRC_TREE}/$@ && [ -r ./Makefile ] || ln -sf ../* ./ )
	[ -r ${COMMON_UCLIBC_SRC_TREE}/$@/.config ] || { \
		printf '[%s] %s\n' $@ 'Configure...' && \
		cd ${COMMON_UCLIBC_SRC_TREE}/$@ && \
		cp ../build-cross-uclibc-startfiles/.config ./ ;\
	}
	[ -r ${COMMON_UCLIBC_SRC_TREE}/$@/lib/crtn.o ] || { \
		printf '[%s] %s\n' $@ 'Build...' && \
		cd ${COMMON_UCLIBC_SRC_TREE}/$@ && \
		make ;\
	}


.PHONY: install-target-uclibc

install-target-uclibc: build-target-uclibc
	[ -r ${PACKAGE_DESTDIR}/lib/libc.so.0 ] || { \
		printf '[%s] %s\n' $@ 'Install...' && \
		cd ${COMMON_UCLIBC_SRC_TREE}/$(patsubst install-%,build-%,$@) && \
		make PREFIX=${PACKAGE_DESTDIR}'/' install_runtime ;\
	}

ALL_PACKAGES+=uclibc
endif
