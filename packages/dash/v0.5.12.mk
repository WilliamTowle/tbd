## TBD -- "Tiny By Design" dash package

## dash (Debian Almquist Shell) -- http://gondor.apana.org.au/~herbert/dash/

ifeq ($(filter dash,${ALL_PACKAGES}),)
TARGET_DASH_VERSION=0.5.12
TARGET_DASH_SRC_TARBALL=${DOWNLOAD_DIR}/d/dash-${TARGET_DASH_VERSION}.tar.gz
TARGET_DASH_SRC_CHECKSUM=6800b5dbfbfdd43ac3df2ba9d31d0706
TARGET_DASH_SRC_URL=https://git.kernel.org/pub/scm/utils/dash/dash.git/snapshot/$(notdir ${TARGET_DASH_SRC_TARBALL})
TARGET_DASH_SRC_TREE=${STAGING_DIR}/target-dash-${TARGET_DASH_VERSION}


.PHONY: prepare-target-dash

prepare-target-dash: | ${DOWNLOAD_DIR} ${STAGING_DIR}
	$(call download_file,$(TARGET_DASH_SRC_TARBALL),$(TARGET_DASH_SRC_URL),$(TARGET_DASH_SRC_CHECKSUM))
	[ -r ${TARGET_DASH_SRC_TREE}/autogen.sh ] || { \
		printf '[%s] %s\n' $@ 'Extract...' && \
		$(call extract_archive,$(TARGET_DASH_SRC_TREE),$(TARGET_DASH_SRC_TARBALL)) ;\
	}


#|ifeq (${PACKAGE_DESTINATION_RULES},target)
.PHONY: build-target-dash

build-target-dash: prepare-target-dash
	mkdir -p ${TARGET_DASH_SRC_TREE}/$@
	( cd ${TARGET_DASH_SRC_TREE}/$@ && [ -r ./configure ] || ln -sf ../* ./ )
	[ -r ${TARGET_DASH_SRC_TREE}/$@/config.log ] || { \
		printf '[%s] %s\n' $@ 'Configure...' && \
		cd ${TARGET_DASH_SRC_TREE}/$@ && \
		sh autogen.sh && \
		./configure \
			--prefix=/ \
			--datarootdir=/usr/share \
			--build=${HOST_TRIPLET} \
			--host=${TARGET_TRIPLET} $(shell echo "--target=${TARGET_TRIPLET}" >/dev/null) \
			--disable-fnmatch --disable-lineno --disable-glob ;\
	}
	[ -r ${TARGET_DASH_SRC_TREE}/$@/src/dash ] || { \
		printf '[%s] %s\n' $@ 'Build...' && \
		cd ${TARGET_DASH_SRC_TREE}/$@ && \
		make top_builddir=$$(pwd) ;\
		}

.PHONY: install-target-dash

install-target-dash: build-target-dash
	[ -r ${PACKAGE_DESTDIR}/bin/dash ] || { \
		printf '[%s] %s\n' $@ 'Install...' && \
		cd ${TARGET_DASH_SRC_TREE}/$(patsubst install-%,build-%,$@) && \
		make install top_builddir=$$(pwd) DESTDIR=${PACKAGE_DESTDIR} ;\
	}
ALL_PACKAGES+=dash
endif
