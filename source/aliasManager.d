class AliasManager {
	string[string] aliases;

	static AliasManager Instance() {
		static AliasManager instance;

		if (!instance) {
			instance = new AliasManager;
		}

		return instance;
	}
	bool AliasExists(string name) {
		return (name in aliases) !is null;
	}
}
