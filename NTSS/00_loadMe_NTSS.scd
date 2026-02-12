/*
This is a new loadMe for NTSS, which is based on the Biophony quark.
There are still Biophony-specific code files in here
which will be either integrated or removed/moved aside over time.

ServerOptions.devices.cs

*/

// works for macOS, to test for others
NTSS.defaults.inDevice = "X-USB"; // Behringer X-32 mixer in macOS
NTSS.defaults.outDevice = "X-USB";
NTSS.defaults.device = "X-USB";
NTSS.defaults.numInputBusChannels = 30;
NTSS.defaults.numOutputBusChannels = 32;
NTSS.defaults.memSize = 8192 * 32; // boost to 256MB for delaylines
NTSS.defaults.numAudioBusChannels = 2048;
NTSS.defaults.maxNodes = 4096;
NTSS.defaults.numWireBufs = 512;
NTSS.defaults.hardwareBufferSize = 256;


q = q ? ();

q.ntss = q.ntss ? ();
NTSS.ready = false;
q.topName = \N_T_S_S;

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


"speakerData.scd".postcs.loadRelative;

// number of Pepsi mixer channels (see David Tudor) as ProxyChains
NTSS.numPmcs = 16;

NTSS.numIOchans = NTSS.speakersOrder.size;
s.options.numOutputBusChannels = NTSS.numIOchans;

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

// These are still the names of Biophony inputs.
// they are dynamically overwriteable later in code!
q.inNames = q.inNames ? [
	\kiteMic, \richtMic, \funkMic1,\funkMic2,
	\micA_innen, \micB_innen, \micC_innen,
	\stringGang, \stringWind,
	\plonkBauL, \plonkBauM, \plonkBauR,
	\line1, \line2, \line3, \line4,
	\echoShure, \geoLom,
	\hydroWheel, \hydroFount,
	\angel, \arianeFunk
].collect { |name, i| ((i+1).asString ++ name).asSymbol }.postcs;


// make nameViews on NdefGuis etc better readable
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
Butz.add(\StartupDial, { StartupFile.dialog });
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

Butz(\NTSS).add(\SpatioScope, { WinBounds.showOrMake(\SpatioScope) });
Butz(\NTSS).add(\NdefMixer, { WinBounds.showOrMake(\NdefMixer) });
Butz(\NTSS).add(\Levels, { WinBounds.showOrMake(\Levels) });
Butz(\NTSS).add(\MainFX, { WinBounds.showOrMake(\MainFX) });
// put all ndefs that can be sources to an NTSS channel
// on one window as dragsources.
Butz(\NTSS).add(\allSrcNdefs, { WinBounds.showOrMake(\allSrcNdefs) });

// default groupNames
q.ndef = q.ndef ? ();
q.ndef.groupNames = q.ndef.groupNames ? [\ntssChan, \ntssPan];
"NdefMixer.scd".postcs.loadRelative;

WinBounds.addMake(\Levels, {
	s.meter.window.name_("Levels").moveTo(0,0);
});


// Note: Spatio gets added to end of s.defaultGroup,
// so it shows the signals BEFORE mainvol and speaker remapping.
// not sure why it sometimes needs stop/start before it shows again.

"spatio.scd".postcs.loadRelative;

"NTSS_save.scd".postcs.loadRelative;


/*
NTSS.showRing(\subs, false);
NTSS.showRing(\subs);
NTSS.showRing(\left, false);
NTSS.showRing(\left);
NTSS.showRing(\up, false);
NTSS.showRing(\up);
NTSS.showRing(\right, false);
NTSS.showRing(\right);
NTSS.showRing(\back, false);
NTSS.showRing(\back);
*/



// get all desired source Ndefs :
// everything audio except the chains and panners.
// can be modified, e.g. for use with NTMI.

NTSS.getSrcNdefs = {
	var sources = Ndef.all[s.name].envir.asArray;
	sources = sources.select { |px| px.rate == \audio };
	q.pchains.do { |chain|
		sources.remove(chain.proxy);
	};
	q.pchains.do { |chain|
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
	MainFX: Rect(803.0, 642.0, 500, 560),
) );

s.waitForBoot {
	Butz.numButz_(24).show;

	0.5.wait;
	"MainFX.scd".postcs.resolveRelative.loadPaths;

	s.volume = -12;

	"make q.buses".postln;
	q.bus_inside  = Bus.audio(s, 5);
	q.bus_outside = Bus.audio(s, 5);
	q.bus_shakers = Bus.audio(s, 5);
	q.bus_bigPA   = Bus.audio(s, 5);

	q.buses = [
		q.bus_inside,
		q.bus_shakers,
		q.bus_outside,
		q.bus_bigPA,
	];

	// make mono sources first:
	// try { "geo/geophoneReceiver.scd".postcs.loadRelative };
	// try { "geo/geoSim.scd".postcs.loadRelative };

	// play on all single channels
	// "one-shot-sampler.scd".postcs.loadRelative;

	// and others ...

	// get panner functions
	"chanPanFuncs.scd".postcs.loadRelative;

	// make Pepsi mixer channels (see David Tudor) as ProxyChains
	"chain1make.scd".postcs.loadRelative;

	NTSS.panNames = NTSS.panNames ? q.allPanNames;

	0.2.wait;

	"chanPanGuis.scd".postcs.loadRelative;
	"TopWindow.scd".postcs.loadRelative;
	"ntss_tester.scd".postcs.loadRelative;
	Butz.add('plotTree', { s.plotTree });

	0.1.wait;

	// "autopilot.scd".postcs.loadRelative;
	Butz.run('SpatioScope');
	Butz.run(q.topName);
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
