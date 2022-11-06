import std.file;
import std.stdio;
import std.string;
import std.process;
import readlineFunctions;
import lexer;
import interpreter;
import commandManager;
import commands;
import util;
import prompt;

const string usage = `
Usage: ysh [-dt/--dump-tokens]

-dt/--dump-tokens:
    Prints out all tokens after a command is typed in
`;

const string appName    = "lysh";
const string appVersion = "v0.1.0";

void main(string[] args) {
	bool   run           = true;
	bool   dumpTokens    = false;
	string defaultPrompt = environment.get("USER", "") == "root"? "# " : "$ ";

	environment["SHELL"] = args[0];
	
	for (size_t i = 1; i < args.length; ++i) {
		if (args[i][0] == '-') {
			switch (args[i]) {
				case "-h":
				case "--help": {
					writeln(usage);
					run = false;
					break;
				}
				case "-dt":
				case "--dump-tokens": {
					dumpTokens = true;
					break;
				}
				case "-v":
				case "--version": {
					writefln("%s %s", appName, appVersion);
					break;
				}
				default: {
					writefln("Unrecognised parameter: %s", args[i]);
					break;
				}
			}
		}
	}

	CommandManager cmds = CommandManagerInstance();

	// run rc file
	string rcFilePath = Util_GetConfigPath() ~ "/lyshrc";
	bool   runConfig  = true;
	if (!exists(rcFilePath)) {
		std.file.write(rcFilePath, []);
	}
	InterpretText(readText(rcFilePath));

	using_history(); // set up readline history

	while (run) {
		string prompt = environment.get("LYSH_PROMPT");
		if (prompt is null) {
			prompt = defaultPrompt;
		}
	
		string input  = Readline(CreatePrompt(prompt));
		Readline_AddHistory(input);
		auto   tokens = Lexer_Lex(input);
		if (dumpTokens) {
			Lexer_DumpTokens(tokens);
		}
		Interpret(tokens);
	}
}
