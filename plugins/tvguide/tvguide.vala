/*
 * foobot - tv plugin
 *
 * Copyright (c) 2011, Christoph Mende <mende.christoph@gmail.com>
 * All rights reserved. Released under the 2-clause BSD license.
 */


using Foobot;
using SQLHeavy;

public class Tvguide : Object, Plugin {
	public void init()
	{
		register_command("tv");
	}

	public string? tv(string channel, User user, string[] args) throws GLib.Error
	{
		var default_channels = "'prosieben.de','rtl.de','sat1.de'";
		var tvdb = new Database("xmltv.db", FileMode.READ);

		string? cmd;
		if (args.length == 0)
			cmd = null;
		else
			cmd = args[0];

		string tv_channels;
		if (user["tv_channels"] == null)
			tv_channels = default_channels;
		else
			tv_channels = user["tv_channels"];

		switch (cmd) {
			case "next":
				var tv = tvdb.execute("SELECT * FROM (SELECT channelid, display_name, title, start FROM programme, channels WHERE channelid=id AND start > strftime('%s', 'now') AND channelid in (" + tv_channels + ") ORDER BY start DESC) GROUP BY channelid");
				var next = "";
				for (; !tv.finished; tv.next()) {
					var datetime = new DateTime.from_unix_local(tv.get_int("start"));
					var ts = datetime.format("%R");
					next += tv.get_string("display_name") + ": " + ts + " " + tv.get_string("title") + ", ";
				}
				if (next.length > 0) {
					next = next.substring(0, next.length - 2);
					return next;
				}
				return "No EPG data available";
			case "chanlist":
				var channels = tvdb.execute("SELECT display_name FROM channels GROUP BY id");
				var chanlist = "I know these channels: ";
				for (; !channels.finished; channels.next())
					chanlist += channels.fetch_string() + ", ";
				if (chanlist.length > 23) {
					chanlist = chanlist.substring(0, chanlist.length - 2);
					return chanlist;
				}
				return "Channel list empty";
			case "set":
				args = args[1:args.length];
				var list = string.joinv("', '", args).down();
				var channels = tvdb.execute("SELECT * FROM channels WHERE lower(display_name) IN ('" + list + "')");
				string chanlist = "", display_names = "";
				for (;!channels.finished; channels.next()) {
					chanlist += "'" + channels.get_string("id") + "', ";
					display_names += channels.get_string("display_name") + ", ";
				}
				if (chanlist.length > 0) {
					user["tv_channels"] = chanlist.substring(0, chanlist.length - 2);
					return "Set your personal channels to " + display_names.substring(0, display_names.length - 2);
				}
				return "Channels not found";
			case "unset":
				user["tv_channels"] = default_channels;
				return "Reset your channels to default";;
			case "search":
				args = args[1:args.length];
				var keywords = string.joinv("%", args);
				var r = tvdb.prepare("SELECT display_name, title, start FROM programme, channels WHERE channelid=id AND start>strftime('%s', 'now') AND title LIKE :keywords GROUP BY channelid ORDER BY start ASC LIMIT 3");
				r["keywords"] = "%" + keywords + "%";
				string match = "";
				for (var programme = r.execute(); !programme.finished; programme.next()) {
					var datetime = new DateTime.now_local();
					var now = datetime.format("%Y%m%d");
					datetime = new DateTime.from_unix_local(programme.get_int("start"));
					var start = datetime.format("%Y%m%d");
					string dateformat;
					if (start == now)
						dateformat = "%R";
					else
						dateformat = "%d.%m. %R";
					match += programme.get_string("display_name") + ": " + datetime.format(dateformat) + " " + programme.get_string("title") + ", ";
				}
				if (match.length > 0)
					return match.substring(0, match.length - 2);
				return "Nothing found";
			default:
				if (args.length > 0) {
					MatchInfo matches;
					if (new Regex("(?<hour>[0-2][0-9])(:|\\.)?(?<minute>[0-5][0-9])").match(args[0], 0, out matches)) { // tv HHMM
						var now = time_t();
						var t = Time.local(now);
						t.hour = int.parse(matches.fetch_named("hour"));
						t.minute = int.parse(matches.fetch_named("minute"));
						t.second = 59;
						if (t.mktime() + 7200 < now)
							t.day++;
						var ts = t.format("%s");
						var tv = tvdb.execute("SELECT display_name, title, start FROM programme, channels WHERE channelid=id AND channelid IN (" + tv_channels + ") AND start<=" + ts + " AND stop>" + ts + " GROUP BY channelid");
						var onair = "";
						for (;!tv.finished; tv.next()) {
							var datetime = new DateTime.from_unix_local(tv.get_int("start"));
							var start = datetime.format("%R");
							onair += tv.get_string("display_name") + ": " + start + " " + tv.get_string("title") + ", ";
						}
						if (onair.length > 0)
							return onair.substring(0, onair.length - 2);
						return "No EPG data available";
					} else { // tv chan
						var r = tvdb.prepare("SELECT id FROM channels WHERE display_name LIKE :name");
						r["name"] = args[0];
						var cid = r.execute().fetch_string();
						if (cid == null)
							return "Channel not found";
						var now = time_t();
						var t = Time.local(now);
						if (args.length > 1) {
							MatchInfo time_info;
							new Regex("(?<hour>[0-2][0-9])(:|\\.)?(?<minute>[0-5][0-9])").match(args[1], 0, out time_info);
							t.hour = int.parse(time_info.fetch_named("hour"));
							t.minute = int.parse(time_info.fetch_named("minute"));
						}
						t.second = 59;
						r = tvdb.prepare("SELECT channelid, title, start FROM programme WHERE stop>:ts AND channelid=:cid ORDER BY start ASC LIMIT 2");
						r["ts"] = t.format("%s");;
						r["cid"] = cid;
						var onair = "";
						string display_name = "";
						for (var data = r.execute(); !data.finished; data.next()) {
							var datetime = new DateTime.from_unix_local(data.get_int("start"));
							var start = datetime.format("%R");
							onair += start + " " + data.get_string("title") + ", ";
							display_name = data.get_string("channelid");
						}
						if (display_name.length > 0) {
							r = tvdb.prepare("SELECT display_name FROM channels WHERE id=:cid");
							r["cid"] = display_name;
							display_name = r.execute().fetch_string();
							onair = display_name + ": " + onair.substring(0, onair.length - 2);
							return onair;
						}
						return "No EPG data available";
					}
				} else {
					var tv = tvdb.execute("SELECT display_name, title, start FROM programme, channels WHERE channelid=id AND channelid IN (" + tv_channels + ") and start<=strftime('%s', 'now') AND stop>strftime('%s', 'now') GROUP by channelid");
					var onair = "";
					for (;!tv.finished; tv.next()) {
						var datetime = new DateTime.from_unix_local(tv.get_int("start"));
						var start = datetime.format("%R");
						onair += tv.get_string("display_name") + ": " + start + " " + tv.get_string("title") + ", ";
					}
					if (onair.length > 0)
						return onair.substring(0, onair.length - 2);
					return "No EPG data available";
				}
		}
	}
}

public Type register_plugin()
{
	return typeof(Tvguide);
}
