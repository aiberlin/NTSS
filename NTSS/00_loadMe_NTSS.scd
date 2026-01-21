/*
this is a new loadMe for NTSS,
so we can keep Biophony loadMe for switching between both.
Then we can throw out all Biophony-only code here.

StartupFile.writeStartupFileToExternalPath('NTSS2', thisProcess.nowExecutingPath);
StartupFile.writeRedirectFile('NTSS2');
StartupFile.dialog;

ServerOptions.devices.cs
*/

//XConnect(\gencomp);

NTSS.defaults.inDevice = "X-USB"; // Behringer X-32 mixer in macOS
NTSS.defaults.outDevice = "X-USB";
NTSS.defaults.device = "X-USB";

q = q ? ();

q.ntss = q.ntss ? ();
q.ntss.ready = false;
q.topName = \N_T_S_S;

s.options.device = NTSS.device;
s.options.inDevice = NTSS.inDevice;
s.options.outDevice = NTSS.outDevice;
s.options.numInputBusChannels = 30;
s.options.memSize = 8192 * 32; // boost to 256MB for delaylines
s.options.numAudioBusChannels = 2048;
s.options.maxNodes = 4096;
s.options.numWireBufs = 512;
s.options.hardwareBufferSize = 256;
s.options.sampleRate = s.options.sampleRate ? 44100;


/*
z = [0.4, 0.35, 0.13, 0.13, 0.14, 0.15, 0.3, 0.7, 0.5, 0.5, 0.5, 0.5, 0.5, 0.4, 0.4, 0.32, 0.4, 0.5, 1, 0.8, 1, 0.6, 0.5, 0.3, 1, 1]
q.ntss.speakers.size
q.ntss.speakersDict[q.ntss.speakersActive[0]]
q.ntss.speakersActive.collect { |sp,i| [sp] ++ q.ntss.speakersDict[sp][..2] ++ [z[i]] }.do {|el| "%: [ %, %, %, %],".format(*el).postln }
*/

q.ntss.speakersDict = (
	//      x    y    z   amp
	bw5: [ 1.2, 5.3, 0.0, 0.4],
	bw6: [ -4.0, -1.0, 1.3, 0.35],
	cabass2: [ -0.5, 2.8, 0.8, 0.13],
	cabass0: [ -0.5, 2.9, 0.8, 0.13],
	cabass1: [ 6.0, 3.8, 3.5, 0.14],
	ldl7: [ 0.5, -1.0, 2.0, 0.15],
	ldl8: [ -3.5, 5.2, 0.0, 0.3],
	gene0: [ 2.0, -0.5, 1.0, 0.7],
	kef0: [ -3.0, 3.0, 3.2, 0.5],
	kef1: [ 0.5, 6.0, 3.2, 0.5],
	kef2: [ 0.5, -0.7, 3.2, 0.5],
	kef3: [ 1.5, 1.0, 2.9, 0.5],
	kef4: [ -3.5, 2.5, 3.0, 0.5],
	wd14: [ -3.5, 1.0, 0.5, 0.4],
	wd13: [ 6.0, 1.5, 1.0, 0.4],
	wd12: [ 1.5, 0.5, 0.2, 0.32],
	wd11: [ 3.5, 0.5, 0.2, 0.4],
	noname: [ 2.4, 4.0, 3.5, 0.5],
	braun1: [ 4.5, 2.0, 2.2, 1],
	braun2: [ -1.0, 3.8, 3.0, 0.8],
	crypt3: [ 5.5, 0.0, 0.0, 1],
	behring: [ 2.5, 3.0, 2.0, 0.6],
	cryptA: [ 4.5, -0.5, 1.0, 0.5],
	bluecab: [ 2.2, 5.5, 2.2, 0.3],
	sub0: [ 0.0, 0.0, 0.0, 1],
	sub1: [ -3.5, 2.8, 0.0, 1]
);


q.ntss.speakersOrder = [
	// 7 XLR outs from X32, 7 to Denon amp
	\bw5,
	\bw6,
	\cabass2,
	\cabass0,
	\cabass1,
	\ldl7,
	\ldl8,

	// last XLR out from X32
	\gene0,

	// 8 XLR outs from s16 to Stereo amps
	\kef0,
	\kef1,
	\kef2,
	\kef3,
	\kef4,

	\empty,
	\empty,
	\empty,

	// 5 JACK outs from s16-RME-ADAT to Yamaha Amp
	\wd14,
	\wd13,
	\wd12,
	\wd11,
	\noname,

	// 2 JACK outs from s16-RME-ADAT to stereo amp 1
	\braun1,
	\braun2,

	// 1 JACK out from s16-RME-ADAT to stereo amp 2
	\crypt3,

	// aux 1-6 from x32 to active speakers
	\behring,
	\cryptA,
	\bluecab,
	\empty,
	\empty,
	\empty,

	// monitor out
	\sub0,
	\sub1,
];

