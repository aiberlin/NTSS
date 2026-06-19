/*
This is a new loadMe for NTSS, which is based on the Biophony quark.
There are still Biophony-specific code files in here
which will be either integrated or removed/moved aside over time.

ServerOptions.devices.cs

*/
// get all defaults first:
(NTSS.dir.setup +/+ "defaults.scd".postln).loadPaths;

q = q ? ();

NTSS.ready = false;

// server settings from defaults, or set before NTSS.run:
s.options.inDevice = s.options.inDevice ? NTSS.inDevice;
s.options.outDevice = s.options.outDevice ? NTSS.outDevice;
if (s.options.device.isKindOf(Array).not) { s.options.device = s.options.device ? NTSS.device };

s.options.numInputBusChannels = NTSS.numInputBusChannels;
s.options.numOutputBusChannels = NTSS.numOutputBusChannels;
s.options.memSize =NTSS.memSize;
s.options.numAudioBusChannels = NTSS.numAudioBusChannels;
s.options.maxNodes = NTSS.maxNodes;
s.options.numWireBufs = NTSS.numWireBufs;
s.options.hardwareBufferSize = NTSS.hardwareBufferSize;

// if sampleRate was already set, keep it
if (NTSS.sampleRate.notNil) {
	s.options.sampleRate = NTSS.sampleRate;
};

"*** NTSS.speakerData: ".post;
NTSS.speakerDataPath = NTSS.speakerData.resolveRelative.postcs;
NTSS.speakerData.loadRelative;



// number of Pepsi mixer channels (see David Tudor) as ProxyChains
"NTSS.numPmcs: %\n".postf(NTSS.numPmcs);

// general specs for everything
Spec.add(\amp4, [0, 4, \amp]);
Spec.add(\amp10, [0, 10, 4.4]);
Spec.add(\level, \amp4);
Spec.add(\gain, \amp4);
Spec.add(\direct, \amp);
Spec.add(\feedback, \amp);

Spec.add(\micBus, [-5, 5]);

Spec.add(\pos, \pan);
Spec.add(\width, [2, 8, \exp]);
Spec.add(\rotate2, [-5, 5]);
Spec.add(\rate2, [-5, 5]);

Spec.add(\delaytime, [0.01, 10, \exp]);

Spec.add(\loop, \unipolar);

// utility: make nameViews on NdefGuis etc better readable
q.tuneNameView = { |q, obj|
	var nameFont = Font(Font.defaultSansFace, 14);
	if (obj.respondsTo(\nameView)) { obj = obj.nameView };
	if (obj.isKindOf(View)) {
		obj.font_(nameFont)
		.stringColor_(Color.white)
		.background_(Color.blue)
	} {
		"q.tuneNameView: obj % has/is no nameView.".postf(obj.cs)
	};
	obj
};

/*
g = NdefGui(Ndef(\x));
q.tuneNameView(g);
*/

// General GUIs

Butz.numButz = 24;
Butz.addMiniMax;
if (\StartupFile.asClass.notNil) {
	Butz.add(\StartupDial, { \StartupFile.asClass.dialog });
};
Butz.add(\SpatioScope, { WinBounds.showOrMake(\SpatioScope) });
Butz.add(\NdefMixer, { WinBounds.showOrMake(\NdefMixer) });
Butz.add(\Levels, { WinBounds.showOrMake(\Levels) });
Butz.add(\MainFX, { WinBounds.showOrMake(\MainFX) });
Butz.add(\N_T_S_S, {});

// put NTSS specifics in its own Butz:
Butz('NTSS').addMiniMax;
Butz(\NTSS).add(\N_T_S_S, {});
Butz(\NTSS).add(\LOAD, { NTSS.loadDialog });
Butz(\NTSS).add(\SAVE, { NTSS.saveDialog });
Butz(\NTSS).add(\TEST_NTSS, { });

Butz(\NTSS).add(\SpatioScope, { WinBounds.showOrMake(\SpatioScope) });
Butz(\NTSS).add(\NdefMixer, { WinBounds.showOrMake(\NdefMixer) });
Butz(\NTSS).add(\Levels, { WinBounds.showOrMake(\Levels) });
Butz(\NTSS).add(\MainFX, { WinBounds.showOrMake(\MainFX) });
// put all ndefs that can be sources to an NTSS channel
// on one window as dragsources.
Butz(\NTSS).add(\allSrcNdefs, { WinBounds.showOrMake(\allSrcNdefs) });

