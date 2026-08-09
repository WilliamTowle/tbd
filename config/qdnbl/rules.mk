## TBD -- "Tiny By Design" rules configuration


include ${CONFIG_DIR}/toolchain.mk
include ${CONFIG_DIR}/rootfs.mk
include ${CONFIG_DIR}/bootfiles.mk


##

${DOWNLOAD_DIR}: ; @mkdir -p $@
${STAGING_DIR}: ; @mkdir -p $@

${TARGET_PACKAGES_DIR}: ; @mkdir -p $@
${TARGET_STAGING_DIR}: ; @mkdir -p $@

##

.PHONY: all

all: $(patsubst %,all-%,${ALL_COMPONENTS})
	@printf '[%s] %s\n' $(firstword ${MAKEFILE_LIST}) "Done at `date +'%F, %X'`"

#

.PHONY: clean distclean

clean::
	@printf '[%s] %s\n' $(firstword ${MAKEFILE_LIST}) "Done at `date +'%F, %X'`"

distclean:: clean
	@printf '[%s] %s\n' $(firstword ${MAKEFILE_LIST}) "Done at `date +'%F, %X'`"
