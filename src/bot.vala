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
	class Bot : Object
	{
		private DataInputStream istream;
		private DataOutputStream ostream;
		private HashTable<string,User> userlist;
		public User usr { get; private set; }

		// emitted when a user or the bot joins a channel
		public signal void joined(string channel, string nick);

		// emitted when someone says something
		public signal void said(string channel, string nick, string text);

		public Bot()
		{
			userlist = new HashTable<string,User>(str_hash, str_equal);
		}

		public bool irc_connect()
		{
			log("Connecting");

			try {
				// Resolve
				var resolver = Resolver.get_default();
				var addresses =	resolver.lookup_by_name(Settings.server);
				var address = addresses.nth_data(0);

				// Connect
				var client = new SocketClient();
				var conn = client.connect (new
						InetSocketAddress(address,
							Settings.port));
				istream = new DataInputStream(conn.input_stream);
				ostream = new
					DataOutputStream(conn.output_stream);

				// Send user/nick
				send(@"USER $(Settings.username) +i * "
						+ @":$(Settings.realname)");
				send(@"NICK $(Settings.nick)");

				// Read response
				for (;;) {
					var line = istream.read_line(null).strip();
					if (@"001 $(Settings.nick) :" in line) {
						log("Connected");
						return true;
					}
				}
			} catch (Error e) {
				stderr.printf("%s\n", e.message);
			}

			return false;
		}

		public void irc_post_connect()
		{
			// TODO auth
			// TODO join debug channel
			// TODO join all channels
			join("#foobot");
		}

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

		private void log(string msg)
		{
			print("log: %s\n", msg);
		}

		public async void wait()
		{
			try {
				var line = yield istream.read_line_async();
				parse(line);
			} catch (Error e) {
				warning("%s\n", e.message);
			}
			wait();
		}

		public void parse(string line)
		{
			MatchInfo match_info;

			if (line.has_prefix("PING :"))
				send(@"PONG :$(line[6:line.length])");

			// Update userlist on JOIN, NICK and WHO events
			try {
				if (new Regex(@"^:[^ ]+ (?<cmd>352) $(Settings.nick) [^ ]+ (?<ident>[^ ]+) (?<host>[^ ]+) [^ ]+ (?<nick>[^ ]+) [^ ]+ :").match(line, 0, out match_info) ||
						new Regex("^:(?<nick>.+)!(?<ident>.+)@(?<host>.+) (?<cmd>JOIN) :(?<channel>[^ ]+)").match(line, 0, out match_info) ||
						new Regex("^:(?<oldnick>[^ ]+)!(?<ident>[^ ]+)@(?<host>[^ ]+) (?<cmd>NICK) :(?<nick>[^ ]+)").match(line, 0, out match_info)) {
					var nick = match_info.fetch_named("nick");
					var ident = match_info.fetch_named("ident");
					var host = match_info.fetch_named("host");

					userlist.insert(nick, new User(nick, ident, host));

					if (match_info.fetch_named("cmd") == "NICK") {
						userlist.remove(match_info.fetch_named("oldnick"));
					} else if (match_info.fetch_named("cmd") == "JOIN") {
						joined(match_info.fetch_named("channel"), match_info.fetch_named("nick"));
					}
				}
			} catch (Error e) {
				warning("%s\n", e.message);
			}

			// Parse PRIVMSG
			try {
				if (new Regex(":(?<nick>[^ ]+)!(?<ident>[^ ]+)@(?<host>[^ ]+) PRIVMSG (?<target>[^ ]+) :(?<text>.+)").match(line, 0, out match_info)) {
					var nick = match_info.fetch_named("nick");
					usr = userlist.lookup(nick);
					var target = match_info.fetch_named("target");
					var text = match_info.fetch_named("text");
					string channel;

					// Set channel to the origin's nick if the
					// PRIVMSG was sent directly to the bot
					if (target == Settings.nick)
						channel = nick;
					else
						channel = target;

					said(channel, nick, text);

					if (text[0:Settings.command_char.length] == Settings.command_char ||
							channel == nick ||
							(text.length > Settings.nick.length + 2 &&
							 text[0:(Settings.nick.length + 2)] == @"$(Settings.nick): ")) {
						if (text.ascii_ncasecmp(@"$(Settings.nick): ", Settings.nick.length + 2) == 0)
							text = text.substring(Settings.nick.length + 2);

						if (text.ascii_ncasecmp(Settings.command_char, Settings.command_char.length) == 0)
							text = text.substring(Settings.command_char.length);

						if (text.length > 0) {
							var args = text.split(" ");
							var cmd = args[0];
							args = args[1:args.length];
							Plugins.run_command(channel, nick, cmd, args);
							// TODO alias
							// TODO forward query
						}
					}
				}
			} catch (Error e) {
				warning("%s\n", e.message);
			}
		}
	}
}
