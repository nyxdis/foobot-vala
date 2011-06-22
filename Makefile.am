SUBDIRS = . plugins
ACLOCAL_AMFLAGS = -I m4

foobotincludedir = $(includedir)
foobotinclude_HEADERS = include/foobot.h

AM_CPPFLAGS = $(FOOBOT_CFLAGS) \
	      -I$(top_srcdir)/include

VALAFLAGS=--pkg gio-2.0 \
	  --pkg gmodule-2.0 \
	  --pkg sqlite3 \
	  --pkg config \
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
		 src/plugin-interface.vala \
		 src/plugins.vala \
		 src/settings.vala \
		 src/user.vala

foobot_LDADD = $(FOOBOT_LIBS)
