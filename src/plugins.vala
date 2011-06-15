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

class PluginLoader<T> : Object
{
	public string path { get; private set; }

	private Type type;
	private Module module;

	private delegate Type RegisterPluginFunction(Module module);

	public PluginLoader(string name)
	{
		assert (Module.supported());
		path = Module.build_path(PLUGINDIR, name);
	}

	public bool load()
	{
		stdout.printf("Loading plugin: %s\n", path);

		module = Module.open(path, ModuleFlags.BIND_LAZY);
		if (module == null) {
			stderr.printf("Failed to load module: %s\n", Module.error());
			return false;
		}

		stdout.printf("Loaded module: %s\n", module.name());

		void* function;
		module.symbol("register_plugin", out function);
		RegisterPluginFunction register_plugin = (RegisterPluginFunction) function;
		type = register_plugin(module);
		return true;
	}

	public T new_object()
	{
		return Object.new(type);
	}
}

public class Plugins : Object
{
	private static List<PluginInterface> loaded;

	public static bool load(string name)
	{
		var registrar = new PluginLoader<PluginInterface>(name);
		if (!registrar.load())
			return false;

		var plugin = registrar.new_object();
		plugin.init();
		loaded.append(plugin);
		return true;
	}

	public static void run_joined(string channel, string nick)
	{
		print(@"signal: $nick joined $channel\n");
	}

	public static void run_said(string channel, string nick, string text)
	{
		print(@"signal: $nick said '$text' in $channel\n");
	}

	public static void run_command(string channel, string nick, string cmd, string[] args)
	{
		print(@"signal: $nick executed $cmd in $channel\n");
	}
}
