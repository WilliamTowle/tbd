## TBD -- "Tiny By Design" toolchain component

include ${CONFIG_DIR}/settings.mk
-include ${CONFIG_DIR}/functions.mk
-include ${CONFIG_DIR}/rules.mk

PACKAGE_DESTINATION_RULES=toolchain

all-toolchain:
	@printf '[toolchain %s] %s\n' $@ 'No package targets defined'
	@printf '[toolchain %s] %s\n' $@ "Done at `date +'%F, %X'`"

clean-toolchain:
	-rm -rf ${TOOLCHAIN_DIR}

distclean-toolchain:
