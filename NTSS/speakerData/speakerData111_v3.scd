/*

This is the speaker setup in room 111 on March 14 2026.


NTSS.spk.data is one list that collects all information
on all the speakers in the system -
name, x y z position data, and connection info:
(name: \crypt3, x:   4.5, y:  2.0, z: 0.5, ...

The speakers have two orderings:
*** HARDWARE order - which outputs are they connected to, and
*** LOGICAL order - in which order do the panners deliver the channels.
in NTSS.spk.data, these are notated as logicOut and hwOut:

(name: \crypt3, x:   4.5, y:  2.0, z: 0.5, 	logicOut: 22, hwOut:  8, path: \Yam1_FL ),

NTSS.spk.data also has info on
the signal path: which amplifier, which channel,
and relAmp: the amplitude compensation that each one equally loud.


**** TESTS ****
// test that hwOut are complete:
NTSS.spk.data.collect(_.hwOut).sort.postln.plot;
// -> 0..31, one line, no repeats

//  test that logicOut are complete:
NTSS.spk.data.collect(_.logicOut).sort.postln.plot;
// -> some -1 for empty, then one line from 0..27

// NTSS.spk.ordered are in logical order:
NTSS.spk.ordered.collect(_.logicOut).plot;
// -> 0..27


NTSS.run;


Hosek space: 13x7m, 3m hoch in der Mitte, 2.65 am Rand

*/

