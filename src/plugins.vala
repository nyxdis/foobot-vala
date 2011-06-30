/*
 * Copyright (C) 2011  Christoph Mende
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
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

	class PluginHandler : Object
	{
		public string path { get; private set; }

		private Type type;
		private Module module;
		private Plugin plugin;

		private delegate Type RegisterPluginFunction();
		private delegate void CommandCallback(Plugin self, string channel, string nick, string[] args);

		public PluginHandler(string name)
		{
			assert (Module.supported());
			path = Module.build_path(PLUGINDIR, name);
		}

		public void load()
		{
			stdout.printf("Loading plugin: %s\n", path);

			module = Module.open(path, ModuleFlags.BIND_LAZY);
			if (module == null) {
				stderr.printf("Failed to load module: %s\n", Module.error());
				return;
			}

			stdout.printf("Loaded module: %s\n", module.name());

			void* function;
			module.symbol("register_plugin", out function);
			RegisterPluginFunction register_plugin = (RegisterPluginFunction) function;
			type = register_plugin();

			plugin = (Plugin) Object.new(type);
			plugin.init();
		}

		public void unload()
		{
			module = null;
		}

		public void run_callback(string method, string channel, string nick, string[] args)
		{
			var symbol = type.name().down() + "_" + method;

			void* function;
			module.symbol(symbol, out function);
			var callback = (CommandCallback) function;
			callback(plugin, channel, nick, args);
		}
	}

	public class Plugins : Object
	{
		private static HashTable<string,PluginHandler> loaded;
		private static List<Command?> commands;

		internal Plugins() {}

		internal static void init()
		{
			loaded = new HashTable<string,PluginHandler>(str_hash, str_equal);
		}

		public static void load(string name)
		{
			var handler = new PluginHandler(name);
			handler.load();
			loaded.insert(name, handler);
		}

		internal static void run_command(string channel, string nick, string cmd, string[] args)
		{
			foreach (var command in commands) {
				if (command.trigger == cmd) {
					var plugin = loaded.lookup(command.plugin.down());
					plugin.run_callback(command.method, channel, nick, args);
				}
			}
		}

		internal static void register_command(string trigger, string plugin, string method, int level)
		{
			var command = Command();
			command.trigger = trigger;
			command.plugin = plugin;
			command.method = method;
			command.level = level;
			commands.append(command);
		}
	}
}
