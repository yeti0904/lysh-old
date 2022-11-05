import std.stdio;
import std.process;
import lexer;
import commandManager;

void Interpret(Lexer_Token[] tokens) {
	for (size_t i = 0; i < tokens.length; ++i) {
		auto token = tokens[i];
		
		switch (token.type) {
			case Lexer_TokenType.End: break;
			case Lexer_TokenType.Command: {
				string[] args       = [token.contents];
				CommandManager cmds = CommandManagerInstance();
				
				++ i;
				string arg;
				while (tokens[i].type != Lexer_TokenType.End) {
					switch (tokens[i].type) {
						case Lexer_TokenType.Parameter: {
							arg  ~= tokens[i].contents;
							args ~= [arg];
							arg   = "";
							break;
						}
						case Lexer_TokenType.EnvVariable: {
							arg ~= environment.get(tokens[i].contents, "");
							break;
						}
						default: {
							writefln(
								"Unexpected token %s: %s",
								Lexer_TokenTypeToString(tokens[i].type),
								tokens[i].contents
							);
							return;
						}
					}
					++ i;
				}

				if (arg != "") {
					args ~= [arg];
				}

				Command* cmd = cmds.GetCommand(args[0]);
				if (cmd) {
					try {
						cmds.RunCommand(cmd, args);
					}
					catch (CommandException e) {
						writefln("CommandException: %s", e.msg);
						return;
					}
				}
				else {
					Pid child;
					try {
						child = spawnProcess(args);
					}
					catch (ProcessException e) {
						writefln("ProcessException: %s", e.msg);
						return;
					}

					try {
						wait(child);
					}
					catch (ProcessException e) {
						writefln("ProcessException: %s", e.msg);
						return;
					}
				}
				break;
			}
			default: {
				writefln(
					"Unexpected token %s: %s",
					Lexer_TokenTypeToString(tokens[i].type), tokens[i].contents
				);
				return;
			}
		}
	}
}

void InterpretText(string text) {
	auto tokens = Lexer_Lex(text);
	Interpret(tokens);
}