(
// all speaker data go here:
NTSS.spk = NTSS.spk ? ();
NTSS.spk.setupName = "111_March2026";
NTSS.spk.data; // the current speaker set

// NTSS.spk.numLogicOuts = 29; // currently
NTSS.spk.numHWOuts = 32;

// possible SpatioScope background image:
// NTSS.spatImagePath = // NTSS.dir.setup +/+ "Kuppel.png";

NTSS.spk.data = List[

	/*** on Mixer X32 : ****/
	///// group kefs as up
	(name: \kef0, 	x:  -5.0, y:  0.5, z: 3.2, 	logicOut: 0, hwOut:  0, path: \denon_FL ),
	(name: \kef1, 	x:  -3.8, y: -0.5, z: 3.2, 	logicOut: 1, hwOut:  1, path: \denon_FR ),
	(name: \kef2, 	x:  -2.5, y: -3.5, z: 2.5, 	logicOut: 2, hwOut:  2, path: \denon_SL ),
	(name: \kef3, 	x:  -0.8, y:  2.0, z: 2.5, 	logicOut: 3, hwOut:  3, path: \denon_SR ),
	(name: \kef4, 	x:  -2.3, y:  4.5, z: 3.5, 	logicOut: 4, hwOut:  4, path: \denon_SBL ),

	// two cabasses on the center table
	(name: \cabass0, x: -2.5, y:  0.4, z: 0.8, 	logicOut: 5, hwOut:  5, path: \denon_SBR ),
	(name: \cabass1, x: -2.5, y: -0.4, z: 0.8, 	logicOut: 6, hwOut:  6, path: \denon_C ),

	(name: \gene0, 	x:   0.5, y:  3.2, z: 0.8, 	logicOut: 7, hwOut:  7, path: \direct ),

	/*** on Expander S16, right side : ****/
	(name: \crypt3, x:   4.5, y:  2.0, z: 0.5, 	logicOut: 22, hwOut:  8, path: \Yam2_FL ),
	(name: \wd12,  	x:   1.0, y:  2.0, z: 0.3, 	logicOut: 18, hwOut:  9, path: \Yam2_FR ),
	(name: \braun2, x:   3.5, y:  0.2, z: 0.8, 	logicOut: 19, hwOut: 10, path: \Yam2_SL ),
	(name: \cabass2,x:   5.5, y: -1.2, z: 3.0, 	logicOut: 20, hwOut: 11, path: \Yam2_SR ),
	(name: \wd11,	x:   5.5, y:  1.0, z: 1.1, 	logicOut: 23, hwOut: 12, path: \Yam2_C ),

	// 3 empty here
	(name: \bshaker,x:   0.0, y:  0.0, z: 0.0, 	logicOut: 27, hwOut: 13 ),
	(name: \empty,  x:   0.0, y:  0.0, z: 0.0, 	logicOut: -1, hwOut: 14 ),
	(name: \empty,  x:   0.0, y:  0.0, z: 0.0, 	logicOut: -1, hwOut: 15 ),

	/*** on RME ADAT : ****/
	(name: \behring,x:   1.0, y: -0.4, z: 2.0, 	logicOut: 17, hwOut: 16, path: \direct ),
	(name: \bluecab,x:   0.7, y: -3.0, z: 2.2, 	logicOut: 13, hwOut: 17, path: \direct ),
	(name: \gene1,  x:   0.2, y: -1.0, z: 1.1, 	logicOut: 16, hwOut: 18, path: \direct ),
	(name: \empty,  x:   0.0, y:  0.0, z: 0.0, 	logicOut: -1, hwOut: 19 ),

	(name: \wd14,  	x:  -0.6, y: -2.8, z: 0.2, 	logicOut: 12, hwOut: 20, path: \bt1_L ),
	(name: \noname, x:   0.5, y: -2.0, z: 3.0, 	logicOut: 14, hwOut: 21, path: \dyna_L ),
	// shaker - soft
	(name: \blech,  x:   0.5, y:  0.0, z: 2.4, 	logicOut: 25, hwOut: 22, path: \dyna_R ),
	(name: \b_o,   	x:   1.2, y: -2.2, z: 1.0, 	logicOut: 15, hwOut: 23, path: \direct ),

	// X-32 again, 6 Auxes, 2 headphone/monitor out channels
	// shakers - very soft
	(name: \harp,   x: -2.5, y:  5.0, z: 3.5, 	logicOut: 26, hwOut: 24, path: \Yam1_FLA ),
	(name: \braun1, x: -2.5, y:  0.0, z: 2.5, 	logicOut: 10, hwOut: 25, path: \Yam1_FRA ),
	(name: \wd13, 	x: -4.5, y:  2.5, z: 0.3, 	logicOut: 9,  hwOut: 26, path: \Yam1_SL ),
	(name: \bw6, 	x: -5.0, y:  4.0, z: 1.5, 	logicOut: 8,  hwOut: 27, path: \Yam1_SR ),

	(name: \ldl8, 	x: -5.0, y: -1.5, z: 0.6, 	logicOut: 11, hwOut: 28, path: \Yam1_C ),
	(name: \ldl7, 	x: -1.0, y:  4.0, z: 1.5, 	logicOut: 24,  hwOut: 29, path: \bt4_L ),
	(name: \cryptA, x:  3.5, y:  3.2, z: 1.1, 	logicOut: 21, hwOut: 30, path: \direct ),
	(name: \sub,   	x: -1.5, y:  2.5, z: 0.4, 	logicOut: 28, hwOut: 31, path: \direct ),

];

// collected with ntss_tester file, which needs update!
// used in MainFX for hardware channel amp balance

(
/// these are in hardware order!
NTSS.hwRelAmps = [
	2, 2, 2, 2,         // kefs 0..3,
	2, 0.6, 0.6, 0.6,   // kef4, cabass0, cabass1, gene0
	1, 0.3, 1, 0.3,     // crypt3, wd12, braun2, cabass2
	0.5, 1, 1, 1,      // wd11, empty, empty, empty
	0.5, 0.5, 1, 2,     // behring, bluecab, gene1, empty
	2, 4, 2, 1.5,       // wd14, noname, blech, b_o
	10, 2, 1, 1.5,     // harp, braun1, wd13, bw6
	1.5, 0.5, 3, 0.5    // ldl8, ldl7, cryptA, sub
];
// put the measured amp compensation levels into spk.data
NTSS.hwRelAmps.do { |amp, idx| NTSS.spk.data[idx].put(\relAmp, amp) };

/**** which channels to compare?
~chans = [0, 1, 2, 3, 4, 5, 6, 7];
~chans = [0, 1, 8, 9, 10, 11];
~chans = [0, 1, 12, 13, 14, 15];
~chans = [0, 1] ++ [16, 17, 18, 19];
~chans = [0, 1] ++ [20, 21, 22, 23];
~chans = [0, 1] ++ [24, 25, 26, 27];
~chans = (0..31);
*****/
//////
///// when tuning volumes, uncomment to update MainFX !
// MainFX(s).remove(\mainMixer);
// MainFX(s).add(\mainMixer, 1);
);

// select non-empties, and sort them in logical order;
// we only use logical order from here on.
NTSS.spk.ordered = NTSS.spk.data.reject { |spk| spk.name == \empty }
.sort { |a, b| a.logicOut < b.logicOut };
NTSS.spk.names = NTSS.spk.ordered.collect(_.name);
"*** NTSS.spk.ordered : % speakers.\n".postf(NTSS.spk.ordered.size);
"*** NTSS.spk.names: ".postln;
NTSS.spk.names.postcs;
NTSS.spk.numLogicOuts = NTSS.spk.names.size;

// backwards compat for now:
// speaker x y z for Spatio
NTSS.spk.positions = NTSS.spk.ordered.collect { |line| [line.x, line.y.neg + 1, line.z] * 0.16 };
// just the names in same order, filtered by active
// NTSS.speakersActive = NTSS.spk.names;
// get them out again in the speakers
// NTSS.speakersTuning = NTSS.spk.ordered.collect { |line| line.relAmp };


NTSS.spk.groups = (
	// rings: clockwise, always begin at center, so they can be one long twirl
	left: [\bw6, \wd13, \cabass0, \wd12,  \gene0, \ldl7 ],
	up: [\kef0, \kef1, \kef2, \braun1, \kef3, \kef4 ], // kefs,
	back: [ /*\noname,*/ \ldl8, \wd14, \bluecab, \b_o, \gene1, \cabass1 ],
	right: [  \behring, \braun2, \cabass2, \wd11, \crypt3, \cryptA],
	// center: [ \mr0, \mr1, \mr2, \mr3, \mr4, \mr5],

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
	shaka: [\blech, \harp]
);

NTSS.spkGroups = NTSS.spk.groups;

// ringnames for NTSS are a subset - 4 ring-zones of 6 speakers each
NTSS.ringNumSpks = 6;
NTSS.ringNames = ['left', 'right', 'back', 'up'/*, 'center'*/]; // leave out subs
NTSS.ringNames.do (Spec.add(_, \amp));

// names to use for setting output amps
NTSS.amp_names = NTSS.spk.names;

);