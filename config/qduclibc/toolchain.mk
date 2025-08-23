## TBD -- "Tiny By Design" toolchain component

include ${CONFIG_DIR}/settings.mk
-include ${CONFIG_DIR}/functions.mk
-include ${CONFIG_DIR}/rules.mk

PACKAGE_DESTINATION_RULES=toolchain

include ${PACKAGE_DIR}/cross-binutils/v2.21.1-qdsp.mk
include ${PACKAGE_DIR}/cross-gcc/v4.3.6-qdsp.mk
include ${PACKAGE_DIR}/linux/v3.4.113-nbl.mk

all-toolchain: \
	install-toolchain-cross-binutils \
	install-toolchain-lxheaders \
	install-cross-gcc
	@printf '[toolchain %s] %s\n' $@ "Done at `date +'%F, %X'`"

clean-toolchain:
	-rm -rf ${TOOLCHAIN_DIR}

distclean-toolchain:
