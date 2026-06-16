/*** NTSS version

NEEDS UPDATE!!!!

This patch is for testing that all speakers work,
and for finding volume levels for each speaker
so they all sound similarly loud.

// first test with Tdef testHW:
// in MainFX, turn off mainMixer and shiftSpeakers;
// then check all spaekers are here:

MainFX(s).remove(\mainMixer);
MainFX(s).remove(\shiftSpeakers);

Tdef(\testHW).play;

~chans = (0..31); // all
~chans = (0..7);  // groups of 8
~chans = (8..15); // 5 here 3 empty
~chans = (16..23);
~chans = (24..31); // one empty

// set all amps equal
~amps = 1 ! 32;
// set all amps to last measured data
~amps = NTSS.hwRelAmps;

Tdef(\testHW).stop;

//////////////////////////////////////
// then test with Tdef testLogic:

MainFX(s).add(\mainMixer, 1);
MainFX(s).add(\shiftSpeakers, 1);
~chans = (0..27);

Tdef(\testLogic).play;

Tdef(\testLogic).stop;

***/

/**** Setup for 111 NTSS : ****/
(
q = q ? ();

// For Butz GUI:
NTSS.testpath = thisProcess.nowExecutingPath;

Butz(\NTSS).add(\TEST_NTSS, {
	w = Window("TEST_NTSS", Rect.aboutPoint(Window.availableBounds.center, 150, 100)).front;
	w.view.addFlowLayout;
	// Document.open(NTSS.testpath);
	TdefGui(Tdef(\testHW), 3, w.view);
	TdefGui(Tdef(\testLogic), 3, w);

});

Butz(\NTSS).add(\openBalance, {
	Document.open(NTSS.testpath);
});


// a simple pink noise burst
SynthDef(\pink, { |out, amp=0.1, sustain=1|
	Out.ar(out,
		PinkNoise.ar(
			XLine.ar(amp, amp * 0.01, sustain, doneAction: 2)
		)
	)
}).add;

/*
// test single chan by out number
(instrument: \pink, out: 0).play;

// test that all speakers run:
~chans = (0..NTSS.spk.data.lastIndex);

// check data
NTSS.spk.data.printAll;'';
NTSS.spk.ordered;
NTSS.spk.data .collect(_.hwOut).sort.plot

We measure amps on the logical order,
so MainFX has to have shiftSpeakers on!
*/



// init space for 32 hardware out amps
~amps = [
	1, 1, 1, 1,  1, 1, 1, 1,
	1, 1, 1, 1,  1, 1, 1, 1,
	1, 1, 1, 1,  1, 1, 1, 1,
	1, 1, 1, 1,  1, 1, 1, 1
];


// TO DO when making new setups:
// measure how much level adjustment each speaker needs,
// here for all 32 hardware outs.
// results should go into NTSS.hwRelAmps relAmp eventually.

/*
// compare one pair of speakers:
~chans = [0, 1];
~chans = (0..7); // first 8

~chans = (0..15); // first 8

~amps = NTSS.hwRelAmps
(
~amps = [
	2, 2, 2, 2, 2, // 5 kefs,
	1, 1, 1,       // 2 cabasses, gene0
	1, 0.5, 1, 0.4, // crypt3, wd12, braun2, cabass2
	0.5, 1, 1,   1, // wd11
	1, 1, 1, 1,  1, 1, 1, 1,
	1, 1, 1, 1,  1, 1, 1, 1
];
);

~chans = (0..4) ++ (12..15); // first 8
~chans = (12..15); //

*/
(
// balance tester Tdef
/*
Tdef(\testHW).play.gui;
*/
Tdef(\testHW).set(\speed, 1);
Tdef(\testHW).addSpec(\speed, [0.25, 4, \exp]);

~chans = (0..31);

Tdef(\testHW, { |env|

	inf.do { |i|
		var chan = ~chans.wrapAt(i);
		var spkDict = NTSS.spk.data[chan];
		var info = "% : %".format(chan, spkDict.name);
		"*** %\n".postf(info);
		env.speaker = info;
		(instrument: \pink,
			out: spkDict.hwOut,
			amp: 0.1 * ~amps[chan]
		).postln.play;
		(env.speed.reciprocal).max(0.1).wait;
	}
});

Tdef(\testLogic).set(\speed, 1);
Tdef(\testLogic).addSpec(\speed, [0.25, 4, \exp]);

Tdef(\testLogic, { |env|

	inf.do { |i|
		var chan = ~chans.wrapAt(i);
		var spkDict = NTSS.spk.ordered[chan];
		if (spkDict.isNil) {
			"*** no speaker at logicOut %!\n".postf(chan);
		} {
			var info = "% : %".format(chan, spkDict.name);
			"*** %\n".postf(info);
			env.speaker = info;
			(instrument: \pink,
				out: spkDict.logicOut,
				amp: 0.1
			).postln.play;
		};
		(env.speed.reciprocal).max(0.1).wait;
	};
});
);
)