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


using Config;
using GLib;

namespace Foobot
{
	public class Settings : Object
	{
		private static KeyFile config;

		public static string command_char { get; private set; }
		public static string nick { get; private set; }
		public static string username { get; private set; }
		public static string realname { get; private set; }
		public static string server { get; private set; }
		public static uint16 port { get; private set; }
		public static string network { get; private set; }
		public static string[] channels { get; private set; }
		public static string authpass { get; private set; }
		public static string authnick { get; private set; }
		public static string authserv { get; private set; }
		public static string authcmd { get; private set; }
		public static bool debug_mode { get; private set; }
		public static string debug_channel { get; private set; }
		public static string main_channel { get; private set; }
		public static string listen_addr { get; private set; }
		public static uint16 dcc_port { get; private set; }
		public static string[] plugin_blacklist { get; private set; }
		public static string version { get; private set; }

		internal Settings() {}

		internal static bool load(string? file)
		{
			config = new KeyFile();

			if (file == null)
				file = "foobot.conf";

			try {
				config.load_from_file(file, KeyFileFlags.NONE);
			} catch (Error e) {
				critical("Failed to load configuration file: %s\n", e.message);
				return false;
			}

			try {
				command_char = get_string_if_exists("command_char") ?? "!";
				nick = get_string_if_exists("nick") ?? "foobot";
				username = get_string_if_exists("username") ?? "foobot";
				realname = get_string_if_exists("realname") ?? "foobot";
				server = config.get_string("foobot", "server"); // mandatory
				network = get_string_if_exists("network") ?? "default";
				authpass = get_string_if_exists("authpass");
				authnick = get_string_if_exists("authnick");
				authserv = get_string_if_exists("authserv");
				authcmd = get_string_if_exists("authcmd");
				debug_channel = get_string_if_exists("debug_channel");
				main_channel = get_string_if_exists("main_channel");
				listen_addr = get_string_if_exists("listen_addr");

				if (config.has_key("foobot", "port"))
					port = (uint16) config.get_uint64("foobot", "port");
				else
					port = 6667;

				if (config.has_key("foobot", "dcc_port"))
					dcc_port = (uint16) config.get_uint64("foobot",
							"dcc_port");
				else
					dcc_port = 3333;

				if (config.has_key("foobot", "debug_mode"))
					debug_mode = config.get_boolean("foobot",
							"debug_mode");
				else
					debug_mode = false;

				// mandatory
				channels = config.get_string_list("foobot", "channels");

				if (config.has_key("foobot", "plugin_blacklist"))
					plugin_blacklist = config.get_string_list("foobot",
							"plugin_blacklist");
			} catch (Error e) {
				warning("%s\n", e.message);
				return false;
			}
			version = PACKAGE_VERSION;

			return true;
		}

		private static string? get_string_if_exists(string key)
		{
			try {
				if (config.has_key("foobot", key)) {
					return config.get_string("foobot", key);
				}
			} catch (Error e) {
				warning("%s\n", e.message);
			}
			return null;
		}
	}
}
