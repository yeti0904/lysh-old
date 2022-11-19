import std.stdio;
import std.ascii;
import std.string;

enum Lexer_TokenType {
	Command,
	Parameter,
	EnvVariable,
	Redirect,
	Async,
	End
}

struct Lexer_Token {
	Lexer_TokenType type;
	string          contents;
}

Lexer_Token[] Lexer_Lex(string input) {
	Lexer_Token[] ret;
	string        reading;
	bool          inString = false;

	input ~= '\0';

	for (size_t i = 0; i < input.length; ++i) {
		auto ch = input[i];
	
		switch (ch) {
			case '\\': {
				++ i;
				switch (input[i]) {
					case '\\': {
						reading ~= '\\';
						break;
					}
					case 'e': {
						reading ~= '\x1b';
						break;
					}
					case 'n': {
						reading ~= '\n';
						break;
					}
					case '$': {
						reading ~= '$';
						break;
					}
					default: {
						writefln("Unknown escape sequence: %c", input[i]);
						return [];
					}
				}
				break;
			}
			case '"': {
				if ((i != 0) && (input[i] - 1) == '\\') {
					reading ~= input[i];
					break;
				}
				inString = !inString;
				break;
			}
			case '&': {
				if (inString) {
					reading ~= input[i];
				}
				else {
					ret ~= Lexer_Token(
						Lexer_TokenType.Async, ""
					);
				}
				break;
			}
			case '>': {
				if (inString) {
					reading ~= input[i];
					break;
				}
				ret ~= Lexer_Token(
					Lexer_TokenType.Redirect,
					reading
				);
				reading = "";
				break;
			}
			case '$': {
				if ((i != 0) && (input[i - 1] == '\\')) {
					reading ~= input[i];
					break;
				}
				goto case;
			}
			case ';':
			case '\0':
			case '\n':
			case ' ': {
				if (inString && (ch == ' ')) {
					reading ~= input[i];
					break;
				}
				if (
					(ret.length != 0) &&
					(ret[ret.length - 1].type == Lexer_TokenType.Redirect) &&
					(reading != "")
				) {
					ret ~= Lexer_Token(
						Lexer_TokenType.Parameter,
						reading
					);
					reading = "";
				}
				else if (
					(
						(ret.length == 0) ||
						(ret[ret.length - 1].type == Lexer_TokenType.End)
					) &&
					(reading != "")
				) {
					ret ~= Lexer_Token(
						Lexer_TokenType.Command,
						reading
					);
					reading = "";
				}
				else if (reading != "") {
					ret ~= Lexer_Token(
						Lexer_TokenType.Parameter,
						reading
					);
					reading = "";
				}
				if ((ch == '\n') || (ch == '\0') || (ch == ';')) {
					ret ~= Lexer_Token(
						Lexer_TokenType.End,
						""
					);
				}

				if (ch == '$') {
					if ((i != 0) && (input[i - 1] == '\\')) {
						reading ~= ch;
						break;
					}

					++ i;
					if (input[i] != '(') {
						writefln("Expected ( after $");
						return [];
					}

					++ i;
					while ((input[i] != ')') && (input[i] != '\0')) {
						reading ~= input[i];
						++ i;
					}

					ret ~= Lexer_Token(
						Lexer_TokenType.EnvVariable,
						reading
					);
					reading = "";
				}
				break;
			}
			default: {
				reading ~= ch;
				break;
			}
		}
	}

	return ret;
}

string Lexer_TokenTypeToString(Lexer_TokenType type) {
	switch (type) {
		case Lexer_TokenType.Command: {
			return "command";
		}
		case Lexer_TokenType.Parameter: {
			return "parameter";
		}
		case Lexer_TokenType.EnvVariable: {
			return "envVariable";
		}
		case Lexer_TokenType.Redirect: {
			return "redirect";
		}
		case Lexer_TokenType.Async: {
			return "async";
		}
		case Lexer_TokenType.End: {
			return "end";
		}
		default: return "error";
	}
}

void Lexer_DumpTokens(Lexer_Token[] tokens) {
	foreach (i, token ; tokens) {
		writefln("(%u) %s: %s", i, Lexer_TokenTypeToString(token.type), token.contents);
	}
}
