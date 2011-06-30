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
	private DataInputStream istream;
	private DataOutputStream ostream;

	public class IRC : Object
	{
		// emitted when a user or the bot joins a channel
		public signal void joined(string channel, string nick);

		internal IRC() {}

		// emitted when someone says something
		public signal void said(string channel, string nick, string text);

		public void join(string channel, string key = "")
		{
			send(@"JOIN $channel :$key");
			send(@"WHO $channel");
		}

		public void send(string raw)
		{
			try {
				ostream.put_string(@"$raw\n");
			} catch (Error e) {
				stderr.printf("%s\n", e.message);
			}
		}

		public void say(string target, string text)
		{
			// TODO line wrapping
			send(@"PRIVMSG $target :$text");
		}
	}
}
