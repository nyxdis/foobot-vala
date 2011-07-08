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
			// db lookup
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
