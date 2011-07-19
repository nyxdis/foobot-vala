/*
 * foobot - IRC bot
 *
 * Copyright (c) 2011, Christoph Mende <mende.christoph@gmail.com>
 * All rights reserved. Released under the 2-clause BSD license.
 */


using GLib;
using Gda;

namespace Foobot
{
	public class Foodb : Object
	{
		private Connection db;

		internal Foodb()
		{
			Gda.init();

			try {
				db = Connection.open_from_string("SQLite", @"DB_DIR=.;DB_NAME=foobot-$(Settings.network)", null, ConnectionOptions.NONE);
			} catch (Error e) {
				stderr.printf("%s\n", e.message);
			}

			initialize();
		}

		private void initialize()
		{
			try {
				db.begin_transaction("init", TransactionIsolation.UNKNOWN);
				exec("CREATE TABLE IF NOT EXISTS users (id integer primary key, username varchar(25) unique, title varchar(25), ulvl integer, userdata varchar(150))");
				exec("CREATE TABLE IF NOT EXISTS hosts (usrid integer, ident varchar(10), host varchar(50))");
				exec("CREATE TABLE IF NOT EXISTS timed_events (id integer primary key, plugin varchar(25), function varchar(25), time int(11), args varchar(255))");
				exec("CREATE TABLE IF NOT EXISTS aliases (id integer primary key, alias varchar(50), function varchar(50), args varchar(250))");
				db.commit_transaction("init");
			} catch (Error e) {
				stderr.printf("%s\n", e.message);
			}
		}

		public int exec(string sql)
		{
			try {
				return execute_non_select_command(db, sql);
			} catch (Error e) {
				stderr.printf("%s\n", e.message);
				return -1;
			}
		}
	}
}
