## TBD -- "Tiny By Design" rootfs component

include ${PACKAGE_DIR}/base-files/v0.1.mk
include ${PACKAGE_DIR}/busybox/v1.20.2.mk
include ${PACKAGE_DIR}/uClibc/v0.9.33.2-qdnbl.mk

ROOTFS_PACKAGES=base-files busybox uclibc

ifneq (${ROOTFS_PACKAGES},)
include ${CONFIG_DIR}/functions.mk
endif



## prepare phase

.PHONY: rootfs-prepare-build rootfs-prepare-fstree rootfs-prepare-tarballs

rootfs-prepare-build: all-toolchain

rootfs-prepare-fstree: \
		rootfs-prepare-build \
		| ${TARGET_STAGING_DIR}

rootfs-prepare-tarballs: \
		rootfs-prepare-build \
		| ${TARGET_PACKAGES_DIR}


##

.PHONY: rootfs-deploy-fstree

rootfs-deploy-fstree: FSTREE_DESTDIR=${TARGET_STAGING_DIR}

rootfs-deploy-fstree: \
		rootfs-prepare-build \
		$(patsubst %,build-target-%,${ROOTFS_PACKAGES}) \
		| ${TARGET_STAGING_DIR}
ifneq (${ROOTFS_PACKAGES},)
	for PKG in ${ROOTFS_PACKAGES} ; do \
		${MAKE} -f $(firstword ${MAKEFILE_LIST}) install-target-$${PKG} PACKAGE_DESTDIR=${FSTREE_DESTDIR} || exit 1 ;\
	done
endif


#

.PHONY: $(patsubst %,rootfs-build-tarball-%,${ROOTFS_PACKAGES})

$(patsubst %,rootfs-build-tarball-%,${ROOTFS_PACKAGES}): TARBALL_DESTDIR=${TARGET_PACKAGES_DIR}/$*

rootfs-build-tarball-base-files: PKGVER=${TARGET_BASE_FILES_VERSION}
rootfs-build-tarball-busybox: PKGVER=${TARGET_BUSYBOX_VERSION}
rootfs-build-tarball-uclibc: PKGVER=${COMMON_UCLIBC_VERSION}


$(patsubst %,rootfs-build-tarball-%,${ROOTFS_PACKAGES}): rootfs-build-tarball-%: \
		| ${TARGET_PACKAGES_DIR}
	mkdir ${TARGET_PACKAGES_DIR}/$*
	${MAKE} -f $(firstword ${MAKEFILE_LIST}) install-target-$* PACKAGE_DESTDIR=${TARBALL_DESTDIR}
	( cd ${TARBALL_DESTDIR} &&\
		tar --create --posix --owner=root --group=root * ) \
			| ( cd ${TARGET_PACKAGES_DIR}/ && gzip -9 > $*-$(if ${PKGVER},${PKGVER},UNKNOWN).tgz )
	rm -rf ${TARGET_PACKAGES_DIR}/$*


.PHONY: rootfs-deploy-tarballs

rootfs-deploy-tarballs: \
		rootfs-prepare-tarballs \
		$(patsubst %,rootfs-build-tarball-%,${ROOTFS_PACKAGES})


.PHONY: rootfs-deploy

rootfs-deploy: rootfs-deploy-${TARGET_DEPLOY_TYPE}


##

.PHONY: clean-rootfs
clean-rootfs:
	-rm -rf ${TARGET_STAGING_DIR}

#

.PHONY: all-rootfs

all-rootfs: rootfs-deploy
	@printf '[rootfs %s] %s\n' $@ "Done (built $(words ${ROOTFS_PACKAGES})) at `date +'%F, %X'`"
