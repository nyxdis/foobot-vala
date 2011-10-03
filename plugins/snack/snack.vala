/*
 * foobot - demo plugin
 *
 * Copyright (c) 2011, Christoph Mende <mende.christoph@gmail.com>
 * All rights reserved. Released under the 2-clause BSD license.
 */


using Foobot;

public class Snack : Object, Plugin {
	public void init()
	{
		register_command("snack");
	}

	public string? snack(string channel, User user)
	{
		irc.act(channel, "munches " + user.nick + "'s snack");
		return null;
	}
}

public Type register_plugin()
{
	return typeof(Snack);
}
