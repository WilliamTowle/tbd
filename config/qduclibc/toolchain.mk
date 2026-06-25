## TBD -- "Tiny By Design" toolchain component


# packages

-include ${CONFIG_DIR}/functions.mk

include ${PACKAGE_DIR}/cross-binutils/v2.21.1-qdsp.mk
include ${PACKAGE_DIR}/cross-gcc/v4.3.6-qdsp.mk
include ${PACKAGE_DIR}/linux/v3.4.113.mk
include ${PACKAGE_DIR}/uClibc-ng/v1.0.0.mk

#

${TOOLCHAIN_DIR}: ; @mkdir -p $@


.PHONY: all-toolchain

all-toolchain: \
	install-toolchain-cross-binutils \
	install-toolchain-lxheaders \
	install-cross-gcc \
	install-cross-uclibc
	@printf '[toolchain %s] %s\n' $@ "Done at `date +'%F, %X'`"

#

.PHONY: clean-toolchain distclean-toolchain

clean-toolchain:
	-rm -rf ${TOOLCHAIN_DIR}

distclean-toolchain:


clean:: clean-toolchain

distclean:: distclean-toolchain
