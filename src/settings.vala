/*
 * foobot - IRC bot
 *
 * Copyright (c) 2011, Christoph Mende <mende.christoph@gmail.com>
 * All rights reserved. Released under the 2-clause BSD license.
 */


using GLib;
using Config;

namespace Foobot
{
	/**
	 * Access to the bot's settings
	 */
	public class Settings : Object
	{
		private static KeyFile config;

		/**
		 * The command char used by the bot, ! by default
		 */
		public static string command_char { get; private set; }

		/**
		 * The bot's nickname, foobot by default
		 */
		public static string nick { get; private set; }

		/**
		 * The bot's username, foobot by default
		 */
		public static string username { get; private set; }

		/**
		 * The bot's realname, foobot by default
		 **/
		public static string realname { get; private set; }

		/**
		 * The IRC server, mandatory setting
		 */
		public static string server { get; private set; }

		/**
		 * The IRC port, 6667 by default
		 */
		public static uint16 port { get; private set; }

		/**
		 * The name of the IRC network, default by default
		 */
		public static string network { get; private set; }

		/**
		 * The channels the bot autojoins
		 */
		public static string[] channels { get; private set; }

		/**
		 * Password used for authentication
		 **/
		public static string authpass { get; private set; }

		/**
		 * Nickname used for authentication
		 **/
		public static string authnick { get; private set; }

		/**
		 * Service to authenticate against, NickServ by default
		 */
		public static string authserv { get; private set; }

		/**
		 * Command used for authentication, identify by default
		 */
		public static string authcmd { get; private set; }

		/**
		 * Enable debugging
		 */
		public static bool debug_mode { get; private set; }

		/**
		 * Channel for debug messages
		 */
		public static string debug_channel { get; private set; }

		/**
		 * Primary bot channel
		 */
		public static string main_channel { get; private set; }

		/**
		 * DCC listening address
		 */
		public static string listen_addr { get; private set; }

		/**
		 * DCC listening port
		 */
		public static uint16 dcc_port { get; private set; }

		/**
		 * List of plugins not to load on startup
		 */
		public static string[] plugin_blacklist { get; private set; }

		/**
		 * The bot's version
		 */
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
				authserv = get_string_if_exists("authserv") ?? "authserv";
				authcmd = get_string_if_exists("authcmd") ?? "identify";
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
