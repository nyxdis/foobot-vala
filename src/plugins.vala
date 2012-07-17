/*
 * foobot - IRC bot
 *
 * Copyright (c) 2011, Christoph Mende <mende.christoph@gmail.com>
 * All rights reserved. Released under the 2-clause BSD license.
 */


using GLib;
using Config;

namespace Foobot
{
	private struct Command {
		string trigger;
		string plugin;
		string method;
		int level;
	}

	public errordomain PluginError {
		FAILED
	}

	/**
	 * Plugin management
	 **/
	namespace Plugins
	{
		private Peas.Engine engine;
		private Peas.ExtensionSet exten_set;
		private SList<Command?> commands;

		internal void init()
		{
			engine = Peas.Engine.get_default();
			engine.add_search_path(Config.PLUGINDIR, null);
			exten_set = new Peas.ExtensionSet(engine, typeof (Plugin));
			exten_set.extension_added.connect(on_extension_added);
			exten_set.extension_removed.connect(on_extension_removed);
		}

		/**
		 * Load a plugin by name
		 *
		 * @param name the filename of the plugin without "lib" suffix
		 * and file extension
		 * @return whether the plugin was loaded successfully
		 */
		public bool load(string name)
		{
			var plugin_info = engine.get_plugin_info(name);

			if (plugin_info == null) {
				warning(@"Plugin $name not found");
				return false;
			}

			return engine.try_load_plugin(plugin_info);
		}

		/**
		 * Unload a plugin by name
		 *
		 * @param name name of the plugin
		 * @return whether the plugin was unloaded successfully
		 */
		public bool unload(string name)
		{
			var plugin_info = engine.get_plugin_info(name);

			if (plugin_info == null) {
				warning(@"Plugin $name not found");
				return false;
			}

			return engine.try_unload_plugin(plugin_info);
		}

		internal void run_command(string channel, User user, string cmd, string[] args)
		{
			foreach (var command in commands) {
				if (command.trigger == cmd) {
					if (user.level >= command.level)
						run_callback.begin(command.plugin, command.method, channel, user, args);
				}
			}
		}

		internal void register_command(string trigger, string plugin, string method, int level)
		{
			var command = Command();
			command.trigger = trigger;
			command.plugin = plugin;
			command.method = method.replace("-", "_");
			command.level = level;
			commands.append(command);
		}

		private void on_extension_added(Peas.ExtensionSet extension_set, Peas.PluginInfo info, GLib.Object exten) {
			var plugin = exten as Plugin;

			try {
				plugin.init();
			} catch (Error e) {
				warning(e.message);
			}
		}

		private void on_extension_removed(Peas.ExtensionSet extension_set, Peas.PluginInfo info, GLib.Object exten) {
			commands.foreach((data) => {
					if (data.plugin == info.get_module_name())
						commands.remove(data);
					});
		}

		private async void run_callback(string plugin, string method, string channel, User user, string[] args)
		{
			var plugin_info = engine.get_plugin_info(plugin);
			var exten = exten_set.get_extension(plugin_info) as Plugin;

			try {
				new Thread<void*>.try ("plugin_thread", () => {
						string? response = null;

						try {
							response = exten.run(method, channel, user, args);
						} catch (Error e) {
							response = "Plugin threw an error";
							warning(e.message);
						}

						if (response != null) {
							var lines = response.split("\n");
							foreach (var line in lines)
								if (line.length > 0)
									irc.say(channel, user.nick + ": " + line);
						}

						return null;
						});
				yield;
			} catch (Error e) {
				bot.log("Failed to create plugin thread: " + e.message);
			}
		}
	}

	/**
	 * The base class for plugins
	 *
	 * Plugins have to inherit this class and they have to define their own
	 * init function.
	 */
	public interface Plugin : Peas.ExtensionBase
	{
		/**
		 * Initialize the plugin, this is called immediately after
		 * loading the plugin
		 */
		public abstract void init() throws Error;

		/**
		 * Use this function to register any new commands in the bot
		 *
		 * @param trigger trigger for the command, without command char
		 * @param method method to call when the command is triggered
		 * or null if it is the same as the trigger
		 * @param level required level for the function
		 */
		protected void register_command(string trigger, string? method = null, int level = 1)
		{
			var plugin_info = get_plugin_info();
			var plugin = plugin_info.get_module_name();

			if (method == null)
				method = trigger;

			Plugins.register_command(trigger, plugin, method, level);
		}

		/**
		 * Call a method on the plugin
		 *
		 * @param method the plugin's method to be called
		 * @param channel where the event happened
		 * @param user who executed the command
		 * @param args arguments to the command
		 */
		public abstract string? run(string method, string channel, User user, string[] args) throws Error;
	}
}
