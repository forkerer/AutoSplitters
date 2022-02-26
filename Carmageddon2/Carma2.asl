state("CARMA2_HW") {}

startup {
    vars.missions = new Dictionary<string, Dictionary<string, int>>
    {
     {"NICE BEAVER",                new Dictionary<string, int>() {{"Index", 0}, {"Group", 1 }}},
     {"ROCKY TOO",                  new Dictionary<string, int>() {{"Index", 1}, {"Group", 1 }}},
     {"CITY SLICKER",               new Dictionary<string, int>() {{"Index", 2}, {"Group", 1 }}},
     {"MISSION: BOULDER DASH",      new Dictionary<string, int>() {{"Index", 3}, {"Group", 1 }}},
     {"TWIN SHRIEKS",               new Dictionary<string, int>() {{"Index", 4}, {"Group", 2 }}},
     {"CITY OF THE LOST GIBLETS",   new Dictionary<string, int>() {{"Index", 5}, {"Group", 2 }}},
     {"GET YER ROCKS OFF",          new Dictionary<string, int>() {{"Index", 6}, {"Group", 2 }}},
     {"MISSION: EYE OF THE BEAVER", new Dictionary<string, int>() {{"Index", 7}, {"Group", 2 }}},
     {"HOME SWEET GROAN",           new Dictionary<string, int>() {{"Index", 8}, {"Group", 3 }}},
     {"TIMBER!",                    new Dictionary<string, int>() {{"Index", 9}, {"Group", 3 }}},
     {"STONED AGAIN",               new Dictionary<string, int>() {{"Index", 10}, {"Group", 3 }}},
     {"MISSION: OUTBREAK!",         new Dictionary<string, int>() {{"Index", 11}, {"Group", 3 }}},
     {"PISTE OFF",                  new Dictionary<string, int>() {{"Index", 12}, {"Group", 4 }}},
     {"SHOVE THY NEIGHBOUR",        new Dictionary<string, int>() {{"Index", 13}, {"Group", 4 }}},
     {"WOODY WOODWRECKER",          new Dictionary<string, int>() {{"Index", 14}, {"Group", 4 }}},
     {"MISSION: TRUCKING HELL",     new Dictionary<string, int>() {{"Index", 15}, {"Group", 4 }}},
     {"UNFAIR FUNFAIR",             new Dictionary<string, int>() {{"Index", 16}, {"Group", 5 }}},
     {"SNOW WAY OUT",               new Dictionary<string, int>() {{"Index", 17}, {"Group", 5 }}},
     {"WEST SIDE GORY",             new Dictionary<string, int>() {{"Index", 18}, {"Group", 5 }}},
     {"MISSION: IN COLD BLOOD",     new Dictionary<string, int>() {{"Index", 19}, {"Group", 5 }}},
     {"RUNWAY RUNAWAY",             new Dictionary<string, int>() {{"Index", 20}, {"Group", 6 }}},
     {"SCARE DEVIL",                new Dictionary<string, int>() {{"Index", 21}, {"Group", 6 }}},
     {"BOB SLAY",                   new Dictionary<string, int>() {{"Index", 22}, {"Group", 6 }}},
     {"MISSION: FAIR GRIND",        new Dictionary<string, int>() {{"Index", 23}, {"Group", 6 }}},
     {"SEAMAN SPLATTER",            new Dictionary<string, int>() {{"Index", 24}, {"Group", 7 }}},
     {"CON ROD AIR",                new Dictionary<string, int>() {{"Index", 25}, {"Group", 7 }}},
     {"ROLL UP, ROLL OVER",         new Dictionary<string, int>() {{"Index", 26}, {"Group", 7 }}},
     {"MISSION: CONTROL FREAK",     new Dictionary<string, int>() {{"Index", 27}, {"Group", 7 }}},
     {"SHEIK, RATTLE & ROLL",       new Dictionary<string, int>() {{"Index", 28}, {"Group", 8 }}},
     {"GOING DOWN",                 new Dictionary<string, int>() {{"Index", 29}, {"Group", 8 }}},
     {"AIRPAIN 3",                  new Dictionary<string, int>() {{"Index", 30}, {"Group", 8 }}},
     {"MISSION: HARD CORE",         new Dictionary<string, int>() {{"Index", 31}, {"Group", 8 }}},
     {"2 MINUTE WARNING",           new Dictionary<string, int>() {{"Index", 32}, {"Group", 9 }}},
     {"DUNE BUGGERED",              new Dictionary<string, int>() {{"Index", 33}, {"Group", 9 }}},
     {"DEFCON FUSED",               new Dictionary<string, int>() {{"Index", 34}, {"Group", 9 }}},
     {"MISSION: OIL BE BLOWED",     new Dictionary<string, int>() {{"Index", 35}, {"Group", 9 }}},
     {"NUCLEAR ARMS RACE",          new Dictionary<string, int>() {{"Index", 36}, {"Group", 10 }}},
     {"THE BRUISE BROTHERS",        new Dictionary<string, int>() {{"Index", 37}, {"Group", 10 }}},
     {"I WANT TO BEREAVE",          new Dictionary<string, int>() {{"Index", 38}, {"Group", 10 }}},
     {"MISSION: CARPOCALYPSE NOW",  new Dictionary<string, int>() {{"Index", 39}, {"Group", 10 }}}
    };

	// Misc settings
    settings.Add("misc", true, "Miscellaneous");
	settings.Add("loadTimeRemoval", false, "Load time removal - USE GAME TIME FOR TIMER", "misc");   
	
	
	// split modes
	settings.Add("splitMode", true, "Splitting mode");
	
	// New Game clear state splitting
    settings.Add("split_missions", true, "Missions 1st completion (any%)", "splitMode");
    for(int i = 1; i <= 10; i++)
        settings.Add("split_group_" + i, true, "GROUP " + i, "split_missions");

    foreach(var entry in vars.missions)
    {
        settings.Add(entry.Key, true, entry.Key, "split_group_" + entry.Value["Group"]);
    }
	
	// Split on each level finished
	settings.Add("split_mapEnd", false, "On any map end", "splitMode");
	
	// Split on each lap finished
	settings.Add("split_lap", false, "On each lap done", "splitMode");
	
	// Split on each ped killed
	settings.Add("split_peds", false, "Split on each ped killed", "splitMode");
	
	
	// Run start modes
	settings.Add("startModes", true, "Timer start modes");
	
	// On first mission started
	settings.Add("start_mapStarted", true, "On any map started", "startModes");
	
	
	// Run reset modes
	settings.Add("resetModes", true, "Timer reset modes");
	
	// On campaign aborted started
	settings.Add("reset_campaignAborted", true, "On campaign aborted", "resetModes");
	
	// On any map started (uses loading screen for compatiblity with run start mode)
	settings.Add("reset_loadingScreen", false, "On loading screen (before race starts)", "resetModes");
}

