## TBD -- "Tiny By Design" toolchain component

include ${PACKAGE_DIR}/linux/v3.4.113.mk
include ${PACKAGE_DIR}/cross-binutils/v2.23.2.mk
include ${PACKAGE_DIR}/cross-gcc/v4.7.3.mk
include ${PACKAGE_DIR}/musl/v0.9.15.mk

TOOLCHAIN_PACKAGES= \
		toolchain-lxheaders \
		toolchain-cross-binutils \
		toolchain-cross-gcc \
		toolchain-cross-musl

ifneq (${TOOLCHAIN_PACKAGES},)
include ${CONFIG_DIR}/functions.mk
endif

#

${TOOLCHAIN_DIR}: ; @mkdir -p $@


##

.PHONY: clean-toolchain
clean-toolchain:
	-rm -rf ${TOOLCHAIN_DIR}

#

.PHONY: all-toolchain

all-toolchain: \
		$(addprefix install-,${TOOLCHAIN_PACKAGES}) \
		| ${TOOLCHAIN_DIR}
	@printf '[toolchain %s] %s\n' $@ "Done (built $(words ${TOOLCHAIN_PACKAGES})) at `date +'%F, %X'`"
