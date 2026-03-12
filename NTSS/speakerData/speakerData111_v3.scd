/*
// test that logicOut and hwOut are complete:
NTSS.spk.data.collect(_.logicOut).sort.plot
NTSS.spk.active.collect(_.logicOut).sort.plot

NTSS.spk.data.collect(_.hwOut).sort.plot

NTSS.speakerData = "speakerData/speakerData111_32.scd";
NTSS.run;

Hosek space: 13x7m, 3m hoch in der Mitte, 2.65 am Rand

*/

(
// all speaker data go here:
NTSS.spk = NTSS.spk ? ();
NTSS.spk.data; // the current speaker set

NTSS.spk.numLogicOuts = 28; // currently
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

	// two cabasses on table
	(name: \cabass0, x: -2.5, y:  0.4, z: 0.8, 	logicOut: 5, hwOut:  5, path: \denon_SBR ),
	(name: \cabass1, x: -2.5, y: -0.4, z: 0.8, 	logicOut: 6, hwOut:  6, path: \denon_C ),

	(name: \gene0, 	x:   0.5, y:  3.2, z: 0.8, 	logicOut: 7, hwOut:  7, path: \direct ),

	/*** on Expander S16 : ****/
	(name: \crypt3, x:   4.5, y:  2.0, z: 0.5, 	logicOut: 22, hwOut:  8, path: \Yam1_FL ),
	(name: \wd12,  	x:   1.0, y:  2.0, z: 0.3, 	logicOut: 18, hwOut:  9, path: \Yam1_FR ),
	(name: \braun2, x:   3.5, y:  0.2, z: 0.8, 	logicOut: 19, hwOut: 10, path: \Yam1_SL ),
	(name: \cabass2,x:   5.5, y: -1.2, z: 3.0, 	logicOut: 20, hwOut: 11, path: \Yam1_SR ),

	(name: \wd11,	x:   5.5, y:  1.0, z: 1.1, 	logicOut: 23, hwOut: 12, path: \Yam1_C ),
	(name: \empty,  x:   0.0, y:  0.0, z: 0.0, 	logicOut: -1, hwOut: 13 ),
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

	// shaker - very soft
	(name: \harp,   x: -2.5, y:  5.0, z: 3.5, 	logicOut: 26, hwOut: 24, path: \bt2_R ),
	(name: \braun1, x: -2.5, y:  0.0, z: 2.5, 	logicOut: 10,  hwOut: 25, path: \bt2_L ),
	(name: \wd13, 	x: -4.5, y:  2.5, z: 0.3, 	logicOut: 9,  hwOut: 26, path: \bt3_R ),
	(name: \bw6, 	x: -5.5, y:  4.0, z: 1.5, 	logicOut: 8,  hwOut: 27, path: \bt3_L ),

	(name: \ldl8, 	x: -5.0, y: -1.5, z: 0.6, 	logicOut: 11, hwOut: 28, path: \bt4_R ),
	(name: \ldl7, 	x: -1.0, y:  4.0, z: 1.5, 	logicOut: 24,  hwOut: 29, path: \bt4_L ),
	(name: \cryptA, x:  3.5, y:  3.2, z: 1.1, 	logicOut: 21, hwOut: 30, path: \direct ),
	(name: \sub,   	x: -1.5, y:  2.5, z: 0.4, 	logicOut: 27, hwOut: 31, path: \direct ),

];

// collected with ntss_tester file, Tdef(\tester)
// used in MainFX for hardware channel amp balance
NTSS.hwRelAmps = [
	2, 2, 2, 2,         // kefs 0..3,
	2, 1, 1, 1,         // kef4, 2 cabasses, gene0
	0.5, 0.25, 1, 0.25, // crypt3, wd12, braun2, cabass2
	0.25, 1, 1,   1,    // wd11, empty, e, e
	0.5, 0.5, 1, 2,   // behring, bluecab, gene1, b_o
	0.5, 3, 2, 1,       // wd14, noname, blech,b_o
	2, 0.6, 0.5, 1,     // harp, braun1, wd13, bw6
	1, 0.5, 0.3, 0.5    // ldl8, ldl7, cryptA, sub
];

// nonempties:
NTSS.spk.active = NTSS.spk.data.reject { |spk| spk.name == \empty };
// and sort tehm in logic order:
NTSS.spk.active.sort { |a, b| a.logicOut < b.logicOut };
"*** NTSS.spk.active : % speakers.\n".postf(NTSS.spk.active.size);
NTSS.spk.logicOrder = NTSS.spk.active;

// backwards compat for now:
// speaker x y z for Spatio
NTSS.speakers = NTSS.spk.active.collect { |line| [line.x, line.y.neg + 1, line.z] * 0.16 };
// just the names in same order, filtered by active
NTSS.speakersActive = NTSS.spk.logicOrder.collect { |line| line.name };
// put the measured  amp compensation levels into spk.data
NTSS.hwRelAmps.do { |amp, idx| NTSS.spk.data[idx].put(\relAmp, amp) };
// get them out again in the speakers
NTSS.speakersTuning = NTSS.spk.active.collect { |line| line.relAmp };
NTSS.speakersOrder = NTSS.spk.logicOrder.collect(_.name);


NTSS.spk.groups = (
	// rings: clockwise, always begin at center, so they can be one long twirl
	left: [\bw6, \wd13, \cabass0, \wd12,  \gene0, \ldl7 ],
	up: [\kef0, \kef1, \kef2, \braun1, \kef3, \kef4 ], // kefs,
	back: [ /*\noname,*/ \ldl8, \wd14, \bluecab, \b_o, \gene1, \cabass0, ],
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
NTSS.amp_names = NTSS.speakersActive;

);