## TBD -- "Tiny By Design" sbase package

## sbase "core - userspace foundation" -- https://core.suckless.org/sbase/

ifeq ($(filter sbase,${ALL_PACKAGES}),)
TARGET_SBASE_VERSION=0.1
TARGET_SBASE_SRC_TARBALL=${DOWNLOAD_DIR}/s/sbase-${TARGET_SBASE_VERSION}.tar.gz
TARGET_SBASE_SRC_CHECKSUM=294eee10e8a2eb476452a0d60f391bd8
TARGET_SBASE_SRC_URL=https://dl.suckless.org/sbase/$(notdir ${TARGET_SBASE_SRC_TARBALL})
TARGET_SBASE_SRC_TREE=${STAGING_DIR}/target-sbase-${TARGET_SBASE_VERSION}


.PHONY: prepare-target-sbase

prepare-target-sbase: | ${DOWNLOAD_DIR} ${STAGING_DIR}
	$(call download_file,$(TARGET_SBASE_SRC_TARBALL),$(TARGET_SBASE_SRC_URL),$(TARGET_SBASE_SRC_CHECKSUM))
	[ -r ${TARGET_SBASE_SRC_TREE}/config.mk ] || { \
		printf '[%s] %s\n' $@ 'Extract...' && \
		$(call extract_archive,$(TARGET_SBASE_SRC_TREE),$(TARGET_SBASE_SRC_TARBALL)) ;\
		case ${TARGET_SBASE_VERSION} in \
		0.1) \
			mkdir -p ${TARGET_SBASE_SRC_TREE}/scripts && \
			wget https://raw.githubusercontent.com/michaelforney/sbase/58ec1f628525b538cf52bf8f1bda1068dd0929f2/scripts/getconf.sh -O ${TARGET_SBASE_SRC_TREE}/scripts/getconf.sh && \
			chmod a+x ${TARGET_SBASE_SRC_TREE}/scripts/getconf.sh && \
			wget https://raw.githubusercontent.com/michaelforney/sbase/b30fb56804bfed69b45ef0e944d2e029e4d26258/scripts/mkproto -O ${TARGET_SBASE_SRC_TREE}/scripts/mkproto && \
			chmod a+x ${TARGET_SBASE_SRC_TREE}/scripts/mkproto && \
			wget https://raw.githubusercontent.com/michaelforney/sbase/b30fb56804bfed69b45ef0e944d2e029e4d26258/scripts/install -O ${TARGET_SBASE_SRC_TREE}/scripts/install && \
			chmod a+x ${TARGET_SBASE_SRC_TREE}/scripts/install ;;\
		esac ;\
	}


.PHONY: build-target-sbase

build-target-sbase: prepare-target-sbase
	mkdir -p ${TARGET_SBASE_SRC_TREE}/$@
	( cd ${TARGET_SBASE_SRC_TREE}/$@ && [ -r ./config.mk ] || ln -sf ../* ./ )
	[ -r ${TARGET_SBASE_SRC_TREE}/$@/config.mk.OLD ] || { \
		printf '[%s] %s\n' $@ 'Configure...' && \
		cd ${TARGET_SBASE_SRC_TREE}/$@ && \
		mv config.mk config.mk.OLD && \
		cat config.mk.OLD \
			| sed '/CC =/ { s/^#// ; s/=.*/= '${TARGET_TRIPLET}'-gcc/ }' \
			> config.mk ;\
	}
	[ -r ${TARGET_SBASE_SRC_TREE}/$@/yes ] || { \
		printf '[%s] %s\n' $@ 'Build...' && \
		cd ${TARGET_SBASE_SRC_TREE}/$@ && \
		make ;\
	}


.PHONY: install-target-sbase

install-target-sbase: build-target-sbase
	[ -r ${PACKAGE_DESTDIR}/bin/yes ] || { \
		printf '[%s] %s\n' $@ 'Install...' && \
		cd ${TARGET_SBASE_SRC_TREE}/$(patsubst install-%,build-%,$@) && \
		make install PREFIX=/ DESTDIR=${PACKAGE_DESTDIR} ;\
		}
ALL_PACKAGES+=sbase
endif
