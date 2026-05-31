## TBD -- "Tiny By Design" toolchain component

# packages

-include ${CONFIG_DIR}/functions.mk

include ${PACKAGE_DIR}/cross-binutils/v2.21.1-qdnbl.mk
include ${PACKAGE_DIR}/cross-gcc/v4.4.7-qdnbl.mk
include ${PACKAGE_DIR}/glibc/v2.14-qdglibc.mk
include ${PACKAGE_DIR}/linux/v3.4.113-qdnbl.mk

#

${TOOLCHAIN_DIR}: ; @mkdir -p $@


.PHONY: all-toolchain

all-toolchain: \
	install-toolchain-cross-binutils \
	install-toolchain-cross-kgcc \
	install-toolchain-lxheaders \
	install-cross-glibc-startfiles \
	install-cross-libgcc \
	install-cross-glibc-libc \
	install-cross-gcc
	@printf '[toolchain %s] %s\n' $@ "Done at `date +'%F, %X'`"


#

.PHONY: clean-toolchain distclean-toolchain

clean-toolchain:
	-rm -rf ${TOOLCHAIN_DIR}

distclean-toolchain:


clean:: clean-toolchain

distclean:: distclean-toolchain