Butz(\NTSS).add(\nanoNTSS, { WinBounds.showOrMake(\nanoNTSS) });


// default groupNames
q.ndef = q.ndef ? ();
q.ndef.groups = q.ndef.groups ? ();
q.ndef.groups.put(\all, { Ndef.dictFor(s) });
q.ndef.groupNames = q.ndef.groupNames ? [\all,\ntssChan, \ntssPan];
"NdefMixer.scd".postcs.loadRelative;

WinBounds.addMake(\Levels, {
	s.meter.window.name_("Levels").moveTo(0,0);
});

"NTSS_save.scd".postcs.loadRelative;

// get all desired source Ndefs :
// everything audio except the chains and panners.
// can be modified, e.g. for use with NTMI.

NTSS.getSrcNdefs = {
	var sources = Ndef.all[s.name].envir.asArray;
	sources = sources.select { |px| px.rate == \audio };
	NTSS.pchains.do { |chain|
		sources.remove(chain.proxy);
		sources.remove(chain.getHalo(\panner));
	};
	sources.sort { |a, b| a.key < b.key };
};

WinBounds.addMake(\allSrcNdefs, {
	w = Window("allSrcNdefs", Rect(500, 13.0, 400.0, 400.0)).front;
	w.background_(Color.grey);
	w.view.layout = GridLayout.rows(
		*NTSS.getSrcNdefs.collect { |ndef|
			DragSource(w).object_(ndef) }.clump(4)
	);
	w;
});


WinBounds.stored.putAll( (
	N_T_S_S: Rect(520, Window.availableBounds.height - 430, 900, 450),
	SpatioScope: Rect(120, 540, 500, 500),
	NdefMixer: Rect(120, 300, 1086.0, 500),
	Levels: Rect(0, 0, 58 + (s.options.numOutputBusChannels * 38), 230.0),
	MainFX: Rect(803.0, 642.0, 500, 640),
) );

// reboot by default, because we NTSS needs its settings:
if (NTSS.reboot) {
	"*** NTSS.rebooting...".postln;
	s.reboot;
} {
	if (s.serverRunning.not) {
		"*** NTSS.boot...".postln;
		s.boot
	}
};

"nanoNTSS.scd".loadRelative;

s.doWhenBooted {

	"*** NTSS has booted.".postln;
	Butz.numButz_(24).show;

	s.sync;
	// Note: Spatio has its own bus that it reads from,
	// and mainFX writes to that bus in the LOGICAL order of  speakers.
	// the remapping to the physical order of the speakers comes later,
	// at the end of the chain.
	"spatio.scd".postcs.loadRelative;

	s.sync;

	if (\Aoo.asClass.notNil) {
		"AudioOverOSC.scd".postcs.resolveRelative.loadPaths;
	};

	"MainFX.scd".postcs.resolveRelative.loadPaths;
	"ntss_tester.scd".postcs.loadRelative;

	s.volume = 0;

	// load panner functions
	"ringPanFuncs.scd".postcs.loadRelative;
	"chanPanFuncs.scd".postcs.loadRelative;
	"ringPanFuncs2.scd".postcs.loadRelative;
	"spatPanFuncs2.scd".postcs.loadRelative;

	NTSS.panNames = NTSS.panNames ? NTSS.allPanNames;

	// make Pepsi Mixer Channels (see David Tudor) as ProxyChains
	"chain1make.scd".postcs.loadRelative;

	0.2.wait;

	// load GUI code
	"chanPanGuis.scd".postcs.loadRelative;
	"TopWindow.scd".postcs.loadRelative;
	Butz.add('plotTree', { s.plotTree });

	0.1.wait;

	// "autopilot.scd".postcs.loadRelative;
	Butz.run('SpatioScope');
	Butz.run(NTSS.topName);
	Butz.curr_('NTSS');

	0.2.wait;

	// turn sound on by default:
	MainFX(s).proxy.set(\mainvol, NTSS.mainvol ? 0.25);

	WinBounds.restoreAll;
	NTSS.ready = true;

	// put next setup script in NTSS.finalSetup,
	// so it runs here:
	NTSS.finalSetup;

};
