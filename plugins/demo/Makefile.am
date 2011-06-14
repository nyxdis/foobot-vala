plugin_LTLIBRARIES = libdemo.la

libdemo_la_VALAFLAGS = --vapidir=$(top_srcdir)/vapi
libdemo_la_SOURCES = demo.vala ../plugin-interface.vala
libdemo_la_LIBADD = $(FOOBOT_LIBS)
libdemo_la_CFLAGS = $(FOOBOT_CFLAGS)
libdemo_la_LDFLAGS = -module -avoid-version
