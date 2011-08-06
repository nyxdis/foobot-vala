/*
 * foobot - IRC bot
 *
 * Copyright (c) 2011, Christoph Mende <mende.christoph@gmail.com>
 * All rights reserved. Released under the 2-clause BSD license.
 */


using GLib;

namespace Foobot
{
	private DataInputStream istream;
	private DataOutputStream ostream;

	/**
	 * IRC communication
	 *
	 * This class is used to communicate with the IRC server
	 *
	 * @see irc
	 */
	public class IRC : Object
	{
		/**
		 * Emitted when a user or the bot joins a channel
		 *
		 * @param channel the joined channel
		 * @param user who joined the channel
		 */
		public signal string? joined(string channel, User user);

		internal IRC() {}

		/**
		 * Emitted when someone says something
		 *
		 * @param channel the channel where the event occured
		 * @param user who said it
		 * @param text what they said
		 */
		public signal string? said(string channel, User user, string text);

		/**
		 * Join a new channel
		 *
		 * @param channel the channel to join
		 * @param key the channel's key or an empty string if there is
		 * none
		 */
		public void join(string channel, string key = "")
		{
			send(@"JOIN $channel :$key");
			send(@"WHO $channel");
		}

		/**
		 * Send a raw IRC command
		 *
		 * @param raw properly formatted IRC command
		 */
		public void send(string raw)
		{
			try {
				ostream.put_string(@"$raw\n");
			} catch (Error e) {
				bot.report_error(e);
			}
		}

		/**
		 * Send text to a channel
		 *
		 * @param target where to send it (channel or nick)
		 * @param text the text to send
		 */
		public void say(string target, string text)
		{
			// TODO line wrapping
			send(@"PRIVMSG $target :$text");
		}

		/**
		 * Send an action to the target
		 */
		public void act(string target, string text)
		{
			say(target, @"\001ACTION $text\001");
		}
	}
}
