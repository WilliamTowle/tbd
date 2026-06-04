## TBD -- "Tiny By Design" rootfs component


# packages

include ${PACKAGE_DIR}/linux/v3.4.113.mk
include ${PACKAGE_DIR}/dash/v0.5.12.mk
include ${PACKAGE_DIR}/mksh/vR59c.mk
include ${PACKAGE_DIR}/musl/v0.9.15.mk

ROOTFS_PACKAGES= \
	target-musl \
	target-dash \
	target-mksh \
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

#

.PHONY: clean-rootfs distclean-rootfs

clean-rootfs:
	-rm -rf ${STAGING_DIR}/rootfs

distclean-rootfs: clean-rootfs


clean:: clean-rootfs

distclean:: distclean-rootfs
