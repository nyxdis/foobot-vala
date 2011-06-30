using Foobot;

class Core : Object, Plugin {
	public void init()
	{
		register_command("\001VERSION\001", "ctcp_version");
                register_command("addhost");
                register_command("adduser", null, 100);
                register_command("alias", null, 5);
                register_command("chlvl", null, 100);
                register_command("disable" , null, 10);
                register_command("enable" , null, 10);
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
		irc.send(@"NOTICE $channel :\001VERSION foobot v$(Settings.version)\001");
	}

	public void addhost(string channel, string nick, string[] args)
	{
	}

	public void adduser(string channel, string nick, string[] args)
	{
	}


	public void alias(string channel, string nick, string[] args)
	{
	}


	public void chlvl(string channel, string nick, string[] args)
	{
	}


	public void getuserdata(string channel, string nick, string[] args)
	{
	}


	public void help(string channel, string nick, string[] args)
	{
	}


	public void hi(string channel, string nick)
	{
	}


	public void join(string channel, string nick, string[] args)
	{
	}


	public void enable(string channel, string nick, string[] args)
	{
	}


	public void disable(string channel, string nick, string[] args)
	{
	}


	public void load(string channel, string nick, string[] args)
	{
	}


	public void merge(string channel, string nick, string[] args)
	{
	}


	public void raw(string channel, string nick, string[] args)
	{
	}


	public void reboot(string channel, string nick)
	{
	}


	public void shutdown(string channel, string nick)
	{
	}


	public void sql(string channel, string nick, string[] args)
	{
	}


	public void unalias(string channel, string nick, string[] args)
	{
	}


	public void version(string channel, string nick)
	{
	}


	public void who(string channel, string nick, string[] args)
	{
	}


	public void whoami(string channel, string nick)
	{
	}


	public void whois(string channel, string nick, string[] args)
	{
	}
}

public Type register_plugin()
{
	return typeof(Core);
}
