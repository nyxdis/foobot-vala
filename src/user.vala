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

class User : Object
{
	public int id { get; private set; }
	public string name { get; private set; }
	public int level { get; private set; }
	public string nick { get; private set; }
	public string ident { get; private set; }
	public string host { get; private set; }
	public string title { get; private set; }
	private HashTable<string,string> userdata;

	public User(string nick, string ident, string host)
	{
		// db lookup
	}

	public new string get(string index)
	{
		return userdata.lookup(index);
	}

	public new void set(string index, string item)
	{
		userdata.insert(index, item);
	}
}
