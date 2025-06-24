## TBD -- "Tiny By Design" musl package

## uclibc -- https://uclibc.org/

# NB. possible invalid binaries with gcc5+ -- see crosstool-ng.github.io
# Forked as uClibc-ng v1.0.0 c. 2015 -- see https://uclibc-ng.org/

CROSS_UCLIBC_VERSION=0.9.33.2
CROSS_UCLIBC_SRC_TARBALL=${DOWNLOAD_DIR}/u/uClibc-${CROSS_UCLIBC_VERSION}.tar.bz2
CROSS_UCLIBC_SRC_CHECKSUM=a338aaffc56f0f5040e6d9fa8a12eda1
CROSS_UCLIBC_SRC_URL=https://uclibc.org/downloads/$(notdir ${CROSS_UCLIBC_SRC_TARBALL})
CROSS_UCLIBC_SRC_TREE=${STAGING_DIR}/build-uclibc-${CROSS_UCLIBC_VERSION}


.PHONY: prepare-uclibc

prepare-cross-uclibc:
	$(call download_file,$(CROSS_UCLIBC_SRC_TARBALL),$(CROSS_UCLIBC_SRC_URL),$(CROSS_UCLIBC_SRC_CHECKSUM))
	[ -r ${CROSS_UCLIBC_SRC_TREE}/README ] || { \
		printf '[%s] %s\n' $@ 'Extract...' && \
		$(call extract_archive,$(CROSS_UCLIBC_SRC_TREE),$(CROSS_UCLIBC_SRC_TARBALL)) ;\
	}



ifeq (${PACKAGE_DESTINATION_RULES},toolchain)
.PHONY: build-cross-uclibc-startfiles

build-cross-uclibc-startfiles: prepare-cross-uclibc
	@printf '%s %s: %s\n' $(lastword ${MAKEFILE_LIST}) $@ "Reached at `date +'%X, %F'`"
	mkdir -p ${CROSS_UCLIBC_SRC_TREE}/$@
	( cd ${CROSS_UCLIBC_SRC_TREE}/$@ && [ -r ./Makefile ] || ln -sf ../* ./ )
	[ -r ${CROSS_UCLIBC_SRC_TREE}/$@/.config ] || { \
		printf '[%s] %s\n' $@ 'Configure...' && \
		cd ${CROSS_UCLIBC_SRC_TREE}/$@ && \
		( \
		 echo 'TARGET_ARCH="'${TARGET_CPU}'"' ;\
		 echo 'TARGET_'${TARGET_CPU}'=y' ;\
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
	[ -r ${CROSS_UCLIBC_SRC_TREE}/$@/lib/crtn.o ] || { \
		printf '[%s] %s\n' $@ 'Build...' && \
		cd ${CROSS_UCLIBC_SRC_TREE}/$@ && \
		make headers startfiles ;\
	}


.PHONY: install-cross-uclibc-startfiles

install-cross-uclibc-startfiles: build-cross-uclibc-startfiles
	[ -r ${TOOLCHAIN_DIR}/lib/crt1.o ] || { \
		printf '[%s] %s\n' $@ 'Install...' && \
		cd ${CROSS_UCLIBC_SRC_TREE}/$(patsubst install-%,build-%,$@) && \
		make PREFIX=${TOOLCHAIN_DIR}'/usr/' install_headers && \
		make PREFIX=${TOOLCHAIN_DIR}'/' install_startfiles ;\
	}


.PHONY: build-cross-uclibc-libc

build-cross-uclibc-libc: prepare-cross-uclibc
	@printf '%s %s: %s\n' $(lastword ${MAKEFILE_LIST}) $@ "Reached at `date +'%X, %F'`"
	mkdir -p ${CROSS_UCLIBC_SRC_TREE}/$@
	( cd ${CROSS_UCLIBC_SRC_TREE}/$@ && [ -r ./Makefile ] || ln -sf ../* ./ )
	[ -r ${CROSS_UCLIBC_SRC_TREE}/$@/.config ] || { \
		printf '[%s] %s\n' $@ 'Configure...' && \
		cd ${CROSS_UCLIBC_SRC_TREE}/$@ && \
		cp ../build-cross-uclibc-startfiles/.config ./ ;\
	}
	[ -r ${CROSS_UCLIBC_SRC_TREE}/$@/lib/crtn.o ] || { \
		printf '[%s] %s\n' $@ 'Build...' && \
		cd ${CROSS_UCLIBC_SRC_TREE}/$@ && \
		make ;\
	}


.PHONY: install-cross-uclibc-libc

install-cross-uclibc-libc: build-cross-uclibc-libc
	[ -r ${TOOLCHAIN_DIR}/lib/libc.a ] || { \
		printf '[%s] %s\n' $@ 'Install...' && \
		cd ${CROSS_UCLIBC_SRC_TREE}/$(patsubst install-%,build-%,$@) && \
		make PREFIX=${TOOLCHAIN_DIR}'/' install ;\
	}
endif
