/*** NTSS version

This patch is for testing that all speakers work,
and for finding volume levels for each speaker
so they all sound similarly loud.

// ~chans sets which speakers will test-play
~chans = (0..13); // (0..13) should play on first 14 speakers
// Tdef(\tester) plays sounds round-robin on ~chans,
with relAmp from
Tdef(\tester).play;
NTSS.spk.find = { |dict, name|
	NTSS.spk.data.detect { |dict| dict.name == name }
};
NTSS.spk.find(\bw6).relAmp;


().find
***/

/**** Setup for 111 NTSS : ****/
(
q = q ? ();
// the old system of names
NTSS.speakersOrder.postcs.size; // all 32 names, 4 empty
NTSS.speakersActive.postcs.size; // the 28 active ones in logical order
NTSS.speakers.size; //

// For Butz GUI:
NTSS.testpath = thisProcess.nowExecutingPath;

Butz(\NTSS).add(\TEST_NTSS, {
	// Document.open(NTSS.testpath);
	Tdef(\tester).gui(3);
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
NTSS.spk.active;
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


// TO BE DONE at 111:
// measure how much level adjustment each speaker needs,
// here for all 32 hardware outs.
// results should go into relAmp eventually.

/*
// compare one pair of speakers:
~chans = [0, 1];
~chans = (0..7); // first 8

~chans = (0..15); // first 8

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
Tdef(\tester).play.gui;
*/
Tdef(\tester).set(\speed, 1);
Tdef(\tester).addSpec(\speed, [0.25, 4, \exp]);

~chans = (0..31);

Tdef(\tester, { |env|

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
);
)