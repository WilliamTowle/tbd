# TBD -- "Tiny By Design" package common build rules


${DOWNLOAD_DIR}: ; @mkdir -p $@

${STAGING_DIR}: ; @mkdir -p $@

${TOOLCHAIN_DIR}: ; @mkdir -p $@


##

.PHONY: all $(patsubst %,all-%,${ALL_COMPONENTS})

$(patsubst %,all-%,${ALL_COMPONENTS}): all-%:
	make -f ${CONFIG_DIR}/$*.mk $@

all: $(patsubst %,all-%,${ALL_COMPONENTS})

#

.PHONY: clean distclean

clean::
	-rm -rf ${TOOLCHAIN_DIR}
	-rm -rf ${STAGING_DIR}


distclean:: clean
	-rm -rf ${DOWNLOAD_DIR}
