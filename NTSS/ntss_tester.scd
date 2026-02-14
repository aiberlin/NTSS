/*** NTSS version

This patch is for testing that all speakers work,
and for finding volume levels for each speaker
so they all sound similarly loud.

// ~chans sets which speakers will test-play
~chans = (0..13); // (0..13) should play on first 14 speakers
Tdef(\bal).play;  // Tdef(\bal) plays sounds round-robin on ~chans

// test each speaker as pair against first
~chans = [0, 1];
~chans = [0, 2];
~chans = [0, 3];
~chans = [0, 14]; // sub 1
***/

/**** Setup for 111 NTSS : ****/
(
q = q ? ();

NTSS.speakers.size;
NTSS.speakersOrder;
NTSS.speakersActive;

// a simple noise burst
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
*/

// compare one pair of speakers:
~chans = [0, 1];

// test that all speakers run:
~chans = (0..NTSS.speakersActive.lastIndex);


// balance tester Tdef
Tdef(\tester).set(\speed, 1);
Tdef(\tester).addSpec(\speed, [0.25, 4, \exp]);

Tdef(\tester, { |env|
	env.info =
	inf.do { |i|
		var chan = ~chans.wrapAt(i);
		var spkName = NTSS.speakersActive[chan];
		var info = "% : %".format(chan, spkName);
		"*** %\n".postf(info);
		env.speaker = info;
		(instrument: \pink,
			out: chan,
			amp: 0.5
		).postln.play;
		(env.speed.reciprocal).max(0.1).wait;
	}
});

q.testpath = thisProcess.nowExecutingPath;

Butz(\NTSS).add(\TEST_NTSS, {
	// Document.open(q.testpath);
	Tdef(\tester).gui(3);
});

Butz(\NTSS).add(\openBalance, {
	Document.open(q.testpath);
});
);
