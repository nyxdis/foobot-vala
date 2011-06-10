AM_CPPFLAGS = $(FOOBOT_CFLAGS)
VALAFLAGS = --pkg gio-2.0 \
	    --pkg sqlite3 \
	    --pkg config \
	    --vapidir vapi

DEFS += -DPLUGINSDIR=\"$(libdir)/foobot\"

bin_PROGRAMS = foobot

foobot_SOURCES = src/main.vala \
		 src/bot.vala \
		 src/foodb.vala \
		 src/user.vala \
		 src/settings.vala

foobot_LDADD = $(FOOBOT_LIBS)
