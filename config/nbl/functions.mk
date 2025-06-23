# TBD -- "Tiny By Design" package build/configuration


define download_file
	mkdir -p $(dir $1) && \
	[ -s $1 ] || { wget --spider $2 && wget $2 -O $1 ; } && \
	export MD5SUM=`md5sum $1 | awk '{ print $$1 }'` && \
	if [ "$3" ] ; then \
		if [ "$3" != "$${MD5SUM}" ] ; then \
			printf '%s(): %s\n' $0 "SRC_CHECKSUM $3 does not match value $${MD5SUM}" && \
			false ;\
		fi ;\
	else \
		printf '%s(): %s\n' $0 "Configuration error - expected package md5sum unset, current file has $${MD5SUM}" && \
		false ;\
	fi
endef

define extract_archive
	mkdir -p $1 && \
	case $2 in \
	*.tar.bz2) \
		( cd $1 && tar xvjf $2 --strip-components=1 ) \
		;; \
	*.tar.gz|*.tgz) \
		( cd $1 && tar xvzf $2 --strip-components=1 ) \
		;; \
	*.tar.xz) \
		( cd $1 && tar xvJf $2 --strip-components=1 ) \
		;; \
	*) \
		printf '%s(): %s\n' $0 "No extract method for SRC_TARBALL=$2" 1>&2 ;\
		false \
		;; \
	esac
endef
