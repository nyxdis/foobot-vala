/*
 * foobot - IRC bot
 *
 * Copyright (c) 2011, Christoph Mende <mende.christoph@gmail.com>
 * All rights reserved. Released under the 2-clause BSD license.
 */


using GLib;

namespace Foobot
{
	/**
	 * User specific data
	 */
	public class User : Object
	{
		/**
		 * Internal user id
		 */
		public int id { get; private set; }

		/**
		 * Username
		 */
		public string name { get; private set; }

		/**
		 * Access level
		 */
		public int level { get; private set; }

		/**
		 * Current IRC nick
		 */
		public string nick { get; private set; }

		/**
		 * Current IRC ident
		 */
		public string ident { get; private set; }

		/**
		 * Current IRC host
		 */
		public string host { get; private set; }

		/**
		 * The user's title
		 */
		public string title { get; private set; }

		private HashTable<string,string> userdata;

		/**
		 * Create a new user object
		 *
		 * @param nick current nick on IRC
		 * @param ident current ident on IRC
		 * @param host current host on IRC
		 */
		public User(string nick, string ident, string host)
		{
			this.nick = nick;
			this.ident = ident;
			this.host = host;

			try {
				var r = db.prepare("SELECT id, " +
							  "username, " +
							  "ulvl, " +
							  "title, " +
							  "userdata " +
						   "FROM users " +
						   "WHERE id=(SELECT usrid " +
							     "FROM hosts " +
							     "WHERE :ident LIKE ident AND " +
								   ":host LIKE host)");
				r[":ident"] = ident;
				r[":host"] = host;
				var user = r.execute();

				id = user.fetch_int(user.field_index("id"));
				name = user.fetch_string(user.field_index("username"));
				level = user.fetch_int(user.field_index("ulvl"));
				title = user.fetch_string(user.field_index("title"));
				// TODO userdata
			} catch (Error e) {
				stderr.printf("%s\n", e.message);
			}
		}

		/**
		 * Retrieve plugin userdata
		 *
		 * Used to retrieve userdata set by plugins
		 *
		 * @param index property name
		 * @return property value
		 */
		public new string get(string index)
		{
			return userdata.lookup(index);
		}

		/**
		 * Set plugin userdata
		 *
		 * Used to set userdata from plugins
		 *
		 * @param index property name
		 * @param item porperty value
		 */
		public new void set(string index, string item)
		{
			userdata.insert(index, item);
		}
	}
}
