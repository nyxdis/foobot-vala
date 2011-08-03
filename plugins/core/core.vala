/*
 * foobot - core plugin
 *
 * Copyright (c) 2011, Christoph Mende <mende.christoph@gmail.com>
 * All rights reserved. Released under the 2-clause BSD license.
 */


using Foobot;

public class Core : Object, Plugin {
	public void init()
	{
		register_command("\001VERSION\001", "ctcp_version");
                register_command("addhost");
                register_command("adduser", null, 100);
                register_command("alias", null, 5);
                register_command("chlvl", null, 100);
                register_command("getuserdata", null, 10);
                register_command("help");
                register_command("hi", null, 0);
                register_command("join", null, 10);
                register_command("load" , null, 10);
                register_command("merge", null, 100);
                register_command("raw", null, 1000);
                register_command("reboot", null, 100);
                register_command("reload" , null, 10);
                register_command("shutdown", null, 1000);
                register_command("sql", null, 1000);
                register_command("unalias", null, 5);
                register_command("unload" , null, 10);
                register_command("update", null, 1000);
                register_command("version");
                register_command("who");
                register_command("whoami", null, 0);
                register_command("whois");
	}

	public void ctcp_version(string channel)
	{
		irc.send(@"NOTICE $channel :\001VERSION foobot v$(Foobot.Settings.version)\001");
	}

	public void addhost(string channel, User user, string[] args)
	{
		int usrid;
		string hostmask;

		if (args.length > 1) {
			try {
				var r = db.prepare("SELECT id FROM users WHERE username=:name");
				r[":name"] = args[0];
				usrid = r.execute().fetch_int();
			} catch (Error e) {
				stderr.printf("%s\n", e.message);
				return;
			}
			hostmask = args[1];
		} else {
			usrid = user.id;
			hostmask = args[0];
		}

		if (!hostmask.contains("@")) {
			irc.say(channel, @"$(user.nick): Invalid format, use addhost ident@host");
			return;
		}

		var hostdata = hostmask.split("@");

		try {
			var r = db.prepare("INSERT INTO hosts VALUES(:id, :ident, :host)");
			r[":id"] = usrid;
			r[":ident"] = hostdata[0];
			r[":host"] = hostdata[1];
			r.execute();
		} catch (Error e) {
			stderr.printf("%s\n", e.message);
			return;
		}

		irc.say(channel, @"$(user.nick): Added host");
	}

	public void adduser(string channel, User user, string[] args)
	{
	}

	public void alias(string channel, User user, string[] args)
	{
	}

	public void chlvl(string channel, User user, string[] args)
	{
	}

	public void getuserdata(string channel, User user, string[] args)
	{
	}

	public void help(string channel, User user, string[] args)
	{
	}

	public void hi(string channel, User user)
	{
		try {
			var users = db.execute("SELECT COUNT(id) FROM users").fetch_int();
			if (users > 0)
				return;

			var r = db.prepare("INSERT INTO users (username, ulvl) VALUES(:name, 1000);");
			r[":name"] = user.nick;
			var id = r.execute_insert();

			r = db.prepare("INSERT INTO hosts VALUES(:id, :ident, :host);");
			r[":id"] = id;
			r[":ident"] = user.ident;
			r[":host"] = user.host;
			r.execute();
		} catch (Error e) {
			stderr.printf("%s\n", e.message);
			return;
		}

		irc.say(channel, @"$(user.nick): Hi, you are now my owner, recognized by $(user.ident)@$(user.host).");
		irc.send(@"WHO $(user.nick)");
	}

	public void join(string channel, User user, string[] args)
	{
		return_if_fail(args.length > 0);

		if (args.length > 1)
			irc.join(args[0], args[1]);
		else
			irc.join(args[0]);
	}

	public void load(string channel, User user, string[] args)
	{
		var plugin = args[0];

		if (Plugins.load(plugin))
			irc.say(channel, @"$(user.nick): $plugin loaded");
		else
			irc.say(channel, @"$(user.nick): failed to load $plugin");
	}

	public void merge(string channel, User user, string[] args)
	{
	}

	public void raw(string channel, User user, string[] args)
	{
		var msg = string.joinv(" ", args);
		irc.send(msg);
	}

	public void reboot(string channel, User user)
	{
	}

	public void reload(string channel, User user, string[] args)
	{
		var plugin = args[0];

		if (Plugins.unload(plugin) && Plugins.load(plugin))
			irc.say(channel, @"$(user.nick): $plugin reloaded");
		else
			irc.say(channel, @"$(user.nick): failed to reload $plugin");
	}

	public void shutdown(string channel, User user)
	{
		bot.shutdown(@"Shutting down as requesetd by $(user.name)");
	}

	public void sql(string channel, User user, string[] args)
	{
	}

	public void unalias(string channel, User user, string[] args)
	{
	}

	public void unload(string channel, User user, string[] args)
	{
		var plugin = args[0];

		if (plugin.down() == "core") {
			irc.say(channel, @"$(user.nick): not going to unload core");
			return;
		}

		if (Plugins.unload(plugin))
			irc.say(channel, @"$(user.nick): $plugin unloaded");
		else
			irc.say(channel, @"$(user.nick): failed to unload $plugin");
	}

	public void version(string channel, User user)
	{
	}

	public void who(string channel, User user, string[] args)
	{
		return_if_fail(args.length > 0);

		var nick = args[0];
		irc.send(@"WHO $nick");
		irc.say(channel, @"$(user.nick): Okay");
	}

	public void whoami(string channel, User user)
	{
		string msg;
		if (user.id > 0) {
			msg = "You are ";
			if (user.title != null)
				msg += user.title + " ";
			msg += user.name + ", level " + user.level.to_string();
		} else {
			msg = "You are unknown";
		}
		irc.say(channel, @"$(user.nick): $msg");
	}

	public void whois(string channel, User user, string[] args)
	{
		return_if_fail(args.length > 0);

		var nick = args[0];
		var tmpuser = bot.get_userlist(nick);
		string msg;
		if (tmpuser != null && tmpuser.id > 0) {
			msg = tmpuser.nick + " is ";
			if (tmpuser.title != null)
				msg += tmpuser.title + " ";
			msg += tmpuser.name + ", level " + tmpuser.level.to_string();
		} else {
			msg = nick + " is unknown";
		}
		irc.say(channel, @"$(user.nick): $msg");
	}
}

public Type register_plugin()
{
	return typeof(Core);
}
