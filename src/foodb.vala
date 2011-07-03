/*
 * Copyright (C) 2011  Christoph Mende
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
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
