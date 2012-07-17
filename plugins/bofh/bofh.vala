/*
 * foobot - bofh plugin
 *
 * Copyright (c) 2011, Christoph Mende <mende.christoph@gmail.com>
 * All rights reserved. Released under the 2-clause BSD license.
 */


using Foobot;

public class Bofh : Peas.ExtensionBase, Plugin {
	public void init() throws Error
	{
		register_command("bofh");
		register_command("addlart");
		register_command("lart");

		db.execute("CREATE TABLE IF NOT EXISTS larts (lart varchar(50))");
	}

	public string? run(string method, string channel, User user, string[] args) throws Error {
		switch (method) {
			case "bofh":
				return bofh();
			case "addlart":
				return addlart(channel, user, args);
			case "lart":
				return lart(channel, user, args);
			default:
				return null;
		}
	}

	public string bofh() throws SpawnError
	{
		string result;
		Process.spawn_command_line_sync("/usr/bin/fortune bofh-excuses", out result);
		return result;
	}

	public string addlart(string channel, User user, string[] args) throws SQLHeavy.Error
	{
		var lart = string.joinv(" ", args);
		var r = db.prepare("INSERT INTO larts VALUES(:lart)");
		r[":lart"] = lart;
		r.execute();
		return "Added LART";
	}

	public string? lart(string channel, User user, string[] args) throws SQLHeavy.Error
	{
		string nick;
		if (args.length == 0)
			nick = user.nick;
		else
			nick = args[0];

		var lart = db.execute("SELECT lart FROM larts ORDER BY RANDOM() LIMIT 1").fetch_string();
		irc.act(channel, @"slaps $nick with $lart");
		return null;
	}
}

[ModuleInit]
public void peas_register_types(GLib.TypeModule module) {
	var objmodule = module as Peas.ObjectModule;
	objmodule.register_extension_type(typeof (Plugin), typeof (Bofh));
}
