import std.string;
import core.stdc.stdlib;

// readline

extern(C) char* readline(const char*);

string Readline(string prompt) {
	char*  input = readline(toStringz(prompt));
	string ret = fromStringz(input).idup;
	free(input);
	return ret;
}

// readline history

extern(C) void using_history();
extern(C) void add_history(const char*);

void Readline_AddHistory(string toAdd) {
	add_history(toStringz(toAdd));
}
