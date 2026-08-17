## TBD -- "Tiny By Design" toolchain component

include ${PACKAGE_DIR}/cross-binutils/v2.21.1-qdnbl.mk
include ${PACKAGE_DIR}/cross-gcc/v4.4.7-qdnbl.mk
include ${PACKAGE_DIR}/glibc/v2.14-qdglibc.mk
include ${PACKAGE_DIR}/linux/v3.18.109-qdnbl.mk

TOOLCHAIN_PACKAGES= \
		toolchain-cross-binutils \
		toolchain-cross-kgcc \
		toolchain-lxheaders \
		cross-glibc-startfiles \
		cross-libgcc \
		cross-glibc-libc \
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
