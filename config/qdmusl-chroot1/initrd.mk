## TBD -- "Tiny By Design" initrd component

include ${CONFIG_DIR}/settings.mk
-include ${CONFIG_DIR}/functions.mk
-include ${CONFIG_DIR}/rules.mk

PACKAGE_DESTINATION_RULES=target
PACKAGE_DESTDIR=${STAGING_DIR}/initrd
include ${PACKAGE_DIR}/musl/v0.9.13.mk
include ${PACKAGE_DIR}/dash/v0.5.12.mk
include ${PACKAGE_DIR}/sbase/v0.1.mk
include ${PACKAGE_DIR}/ubase/v0.1.mk

all-initrd: \
	all-toolchain \
	install-target-musl \
	install-target-dash \
	install-target-sbase \
	install-target-ubase
	( cd ${STAGING_DIR}/initrd && find . | cpio -o -H newc -R root:root | gzip -9 ) > ${STAGING_DIR}/initrd.gz
	@printf '[initrd %s] %s\n' $@ "Done at `date +'%F, %X'`"
