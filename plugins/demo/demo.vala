/*
 * foobot - demo plugin
 *
 * Copyright (c) 2011, Christoph Mende <mende.christoph@gmail.com>
 * All rights reserved. Released under the 2-clause BSD license.
 */


using Foobot;

public class Demo : Peas.ExtensionBase, Plugin {
	public void init()
	{
		register_command("ping");
	}

	public string? run(string method, string channel, User user, string[] args) {
		switch (method) {
			case "ping":
				return ping();
			default:
				return null;
		}
	}

	public string ping()
	{
		return "pong";
	}
}

[ModuleInit]
public void peas_register_types(GLib.TypeModule module)
{
	var objmodule = module as Peas.ObjectModule;
	objmodule.register_extension_type(typeof (Plugin), typeof (Demo));
}
