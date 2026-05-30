## TBD -- "Tiny By Design" initrd component


# packages

-include ${CONFIG_DIR}/functions.mk

include ${PACKAGE_DIR}/musl/v0.9.15.mk
include ${PACKAGE_DIR}/dash/v0.5.12.mk
include ${PACKAGE_DIR}/sbase/v0.1.mk
include ${PACKAGE_DIR}/ubase/v0.1.mk


#

INITRD_STAGING_DIR=${STAGING_DIR}/initrd
INITRD_MEDIA_TYPE=cpio
INITRD_PACKAGES=musl dash sbase ubase


${INITRD_STAGING_DIR}: ; mkdir -p $@


.PHONY: all-initrd


.PHONY: prepare-initrd-staging

prepare-initrd-staging: \
		all-toolchain \
		$(patsubst %,build-target-%,${INITRD_PACKAGES}) \
		| ${STAGING_DIR}


.PHONY: install-initrd-cpio

install-initrd-cpio: PACKAGE_DESTDIR=${INITRD_STAGING_DIR}

install-initrd-cpio: \
		prepare-initrd-staging \
		$(patsubst %,install-target-%,${INITRD_PACKAGES}) \
		| ${INITRD_STAGING_DIR}
	( cd ${INITRD_STAGING_DIR} && find . | cpio -o -H newc -R root:root | gzip -9 ) > ${INITRD_STAGING_DIR}.gz


.PHONY: install-initrd-squashfs

install-initrd-squashfs: PACKAGE_DESTDIR=${INITRD_STAGING_DIR}

install-initrd-squashfs: \
		prepare-initrd-staging \
		$(patsubst %,install-target-%,${INITRD_PACKAGES}) \
		| ${INITRD_STAGING_DIR}
	( cd ${INITRD_STAGING_DIR} && /usr/bin/mksquashfs . ${INITRD_STAGING_DIR}.squashfs -noappend -all-root -nopad )


all-initrd: install-initrd-${INITRD_MEDIA_TYPE}
	@printf '[initrd %s] %s\n' $@ "Done at `date +'%F, %X'`"

#

.PHONY: clean-initrd distclean-initrd

clean-initrd:
	-rm -f ${INITRD_STAGING_DIR}.gz ${INITRD_STAGING_DIR}.squashfs
	-rm -rf ${INITRD_STAGING_DIR}

distclean-initrd: clean-initrd


clean:: clean-initrd

distclean:: distclean-initrd
