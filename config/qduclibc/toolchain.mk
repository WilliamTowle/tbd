## TBD -- "Tiny By Design" toolchain component


# packages

include ${PACKAGE_DIR}/cross-binutils/v2.21.1-qdsp.mk
include ${PACKAGE_DIR}/cross-gcc/v4.3.6-qdsp.mk
include ${PACKAGE_DIR}/linux/v3.4.113.mk
include ${PACKAGE_DIR}/uClibc-ng/v1.0.0.mk

TOOLCHAIN_PACKAGES= \
	toolchain-cross-binutils \
	toolchain-lxheaders \
	cross-gcc \
	cross-uclibc

ifneq (${TOOLCHAIN_PACKAGES},)
-include ${CONFIG_DIR}/functions.mk
endif


#

${TOOLCHAIN_DIR}: ; @mkdir -p $@


.PHONY: all-toolchain

all-toolchain: \
	$(addprefix install-,${TOOLCHAIN_PACKAGES})
	@printf '[toolchain %s] %s\n' $@ "Done (built $(words ${TOOLCHAIN_PACKAGES})) at `date +'%F, %X'`"

#

.PHONY: clean-toolchain distclean-toolchain

clean-toolchain:
	-rm -rf ${TOOLCHAIN_DIR}

distclean-toolchain:


clean:: clean-toolchain

distclean:: distclean-toolchain
