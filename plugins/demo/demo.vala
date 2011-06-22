using Foobot;

class Demo : Object, Plugin {
	public void init()
	{
		register_command("ping");
	}

	public void ping(string channel, string nick)
	{
		irc.say(channel, @"$nick: pong");
	}
}

public Type register_plugin()
{
	return typeof(Demo);
}
