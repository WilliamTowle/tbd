## TBD -- "Tiny By Design" toolchain component

TOOLCHAIN_PACKAGES=

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
