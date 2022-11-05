import std.stdio;
import std.conv;
import std.process;
import core.stdc.stdlib;
import commandManager;

void Commands_Help(string[] args) {
	CommandManager cmds = CommandManagerInstance();
	if (args.length <= 1) {
		writeln("Available commands:");
		foreach (i, cmd ; cmds.commands) {
			writef("%s%s", cmd.name, i == cmds.commands.length - 1? "" : ", ");
		}
		writeln("");
	}
	else {
		Command* cmd = cmds.GetCommand(args[1]);
		if (!cmd) {
			writefln("No such command: %s", cmd);
			return;
		}
		foreach (line ; cmd.help) {
			writeln(line);
		}
	}
}

void Commands_Exit(string[] args) {
	if (args.length <= 1) {
		exit(0);
	}
	else {
		try {
			exit(parse!uint(args[1]));
		}
		catch (Throwable) {
			writeln("Non-integer argument");
			return;
		}
	}
}

void Commands_Set(string[] args) {
	environment[args[1]] = args[2];
}

void Commands_Unset(string[] args) {
	environment[args[1]] = null;
}
