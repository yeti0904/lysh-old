import std.stdio;
import std.string;
import readlineFunctions;
import lexer;
import interpreter;

const string usage = `
Usage: ysh [-dt/--dump-tokens]

-dt/--dump-tokens:
    Prints out all tokens after a command is typed in
`;

void main(string[] args) {
	bool run        = true;
	bool dumpTokens = false;

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
				default: {
					writefln("Unrecognised parameter: %s", args[i]);
					break;
				}
			}
		}
	}

	while (run) {
		string input  = Readline("$ ");
		auto   tokens = Lexer_Lex(input);
		if (dumpTokens) {
			Lexer_DumpTokens(tokens);
		}
		Interpret(tokens);
	}
}
