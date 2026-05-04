## TBD -- "Tiny By Design" rootfs component


# packages

-include ${CONFIG_DIR}/functions.mk

include ${PACKAGE_DIR}/musl/v0.9.13.mk
include ${PACKAGE_DIR}/dash/v0.5.12.mk
include ${PACKAGE_DIR}/mksh/vR59c.mk

#

PACKAGE_DESTDIR=${STAGING_DIR}/rootfs


.PHONY: all-rootfs

all-rootfs: \
	all-toolchain \
	install-target-musl \
	install-target-dash \
	install-target-mksh
	@printf '[rootfs %s] %s\n' $@ "Done at `date +'%F, %X'`"

#

.PHONY: clean-rootfs distclean-rootfs

clean-rootfs:
	-rm -rf ${STAGING_DIR}/rootfs

distclean-rootfs: clean-rootfs


clean:: clean-rootfs

distclean:: distclean-rootfs
