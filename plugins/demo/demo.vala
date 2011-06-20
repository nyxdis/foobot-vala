class Demo : Object, Plugin {
	public void init()
	{
		print("demo plugin initialized\n");
	}
}

public Type register_plugin()
{
	return typeof(Demo);
}
