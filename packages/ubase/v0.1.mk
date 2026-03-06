## TBD -- "Tiny By Design" ubase package


## ubase "core - unportable tools" -- https://core.suckless.org/ubase/

ifeq ($(filter ubase,${ALL_PACKAGES}),)
TARGET_UBASE_VERSION=0.1
TARGET_UBASE_SRC_TARBALL=${DOWNLOAD_DIR}/u/ubase-0.1.tar.gz
TARGET_UBASE_SRC_CHECKSUM=38a7a1f1d66b53d4c55f17e01ee3fa44
TARGET_UBASE_SRC_URL=https://dl.suckless.org/ubase/$(notdir ${TARGET_UBASE_SRC_TARBALL})
TARGET_UBASE_SRC_TREE=${STAGING_DIR}/target-ubase-${TARGET_UBASE_VERSION}


prepare-target-ubase: | ${DOWNLOAD_DIR} ${STAGING_DIR}
	$(call download_file,$(TARGET_UBASE_SRC_TARBALL),$(TARGET_UBASE_SRC_URL),$(TARGET_UBASE_SRC_CHECKSUM))
	[ -r ${TARGET_UBASE_SRC_TREE}/config.mk ] || { \
		printf '[%s] %s\n' $@ 'Extract...' && \
		$(call extract_archive,$(TARGET_UBASE_SRC_TREE),$(TARGET_UBASE_SRC_TARBALL)) ;\
	}


#|ifeq (${PACKAGE_DESTINATION_RULES},target)
.PHONY: build-target-ubase

build-target-ubase: prepare-target-ubase
	mkdir -p ${TARGET_UBASE_SRC_TREE}/$@
	( cd ${TARGET_UBASE_SRC_TREE}/$@ && [ -r ./config.mk ] || ln -sf ../* ./ )
	[ -r ${TARGET_UBASE_SRC_TREE}/$@/config.mk.OLD ] || { \
		printf '[%s] %s\n' $@ 'Configure...' && \
		cd ${TARGET_UBASE_SRC_TREE}/$@ && \
		mv config.mk config.mk.OLD && \
		cat config.mk.OLD \
			| sed '/CC =/ { s/^#// ; s/=.*/= '${TARGET_TRIPLET}'-gcc/ }' \
			> config.mk ;\
	}
	[ -r ${TARGET_UBASE_SRC_TREE}/$@/who ] || { \
		printf '[%s] %s\n' $@ 'Build...' && \
		cd ${TARGET_UBASE_SRC_TREE}/$@ && \
		make ;\
	}

.PHONY: install-target-ubase

install-target-ubase: build-target-ubase
	[ -r ${PACKAGE_DESTDIR}/bin/who ] || { \
		printf '[%s] %s\n' $@ 'Install...' && \
		cd ${TARGET_UBASE_SRC_TREE}/$(patsubst install-%,build-%,$@) && \
		make install PREFIX=/ DESTDIR=${PACKAGE_DESTDIR} ;\
		}
ALL_PACKAGES+=ubase
endif
