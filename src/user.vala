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

			var sub = new SqlBuilder(SqlStatementType.SELECT);
			sub.select_add_target("hosts", null);
			sub.add_field_value_id(sub.add_id("usrid"), 0);
			var ident_cond = sub.add_cond(SqlOperatorType.LIKE, sub.add_expr(null, typeof(string), ident), sub.add_id("ident"), 0);
			var host_cond = sub.add_cond(SqlOperatorType.LIKE, sub.add_expr(null, typeof(string), host), sub.add_id("host"), 0);
			sub.set_where(sub.add_cond(SqlOperatorType.AND, ident_cond, host_cond, 0));

			var b = new SqlBuilder(SqlStatementType.SELECT);
			b.select_add_target("users", null);
			b.add_field_value_id(b.add_id("id"), 0);
			b.add_field_value_id(b.add_id("username"), 0);
			b.add_field_value_id(b.add_id("ulvl"), 0);
			b.add_field_value_id(b.add_id("title"), 0);
			//b.add_field_value_id(b.add_id("userdata"), 0);
			b.set_where(b.add_cond(SqlOperatorType.EQ, b.add_id("id"), b.add_sub_select(sub.get_sql_statement()), 0));

			var user = db.select_from_builder(b);
			if (user == null || user.get_n_rows() == 0)
				return;

			try {
				id = user.get_value_at(0, 0).get_int();
				name = user.get_value_at(1, 0).dup_string();
				level = user.get_value_at(2, 0).get_int();
				var title = user.get_value_at(3, 0);
				if (title.holds(typeof(string)))
					this.title = title.dup_string();
				else
					title.init(typeof(bool));
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
