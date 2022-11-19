import commands;

alias CommandFunction = void function(string[]);

struct Command {
	string          name;
	string[]        help;
	CommandFunction func;
	uint            minimumArgs;
}

class CommandException : Exception {
	this(string msg, string file = __FILE__, size_t line = __LINE__) {
		super(msg, file, line);
	}
}

class CommandManager {
	Command[] commands;

	this() {
		RegisterCommand(
			"help", &Commands_Help, 0,
			[
				"help <command>",
				"when command is not given, show the names of all registered commands",
				"when command is given, show information for that command"
			]
		);
		RegisterCommand(
			"exit", &Commands_Exit, 0,
			[
				"exit <status>",
				"when status is not given, exit with status 0",
				"when status is given, exit with that status"
			]
		);
		RegisterCommand(
			"set", &Commands_Set, 2,
			[
				"set [variable] [value]",
				"sets variable to value"
			]
		);
		RegisterCommand(
			"unset", &Commands_Unset, 1,
			[
				"unset [variable]",
				"deletes variable from the environment"
			]
		);
		RegisterCommand(
			"cd", &Commands_Cd, 1,
			[
				"cd [path]",
				"changes current working directory to [path]"
			]
		);
		RegisterCommand(
			"alias", &Commands_Alias, 2,
			[
				"alias [name] [command]",
				"sets an alias, so when you use a [name] command, it executes [command]"
			]
		);
	}
	void RegisterCommand(string name, CommandFunction func, uint min, string[] help) {
		commands ~= Command(name, help, func, min);
	}
	Command* GetCommand(string name) {
		foreach (ref cmd ; commands) {
			if (cmd.name == name) {
				return &cmd;
			}
		}
		return null;
	}
	void RunCommand(Command* cmd, string[] args) {
		if (args.length - 1 < cmd.minimumArgs) {
			throw new CommandException("Not enough arguments for this command");
		}
		cmd.func(args);
	}
}

CommandManager CommandManagerInstance() {
	static CommandManager instance;

	if (!instance) {
		instance = new CommandManager();
	}

	return instance;
}
