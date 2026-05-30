## TBD -- "Tiny By Design" toolchain component


# packages

-include ${CONFIG_DIR}/functions.mk

include ${PACKAGE_DIR}/cross-binutils/v2.21.1-qdnbl.mk
include ${PACKAGE_DIR}/cross-gcc/v4.3.6-qdnbl.mk
include ${PACKAGE_DIR}/linux/v3.4.113-qdnbl.mk
include ${PACKAGE_DIR}/uClibc/v0.9.33.2-qdnbl.mk

#

${TOOLCHAIN_DIR}: ; @mkdir -p $@


.PHONY: all-toolchain

all-toolchain: \
	install-toolchain-cross-binutils \
	install-toolchain-cross-kgcc \
	install-toolchain-lxheaders \
	install-cross-uclibc-startfiles \
	install-cross-libgcc \
	install-cross-uclibc-libc \
	install-cross-gcc
	@printf '[toolchain %s] %s\n' $@ "Done at `date +'%F, %X'`"

#

.PHONY: clean-toolchain

clean-toolchain:
	-rm -rf ${TOOLCHAIN_DIR}


.PHONY: distclean-toolchain

distclean-toolchain: clean-toolchain


clean:: clean-toolchain

distclean:: distclean-toolchain
