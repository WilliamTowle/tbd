## TBD -- "Tiny By Design" rootfs component


# packages

-include ${CONFIG_DIR}/functions.mk

include ${PACKAGE_DIR}/busybox/v1.20.2.mk
include ${PACKAGE_DIR}/uClibc-ng/v1.0.0.mk


#

PACKAGE_DESTDIR=${STAGING_DIR}/rootfs


.PHONY: all-rootfs

all-rootfs: \
	all-toolchain \
	install-target-uclibc \
	install-target-busybox
	@printf '[rootfs %s] %s\n' $@ "Done at `date +'%F, %X'`"

#

.PHONY: clean-rootfs distclean-rootfs

clean-rootfs:
	-rm -rf ${STAGING_DIR}/rootfs

distclean-rootfs:


clean:: clean-rootfs

distclean:: distclean-rootfs
