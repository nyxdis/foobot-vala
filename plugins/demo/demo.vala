/*
 * foobot - demo plugin
 *
 * Copyright (c) 2011, Christoph Mende <mende.christoph@gmail.com>
 * All rights reserved. Released under the 2-clause BSD license.
 */


using Foobot;

public class Demo : Object, Plugin {
	public void init()
	{
		register_command("ping");
	}

	public string ping(string channel, User user)
	{
		return "pong";
	}
}

public Type register_plugin()
{
	return typeof(Demo);
}
