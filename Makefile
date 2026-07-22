#!/usr/bin/make

## TBD -- "Tiny By Design"


## Configuration

.PHONY: default
default: help


export TOPLEV=${CURDIR}
CONFIG_DIR?=${TOPLEV}/config


##

HAVE_SETTINGS:=$(shell if [ -r "${CONFIG_DIR}/settings.mk" ] ; then echo y ; else echo n ; fi)
-include ${CONFIG_DIR}/settings.mk
-include ${CONFIG_DIR}/rules.mk


# Build rules

.PHONY: config-sanity
config-sanity:
	@[ ${HAVE_SETTINGS} = 'y' ] || echo "WARNING: Suitable CONFIG_DIR= (directory containing settings.mk) has not been provided" 1>&2


help:
	@printf '%s\n' \
		'Configuration status:' \
		"	CONFIG_DIR: ${CONFIG_DIR}" \
		"	HAVE_SETTINGS: $(if $(filter y,${HAVE_SETTINGS}),y,[settings.mk not found])" \
		"	ALL_COMPONENTS: $(if ${ALL_COMPONENTS},${ALL_COMPONENTS},[list is empty])" \
		''
ifneq (${HAVE_SETTINGS}$(if ${ALL_COMPONENTS},y,),yy)
	@${MAKE} --quiet config-sanity
endif


.PHONY: clean distclean

clean:: config-sanity

distclean:: config-sanity clean
