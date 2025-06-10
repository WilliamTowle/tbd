## TBD -- "Tiny By Design" musl package

## musl libc -- https://musl.libc.org/

# ...v1.2.x is available
# ...v1.1 series ends with 1.1.24 (2019)
# ...v1.0 series ends with 1.0.5 (2015)
# ...v0.9 series ends with 0.9.15 (2014)
# ...v0.8 ("beta") series ends with 0.8.10 (2012)
# see musl-cross-make for patches addressing various CVEs
CROSS_MUSL_VERSION=0.9.13
#CROSS_MUSL_VERSION=1.0.5
#CROSS_MUSL_VERSION=1.1.24
CROSS_MUSL_SRC_TARBALL=${DOWNLOAD_DIR}/m/musl-${CROSS_MUSL_VERSION}.tar.gz
CROSS_MUSL_SRC_CHECKSUM=6af97d6157a2f4ee7a17af2316389fd7
#CROSS_MUSL_SRC_CHECKSUM=2c251431945047de8486e8ec1ab2ee17
#CROSS_MUSL_SRC_CHECKSUM=2ac378736ea749b073a3795abb095329
CROSS_MUSL_SRC_URL=https://musl.libc.org/releases/$(notdir ${CROSS_MUSL_SRC_TARBALL})

CROSS_MUSL_SRC_TREE=${STAGING_DIR}/cross-musl-${CROSS_MUSL_VERSION}


.PHONY: prepare-cross-musl

prepare-cross-musl: | ${DOWNLOAD_DIR} ${STAGING_DIR}
	$(call download_file,$(CROSS_MUSL_SRC_TARBALL),$(CROSS_MUSL_SRC_URL),$(CROSS_MUSL_SRC_CHECKSUM))
	[ -r ${CROSS_MUSL_SRC_TREE}/README ] || { \
		printf '[%s] %s\n' $@ 'Extract...' && \
		$(call extract_archive,$(CROSS_MUSL_SRC_TREE),$(CROSS_MUSL_SRC_TARBALL)) && \
		case ${CROSS_MUSL_VERSION} in \
		0.9.13) \
			cd ${CROSS_MUSL_SRC_TREE} && \
			[ -r Makefile.OLD ] || mv Makefile Makefile.OLD ;\
			cat Makefile.OLD \
				| sed '/__:.*libc.so$$/ s/: $$(DESTDIR)/: /' \
				| sed '/-D -l/ s%$$<%../lib/libc.so%' \
				> Makefile ;;\
		esac ;\
	}


ifeq (${PACKAGE_DESTINATION_RULES},toolchain)
.PHONY: build-toolchain-cross-musl

build-toolchain-cross-musl: prepare-cross-musl
	mkdir -p ${CROSS_MUSL_SRC_TREE}/$@
	mkdir -p ${CROSS_MUSL_SRC_TREE}/$@
	( cd ${CROSS_MUSL_SRC_TREE}/$@ && [ -r ./configure ] || ln -sf ../* ./ )
	[ -r ${CROSS_MUSL_SRC_TREE}/$@/config.mak ] || { \
		printf '[%s] %s\n' $@ 'Configure...' && \
		cd ${CROSS_MUSL_SRC_TREE}/$@ && \
		CROSS_COMPILE=${TARGET_TRIPLET}- \
			./configure --prefix=${TOOLCHAIN_DIR} \
				--target=${TARGET_TRIPLET} --build=${HOST_TRIPLET} \
				--syslibdir=${TOOLCHAIN_DIR}/lib --includedir=${TOOLCHAIN_DIR}/usr/include \
				--disable-gcc-wrapper ;\
		}
	[ -r ${CROSS_MUSL_SRC_TREE}/$@/lib/crt1.o ] || { \
		printf '[%s] %s\n' $@ 'Build...' && \
		cd ${CROSS_MUSL_SRC_TREE}/$@ && \
		make ;\
		}

.PHONY: install-toolchain-cross-musl

install-toolchain-cross-musl: build-toolchain-cross-musl
	[ -r ${TOOLCHAIN_DIR}/lib/libc.so ] || { \
		printf '[%s] %s\n' $@ 'Install...' && \
		cd ${CROSS_MUSL_SRC_TREE}/$(patsubst install-%,build-%,$@) && \
		make install && \
		mkdir -p ${TOOLCHAIN_DIR}/etc && \
		printf '%s\n' \
			'/lib:/usr/lib' \
			> ${TOOLCHAIN_DIR}/etc/ld-musl-${TARGET_CPU}.path && \
		ln -sf ${TOOLCHAIN_DIR}/lib/libc.so ${TOOLCHAIN_DIR}/lib/ld-musl-${TARGET_CPU}.so.1 ;\
		}
endif

ifeq (${PACKAGE_DESTINATION_RULES},target)
.PHONY: build-target-musl

build-target-musl: prepare-cross-musl
	mkdir -p ${CROSS_MUSL_SRC_TREE}/$@
	( cd ${CROSS_MUSL_SRC_TREE}/$@ && [ -r ./configure ] || ln -sf ../* ./ )
	[ -r ${CROSS_MUSL_SRC_TREE}/$@/config.mak ] || { \
		printf '[%s] %s\n' $@ 'Configure...' && \
		cd ${CROSS_MUSL_SRC_TREE}/$@ && \
		CROSS_COMPILE=${TARGET_TRIPLET}- \
		  ./configure --prefix=/ \
			--target=${TARGET_TRIPLET} \
			--syslibdir=/lib \
			--includedir=/usr/include \
			--disable-gcc-wrapper ;\
		}
	[ -r ${TARGET_ROOTFS}/lib/ld-musl-${TARGET_CPU}.so.1 ] || { \
		printf '[%s] %s\n' $@ 'Build...' && \
		cd ${CROSS_MUSL_SRC_TREE}/$@ && \
		make ;\
		}

.PHONY: install-target-musl

install-target-musl: build-target-musl
	[ -r ${PACKAGE_DESTDIR}/lib/ld-musl-${TARGET_CPU}.so.1 ] || { \
		printf '[%s] %s\n' $@ 'Install...' && \
		cd ${CROSS_MUSL_SRC_TREE}/$(patsubst install-%,build-%,$@) && \
		make install DESTDIR=${PACKAGE_DESTDIR} ;\
		}
endif
