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
	 * Internal bot data
	 */
	public class Bot : Object
	{
		private HashTable<string,User> userlist;

		internal Bot()
		{
			userlist = new HashTable<string,User>(str_hash, str_equal);
			irc = new IRC();
		}

		internal bool irc_connect()
		{
			log("Connecting");

			try {
				// Resolve
				var resolver = Resolver.get_default();
				var addresses =	resolver.lookup_by_name(Settings.server);
				var address = addresses.nth_data(0);

				// Connect
				var client = new SocketClient();
				client.tls = Settings.ssl;
				client.tls_validation_flags = 0;

				var conn = client.connect (new
						InetSocketAddress(address,
							Settings.port));
				istream = new DataInputStream(conn.input_stream);
				ostream = new
					DataOutputStream(conn.output_stream);

				// Send user/nick
				irc.send(@"USER $(Settings.username) +i * "
						+ @":$(Settings.realname)");
				irc.send(@"NICK $(Settings.nick)");

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

		internal void irc_post_connect()
		{
			// TODO auth
			// TODO join debug channel
			// TODO join all channels
			irc.join("#foobot");
		}

		private void log(string msg)
		{
			print("log: %s\n", msg);
		}

		internal async void wait()
		{
			try {
				var line = yield istream.read_line_async();
				parse(line);
			} catch (Error e) {
				warning("%s\n", e.message);
			}
			wait();
		}

		internal void parse(string line)
		{
			MatchInfo match_info;

			if (line.has_prefix("PING :"))
				irc.send(@"PONG :$(line[6:line.length])");

			// Update userlist on JOIN, NICK and WHO events
			try {
				if (new Regex(@"^:[^ ]+ (?<cmd>352) $(Settings.nick) [^ ]+ (?<ident>[^ ]+) (?<host>[^ ]+) [^ ]+ (?<nick>[^ ]+) [^ ]+ :").match(line, 0, out match_info) ||
						new Regex("^:(?<nick>.+)!(?<ident>.+)@(?<host>.+) (?<cmd>JOIN) :(?<channel>[^ \r\n]+)").match(line, 0, out match_info) ||
						new Regex("^:(?<oldnick>[^ ]+)!(?<ident>[^ ]+)@(?<host>[^ ]+) (?<cmd>NICK) :(?<nick>[^ \r\n]+)").match(line, 0, out match_info)) {
					var nick = match_info.fetch_named("nick");
					var ident = match_info.fetch_named("ident");
					var host = match_info.fetch_named("host");
					var user = new User(nick, ident, host);

					userlist.insert(nick, user);

					if (match_info.fetch_named("cmd") == "NICK") {
						userlist.remove(match_info.fetch_named("oldnick"));
					} else if (match_info.fetch_named("cmd") == "JOIN") {
						irc.joined(match_info.fetch_named("channel"), user);
					}
				}
			} catch (Error e) {
				warning("%s\n", e.message);
			}

			// Parse PRIVMSG
			try {
				if (new Regex(":(?<nick>[^ ]+)!(?<ident>[^ ]+)@(?<host>[^ ]+) PRIVMSG (?<target>[^ ]+) :(?<text>.+)").match(line, 0, out match_info)) {
					var nick = match_info.fetch_named("nick");
					var user = userlist.lookup(nick);
					var target = match_info.fetch_named("target");
					var text = match_info.fetch_named("text");
					string channel;

					// Set channel to the origin's nick if the
					// PRIVMSG was sent directly to the bot
					if (target == Settings.nick)
						channel = nick;
					else
						channel = target;

					irc.said(channel, user, text);

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
							Plugins.run_command(channel, user, cmd, args);
							// TODO alias
							// TODO forward query
						}
					}
				}
			} catch (Error e) {
				warning("%s\n", e.message);
			}
		}

		/**
		 * Fetch an entry from the internal userlist
		 * @param nick name of the entry
		 * @return a #User object or null if there is no such entry
		 */
		public User? get_userlist(string nick)
		{
			return userlist.lookup(nick);
		}
	}
}
