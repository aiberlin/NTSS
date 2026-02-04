/*
// test for one
NTSS.pmcSaveString(q.pchains[0]);

NTSS.saveDialog

// example: load setup automatically on startup
(
NTSS.finalSetup = {
	"/Users/adc/Desktop/adc0001.ntssSave.scd".loadPaths;
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
			var strings = [ "/*** NTSS Setup saved ***/" ];

			q.pchains.do { |pc|
				strings = strings.add(NTSS.pmcSaveString(pc));
			};

			file.write(strings.join("\n\n"));

			"*** NTSS setup saved at %\n\n".postf(path.cs);
		});
	});
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
			"MFdef('setPanner').(%, %, %);".format(pc,

				q.panNames.indexOf(panName),
				panName.cs
			)
		)
	};
	saveStrings.add(
		"MFdef('setSlots').(%, %);".format(pc, slots.cs)
	);
	saveStrings.add(
		"%.set(*%);".format(pc, pcSettings.flat.cs)
	);

	saveStrings.add(
		"%.set(*%);".format(panner, panSettings.flat.cs)
	);

	saveStrings.add(
		"%.set(*%);".format(panner, panSettings.flat.cs)
	);

	if (panner.monitor.isPlaying) {
		saveStrings.add(panner.playEditString);
	};

	saveStrings.join(Char.nl);

};
);