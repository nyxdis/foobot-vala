public interface PluginInterface : Object
{
	public abstract void init();

	protected void answer(string text)
	{
		stdout.printf("answer: %s\n", text);
	}
}
