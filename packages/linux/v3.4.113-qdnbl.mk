## TBD -- "Tiny By Design" linux (kernel/headers) package

## linux kernel/headers -- kernel.org

# portlx had kernel 3.2.4 but modern perl rejects kernel/timeconst.pl

ifeq ($(filter linux,${ALL_PACKAGES}),)
#TARGET_LINUX_VERSION=2.6.28
#TARGET_LINUX_VERSION=3.2.4
TARGET_LINUX_VERSION=3.4.113
#TARGET_LINUX_VERSION=3.19.8
TARGET_LINUX_SRC_TARBALL=${DOWNLOAD_DIR}/l/linux-${TARGET_LINUX_VERSION}.tar.xz
TARGET_LINUX_SRC_CHECKSUM= $(strip \
	$(if $(filter 2.6.28,${TARGET_LINUX_VERSION}),c4107a182468ff37954fe86e17de15cb,) \
	$(if $(filter 3.2.4,${TARGET_LINUX_VERSION}),560b700f34ba17ec1eaeb19c7af427de,) \
	$(if $(filter 3.4.113,${TARGET_LINUX_VERSION}),98e195635d314578efe118d38dd146bd,) \
	$(if $(filter 3.19.8,${TARGET_LINUX_VERSION}),4417244850b060d93a9181f370bfa80c,) \
	)
TARGET_LINUX_SRC_URL=https://mirrors.edge.kernel.org/pub/linux/kernel/v3.x/$(notdir ${TARGET_LINUX_SRC_TARBALL})

TARGET_LINUX_SRC_TREE=${STAGING_DIR}/build-linux-${TARGET_LINUX_VERSION}


.PHONY: prepare-lxheaders

prepare-lxheaders: | ${DOWNLOAD_DIR} ${STAGING_DIR}
	$(call download_file,$(TARGET_LINUX_SRC_TARBALL),$(TARGET_LINUX_SRC_URL),$(TARGET_LINUX_SRC_CHECKSUM))
	[ -r ${TARGET_LINUX_SRC_TREE}/README ] || { \
		printf '[%s] %s\n' $@ 'Extract...' && \
		$(call extract_archive,$(TARGET_LINUX_SRC_TREE),$(TARGET_LINUX_SRC_TARBALL)) ;\
		cd ${TARGET_LINUX_SRC_TREE} && \
		{ [ -r Makefile.OLD ] || mv Makefile Makefile.OLD ; } && \
		cat Makefile.OLD \
			| sed '/^ARCH/		s/?=.*/:= '${TARGET_ARCH}'/' \
			| sed '/^CROSS_COMPILE/	s/?=.*/:= '${TARGET_CPU}'-'${TARGET_VENDOR}'-linux-none-/' \
		> Makefile ;\
	}
	[ -r ${TARGET_LINUX_SRC_TREE}/$@/.config ] || { \
		mkdir -p ${TARGET_LINUX_SRC_TREE}/$@ &&\
		cd ${TARGET_LINUX_SRC_TREE}/$@ &&\
		make O=$${PWD} -C ${TARGET_LINUX_SRC_TREE} mrproper &&\
		make O=$${PWD} -C ${TARGET_LINUX_SRC_TREE} ${TARGET_ARCH}_defconfig ARCH=${TARGET_ARCH} &&\
		cp ${TARGET_LINUX_SRC_TREE}/scripts/config ./scripts &&\
		scripts/config --disable MODULES &&\
		scripts/config --enable CONFIG_EFI --enable CONFIG_EFI_STUB &&\
		scripts/config --disable SND &&\
		scripts/config --enable IKCONFIG --enable IKCONFIG_PROC && \
		scripts/config --enable DEVTMPFS --enable DEVTMPFS_MOUNT --enable TMPFS &&\
		scripts/config --set-str LOCALVERSION 'tbd' &&\
		yes '' | make O=$${PWD} -C ${TARGET_LINUX_SRC_TREE} \
			 ARCH=${TARGET_ARCH} oldconfig ;\
	}


.PHONY: build-toolchain-lxheaders

build-toolchain-lxheaders: prepare-lxheaders
	mkdir -p ${TARGET_LINUX_SRC_TREE}/$@
	[ -r ${TARGET_LINUX_SRC_TREE}/$@/include/linux/version.h ] || { \
		printf '[%s] %s\n' $@ 'Build...' && \
		cd ${TARGET_LINUX_SRC_TREE}/$@ && \
		LANG=C make O=$${PWD} -C ${TARGET_LINUX_SRC_TREE} \
			 ARCH=${TARGET_ARCH} headers_check ;\
	}


.PHONY: install-toolchain-lxheaders

install-toolchain-lxheaders: build-toolchain-lxheaders
	[ -r ${TOOLCHAIN_DIR}/usr/include/asm/.install ] || { \
		printf '[%s] %s\n' $@ 'Install...' && \
		cd ${TARGET_LINUX_SRC_TREE}/$(patsubst install-%,build-%,$@) && \
		cp ${TARGET_LINUX_SRC_TREE}/prepare-lxheaders/.config .config && \
		LANG=C make O=$${PWD} -C ${TARGET_LINUX_SRC_TREE} \
			headers_install \
			ARCH=${TARGET_ARCH} INSTALL_HDR_PATH=${TOOLCHAIN_DIR}/usr headers_install ;\
		}
ALL_PACKAGES+=linux
endif
