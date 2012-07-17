/*
 * foobot - snack plugin
 *
 * Copyright (c) 2011, Christoph Mende <mende.christoph@gmail.com>
 * All rights reserved. Released under the 2-clause BSD license.
 */


using Foobot;

public class Snack : Peas.ExtensionBase, Plugin {
	public void init()
	{
		register_command("snack");
	}

	public string? run(string method, string channel, User user, string[] args) {
		switch (method) {
			case "snack":
				return snack(channel, user);
			default:
				return null;
		}
	}

	public string? snack(string channel, User user)
	{
		irc.act(channel, "munches " + user.nick + "'s snack");
		return null;
	}
}

[ModuleInit]
public void peas_register_types(GLib.TypeModule module) {
	var objmodule = module as Peas.ObjectModule;
	objmodule.register_extension_type(typeof (Plugin), typeof (Snack));
}