init {
    vars.missionWatchers = new List<Tuple<MemoryWatcher<bool>, StringWatcher>>();
    foreach(var item in vars.missions)
    {
        var flagAddr = 0x74D660 + item.Value["Index"] * 0x244 + 0x184;
        var flagWatcher = new MemoryWatcher<bool>(new IntPtr(flagAddr)) { Name = item.Key };
        
        var nameAddr = 0x74D660 + item.Value["Index"] * 0x244;
        var nameWatcher = new StringWatcher(new IntPtr(nameAddr), 32) { Name = item.Key + "_name"};

        var container = new Tuple<MemoryWatcher<bool>, StringWatcher>(flagWatcher, nameWatcher);
        vars.missionWatchers.Add(container);
    }

    vars.pedsWatcher = new MemoryWatcher<int>(new IntPtr(0x7447CC)) { Name = "Peds" };
    vars.mapStartedWatcher = new MemoryWatcher<int>(new IntPtr(0x676908)) { Name = "MapStarted" };
	vars.loadScreenWatcher = new MemoryWatcher<bool>(new IntPtr(0x694490)) { Name = "LoadingScreen" };
	vars.raceEndedWatcher = new MemoryWatcher<bool>(new IntPtr(0x6792C8)) { Name = "RaceEnded" };
	vars.lapsCounter = new MemoryWatcher<int>(new IntPtr(0x75B944)) { Name = "LapsCounter" };
}

update {
    foreach(var entry in vars.missionWatchers)
    {
        entry.Item1.Update(game);
        entry.Item2.Update(game);
    }

    vars.pedsWatcher.Update(game);
    vars.mapStartedWatcher.Update(game);
	vars.loadScreenWatcher.Update(game);
	vars.raceEndedWatcher.Update(game);
	vars.lapsCounter.Update(game);
}

split {
	if (settings["split_missions"]){
		foreach(var entry in vars.missionWatchers)
		{
			var name = ((string)entry.Item2.Current).Trim();
			var watcher = entry.Item1;
			if ((watcher.Current != watcher.Old) && (bool)watcher.Current && settings[name])
				return true;
		}
	}    

    if (settings["split_peds"])
    {
        var diff = (int)vars.pedsWatcher.Current - (int)vars.pedsWatcher.Old;
        if (diff > 0)
            return true;
    }
	
	if (settings["split_mapEnd"])
	{
		if ((int)vars.mapStartedWatcher.Current != 0)
		{
			if ((bool)vars.raceEndedWatcher.Current && !(bool)vars.raceEndedWatcher.Old)
				return true;
		}
	}
	
	if (settings["split_lap"])
	{
		if ((int)vars.mapStartedWatcher.Current != 0)
		{
			if ((int)vars.lapsCounter.Current > (int)vars.lapsCounter.Old)
				return true;
		}
	}
}

start {
	if (settings["start_mapStarted"])
		if ((int)vars.mapStartedWatcher.Current != 0 && (int)vars.mapStartedWatcher.Current != (int)vars.mapStartedWatcher.Old)
			return true;
}

reset {
	if (settings["reset_campaignAborted"])
	{
		if ((int)vars.mapStartedWatcher.Current == 0)
		{
			bool anyFinished = false;
			for (int i = 0; i<3; i++)
			{
				var watcher = vars.missionWatchers[i].Item1;
				if ((bool)watcher.Current)
				{
					anyFinished = true;
					break;
				}
			}

			if (!anyFinished)
				return true;
		}
	}   

	if (settings["reset_loadingScreen"])
	{
		if ((int)vars.mapStartedWatcher.Current == 0)
			if ((bool)vars.loadScreenWatcher.Current && !(bool)vars.loadScreenWatcher.Old)
				return true;
	}
}

isLoading {
	if (!settings["loadTimeRemoval"])
		return false;
		
	if ((bool)vars.loadScreenWatcher.Current)
		return true;
		
	return false;
}