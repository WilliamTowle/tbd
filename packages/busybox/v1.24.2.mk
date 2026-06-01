## busybox -- busybox.net

# [2025-01-22] busybox with musl: https://github.com/kanj/elfs/issues/4
# [2025-06-01] busybox 1.21.1 silentoldconfig bails on bookworm host
# [2025-06-01] busybox 1.37.0 silentoldconfig bails on bookworm host

ifeq ($(filter busybox,${ALL_PACKAGES}),)
#TARGET_BUSYBOX_VERSION=1.19.3
#TARGET_BUSYBOX_VERSION=1.20.2
#TARGET_BUSYBOX_VERSION=1.21.1
TARGET_BUSYBOX_VERSION=1.24.2
#TARGET_BUSYBOX_VERSION=1.37.0
TARGET_BUSYBOX_SRC_TARBALL=${DOWNLOAD_DIR}/b/busybox-${TARGET_BUSYBOX_VERSION}.tar.bz2
TARGET_BUSYBOX_SRC_CHECKSUM= $(strip \
	$(if $(filter 1.19.3,${TARGET_BUSYBOX_VERSION}),c3938e1ac59602387009bbf1dd1af7f6,) \
	$(if $(filter 1.20.2,${TARGET_BUSYBOX_VERSION}),e025414bc6cd79579cc7a32a45d3ae1c,) \
	$(if $(filter 1.21.1,${TARGET_BUSYBOX_VERSION}),795394f83903b5eec6567d51eebb417e,) \
	$(if $(filter 1.24.2,${TARGET_BUSYBOX_VERSION}),2eaae519cac1143bcf583636a745381f,) \
	$(if $(filter 1.37.0,${TARGET_BUSYBOX_VERSION}),865b68ab41b923d9cdbebf3f2c8b04ec,) \
	)
TARGET_BUSYBOX_SRC_URL=https://busybox.net/downloads/$(notdir ${TARGET_BUSYBOX_SRC_TARBALL})
TARGET_BUSYBOX_SRC_TREE=${STAGING_DIR}/build-busybox-${TARGET_BUSYBOX_VERSION}

#|ifeq (${TARGET_BUSYBOX_VERSION},1.19.3)
#|TARGET_BUSYBOX_PATCH1_URL=https://raw.githubusercontent.com/pikhq/bootstrap-linux/refs/heads/master/patches/busybox-musl-fixes.patch
#|TARGET_BUSYBOX_PATCH1_FILE=${DOWNLOAD_DIR}/b/$(notdir ${TARGET_BUSYBOX_PATCH1_URL})
#|TARGET_BUSYBOX_PATCH1_CHECKSUM=f718d6d53b6cd1e012edcee32686a846
#|endif
#|TARGET_BUSYBOX_PATCH1_FILE=${DOWNLOAD_DIR}/b/$(notdir ${TARGET_BUSYBOX_PATCH1_URL})
#|TARGET_BUSYBOX_PATCH1_CHECKSUM=335622b0f2bf4e18e9d93fd48afe53da
#|endif


.PHONY: prepare-target-busybox

prepare-target-busybox: | ${DOWNLOAD_DIR} ${STAGING_DIR}
	$(call download_file,$(TARGET_BUSYBOX_SRC_TARBALL),$(TARGET_BUSYBOX_SRC_URL),$(TARGET_BUSYBOX_SRC_CHECKSUM))
ifneq (${TARGET_BUSYBOX_PATCH1_FILE},)
	$(call download_file,$(TARGET_BUSYBOX_PATCH1_TARBALL),$(TARGET_BUSYBOX_PATCH1_URL),$(TARGET_BUSYBOX_PATCH1_CHECKSUM))
endif
	[ -r ${TARGET_BUSYBOX_SRC_TREE}/README ] || { \
		$(call extract_archive,$(TARGET_BUSYBOX_SRC_TREE),$(TARGET_BUSYBOX_SRC_TARBALL)) ;\
		[ -z "${TARGET_BUSYBOX_PATCH1_FILE}" ] || ( cd ${TARGET_BUSYBOX_SRC_TREE} && patch -Np1 -i ${TARGET_BUSYBOX_PATCH1_FILE} ) ;\
	}


.PHONY: build-target-busybox

build-target-busybox: prepare-target-busybox
#|	mkdir -p ${TARGET_BUSYBOX_SRC_TREE}/$@
#|	( cd ${TARGET_BUSYBOX_SRC_TREE}/$@ && [ -r ./configure ] || ln -sf ../* ./ )
	[ -r ${TARGET_BUSYBOX_SRC_TREE}/.config ] || { \
		cd ${TARGET_BUSYBOX_SRC_TREE} && \
		printf '%s\n' \
			\#' CONFIG_STATIC is not set' \
			'CONFIG_CROSS_COMPILER_PREFIX="'${TARGET_TRIPLET}-'"' \
			'CONFIG_PREFIX="'${PACKAGE_DESTDIR}'/"' \
			'CONFIG_ASH=y' \
			'CONFIG_SH_IS_ASH=y' \
			\#' CONFIG_INETD is not set' \
			\#' CONFIG_NSLOOKUP is not set' \
			'CONFIG_PING=y' \
			\#' CONFIG_PING6 is not set' \
			\#' CONFIG_TRACEROUTE is not set' \
			 > .config && \
		case ${TARGET_LIBC}-${TARGET_BUSYBOX_VERSION} in \
		musl-1.23.2) \
			printf '%s\n' \
				\#' CONFIG_FEATURE_UTMP is not set'\
				\#' CONFIG_FEATURE_WTMP is not set'\
				\#' CONFIG_TCPSVD is not set'\
				\#' CONFIG_UDPSVD is not set'\
				>> .config ;;\
		musl-1.24.*) \
			printf '%s\n' \
				\#' CONFIG_FEATURE_UTMP is not set'\
				\#' CONFIG_FEATURE_WTMP is not set'\
				\#' CONFIG_TCPSVD is not set'\
				\#' CONFIG_UDPSVD is not set'\
				>> .config ;;\
		esac ;\
		yes '' | make oldconfig ;\
	}
	[ -r ${TARGET_BUSYBOX_SRC_TREE}/busybox ] || { \
		printf '[%s] %s\n' $@ 'Build...' && \
		cd ${TARGET_BUSYBOX_SRC_TREE} && \
		make ;\
		}


.PHONY: install-target-busybox

install-target-busybox: build-target-busybox
	[ -r ${PACKAGE_DESTDIR}/bin/busybox ] || { \
		printf '[%s] %s\n' $@ 'Install...' && \
		cd ${TARGET_BUSYBOX_SRC_TREE} && \
		make install CONFIG_PREFIX=${PACKAGE_DESTDIR} ;\
	}
ALL_PACKAGES+=busybox
endif
