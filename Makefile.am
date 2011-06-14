SUBDIRS = . plugins

ACLOCAL_AMFLAGS = -I m4
AM_CPPFLAGS = $(FOOBOT_CFLAGS)

DEFS += -DPLUGINDIR=\"$(plugindir)\"

bin_PROGRAMS = foobot

foobot_SOURCES = src/main.vala \
		 src/bot.vala \
		 src/foodb.vala \
		 src/plugins.vala \
		 src/user.vala \
		 src/settings.vala \
		 plugins/plugin-interface.vala

foobot_LDADD = $(FOOBOT_LIBS)
