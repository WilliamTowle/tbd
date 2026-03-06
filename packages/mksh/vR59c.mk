## TBD -- "Tiny By Design" mksh package

## mksh (MirBSD Korn Shell) -- http://www.mirbsd.org/mksh.htm

ifeq ($(filter mksh,${ALL_PACKAGES}),)
TARGET_MKSH_VERSION=R59c
TARGET_MKSH_SRC_TARBALL=${DOWNLOAD_DIR}/m/mksh-${TARGET_MKSH_VERSION}.tgz
TARGET_MKSH_SRC_CHECKSUM=99f8ac3c1d8a30b913d509f1969a4aaa
TARGET_MKSH_SRC_URL=http://www.mirbsd.org/MirOS/dist/mir/mksh/$(notdir ${TARGET_MKSH_SRC_TARBALL})
TARGET_MKSH_SRC_TREE=${STAGING_DIR}/target-mksh-${TARGET_MKSH_VERSION}


.PHONY: prepare-target-mksh

prepare-target-mksh: | ${DOWNLOAD_DIR} ${STAGING_DIR}
	$(call download_file,$(TARGET_MKSH_SRC_TARBALL),$(TARGET_MKSH_SRC_URL),$(TARGET_MKSH_SRC_CHECKSUM))
	[ -r ${TARGET_MKSH_SRC_TREE}/Build.sh ] || { \
		printf '[%s] %s\n' $@ 'Extract...' && \
		$(call extract_archive,$(TARGET_MKSH_SRC_TREE),$(TARGET_MKSH_SRC_TARBALL)) ;\
	}
	@echo "[$@] TODO: configure (and build/install) mksh v${TARGET_MKSH_VERSION}"


.PHONY: build-target-mksh

build-target-mksh: prepare-target-mksh
	mkdir -p ${TARGET_MKSH_SRC_TREE}/$@
	( cd ${TARGET_MKSH_SRC_TREE}/$@ && [ -r ./configure ] || ln -sf ../* ./ )
	[ -r ${TARGET_MKSH_SRC_TREE}/$@/mksh ] || { \
		printf '[%s] %s\n' $@ 'Build...' && \
		cd ${TARGET_MKSH_SRC_TREE}/$@ && \
		CC=${TARGET_TRIPLET}-gcc sh ./Build.sh ;\
		}

.PHONY: install-target-mksh

install-target-mksh: build-target-mksh
	[ -r ${PACKAGE_DESTDIR}/bin/mksh ] || { \
		printf '[%s] %s\n' $@ 'Install...' && \
		cd ${TARGET_MKSH_SRC_TREE}/$(patsubst install-%,build-%,$@) && \
		mkdir -p ${PACKAGE_DESTDIR}/bin && \
		cp mksh ${PACKAGE_DESTDIR}/bin/mksh ;\
		}
ALL_PACKAGES+=mksh
endif
