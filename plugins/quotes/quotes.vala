/*
 * foobot - quotes plugin
 *
 * Copyright (c) 2011, Christoph Mende <mende.christoph@gmail.com>
 * All rights reserved. Released under the 2-clause BSD license.
 */


using Foobot;

public class Quotes : Peas.ExtensionBase, Plugin {
	public void init() throws Error
	{
		register_command("2q", "pub_2q");
		register_command("q");
		register_command("aq");
		register_command("dq");
		register_command("iq");
		register_command("sq");
		register_command("tq");

		db.execute("CREATE TABLE IF NOT EXISTS quotes (id integer primary key, text text, karma int)");
	}

	public string? run(string method, string channel, User user, string[] args) {
		switch (method) {
			case "2q":
				return pub_2q(channel, user, args);
			case "q":
				return q(channel, user, args);
			case "aq":
				return aq(channel, user, args);
			case "dq":
				return dq(channel, user, args);
			case "iq":
				return iq(channel, user, args);
			case "sq":
				return sq(channel, user, args);
			case "tq":
				return tq(channel, user, args);
			default:
				return null;
		}
	}

	public string pub_2q(string channel, User user, string[] args) throws Error
	{
		return q(channel, user, { "2" });
	}

	public string q(string channel, User user, string[] args) throws Error
	{
		int num;
		if (args.length > 0) {
			num = int.parse(args[0]);
			if (num < 1)
				num = 1;
			else if (num > 9)
				num = 9;
		} else {
			num = 1;
		}

		var r = db.prepare("SELECT * FROM quotes WHERE karma > -3 ORDER BY RANDOM() LIMIT :num");
		r["num"] = num;
		string msg = "";
		for (var quotes = r.execute(); !quotes.finished; quotes.next()) {
			var id = quotes.get_int("id").to_string();
			var text = quotes.get_string("text");
			var karma = quotes.get_int("karma").to_string();
			msg += "#" + id + " " + text + " (Karma: " + karma + ")\n";
		}
		return msg;
	}

	public string aq(string channel, User user, string[] args) throws Error
	{
		if (args.length == 0)
			return "Add what?";
		var quote = string.joinv(" ", args);
		var r = db.prepare("INSERT INTO quotes (text, karma) VALUES(:quote, 0)");
		r["quote"] = quote;
		r.execute();
		return "Added quote " + db.last_insert_id.to_string();
	}

	public string dq(string channel, User user, string[] args) throws Error
	{
		var qid = int.parse(args[0]);
		var r = db.prepare("DELETE FROM quotes WHERE id = :qid");
		r["qid"] = qid;
		var res = r.execute();
		var rd = res.get_int("rows deleted");
		if (rd > 0)
			return "Deleted quote " + qid.to_string();
		else
			return "No quote with id " + qid.to_string() + " found";
	}

	public string iq(string channel, User user, string[] args) throws Error
	{
		var qid = int.parse(args[0]);
		var r = db.prepare("SELECT * FROM quotes WHERE id = :qid");
		r["qid"] = qid;
		var quote = r.execute();
		var text = quote.get_string("text");
		if (text == null)
			return "Can't fetch quote with id " + qid.to_string();
		var karma = quote.get_int("karma");
		return text + " (Karma: " + karma.to_string() + ")";
	}

	public string sq(string channel, User user, string[] args) throws Error
	{
		var pattern = string.joinv(" ", args);
		var r = db.prepare("SELECT * FROM quotes WHERE text LIKE :pattern ORDER BY RANDOM() LIMIT 3");
		r["pattern"] = "%" + pattern.replace(" ", "%") + "%";
		string msg = "";
		for (var quotes = r.execute(); !quotes.finished; quotes.next()) {
			var id = quotes.get_int("id").to_string();
			var text = quotes.get_string("text");
			var karma = quotes.get_int("karma").to_string();
			msg += "#" + id + " " + text + " (Karma: " + karma + ")\n";
		}
		return msg;
	}

	public string tq(string channel, User user, string[] args) throws Error
	{
		int num;

		if (args.length == 0)
			num = 3;
		else
			num = int.parse(args[0]);

		if (num > 5)
			num = 5;
		else if (num < 1)
			num = 1;

		var r = db.prepare("SELECT * FROM quotes ORDER BY karma DESC LIMIT :num");
		r["num"] = num;
		string msg = "";
		for (var quotes = r.execute(); !quotes.finished; quotes.next()) {
			var id = quotes.get_int("id").to_string();
			var text = quotes.get_string("text");
			var karma = quotes.get_int("karma").to_string();
			msg += "#" + id + " " + text + " (Karma: " + karma + ")\n";
		}
		return msg;
	}
}

[ModuleInit]
public void peas_register_types(GLib.TypeModule module) {
	var objmodule = module as Peas.ObjectModule;
	objmodule.register_extension_type(typeof (Plugin), typeof (Quotes));
}
