/*
NTSS state can e saved as code file to reload later,
e.g. as setup file on startup.

// test for one proxychain
NTSS.pmcSaveString(NTSS.pchains[0]);

// whole setup save as string
NTSS.saveString;

// as text document to save by hand:
NTSS.document

// by dialog
NTSS.saveDialog;

// example to load setup automatically on startup
(
NTSS.finalSetup = {
	("/Users/adc/Desktop/ntss_curr/mytestsave.ntssSave.scd").loadPaths;
};
NTSS.run;
)
*/

(
NTSS.saveDialog = {
	Dialog.savePanel ({ |path|
		if (path.endsWith(".ntssSave.scd").not) {
			path = path ++ ".ntssSave.scd";
		};
		File.use(path, "w", { |file|
			file.write(NTSS.saveString);
			"*** NTSS setup saved at %\n\n".postf(path.cs);
		});
	});
};


NTSS.saveString = {
	var strings = List[ "/*** NTSS Setup saved on % ***/".format(Date.getDate.stamp), "" ];
	NTSS.pchains.do { |pc|
		strings.add(NTSS.pmcSaveString(pc));
	};
	strings.add( "// Add more things to setup here: \n\n" );
	strings.join("\n\n");
};

NTSS.document = {
	Document("NTSS_%.ntssSave.scd".format(Date.getDate.stamp), NTSS.saveString);
};



NTSS.loadDialog = {
	Dialog.openPanel({ |path|
		path.postln;
		try { path.loadPaths };
	});
};


NTSS.pmcSaveString = { |dict, pc|
	// save proxychain:
	// activeSlots, settings,
	/// halo - micChan, src, sndfile,
	// attached panner:
	// which panMode, settings

	var halo = pc.getHalo;
	var panner = halo.panner;
	var panName = halo.panName;

	var path = pc.getHalo(\mybuf).path;
	var srcNdef = pc.getHalo(\src);
	var slots = pc.activeSlotNames;
	var pcSettings = pc.proxy.getKeysValues;
	var panSettings = panner.getKeysValues;

	var saveStrings = List[
		"/*** saved %: ***/".format(pc) ];

	if (path.notNil) {
		saveStrings.add(
			"MFdef('setSndfile').(%, %);".format(pc, path.cs)
		)
	};
	if (srcNdef.notNil) {
		saveStrings.add(
			"MFdef('setSrc').(%, %);".format(pc, srcNdef)
		)
	};
	if (panName.notNil) {
		saveStrings.add(
			"MFdef('setPanner').(%, %, %);".format(pc, panName.cs)
		)
	};
	saveStrings.add(
		"MFdef('setSlots').(%, %);".format(pc, slots.cs)
	);
	saveStrings.add(
		"%.set(*%);".format(pc, pcSettings.flat.cs)
	);

	saveStrings.add("// panner:");
	saveStrings.add(
		"%.set(*%);".format(panner, panSettings.flat.cs)
	);

	if (panner.monitor.isPlaying) {
		saveStrings.add(panner.playEditString);
	};

	saveStrings.join(Char.nl);

};
);