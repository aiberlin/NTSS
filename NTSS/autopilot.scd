/*
This is still for Biophony,
but it could be nicely adapted for NTSS,
esp. when soundfile collections are added.

Tdef(\AUTOPILOT).gui;
*/

Butz.add(\AUTOPILOT, { WinBounds.showOrMake(\AUTOPILOT) });
WinBounds.addMake(\AUTOPILOT, {
	var tdgui = Tdef(\AUTOPILOT).gui(5);
	var win = tdgui.parent.name_(\AUTOPILOT);
	tdgui.nameBut.font_(Font("Helvetica", 14))
	.states_(tdgui.nameBut.states.put(0, [\AUTOPILOT, Color.white, Color.blue]));
	win
});

Butz.run(\AUTOPILOT);

Tdef(\AUTOPILOT).addSpec(\rndChans, [1, 8, \lin, 1]);
Tdef(\AUTOPILOT).addSpec(\nextTime, [0, 180, \lin, 1]);
Tdef(\AUTOPILOT).addSpec(\maxNext, [5, 180, \exp, 1]);

Tdef(\AUTOPILOT).set(\rndChans, [6, 8]);
Tdef(\AUTOPILOT).set(\maxNext, 20);
Tdef(\AUTOPILOT).set(\nextTime, 1);

Tdef(\AUTOPILOT, { |env|

	loop {
		// use ch5-8 for AUTOPILOT?
		var pch = q.pchains.at(env.rndChans.asInteger - 1).choose;
		// always show its gui?
		// Butz.run(pch.key);
		pch.proxy.send;
		// open its mic/line input
		// pch.set(\micAmp, 0.2);

		"\n - AUTOPILOT: -".postln;
		pch.postln;

		MFdef(\findSoundfiles).();

			// drop a new soundfile on it
		if (0.5.coin or: { pch.getHalo.mybuf.path.isNil }) {
			MFdef(\setSndfile.postln).(pch, q.bio.soundfiles.choose)
		};

		if (0.5.coin) {
			// or switch panning algorithm
			MFdef(\setPanner.postln).(pch, q.panNames.size.rand)
		};

		if (0.5.coin) {
			// or randomize panning params
			MFdef(\randPanPars.postln).(pch, exprand(0.1, 0.4))
		};

		// add or subtract or jiggle an effect?
		if (0.5.coin) {
			// or randomize panning params
		// 	MFdef(\randFXchain.postln).(pch, exprand(0.1, 0.4))
		};

		pch.getHalo.panner.postln.play;

		env.nextTime = (exprand(0.1, 1) * env.maxNext).round;
		while { env.nextTime > 0 } {
			env.nextTime = min(env.maxNext, env.nextTime) - 1;
			1.wait;
		};
	}
}).clock_(AppClock);

