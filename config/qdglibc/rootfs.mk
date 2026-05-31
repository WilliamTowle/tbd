## TBD -- "Tiny By Design" rootfs component

# packages

-include ${CONFIG_DIR}/functions.mk

include ${PACKAGE_DIR}/glibc/v2.14-qdglibc.mk
include ${PACKAGE_DIR}/dash/v0.5.8.mk

#

PACKAGE_DESTDIR=${STAGING_DIR}/rootfs


.PHONY: all-rootfs

all-rootfs: \
	all-toolchain \
	install-target-glibc \
	install-target-dash
	@printf '[rootfs %s] %s\n' $@ "Done at `date +'%F, %X'`"

#

.PHONY: clean-rootfs distclean-rootfs

clean-rootfs:
	-rm -rf ${STAGING_DIR}/rootfs

distclean-rootfs:


clean:: clean-rootfs

distclean:: distclean-rootfs
