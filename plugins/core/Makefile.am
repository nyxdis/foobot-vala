plugin_LTLIBRARIES = libcore.la

libcore_la_VALAFLAGS = --pkg libgda-4.0
libcore_la_SOURCES = core.vala
libcore_la_LIBADD = $(FOOBOT_LIBS)
libcore_la_CFLAGS = $(FOOBOT_CFLAGS)
libcore_la_LDFLAGS = -module -avoid-version

include ../plugins.mk
