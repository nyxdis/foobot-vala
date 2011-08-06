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

	public string qalc(string channel, User user, string[] args) throws SpawnError
	{
		string result;
		var cmdargs = string.joinv(" ", args);
		Process.spawn_command_line_sync("/usr/bin/qalc " + cmdargs, out result);
		return result;
	}
}

public Type register_plugin()
{
	return typeof(Qalc);
}
