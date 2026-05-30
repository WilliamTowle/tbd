## TBD -- "Tiny By Design" rules configuration

include ${CONFIG_DIR}/toolchain.mk
include ${CONFIG_DIR}/rootfs.mk


##

${DOWNLOAD_DIR}: ; @mkdir -p $@
${STAGING_DIR}: ; @mkdir -p $@

##

all: $(patsubst %,all-%,${ALL_COMPONENTS})
	@printf '[%s] %s\n' $(firstword ${MAKEFILE_LIST}) "Done at `date +'%F, %X'`"


.PHONY: clean distclean

clean::
	@printf '[%s] %s\n' $(firstword ${MAKEFILE_LIST}) "Done at `date +'%F, %X'`"

distclean:: clean
	@printf '[%s] %s\n' $(firstword ${MAKEFILE_LIST}) "Done at `date +'%F, %X'`"
