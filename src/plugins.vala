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
	struct Command {
		string trigger;
		string plugin;
		string method;
		int level;
	}

	public errordomain PluginError {
		FAILED
	}

	class PluginHandler : Object
	{
		public string path { get; private set; }

		private Type type;
		private Module module;
		private Plugin plugin;
		private bool registered;

		private delegate Type RegisterPluginFunction();
		[CCode (has_target = false)]
		private delegate string? CommandCallback(Plugin self, string channel, User user, string[] args) throws Error;

		public PluginHandler(string name)
		{
			path = Module.build_path(PLUGINDIR, name);
			registered = false;
		}

		public bool load()
		{
			stdout.printf("Loading plugin: %s\n", path);

			module = Module.open(path, ModuleFlags.BIND_LAZY);
			if (module == null) {
				bot.log("Failed to load module: " + Module.error());
				return false;
			}

			stdout.printf("Loaded module: %s\n", module.name());

			if (!registered) {
				void* function;
				module.symbol("register_plugin", out function);
				RegisterPluginFunction register_plugin = (RegisterPluginFunction) function;
				type = register_plugin();
				registered = true;
			}

			plugin = (Plugin) Object.new(type);
			try {
				plugin.init();
			} catch (Error e) {
				bot.report_error(e);
			}
			return true;
		}

		public void unload()
		{
			module = null;
		}

		public async void run_callback(string method, string channel, User user, string[] _args)
		{
			var symbol = type.name().down() + "_" + method;
			var args = _args; // vala bug

			void* function;
			module.symbol(symbol, out function);
			var callback = (CommandCallback) function;
			try {
				Thread.create<void*>(() => {
					string? response = null;
					try {
						response = callback(plugin, channel, user, args);
					} catch (Error e) {
						response = "Plugin threw an error";
						bot.report_error(e);
					}
					if (response != null) {
						var lines = response.split("\n");
						foreach (var line in lines)
							if (line.length > 0)
								irc.say(channel, user.nick + ": " + line);
					}
					return null;
					}, false);
				yield;
			} catch (Error e) {
				bot.log("Failed to create plugin thread: " + e.message);
			}
		}
	}

	/**
	 * Plugin management
	 **/
	public class Plugins : Object
	{
		private static HashTable<string,PluginHandler> loaded;
		private static SList<Command?> commands;

		private Plugins() {}

		internal static void init()
		{
			loaded = new HashTable<string,PluginHandler>(str_hash, str_equal);
		}

		/**
		 * Load a plugin by name
		 *
		 * @param name the filename of the plugin without "lib" suffix
		 * and file extension
		 * @return wether the plugin was loaded successfully
		 */
		public static bool load(string name)
		{
			PluginHandler handler = loaded.lookup(name);

			if (handler == null) {
				handler = new PluginHandler(name);
				loaded.insert(name, handler);
			}

			if (!handler.load())
				return false;

			return true;
		}

		/**
		 * Unload a plugin
		 *
		 * This function unregisters any commands used in the plugin
		 * and unloads it
		 *
		 * @param _name name of the plugin
		 * @return false if the plugin is not loaded
		 */
		public static bool unload(string _name)
		{
			var name = _name.down();

			var handler = loaded.lookup(name);
			if (handler == null)
				return false;

			commands.foreach((data) => {
					if (data.plugin == name)
						commands.remove(data);
					});

			handler.unload();
			return true;
		}

		internal static void run_command(string channel, User user, string cmd, string[] args)
		{
			foreach (var command in commands) {
				if (command.trigger == cmd) {
					var plugin = loaded.lookup(command.plugin);
					if (user.level >= command.level)
						plugin.run_callback.begin(command.method, channel, user, args);
				}
			}
		}

		internal static void register_command(string trigger, string plugin, string method, int level)
		{
			var command = Command();
			command.trigger = trigger;
			command.plugin = plugin.down();
			command.method = method.replace("-", "_");
			command.level = level;
			commands.append(command);
		}
	}

	/**
	 * The base class for plugins
	 *
	 * Plugins have to inherit this class and they have to define their own
	 * init function.
	 */
	public interface Plugin : Object
	{
		/**
		 * Initialize the plugin, this is called immediately after
		 * loading the plugin
		 */
		public abstract void init() throws Error;

		/**
		 * Use this function to register any new commands in the bot
		 *
		 * @param command trigger for the command, without command char
		 * @param method method to call when the command is triggered
		 * or null if it is the same as the trigger
		 * @param level required level for the function
		 */
		protected void register_command(string command, string? method = null, int level = 1)
		{
			var type = Type.from_instance(this);
			var plugin = type.name();

			if (method == null)
				method = command;

			Plugins.register_command(command, plugin, method, level);
		}
	}
}
