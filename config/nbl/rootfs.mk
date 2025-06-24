## TBD -- "Tiny By Design" rootfs component

include ${CONFIG_DIR}/settings.mk
-include ${CONFIG_DIR}/functions.mk
-include ${CONFIG_DIR}/rules.mk

PACKAGE_DESTINATION_RULES=target
PACKAGE_DESTDIR=${STAGING_DIR}/rootfs

include ${PACKAGE_DIR}/busybox/v1.20.2.mk
include ${PACKAGE_DIR}/uClibc/v0.9.33.2.mk

all-rootfs: \
	install-target-uclibc \
	install-target-busybox
	@printf '[rootfs %s] %s\n' $@ "Done at `date +'%F, %X'`"

clean-rootfs:
	-rm -rf ${STAGING_DIR}/rootfs

distclean-rootfs:
