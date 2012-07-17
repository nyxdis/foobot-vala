VALAFLAGS=--pkg foobot \
	  --pkg gmodule-2.0 \
	  --vapidir $(top_srcdir)/vapi

AM_CPPFLAGS = -I$(top_srcdir)/include
LIBADD = $(FOOBOT_LIBS)
CFLAGS += $(FOOBOT_CFLAGS)
LDFLAGS += -module -avoid-version
EXTRA_DIST = $(plugin_DATA)
