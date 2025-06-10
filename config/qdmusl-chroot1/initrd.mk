## TBD -- "Tiny By Design" initrd component

include ${CONFIG_DIR}/settings.mk
-include ${CONFIG_DIR}/functions.mk
-include ${CONFIG_DIR}/rules.mk

PACKAGE_DESTINATION_RULES=target
PACKAGE_DESTDIR=${STAGING_DIR}/initrd

all-initrd:
	@printf '[initrd %s] %s\n' $@ 'No package targets defined'
	@printf '[initrd %s] %s\n' $@ "Done at `date +'%F, %X'`"
