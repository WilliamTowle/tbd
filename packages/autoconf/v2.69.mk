## TBD -- "Tiny By Design" autoconf package

## autoconf -- www.gnu.org

ifeq ($(filter autoconf,${ALL_PACKAGES}),)
# versions:
#	v2.69, c. Apr 2012

AUTOCONF_VERSION=2.69
AUTOCONF_SRC_TARBALL=${DOWNLOAD_DIR}/b/autoconf-${AUTOCONF_VERSION}.tar.gz
AUTOCONF_SRC_CHECKSUM=82d05e03b93e45f5a39b828dc9c6c29b
AUTOCONF_SRC_URL=https://ftp.gnu.org/gnu/autoconf/$(notdir ${AUTOCONF_SRC_TARBALL})

AUTOCONF_SRC_TREE=${STAGING_DIR}/autoconf-${AUTOCONF_VERSION}


.PHONY: prepare-autoconf

prepare-autoconf: | ${DOWNLOAD_DIR} ${STAGING_DIR}
	$(call download_file,$(AUTOCONF_SRC_TARBALL),$(AUTOCONF_SRC_URL),$(AUTOCONF_SRC_CHECKSUM))
	[ -r ${AUTOCONF_SRC_TREE}/README ] || { \
		printf '[%s] %s\n' $@ 'Extract/patch...' && \
		$(call extract_archive,$(AUTOCONF_SRC_TREE),$(AUTOCONF_SRC_TARBALL)) ;\
		}


.PHONY: build-toolchain-autoconf

build-toolchain-autoconf: prepare-autoconf
	mkdir -p ${AUTOCONF_SRC_TREE}/$@
	[ -r ${AUTOCONF_SRC_TREE}/$@/config.status ] || { \
		printf '[%s] %s\n' $@ 'Configure...' && \
		cd ${AUTOCONF_SRC_TREE}/$@ && \
		../configure \
			--prefix=${TOOLCHAIN_DIR} ;\
		}
	[ -r ${AUTOCONF_SRC_TREE}/$@/bin/autoconf ] || { \
		printf '[%s] %s\n' $@ 'Build...' && \
		cd ${AUTOCONF_SRC_TREE}/$@ && \
		make ;\
		}


.PHONY: install-toolchain-autoconf

install-toolchain-autoconf: build-toolchain-autoconf
	[ -r ${TOOLCHAIN_DIR}/bin/autoconf ] || { \
		printf '[%s] %s\n' $@ 'Install...' && \
		cd ${AUTOCONF_SRC_TREE}/$(patsubst install-%,build-%,$@) && \
		make install ;\
		}
ALL_PACKAGES+=autoconf
endif
