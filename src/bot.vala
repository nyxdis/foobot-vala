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

	public bool irc_connect()
	{
		this.log("Connecting");

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
			this.istream = new DataInputStream(conn.input_stream);
			this.ostream = new
				DataOutputStream(conn.output_stream);

			// Send user/nick
			this.send(@"USER $(Settings.username) +i * "
					+ @":$(Settings.realname)");
			this.send(@"NICK $(Settings.nick)");

			// Read response
			for (;;) {
				var line = this.read();
				if (@"001 $(Settings.nick) :" in line) {
					this.log("Connected");
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
		this.join("#foobot");
	}

	public void join(string channel, string key = "")
	{
		this.send(@"JOIN $channel :$key");
		this.send(@"WHO $channel");
	}

	public void send(string raw)
	{
		try {
			this.ostream.put_string(@"$raw\n");
		} catch (Error e) {
			stderr.printf("%s\n", e.message);
		}
	}

	private void log(string msg)
	{
		print("log: %s\n", msg);
	}

	private string read()
	{
		string retval = "";

		try {
			retval = istream.read_line(null).strip();
		} catch (Error e) {
			stderr.printf("%s\n", e.message);
		}

		return retval;
	}
}