q.ntss.speakersActive = q.ntss.speakersOrder.reject {|spk| spk == \empty };
q.ntss.speakersTuning = q.ntss.speakersActive.collect {|spk| q.ntss.speakersDict[spk][3] };
q.ntss.speakers = q.ntss.speakersActive.collect {|key|
	var loc = q.ntss.speakersDict[key];
	[loc[0], loc[1], loc[2]]
}.flat.normalize(-0.85,0.85).reshape(q.ntss.speakersActive.size, 3);

//q.ntss.amp_names = q.ntss.speakers.size.collect {|i| "amp_%".format(i).asSymbol };
q.ntss.amp_names = q.ntss.speakersActive;

q.numPmcs = 16;
~num = q.ntss.speakersOrder.size;
~numIOchans = 32; // 16 for install, 24 for concert
~hideChanNdefs = false;

s.options.numOutputBusChannels = ~num;


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

// make them dynamically overwriteable later in code!
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


// make nameViews better readable
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
Butz(\NTSS).add(\N_T_S_S, {});
Butz(\NTSS).add(\SpatioScope, { WinBounds.showOrMake(\SpatioScope) });
Butz(\NTSS).add(\NdefMixer, { WinBounds.showOrMake(\NdefMixer) });
Butz(\NTSS).add(\Levels, { WinBounds.showOrMake(\Levels) });
Butz(\NTSS).add(\MainFX, { WinBounds.showOrMake(\MainFX) });
// put all ndefs that can be sources to an NTSS channel
// on one window as dragsources.
Butz(\NTSS).add(\allSrcNdefs, { WinBounds.showOrMake(\allSrcNdefs) });

"NdefMixer.scd".postcs.loadRelative;

WinBounds.addMake(\Levels, {
	s.meter.window.name_("Levels").moveTo(0,0);
});

WinBounds.addMake(\SpatioScope, {
	q.spat = SpatioScope.new(q.ntss.speakers.collect {|sp| Point(*sp)}, bounds: Rect(0,0,500,500));

	q.spat.magnify_(10);
	q.spat.parent.background_(Color.blue(0.5));
	// make amps semitransparent for overlapping speakers
	q.spat.ampAlpha = 0.5;

	q.spat.ampViews.do(_.stringColor_(Color.white));
	q.spat.ampViews.do {|view,i|
		view.string = q.ntss.speakersActive[i];
		view.mouseDownAction = {
			var name = q.ntss.speakersActive[i];
			"*** q.spat: %, %: %\n".postf(i, name,
				q.ntss.speakersDict[name]
			);
		};
	};
	q.spat.parent.moveTo(120, 480);
	q.spat.parent
});

// get all desired source Ndefs :
// everything audio except the chains and panners,
q.ntss.getSrcNdefs = {
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
		*q.ntss.getSrcNdefs.collect { |ndef|
			DragSource(w).object_(ndef) }.clump(4)
	);
	w;
});


WinBounds.stored.putAll( (
	N_T_S_S: Rect(520, Window.availableBounds.height - 430, 900, 450),
	SpatioScope: Rect(120, 540, 500, 500),
	NdefMixer: Rect(120, 300, 1086.0, 500),
	Levels: Rect(0, 0, 58 + (~numIOchans * 38), 230.0),
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

	// get biophony panner functions
	"chanPanFuncs.scd".postcs.loadRelative;

	"chain1make.scd".postcs.loadRelative;

	0.2.wait;

	"chanPanGuis.scd".postcs.loadRelative;
	"TopWindow.scd".postcs.resolveRelative.loadPaths;

	// ("audio buses top: " + s.audioBusAllocator.top).postcs;
	// ("bufs top: " + s.bufferAllocator.top).postcs;

	0.1.wait;

	// "autopilot.scd".postcs.loadRelative;
	Butz.run('SpatioScope');
	Butz.run(q.topName);

	0.2.wait;

	WinBounds.restoreAll;
	q.ntss.ready = true;
	q.ntss.finalSetup;
};
