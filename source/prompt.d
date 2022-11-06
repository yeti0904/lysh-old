import std.stdio;
import std.file;
import std.array;
import std.string;
import std.process;

string CreatePrompt(string input) {
	string cwd;
	try {
		cwd = getcwd();
	}
	catch (FileException) {
		cwd = "(err)";
	}
	cwd = cwd.replace(environment.get("HOME", ""), "~");
	string user = environment.get("USER", "(err)");
	string hostname;
	try {
		hostname = chomp(readText("/etc/hostname"));
	}
	catch (Throwable) {
		hostname = "(err)";
	}

	string ret;
	input ~= '\0';
	for (size_t i = 0; i < input.length; ++i) {
		switch (input[i]) {
			case '/': {
				++ i;
				switch (input[i]) {
					case 'w': {
						ret ~= cwd;
						break;
					}
					case 'u': {
						ret ~= user;
						break;
					}
					case 'h': {
						ret ~= hostname;
						break;
					}
					default: {
						ret ~= "/" ~ input[i];
						break;
					}
				}
				break;
			} /*
			case '\\': {
				++ i;
				switch (input[i]) {
					case '\\': {
						ret ~= '\\';
						break;
					}
					case 'e': {
						ret ~= '\x1b';
						break;
					}
					case 'n': {
						ret ~= '\n';
						break;
					}
					default: {
						writefln("Unknown escape sequence: %c", input[i]);
						ret ~= "err";
						break;
					}
				}
				break;
			} */
			default: {
				ret ~= input[i];
				break;
			}
		}
	}

	return ret;
}
