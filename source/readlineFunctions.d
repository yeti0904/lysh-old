import std.string;
import core.stdc.stdlib;

extern(C) char* readline(const char*);

string Readline(string prompt) {
	char*  input = readline(toStringz(prompt));
	string ret = fromStringz(input).idup;
	free(input);
	return ret;
}
