#!/bin/sh

autoreconf -iv

if [ -z "${NOCONFIGURE}" ]; then
	./configure
fi
