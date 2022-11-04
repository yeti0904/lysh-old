alias CommandFunction = void function(string[]);

struct Command {
	string          name;
	string[]        help;
	CommandFunction func;
}

class CommandManager {
	Command[] commands;

	this() {}
	void RegisterCommand(string name, CommandFunction func, string[] help) {
		commands ~= Command(name, help, func);
	}
	Command* GetCommand(string name) {
		foreach (ref cmd ; commands) {
			if (cmd.name == name) {
				return &cmd;
			}
		}
		return null;
	}
}

CommandManager CommandManagerInstance() {
	static CommandManager instance;

	if (!instance) {
		instance = new CommandManager();
	}

	return instance;
}
