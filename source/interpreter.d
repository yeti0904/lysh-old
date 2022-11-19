import std.stdio;
import std.process;
import std.algorithm;
import std.exception;
import lexer;
import commandManager;
import aliasManager;

void Interpret(Lexer_Token[] tokens) {
	AliasManager aliases = AliasManager.Instance();

	for (size_t i = 0; i < tokens.length; ++i) {
		auto token = tokens[i];
		
		switch (token.type) {
			case Lexer_TokenType.End: break;
			case Lexer_TokenType.Command: {
				CommandManager cmds = CommandManagerInstance();

				if (aliases.AliasExists(tokens[i].contents)) {
					auto aliasTokens = Lexer_Lex(aliases.aliases[token.contents]);
					aliasTokens = aliasTokens.remove(aliasTokens.length - 1);
				
					tokens = tokens.remove(i);
					tokens =
						tokens[0 .. i] ~
						aliasTokens ~
						tokens[i .. $];
					token = tokens[i];
				}
				
				++ i;
				string[] args = [token.contents];
				string arg;
				while (
					(tokens[i].type != Lexer_TokenType.End) &&
					(tokens[i].type != Lexer_TokenType.Redirect) &&
					(tokens[i].type != Lexer_TokenType.Async)
				) {
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

				bool redirect = false;
				bool dontWait = false;
				File redirectTo;
				if (tokens[i].type == Lexer_TokenType.Redirect) {
					redirect = true;
					++ i;
					if (!(i < tokens.length)) {
						writeln("Redirect expects file path parameter");
						return;
					}
					try {
						redirectTo = File(tokens[i].contents, "w");
					}
					catch (ErrnoException e) {
						writefln("ErrnoException: %s", e.msg);
						return;
					}
				}
				else if (tokens[i].type == Lexer_TokenType.Async) {
					dontWait = true;
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
						if (redirect) {
							child = spawnProcess(
								args, stdin, redirectTo, redirectTo
							);
						}
						else {
							child = spawnProcess(args);
						}
					}
					catch (ProcessException e) {
						writefln("ProcessException: %s", e.msg);
						return;
					}

					if (dontWait) {
						writefln("[%d]", child.processID);
					}

					if (!dontWait) {
						try {
							wait(child);
						}
						catch (ProcessException e) {
							writefln("ProcessException: %s", e.msg);
							return;
						}
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
