AC_INIT([foobot], [0.1.0], [mende.christoph@gmail.com], [foobot])
AC_CONFIG_SRCDIR([Makefile.am])
AC_CONFIG_HEADERS(config.h)
AC_CONFIG_MACRO_DIR([m4])
AM_INIT_AUTOMAKE([dist-bzip2 foreign])
AM_MAINTAINER_MODE

AC_PROG_CC
AC_PROG_LIBTOOL

AC_PATH_PROG(VALAC, valac, valac)
AC_SUBST(VALAC)

AC_SUBST([plugindir], [${libdir}/foobot])

GLIB_REQUIRED=2.12.0

PKG_PROG_PKG_CONFIG([0.24])
PKG_CHECK_MODULES(FOOBOT, glib-2.0 >= $GLIB_REQUIRED
		  gmodule-2.0 >= $GLIB_REQUIRED
		  gobject-2.0 >= $GLIB_REQUIRED
		  gio-2.0 >= $GLIB_REQUIRED
		  sqlite3)

VALAFLAGS="--pkg gio-2.0 \
	--pkg gmodule-2.0 \
	--pkg sqlite3 \
	--pkg config \
	--vapidir vapi"
AC_SUBST(VALAFLAGS)

AC_CONFIG_FILES([Makefile plugins/Makefile
		 plugins/demo/Makefile])
AC_OUTPUT
