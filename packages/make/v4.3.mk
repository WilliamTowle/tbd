## TBD -- "Tiny By Design" make package

## make -- www.gnu.org

ifeq ($(filter make,${ALL_PACKAGES}),)
# versions:
#	v3.82 c. Jul 2010
#	v4.3 c. Jan 2020

#MAKE_VERSION=3.82
MAKE_VERSION=4.3
#MAKE_SRC_TARBALL=${DOWNLOAD_DIR}/m/make-${MAKE_VERSION}.tar.bz2
MAKE_SRC_TARBALL=${DOWNLOAD_DIR}/m/make-${MAKE_VERSION}.tar.gz
MAKE_SRC_CHECKSUM= $(strip \
	$(if $(filter 3.82,${MAKE_VERSION}),1a11100f3c63fcf5753818e59d63088f) \
	$(if $(filter 4.3,${MAKE_VERSION}),fc7a67ea86ace13195b0bce683fd4469) \
	)
MAKE_SRC_URL=https://ftp.gnu.org/gnu/make/$(notdir ${MAKE_SRC_TARBALL})

MAKE_SRC_TREE=${STAGING_DIR}/make-${MAKE_VERSION}


.PHONY: prepare-make

prepare-make: | ${DOWNLOAD_DIR} ${STAGING_DIR}
	$(call download_file,$(MAKE_SRC_TARBALL),$(MAKE_SRC_URL),$(MAKE_SRC_CHECKSUM))
	[ -r ${MAKE_SRC_TREE}/README ] || { \
		printf '[%s] %s\n' $@ 'Extract/patch...' && \
		$(call extract_archive,$(MAKE_SRC_TREE),$(MAKE_SRC_TARBALL)) ;\
		}


.PHONY: build-toolchain-make

build-toolchain-make: prepare-make
	mkdir -p ${MAKE_SRC_TREE}/$@
	[ -r ${MAKE_SRC_TREE}/$@/config.status ] || { \
		printf '[%s] %s\n' $@ 'Configure...' && \
		cd ${MAKE_SRC_TREE}/$@ && \
		../configure \
			--prefix=${TOOLCHAIN_DIR} ;\
		}
	[ -r ${MAKE_SRC_TREE}/$@/make ] || { \
		printf '[%s] %s\n' $@ 'Build...' && \
		cd ${MAKE_SRC_TREE}/$@ && \
		make ;\
		}


.PHONY: install-toolchain-make

install-toolchain-make: build-toolchain-make
	[ -r ${TOOLCHAIN_DIR}/bin/make ] || {\
		printf '[%s] %s\n' $@ 'Install...' && \
		cd ${MAKE_SRC_TREE}/$(patsubst install-%,build-%,$@) && make install ;\
		}
ALL_PACKAGES+=make
endif
