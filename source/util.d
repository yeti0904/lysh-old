import std.process;

string Util_GetConfigPath() {
	string ret;
	version(Windows) {
		ret = environment.get("APPDATA");
		if (ret is null) {
			ret = environment.get("programfiles");
			if (ret is null) {
				return ".";
			}

			return ret;
		}

		return ret;
	}
	else version(Posix) {
		ret = environment.get("HOME");
		if (ret is null) {
			return ".";
		}
		return ret ~ "/.config";
	}
	else {
		return ".";
	}
}
