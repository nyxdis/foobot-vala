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
	 * Instance used for IRC commands
	 */
	public IRC irc;

	/**
	 * Instance used for database access
	 */
	public Foodb db;

	/**
	 * Instance used to access bot data
	 * @see Bot
	 */
	public Bot bot;

	string config = null;
	const OptionEntry[] options = {
		{ "config-file", 'f', 0, OptionArg.FILENAME, ref config, "Path to an alternative configuration file", null },
		{ null }
	};

	int main(string[] args)
	{
		var loop = new MainLoop();
		var context = new OptionContext("");
		bot = new Bot();

		context.set_help_enabled(true);
		context.add_main_entries(options, null);
		try {
			context.parse(ref args);
		} catch (Error e) {
			error("Failed to parse options: %s", e.message);
		}

		if (!Settings.load(config))
			return 1;

		db = new Foodb();

		Plugins.init();
		Plugins.load("core");

		if (bot.irc_connect())
			bot.irc_post_connect();

		bot.wait();
		loop.run();

		return 0;
	}
}
