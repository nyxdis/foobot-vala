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


class Bot : GLib.Object
{
	private DataInputStream istream;
	private DataOutputStream ostream;
	private HashTable<string,User> userlist;

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

		print(@"got line: $line\n");

		if (line.has_prefix("PING :"))
			send(@"PONG :$(line[6:line.length])");

		// Update userlist on JOIN, NICK and WHO events
		try {
			if (new Regex(@"^:[^ ]+ 352 $(Settings.nick) [^ ]+ (?<ident>[^ ]+) (?<host>[^ ]+) [^ ]+ (?<nick>[^ ]+) [^ ]+ :[0-9]+((?<realname>.+))?").match(line, 0, out match_info) ||
					new Regex("^:(?<nick>.+)!(?<ident>.+)@(?<host>.+) JOIN :(?<channel>[^ ]+)").match(line, 0, out match_info) ||
					new Regex("^:(?<oldnick>[^ ]+)!(?<ident>[^ ]+)@(?<host>[^ ]+) NICK :(?<nick>[^ ]+)").match(line, 0, out match_info)) {
				// put user in userlist
				// check realname (WHO)
				// check oldnick (NICK)
				// check channel (JOIN)
			}
		} catch (Error e) {
			warning("%s\n", e.message);
		}

		// Parse PRIVMSG
		try {
			if (new Regex(":(?<nick>[^ ]+)!(?<ident>[^ ]+)@(?<host>[^ ]+) PRIVMSG (?<target>[^ ]+) :(?<text>.+)").match(line, 0, out match_info)) {

			}
		} catch (Error e) {
			warning("%s\n", e.message);
		}
	}
}
