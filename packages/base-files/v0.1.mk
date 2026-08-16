## TBD -- "Tiny By Design" base-files package

ifeq ($(filter base-files,${ALL_PACKAGES}),)
TARGET_BASE_FILES_VERSION=0.1
TARGET_BASE_FILES_SRC_TREE=${STAGING_DIR}/build-base-files-${TARGET_BASE_FILES_VERSION}


${TARGET_BASE_FILES_SRC_TREE}: ; @mkdir -p $@


.PHONY: build-target-base-files

${TARGET_BASE_FILES_SRC_TREE}/fstab: \
		| ${TARGET_BASE_FILES_SRC_TREE}
	printf '%s\n' \
		'rootfs / rootfs rw 0 0' \
		'devtmpfs /dev devtmpfs rw,relatime,size=508816k,nr_inodes=127204,mode=755 0 0' \
		> $@

${TARGET_BASE_FILES_SRC_TREE}/passwd: \
		| ${TARGET_BASE_FILES_SRC_TREE}
	printf '%s\n' \
		'root::0:0:root:/root:/bin/sh' \
		> $@

${TARGET_BASE_FILES_SRC_TREE}/group: \
		| ${TARGET_BASE_FILES_SRC_TREE}
	printf '%s\n' \
		'root:x:0:' \
		> $@

${TARGET_BASE_FILES_SRC_TREE}/rcS: \
		| ${TARGET_BASE_FILES_SRC_TREE}
	printf '%s\n' \
		'#!/bin/sh' \
		'mount -t proc proc /proc' \
		'mount -t sysfs sysfs /sys' \
		> $@


${TARGET_BASE_FILES_SRC_TREE}/resolv.conf: \
		| ${TARGET_BASE_FILES_SRC_TREE}
	printf '%s\n' \
		'nameserver 8.8.4.4' \
		'nameserver 8.8.8.8' \
		> $@


build-target-base-files: \
		${TARGET_BASE_FILES_SRC_TREE}/fstab \
		${TARGET_BASE_FILES_SRC_TREE}/passwd \
		${TARGET_BASE_FILES_SRC_TREE}/group \
		${TARGET_BASE_FILES_SRC_TREE}/rcS \
		${TARGET_BASE_FILES_SRC_TREE}/resolv.conf


.PHONY: install-target-base-files

install-target-base-files: build-target-base-files
	[ -r ${PACKAGE_DESTDIR}/etc/resolv.conf ] || {\
		printf '[%s] %s\n' $@ 'Install...' &&\
		cd ${TARGET_BASE_FILES_SRC_TREE} && \
		mkdir ${PACKAGE_DESTDIR}/dev &&\
		mkdir ${PACKAGE_DESTDIR}/etc ${PACKAGE_DESTDIR}/etc/init.d &&\
		mkdir ${PACKAGE_DESTDIR}/proc ${PACKAGE_DESTDIR}/sys &&\
		cp fstab passwd group resolv.conf ${PACKAGE_DESTDIR}/etc/ &&\
		cp rcS ${PACKAGE_DESTDIR}/etc/init.d/ &&\
		chmod a+x ${PACKAGE_DESTDIR}/etc/init.d/rcS ;\
	}
ALL_PACKAGES+=base-files
endif
