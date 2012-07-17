SUBDIRS = . plugins

foobotincludedir = $(includedir)
foobotinclude_HEADERS = include/foobot.h

AM_CPPFLAGS = $(FOOBOT_CFLAGS) \
	      -I$(top_srcdir)/include

VALAFLAGS=--pkg gio-2.0 \
	  --pkg gmodule-2.0 \
	  --pkg libpeas-1.0 \
	  --pkg sqlheavy-0.1 \
	  --pkg config \
	  --target-glib=2.32 \
	  --thread \
	  --vapidir $(top_srcdir)/vapi \
	  -H $(top_srcdir)/include/foobot.h \
	  --library=$(top_srcdir)/vapi/foobot \
	  --use-header

DEFS += -DPLUGINDIR=\"$(plugindir)\"

bin_PROGRAMS = foobot

foobot_SOURCES = src/main.vala \
		 src/bot.vala \
		 src/foodb.vala \
		 src/irc.vala \
		 src/plugins.vala \
		 src/settings.vala \
		 src/user.vala

foobot_LDADD = $(FOOBOT_LIBS)

include/foobot.h: foobot_vala.stamp
