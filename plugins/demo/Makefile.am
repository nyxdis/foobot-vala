plugin_LTLIBRARIES = demo.la

demo_la_VALAFLAGS = --vapidir=$(top_srcdir)/vapi
demo_la_SOURCES = demo.vala ../plugin-interface.vala
demo_la_LIBADD = $(FOOBOT_LIBS)
demo_la_CFLAGS = $(FOOBOT_CFLAGS)
demo_la_LDFLAGS = -module -avoid-version
