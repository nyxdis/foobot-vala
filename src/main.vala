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


private string config = null;
private const OptionEntry[] options = {
	{ "config-file", 'f', 0, OptionArg.FILENAME, ref config, "Path to an alternative configuration file", null },
	{ null }
};

public int main(string[] args)
{
	var loop = new MainLoop();
	var context = new OptionContext("");
	var bot = new Bot();

	context.set_help_enabled(true);
	context.add_main_entries(options, null);
	try {
		context.parse(ref args);
	} catch (Error e) {
		error("Failed to parse options: %s", e.message);
	}

	if (!Settings.load(config))
		return 1;

	// set up signal handlers
	bot.command.connect(Plugins.run_command);
	bot.joined.connect(Plugins.run_joined);
	bot.said.connect(Plugins.run_said);

	if (bot.irc_connect())
		bot.irc_post_connect();

	bot.wait();
	loop.run();

	return 0;
}
