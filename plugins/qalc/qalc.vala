/*
 * foobot - qalc plugin
 *
 * Copyright (c) 2011, Christoph Mende <mende.christoph@gmail.com>
 * All rights reserved. Released under the 2-clause BSD license.
 */


using Foobot;

public class Qalc : Peas.ExtensionBase, Plugin {
	public void init()
	{
		register_command("qalc");
	}

	public string? run(string method, string channel, User user, string[] args) {
		switch (method) {
			case "qalc":
				return qalc(channel, user, args);
			default:
				return null;
		}
	}

	public string qalc(string channel, User user, string[] args) throws SpawnError
	{
		string result;
		var cmdargs = string.joinv(" ", args);
		Process.spawn_command_line_sync("/usr/bin/qalc " + cmdargs, out result);
		return result;
	}
}

[ModuleInit]
public void peas_register_types(GLib.TypeModule module) {
	var objmodule = module as Peas.ObjectModule;
	objmodule.register_extension_type(typeof (Plugin), typeof (Qalc));
}
