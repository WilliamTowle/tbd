## TBD -- "Tiny By Design" m4 package

## m4 -- www.gnu.org

ifeq ($(filter m4,${ALL_PACKAGES}),)
# versions:
#	v1.4.16 c. Mar 2011
#	v1.4.19 c. May 2021

#M4_VERSION=1.4.16
M4_VERSION=1.4.19
M4_SRC_TARBALL=${DOWNLOAD_DIR}/m/m4-${M4_VERSION}.tar.gz
M4_SRC_CHECKSUM= $(strip \
	$(if $(filter 1.4.16,${M4_VERSION}),a5dfb4f2b7370e9d34293d23fd09b280) \
	$(if $(filter 1.4.19,${M4_VERSION}),f4a2b0284d80353b995f8ef2385ed73c) \
	)
M4_SRC_URL=https://ftp.gnu.org/gnu/m4/$(notdir ${M4_SRC_TARBALL})

M4_SRC_TREE=${STAGING_DIR}/m4-${M4_VERSION}


.PHONY: prepare-m4

prepare-m4: | ${DOWNLOAD_DIR} ${STAGING_DIR}
	$(call download_file,$(M4_SRC_TARBALL),$(M4_SRC_URL),$(M4_SRC_CHECKSUM))
	[ -r ${M4_SRC_TREE}/README ] || { \
		printf '[%s] %s\n' $@ 'Extract/patch...' && \
		$(call extract_archive,$(M4_SRC_TREE),$(M4_SRC_TARBALL)) ;\
		}


.PHONY: build-toolchain-m4

build-toolchain-m4: prepare-m4
	mkdir -p ${M4_SRC_TREE}/$@
	[ -r ${M4_SRC_TREE}/$@/config.status ] || { \
		printf '[%s] %s\n' $@ 'Configure...' && \
		cd ${M4_SRC_TREE}/$@ && \
		../configure \
			--prefix=${TOOLCHAIN_DIR} ;\
		}
	[ -r ${M4_SRC_TREE}/$@/src/m4 ] || { \
		printf '[%s] %s\n' $@ 'Build...' && \
		cd ${M4_SRC_TREE}/$@ && \
		make ;\
		}


.PHONY: install-toolchain-m4

install-toolchain-m4: build-toolchain-m4
	[ -r ${TOOLCHAIN_DIR}/bin/m4 ] || { \
		printf '[%s] %s\n' $@ 'Install...' && \
		cd ${M4_SRC_TREE}/$(patsubst install-%,build-%,$@) &&\
		make install ;\
		}
ALL_PACKAGES+=m4
endif
