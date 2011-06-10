class Demo : Object, PluginInterface {
	public void init()
	{
		print("demo plugin initialized\n");
	}

	Demo()
	{
		print("demo plugin constructed\n");
	}

	~Demo()
	{
		print("demo plugin destroyed\n");
	}
}

public Type register_plugin(Module module)
{
	return typeof(Demo);
}
