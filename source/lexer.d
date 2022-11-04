import std.stdio;
import std.ascii;
import std.string;

enum Lexer_TokenType {
	Command,
	Parameter,
	End
}

struct Lexer_Token {
	Lexer_TokenType type;
	string          contents;
}

Lexer_Token[] Lexer_Lex(string input) {
	Lexer_Token[] ret;
	string        reading;

	input ~= '\0';

	foreach (char ch ; input) {
		switch (ch) {
			case '\0':
			case '\n':
			case ' ': {
				if (
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
				if ((ch == '\n') || (ch == '\0')) {
					ret ~= Lexer_Token(
						Lexer_TokenType.End,
						""
					);
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
