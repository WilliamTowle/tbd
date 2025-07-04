## TBD -- "Tiny By Design" rootfs component

include ${CONFIG_DIR}/settings.mk
-include ${CONFIG_DIR}/functions.mk
-include ${CONFIG_DIR}/rules.mk

PACKAGE_DESTINATION_RULES=target
PACKAGE_DESTDIR=${STAGING_DIR}/rootfs

include ${PACKAGE_DIR}/glibc/v2.14.mk
include ${PACKAGE_DIR}/dash/v0.5.8.mk

all-rootfs: \
	install-target-glibc \
	install-target-dash
	@printf '[rootfs %s] %s\n' $@ "Done at `date +'%F, %X'`"

clean-rootfs:
	-rm -rf ${STAGING_DIR}/rootfs

distclean-rootfs:
