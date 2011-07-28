/*
 * foobot - qalc plugin
 *
 * Copyright (c) 2011, Christoph Mende <mende.christoph@gmail.com>
 * All rights reserved. Released under the 2-clause BSD license.
 */


using Foobot;

public class Qalc : Object, Plugin {
	public void init()
	{
		register_command("qalc");
	}

	public void qalc(string channel, User user, string[] args)
	{
		try {
			string result;
			var cmdargs = string.joinv(" ", args);
			Process.spawn_command_line_sync("/usr/bin/qalc " + cmdargs, out result);
			irc.say(channel, @"$(user.nick): $result");
		} catch (Error e) {
			stderr.printf("%s\n", e.message);
		}
	}
}

public Type register_plugin()
{
	return typeof(Qalc);
}
