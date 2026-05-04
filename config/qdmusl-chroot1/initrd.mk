## TBD -- "Tiny By Design" initrd component


# packages

-include ${CONFIG_DIR}/functions.mk

include ${PACKAGE_DIR}/musl/v0.9.13.mk
include ${PACKAGE_DIR}/dash/v0.5.12.mk
include ${PACKAGE_DIR}/sbase/v0.1.mk
include ${PACKAGE_DIR}/ubase/v0.1.mk


#

PACKAGE_DESTDIR=${STAGING_DIR}/initrd


.PHONY: all-initrd

all-initrd: \
	all-toolchain \
	install-target-musl \
	install-target-dash \
	install-target-sbase \
	install-target-ubase
	( cd ${STAGING_DIR}/initrd && find . | cpio -o -H newc -R root:root | gzip -9 ) > ${STAGING_DIR}/initrd.gz
	@printf '[initrd %s] %s\n' $@ "Done at `date +'%F, %X'`"

#

.PHONY: clean-initrd distclean-initrd

clean-initrd:
	-rm -f ${STAGING_DIR}/initrd.gz
	-rm -rf ${STAGING_DIR}/initrd

distclean-initrd: clean-initrd


clean:: clean-initrd

distclean:: distclean-initrd
