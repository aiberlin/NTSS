/* aggregate device UMC_NTSS:
 UMC Bruno is ADAT -> 20 chans 32
 UMC adc is SPDIF -> 12 chan, chan 8 is broken.

0-9: Bruno analog out
-> 0-4 to Yam1 AVR, -> kef 0-4
5-9 go to Yam2 ??

///// 10/11 SPIDF, skip!
12..19: ADAT
12-18 go to Denon 1-7, bodenring 6 passive + 1 aktive
19 (ADAT 8) goes to sub

/// UMC 2 TOP Analog outs
20-26, 28 :
-> kleine amps 1-4 (x2chan)
//// 27: (Ana 7) kaputt, skip

29 ? free

//// 30, 31 SPDIF, skip

4 aktive:

{ PinkNoise.ar(0.25) ! 32 }.scope

Ndef(\x, { PinkNoise.ar(0.25) }).gui
{ PinkNoise.ar(0.25) ! 32 }.scope

s.meter

*/

(
// all speaker data go here:
NTSS.spk = NTSS.spk ? ();
NTSS.spk.setupName = "Hosek";
NTSS.spk.data; // the current speaker set

NTSS.spk.numLogicOuts = 28; // currently
NTSS.spk.numHWOuts = 32;

// possible SpatioScope background image:
// NTSS.spatImagePath = // NTSS.dir.setup +/+ "Kuppel.png";

NTSS.spk.data = List[

	/*** on Mixer  ****/
	///// group kefs as up, right font is 0, clockwise
	(name: \kef0, 	x:  1.5, y:  4, z: 2.2, 	logicOut: 0, hwOut:  0, path: \yam1_FL, hpf: 100 ),
	(name: \kef1, 	x:  1,   y: -1, z: 2.2, 	logicOut: 1, hwOut:  1, path: \yam1_FR, hpf: 100 ),
	(name: \kef2, 	x:  0,   y: -4.2, z: 2.2, 	logicOut: 2, hwOut:  2, path: \yam1_SL, hpf: 100 ),
	(name: \kef3, 	x: -1,   y: -1, z: 2.2, 	logicOut: 3, hwOut:  3, path: \yam1_SR, hpf: 100 ),
	(name: \kef4, 	x: -1,   y:  4, z: 2.2, 	logicOut: 4, hwOut:  4, path: \yam1_C, hpf: 100 ),

	// center line
	// which cabasse is where?
	(name: \cabass2, x: 0.2, y:  -0.3, z: 0.0,  logicOut: 5, hwOut:  5, path: \yam2_FL, hpf: 60 ),
	(name: \cabass0, x: 0.2, y:   0.3, z: 0.0, 	logicOut: 6, hwOut:  6, path: \yam2_FR, hpf: 60 ),
	(name: \cabass1, x: -0.3, y:  0.0, z: 0.0,  logicOut: 7, hwOut:  7, path: \yam2_SL, hpf: 60 ),
	(name: \ldl7,    x: 0.0, y:  4.5, z: 0.0,  	logicOut: 8, hwOut:  8, path: \yam2_SR, hpf: 40 ),
	(name: \ldl8,    x: 0.0, y: -5.0, z: 0.0,  	logicOut: 9, hwOut:  9, path: \yam2_C,  hpf: 40 ),

	(name: \empty,  x:   0.0, y:  0.0, z: 0.0, 	logicOut: -1, hwOut: 10 ),
	(name: \empty,  x:   0.0, y:  0.0, z: 0.0, 	logicOut: -1, hwOut: 11 ),

	// ADAT OUTS:
	// floor ring:
	(name: \crypt3,  x:   3, y:  5.5, z: 0.0, 	logicOut: 10, hwOut: 12, path: \denon_FL  ),
	(name: \wd11,  x:   3.5, y:  -4, z: 0.0, 	logicOut: 11, hwOut: 13, path: \denon_FR ),
	(name: \wd14,  x:   -3, y:  0.0, z: 0.0, 	logicOut: 12, hwOut: 14, path: \denon_SL ),
	(name: \wd12,  x:   -3, y:  4.5, z: 0.0, 	logicOut: 13, hwOut: 15, path: \denon_SR ),
	(name: \wd13,  x:   -3, y:  -4, z: 0.0, 	logicOut: 14, hwOut: 16, path: \denon_SBL ),
	(name: \bw6,  x:   -3, y:  5.5, z: 0.0, 	logicOut: 15, hwOut: 17, path: \denon_SBR ),

	// check cryptA and crypt3 positions
	(name: \cryptA,  x:   3, y:  3.5, z: 0.0, 	logicOut: 16, hwOut: 18 ),

	// middle ring:
	(name: \bluecab,  x:   4, y:  -2.5, z: 1.5, logicOut: 17, hwOut: 19 ),
	(name: \braun1,  x:   3.5, y:  -3, z: 2.0, 	logicOut: 18, hwOut: 20, hpf: 60 ),
	(name: \minibose,  x:  -4, y:  -2, z: 1.5, 	logicOut: 19, hwOut: 21, hpf: 60 ),
	(name: \noname,  x:   -4, y:  2, z: 1.5, 	logicOut: 20, hwOut: 22 ),
	(name: \braun2,  x:   -3.5, y:  -3, z: 2.0,	logicOut: 21, hwOut: 23, hpf: 60 ),

	// 24, 25, 26 are free maybe use for shaker?
	(name: \ceil,   x:  2.5, y:  0.0, z: 3.2, 	logicOut: 23, hwOut: 24 ),
	(name: \floor,  x:  3.5, y: -1.0, z: 0.0, 	logicOut: 24, hwOut: 25 ),
	(name: \plank,  x:  4.0, y:  4.5, z: 0.0, 	logicOut: 25, hwOut: 26 ),
	// broken
	(name: \empty,  x:   0.0, y:  0.0, z: 0.0, 	logicOut: -1, hwOut: 27 ),

	(name: \behring,  x:   4, y:  2, z: 1.5, 	logicOut: 22, hwOut: 28 ),
	(name: \sub,  x:   -3, y:  -5, z: 0.0,  	logicOut: 26, hwOut: 29 ),

	(name: \empty,  x:   0.0, y:  0.0, z: 0.0, 	logicOut: -1, hwOut: 30 ),
	(name: \empty,  x:   0.0, y:  0.0, z: 0.0, 	logicOut: -1, hwOut: 31 ),

];


// collected with ntss_tester file, Tdef(\tester)
// used in MainFX for hardware channel amp balance
 NTSS.hwRelAmps = [
	1, 1, 1, 1,  1,// kefs
	0.3, 0.3, 0.3, // cabasse
	1, 0.4,// ldls
	1, 1, // empty
	2, 1, 1, 1,

	1.5, 1.5, 1, 0.5,  // 16
	1, 1, 1, 1,
	1, 1, 1, 1,  // 24-26 shakers, 27 empty
	0.6, 0.3, // berh, sub
	1, 1    /// empty
];

// put the measured amp compensation levels into spk.data
NTSS.hwRelAmps.do { |amp, idx| NTSS.spk.data[idx].put(\relAmp, amp) };

// select non-empties, and sort them in logical order;
// we only use logical order from here on.
NTSS.spk.ordered = NTSS.spk.data.reject { |spk| spk.name == \empty }
.sort { |a, b| a.logicOut < b.logicOut };
NTSS.spk.names = NTSS.spk.ordered.collect(_.name);
"*** NTSS.spk.ordered : % speakers.\n".postf(NTSS.spk.ordered.size);
"*** NTSS.spk.names: ".postln;
NTSS.spk.names.postcs;

// backwards compat for now:
// speaker x y z for Spatio
NTSS.spk.positions = NTSS.spk.ordered.collect { |line| [line.x, line.y.neg + 1, line.z] * 0.16 };
// just the names in same order, filtered by active
// NTSS.speakersActive = NTSS.spk.names;
// get them out again in the speakers
// NTSS.speakersTuning = NTSS.spk.ordered.collect { |line| line.relAmp };


NTSS.spk.groups = (
	all: NTSS.spk.names,
	// rings: clockwise, always begin at center, so they can be one long twirl
	up: [\kef0, \kef1, \kef2, \kef3, \kef4 ], // kefs,
	center: [ \cabass0, \cabass2, \cabass1, \ldl7, \ldl8],
	floor: [\crypt3, \cryptA, \wd11, \wd14, \wd12,\wd13, \bw6 ],
	mid: [  \behring, \bluecab, \braun1, \braun2, \minibose, \noname ],

	// same-speakers:
	wd: [\wd11, \wd12, \wd13, \wd14],
	kef: [\kef0, \kef1, \kef2, \kef3, \kef4],
	cabass: [\cabass0, \cabass1, \cabass2],
	// pairs by brand/type
	// bw: [\bw5, \bw6],
	ldl: [\ldl7, \ldl8],
	braun: [\braun1, \braun2],
	amps: [\behring, \bluecab],
	crypt: [\cryptA, \crypt3],
	shake: [\ceil, \floor, \plank]
);


// ringnames for NTSS are a subset - 4 ring-zones of 6 speakers each
NTSS.ringNumSpks = 6;
NTSS.ringNames = ['center', 'up', 'floor', 'mid' ]; // leave out subs
NTSS.ringNames.do (Spec.add(_, \amp));

);