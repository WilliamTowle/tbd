## TBD -- "Tiny By Design" musl package

## glibc -- www.gnu.org

ifeq ($(filter glibc,${ALL_PACKAGES}),)
COMMON_GLIBC_VERSION=2.14
COMMON_GLIBC_SRC_TARBALL=${DOWNLOAD_DIR}/g/glibc-${COMMON_GLIBC_VERSION}.tar.bz2
COMMON_GLIBC_SRC_CHECKSUM= $(strip \
	$(if $(filter 2.7,${COMMON_GLIBC_VERSION}),065c5952b439deba40083ccd67bcc8f7,) \
	$(if $(filter 2.14,${COMMON_GLIBC_VERSION}),1588cc22e796c296223744895ebc4cef,) \
	)
COMMON_GLIBC_SRC_URL=https://ftp.gnu.org/gnu/glibc/$(notdir ${COMMON_GLIBC_SRC_TARBALL})
COMMON_GLIBC_SRC_TREE=${STAGING_DIR}/common-glibc-${COMMON_GLIBC_VERSION}


.PHONY: prepare-common-glibc

prepare-common-glibc: | ${DOWNLOAD_DIR} ${STAGING_DIR}
ifneq (${COMMON_GLIBC_VERSION},)
	$(call download_file,$(COMMON_GLIBC_SRC_TARBALL),$(COMMON_GLIBC_SRC_URL),$(COMMON_GLIBC_SRC_CHECKSUM))
endif
	[ -r ${COMMON_GLIBC_SRC_TREE}/README ] || { \
		printf '[%s] %s\n' $@ 'Extract...' && \
		$(call extract_archive,$(COMMON_GLIBC_SRC_TREE),$(COMMON_GLIBC_SRC_TARBALL)) ;\
		cd ${COMMON_GLIBC_SRC_TREE} && \
		case ${TARGET_CPU} in \
		i386) \
			printf '%s: %s\n' $(firstword ${MAKEFILE_LIST}) "Cannot configure for TARGET_CPU=${TARGET_CPU} - NPTL needs i486+" 1>&2 &&\
			exit 1 ;;\
		i[4-6]86) \
			printf '%s\n' 'CFLAGS += -march=i486' \
				> configparms ;;\
		esac &&\
		case ${COMMON_GLIBC_VERSION} in \
		2.7) \
			[ -r configure.OLD ] || mv configure configure.OLD ;\
			cat configure.OLD \
				| sed '/3.79\*/ s/)$$/ | 4.3)/' \
				| sed '/2.1\[/ s/)$$/ | 2.21*)/' \
				> configure ;\
			chmod a+x configure ;;\
		2.14) \
			[ -r configure.OLD ] || mv configure configure.OLD ;\
			cat configure.OLD \
				| sed '/3.79\*/ s/)$$/ | 4.3)/' \
				> configure ;\
			chmod a+x configure ;\
			[ -r sysdeps/i386/configure.OLD ] || mv sysdeps/i386/configure sysdeps/i386/configure.OLD ;\
			cat sysdeps/i386/configure.OLD \
				| sed '/"cpuid.h"/ { s/header_mongrel/header_compile/ ; s/ "[^"]*"$$// }' \
				> sysdeps/i386/configure ;;\
		esac ;\
	}


.PHONY: build-cross-glibc-startfiles

build-cross-glibc-startfiles: prepare-common-glibc
	@printf '%s %s: %s\n' $(lastword ${MAKEFILE_LIST}) $@ "Reached at `date +'%X, %F'`"
	mkdir -p ${COMMON_GLIBC_SRC_TREE}/$@
	[ -r ${COMMON_GLIBC_SRC_TREE}/$@/config.status ] || { \
		printf '[%s] %s\n' $@ 'Configure...' && \
		cd ${COMMON_GLIBC_SRC_TREE}/$@ && \
		CC=${TARGET_CPU}-${TARGET_VENDOR}-linux-none-gcc \
		  AS=${TARGET_CPU}-${TARGET_VENDOR}-linux-none-as \
		  LD=${TARGET_CPU}-${TARGET_VENDOR}-linux-none-ld \
		  libc_cv_forced_unwind=yes \
		  libc_cv_c_cleanup=yes \
			../configure \
			  --prefix=/ \
			  --includedir=/usr/include \
			  --build=${HOST_TRIPLET} --host=${TARGET_TRIPLET} \
			  --target=${TARGET_TRIPLET} \
			  --with-headers=${TOOLCHAIN_DIR}/usr/include \
			  --with-pkgversion='tbd' --enable-kernel=3.2.4 \
			  --disable-profile --enable-add-ons ;\
	}
	[ -r ${COMMON_GLIBC_SRC_TREE}/$@/csu/crtn.o ] || { \
		printf '[%s] %s\n' $@ 'Build...' && \
		cd ${COMMON_GLIBC_SRC_TREE}/$@ && \
		make csu/subdir_lib ;\
	}


.PHONY: install-cross-glibc-startfiles

