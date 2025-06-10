## TBD -- "Tiny By Design" rootfs component

include ${CONFIG_DIR}/settings.mk
-include ${CONFIG_DIR}/functions.mk
-include ${CONFIG_DIR}/rules.mk

PACKAGE_DESTINATION_RULES=target
PACKAGE_DESTDIR=${STAGING_DIR}/rootfs

all-rootfs:
	@printf '[initrd %s] %s\n' $@ 'No package targets defined'
	@printf '[rootfs %s] %s\n' $@ "Done at `date +'%F, %X'`"

clean-rootfs:
	-rm -rf ${STAGING_DIR}/rootfs

distclean-rootfs:
