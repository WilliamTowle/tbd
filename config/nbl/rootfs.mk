## TBD -- "Tiny By Design" rootfs component

# packages

include ${PACKAGE_DIR}/busybox/v1.20.2.mk
include ${PACKAGE_DIR}/linux/v3.4.113-qdnbl.mk
include ${PACKAGE_DIR}/uClibc/v0.9.33.2-qdnbl.mk

ROOTFS_PACKAGES= \
	target-uclibc \
	target-busybox \
	target-lximage

ifneq (${ROOTFS_PACKAGES},)
-include ${CONFIG_DIR}/functions.mk
endif


#

PACKAGE_DESTDIR=${STAGING_DIR}/rootfs

.PHONY: all-rootfs

all-rootfs: \
	all-toolchain \
	$(addprefix install-,${ROOTFS_PACKAGES})
	@printf '[rootfs %s] %s\n' $@ "Done (built $(words ${ROOTFS_PACKAGES})) at `date +'%F, %X'`"

##

.PHONY: clean-rootfs distclean-rootfs

clean-rootfs:
	-rm -rf ${STAGING_DIR}/rootfs

distclean-rootfs: clean-rootfs


clean:: clean-toolchain

distclean:: distclean-toolchain
