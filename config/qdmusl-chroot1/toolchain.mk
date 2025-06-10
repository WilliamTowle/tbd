## TBD -- "Tiny By Design" toolchain component

include ${CONFIG_DIR}/settings.mk
-include ${CONFIG_DIR}/functions.mk
-include ${CONFIG_DIR}/rules.mk

PACKAGE_DESTINATION_RULES=toolchain

include ${PACKAGE_DIR}/linux/v3.4.113.mk
include ${PACKAGE_DIR}/cross-binutils/v2.23.2.mk

all-toolchain: \
	install-toolchain-lxheaders \
	install-toolchain-cross-binutils
	@printf '[toolchain %s] %s\n' $@ "Done at `date +'%F, %X'`"

distclean-toolchain:
