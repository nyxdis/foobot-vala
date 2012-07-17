/*
 * foobot - 8ball plugin
 *
 * Copyright (c) 2011, Christoph Mende <mende.christoph@gmail.com>
 * All rights reserved. Released under the 2-clause BSD license.
 */


using Foobot;

public class Eightball : Peas.ExtensionBase, Plugin {
	public void init()
	{
		register_command("8ball", "eightball");
		register_command("decide");
	}

	public string? run(string method, string channel, User user, string[] args) {
		switch (method) {
			case "eightball":
				return eightball();
			case "decide":
				return decide(channel, user, args);
			default:
				return null;
		}
	}

	public string eightball()
	{
		string[] answers = { "As I see it, yes",
			"It is certain",
			"It is decidedly so",
			"Most likely",
			"Outlook good",
			"Signs point to yes",
			"Without a doubt",
			"Yes",
			"Yes - definitely",
			"You may rely on it",
			"Reply hazy, try again",
			"Ask again later",
			"Better not tell you now",
			"Cannot predict now",
			"Concentrate and ask again",
			"Don't count on it",
			"My reply is no",
			"My sources say no",
			"Outlook not so good",
			"Very doubtful" };

		var idx = Random.int_range(0, answers.length - 1);
		return answers[idx];
	}

	public string decide(string channel, User user, string[] args)
	{
		// TODO csv
		if (args.length < 2)
			return eightball();

		var idx = Random.int_range(0, args.length - 1);
		return args[idx];
	}
}

[ModuleInit]
public void peas_register_types(GLib.TypeModule module) {
	var objmodule = module as Peas.ObjectModule;
	objmodule.register_extension_type(typeof (Plugin), typeof (Eightball));
}