install-cross-glibc-startfiles: build-cross-glibc-startfiles
	[ -r ${TOOLCHAIN_DIR}/lib/libc.so ] || { \
		printf '[%s] %s\n' $@ 'Install...' && \
		cd ${COMMON_GLIBC_SRC_TREE}/$(patsubst install-%,build-%,$@) && \
		make cross-compiling=yes install-bootstrap-headers=yes install-headers install_root=${TOOLCHAIN_DIR} && \
		install -D bits/stdio_lim.h ${TOOLCHAIN_DIR}/usr/include/bits/stdio_lim.h && \
		install -D ../include/gnu/stubs.h ${TOOLCHAIN_DIR}/usr/include/gnu/stubs.h && \
		install csu/crt1.o csu/crti.o csu/crtn.o ${TOOLCHAIN_DIR}/lib && \
		${TARGET_CPU}-${TARGET_VENDOR}-linux-none-gcc -nostdlib -nostartfiles -shared -x c /dev/null -o ${TOOLCHAIN_DIR}/lib/libc.so ;\
	}


.PHONY: build-cross-glibc-libc

build-cross-glibc-libc: prepare-common-glibc
	@printf '%s %s: %s\n' $(lastword ${MAKEFILE_LIST}) $@ "Reached at `date +'%X, %F'`"
	mkdir -p ${COMMON_GLIBC_SRC_TREE}/$@
	[ -r ${COMMON_GLIBC_SRC_TREE}/$@/config.status ] || { \
		printf '[%s] %s\n' $@ 'Configure...' && \
		cd ${COMMON_GLIBC_SRC_TREE}/$@ && \
		CC=${TARGET_CPU}-${TARGET_VENDOR}-linux-none-gcc \
		  AS=${TARGET_CPU}-${TARGET_VENDOR}-linux-none-as \
		  LD=${TARGET_CPU}-${TARGET_VENDOR}-linux-none-ld \
		  libc_cv_forced_unwind=yes \
		  libc_cv_c_cleanup=yes \
		  libc_cv_slibdir=$(if $(filter i%86,${TARGET_CPU}),/lib,/lib64) \
			../configure \
			  --prefix=/ \
			  --includedir=/usr/include \
			  --build=${HOST_TRIPLET} --host=${TARGET_TRIPLET} \
			  --target=${TARGET_TRIPLET} \
			  --with-headers=${TOOLCHAIN_DIR}/usr/include \
			  --with-pkgversion='tbd' --enable-kernel=3.2.4 \
			  --disable-profile --enable-add-ons ;\
	}
	[ -r ${COMMON_GLIBC_SRC_TREE}/$@/csu/crtn.o ] || { \
		printf '[%s] %s\n' $@ 'Build...' && \
		cd ${COMMON_GLIBC_SRC_TREE}/$@ && \
		make ;\
	}


.PHONY: install-cross-glibc-libc

install-cross-glibc-libc: build-cross-glibc-libc
	[ -r ${TOOLCHAIN_DIR}/lib/libc-${COMMON_GLIBC_VERSION}.so ] || { \
		printf '[%s] %s\n' $@ 'Install...' && \
		cd ${COMMON_GLIBC_SRC_TREE}/$(patsubst install-%,build-%,$@) && \
		make install_root=${TOOLCHAIN_DIR} install ;\
	}


.PHONY: build-target-glibc

## [2025-07-03] 'build' empty - install copies sysroot's libs

build-target-glibc: prepare-common-glibc
	@printf '%s %s: %s\n' $(firstword ${MAKEFILE_LIST}) $@ "Reached at `date +'%X, %F'`"


.PHONY: install-target-glibc

install-target-glibc: build-target-glibc
	[ -r ${PACKAGE_DESTDIR}/$(if $(filter i%86,${TARGET_CPU}),/lib/ld-linux.so.2,/lib64/ld-linux-x86-64.so.2) ] || { \
		printf '[%s] %s\n' $@ 'Install...' && \
		case ${TARGET_CPU} in \
		i*86)\
			mkdir -p ${PACKAGE_DESTDIR}/lib/ &&\
			for TCLIB in \
				libc.so.* libm.so.* \
				; do \
					cp ${TOOLCHAIN_DIR}/lib/$${TCLIB} ${PACKAGE_DESTDIR}/lib/ ;\
				done && \
			for TCLIB in \
				ld*.so.* \
				; do \
					cp ${TOOLCHAIN_DIR}/lib/$${TCLIB} ${PACKAGE_DESTDIR}/lib/ ;\
				done ;;\
		x86_64)\
			mkdir -p ${PACKAGE_DESTDIR}/lib64/ &&\
			for TCLIB in \
				libc.so.* libm.so.* \
				; do \
					cp ${TOOLCHAIN_DIR}/lib64/$${TCLIB} ${PACKAGE_DESTDIR}/lib64/ ;\
				done && \
			for TCLIB in \
				ld*.so.* \
				; do \
					cp ${TOOLCHAIN_DIR}/lib64/$${TCLIB} ${PACKAGE_DESTDIR}/lib64/ ;\
				done ;;\
		esac ;\
		}
ALL_PACKAGES+=glibc
endif
