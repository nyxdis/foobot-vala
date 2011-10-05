/*
 * foobot - IRC bot
 *
 * Copyright (c) 2011, Christoph Mende <mende.christoph@gmail.com>
 * All rights reserved. Released under the 2-clause BSD license.
 */


using GLib;
using SQLHeavy;

namespace Foobot.Foodb
{
	void open()
	{
		try {
			db = new Database(@"foobot-$(Settings.network).db", FileMode.READ | FileMode.WRITE | FileMode.CREATE);
			initialize();
			// XXX: this is deprecated
			db.count_changes = true;
		} catch (SQLHeavy.Error e) {
			bot.report_error(e);
		}
	}

	void initialize() throws SQLHeavy.Error
	{
		var trans = db.begin_transaction();
		trans.execute("CREATE TABLE IF NOT EXISTS users (id integer primary key, username varchar(25) unique, title varchar(25), ulvl integer, userdata varchar(150))");
		trans.execute("CREATE TABLE IF NOT EXISTS hosts (usrid integer, ident varchar(10), host varchar(50))");
		trans.execute("CREATE TABLE IF NOT EXISTS timed_events (id integer primary key, plugin varchar(25), function varchar(25), time int(11), args varchar(255))");
		trans.execute("CREATE TABLE IF NOT EXISTS aliases (id integer primary key, alias varchar(50), function varchar(50), args varchar(250))");
		trans.commit();
	}
}
