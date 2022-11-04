import std.stdio;
import std.string;
import readlineFunctions;
import lexer;
import interpreter;

void main(string[] args) {
	bool run        = true;
	bool dumpTokens = false;

	for (size_t i = 1; i < args.length; ++i) {
		if (args[i][0] == '-') {
			switch (args[i]) {
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
