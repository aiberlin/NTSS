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
NTSS.speakerData.postcs.loadRelative;

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

Butz.numButz = 12;
Butz.addMiniMax;
if (\StartupFile.asClass.notNil) {
	Butz.add(\StartupDial, { \StartupFile.asClass.dialog });
};
Butz.add(\SpatioScope, { WinBounds.showOrMake(\SpatioScope) });

// get all desired source Ndefs :
// everything audio except the chains and panners.
// can be modified, e.g. for use with NTMI.




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



	Butz.add('plotTree', { s.plotTree });

	0.1.wait;

	// "autopilot.scd".postcs.loadRelative;
	Butz.run('SpatioScope');

	0.2.wait;

	// turn sound on by default:
	MainFX(s).proxy.set(\mainvol, NTSS.mainvol ? 0.25);

	NTSS.ready = true;

	0.2.wait;

	MainFX(s).add(\aooReceive, 1);

	// put next setup script in NTSS.finalSetup,
	// so it runs here:
	NTSS.finalSetup;

};
