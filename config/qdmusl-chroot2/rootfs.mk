## TBD -- "Tiny By Design" rootfs component

include ${CONFIG_DIR}/settings.mk
-include ${CONFIG_DIR}/functions.mk
-include ${CONFIG_DIR}/rules.mk

PACKAGE_DESTINATION_RULES=target
PACKAGE_DESTDIR=${STAGING_DIR}/rootfs
include ${PACKAGE_DIR}/musl/v0.9.13.mk
include ${PACKAGE_DIR}/dash/v0.5.12.mk
include ${PACKAGE_DIR}/mksh/vR59c.mk

all-rootfs: \
	all-toolchain \
	install-target-musl \
	install-target-dash \
	install-target-mksh
	@printf '[rootfs %s] %s\n' $@ "Done at `date +'%F, %X'`"

clean-rootfs:
	-rm -rf ${STAGING_DIR}/rootfs

distclean-rootfs:
