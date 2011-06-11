#!/bin/sh

set -x
libtoolize --copy || exit -1
aclocal || exit -1
autoconf || exit -1
autoheader || exit -1
automake --add-missing --copy || exit -1

if [ -z "${NOCONFIGURE}" ]; then
	./configure "$@"
fi
