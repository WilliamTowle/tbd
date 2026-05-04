# TBD -- "Tiny By Design" package common build rules

include ${CONFIG_DIR}/toolchain.mk
include ${CONFIG_DIR}/rootfs.mk


#

${DOWNLOAD_DIR}: ; @mkdir -p $@

${STAGING_DIR}: ; @mkdir -p $@


##

.PHONY: all

all: $(patsubst %,all-%,${ALL_COMPONENTS})

# clean/distclean
#
# Common cleaning here - component-specific rules may also apply

clean::
	-rm -rf ${STAGING_DIR}


distclean:: clean
	-rm -rf ${DOWNLOAD_DIR}
