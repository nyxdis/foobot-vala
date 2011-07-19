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
		 * @param nick who joined the channel
		 */
		public signal void joined(string channel, string nick);

		internal IRC() {}

		/**
		 * Emitted when someone says something
		 *
		 * @param channel the channel where the event occured
		 * @param nick who said it
		 * @param text what they said
		 */
		public signal void said(string channel, string nick, string text);

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
				stderr.printf("%s\n", e.message);
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
	}
}
