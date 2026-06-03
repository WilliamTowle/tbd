## TBD -- "Tiny By Design" rootfs component

# packages

include ${PACKAGE_DIR}/dash/v0.5.8.mk
include ${PACKAGE_DIR}/glibc/v2.14-qdglibc.mk

ROOTFS_PACKAGES= \
	target-glibc \
	target-dash

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

#

.PHONY: clean-rootfs distclean-rootfs

clean-rootfs:
	-rm -rf ${STAGING_DIR}/rootfs

distclean-rootfs:


clean:: clean-rootfs

distclean:: distclean-rootfs
