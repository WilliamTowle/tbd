## TBD -- "Tiny By Design" toolchain component

include ${PACKAGE_DIR}/cross-binutils/v2.21.1-qdnbl.mk
include ${PACKAGE_DIR}/cross-gcc/v4.3.6-qdnbl.mk
include ${PACKAGE_DIR}/linux/v3.18.109-qdnbl.mk
include ${PACKAGE_DIR}/uClibc/v0.9.33.2-qdnbl.mk

TOOLCHAIN_PACKAGES= \
		toolchain-cross-binutils \
		toolchain-cross-kgcc \
		toolchain-lxheaders \
		cross-uclibc-startfiles \
		cross-libgcc \
		cross-uclibc-libc \
		cross-gcc

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
