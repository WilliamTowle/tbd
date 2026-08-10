## TBD -- "Tiny By Design" bootfiles component

include ${PACKAGE_DIR}/linux/v3.4.113-qdnbl.mk

include ${CONFIG_DIR}/functions.mk


## prepare phase

.PHONY: bootfiles-prepare-build bootfiles-prepare-fstree bootfiles-prepare-tarballs

bootfiles-prepare-build: all-toolchain

bootfiles-prepare-fstree: \
		bootfiles-prepare-build \
		| ${TARGET_STAGING_DIR}

bootfiles-prepare-tarballs: \
		bootfiles-prepare-build \
		| ${TARGET_PACKAGES_DIR}


##

.PHONY: lximage-deploy-fstree

lximage-deploy-fstree: FSTREE_DESTDIR=${TARGET_STAGING_DIR}

lximage-deploy-fstree: \
		bootfiles-prepare-build \
		build-target-lximage \
		| ${TARGET_STAGING_DIR}
	${MAKE} -f $(firstword ${MAKEFILE_LIST}) install-target-lximage PACKAGE_DESTDIR=${FSTREE_DESTDIR} || exit 1 ;\


#

.PHONY: bootfiles-build-tarball-bootfiles-kernel


bootfiles-build-tarball-bootfiles-kernel: TARBALL_DESTDIR=${TARGET_PACKAGES_DIR}/lximage
bootfiles-build-tarball-bootfiles-kernel: PKGVER=${TARGET_LINUX_VERSION}


bootfiles-build-tarball-bootfiles-kernel: \
		| ${TARGET_PACKAGES_DIR}
	mkdir ${TARGET_PACKAGES_DIR}/lximage
	${MAKE} -f $(firstword ${MAKEFILE_LIST}) install-target-lximage PACKAGE_DESTDIR=${TARBALL_DESTDIR}
	( cd ${TARBALL_DESTDIR} &&\
		tar --create --posix --owner=root --group=root * ) \
			| ( cd ${TARGET_PACKAGES_DIR}/ && gzip -9 > lximage-$(if ${PKGVER},${PKGVER},UNKNOWN).tgz )
	rm -rf ${TARGET_PACKAGES_DIR}/lximage


.PHONY: lximage-deploy-tarballs

lximage-deploy-tarballs: \
		bootfiles-prepare-tarballs \
		bootfiles-build-tarball-bootfiles-kernel


.PHONY: bootfiles-deploy

bootfiles-deploy: lximage-deploy-${TARGET_DEPLOY_TYPE}


##

.PHONY: clean-bootfiles
clean-bootfiles:
	-rm -rf ${TARGET_STAGING_DIR}

#

.PHONY: all-bootfiles

all-bootfiles: bootfiles-deploy
	@printf '[bootfiles %s] %s\n' $@ "Done (built kernel) at `date +'%F, %X'`"
