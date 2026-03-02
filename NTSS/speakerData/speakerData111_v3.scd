/*
// test that logicOut and hwOut are complete:
NTSS.spk.data.collect(_.logicOut).sort.plot
NTSS.spk.active.collect(_.logicOut).sort.plot

NTSS.spk.data.collect(_.hwOut).sort.plot

NTSS.speakerData = "speakerData/speakerData111_32.scd";
NTSS.run;

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
	(name: \kef0, 	x:   5.0, y:  0.5, z: 3.2, 	logicOut: 6, hwOut:  0, relAmp: 2),
	(name: \kef1, 	x:   3.8, y: -0.5, z: 3.2, 	logicOut: 7, hwOut:  1, relAmp: 2),
	(name: \kef2, 	x:  -2.5, y: -3.5, z: 2.5, 	logicOut: 8, hwOut:  2, relAmp: 2),
	(name: \kef3, 	x:  -0.8, y:  2.5, z: 2.5, 	logicOut: 10, hwOut: 3, relAmp: 2),
	(name: \kef4, 	x:  -2.3, y:  3.0, z: 3.5, 	logicOut: 11, hwOut: 4, relAmp: 2),

	// two cabasses on table
	(name: \cabass0, x: -2.5, y:  0.3, z: 0.8, 	logicOut: 16, hwOut: 5, relAmp: 1),
	(name: \cabass1, x: -2.5, y: -0.3, z: 0.8, 	logicOut: 2, hwOut:  6, relAmp: 1),

	(name: \gene0, 	x:   0.8, y: 3.2, z: 0.8, 	logicOut: 4, hwOut: 7, relAmp: 1.2),


	/*** on Expander S16 : ****/
	(name: \crypt3, x:   2.0, y: 4.5, z: 0.5, 	logicOut: 20, hwOut:  8, relAmp: 1.2),
	(name: \wd12,  	x:   2.0, y: 1.0, z: 0.3, 	logicOut: 3, hwOut:   9, relAmp: 1.2),
	(name: \braun2, x: -2.5, y: -0.3, z: 0.8, 	logicOut: 23, hwOut: 10, relAmp: 1.2),
	(name: \cabass2,x:   5.5, y: 1.2, z: 3.0, 	logicOut: 22, hwOut: 11, relAmp: 1.2),

	(name: \wd11,	x:   1.0, y: 5.5, z: 1.1, 	logicOut: 21, hwOut: 12, relAmp: 1.2),
	(name: \empty,  x:  -2.5, y: -0.3, z: 0.8, 	logicOut: -1, hwOut: 13, relAmp: 1.2),
	(name: \empty,  x:  -2.5, y: -0.3, z: 0.8, 	logicOut: -1, hwOut: 14, relAmp: 1.2),
	(name: \empty,  x:  -2.5, y: -0.3, z: 0.8, 	logicOut: -1, hwOut: 15, relAmp: 1.2),

	/*** on RME ADAT : ****/
	(name: \behring,x:   1.0, y: -0.4, z: 2.0, 	logicOut: 24, hwOut: 16, relAmp: 1.2),
	(name: \bluecab,x:   0.7, y: -2.5, z: 2.2, 	logicOut: 13, hwOut: 17, relAmp: 1.2),
	(name: \gene1,  x:   0.7, y: -0.7, z: 1.1, 	logicOut: 15, hwOut: 18, relAmp: 1.2),
	(name: \empty,  x:  -2.5, y: -0.3, z: 0.8, 	logicOut: -1, hwOut: 19, relAmp: 1.2),

	(name: \wd14,  	x:  -0.6, y: -2.7, z: 0.2, 	logicOut: 18, hwOut: 20, relAmp: 1.2),
	(name: \noname, x:   0.6, y: -2.0, z: 3.0, 	logicOut: 12, hwOut: 21, relAmp: 1.2),
	// shaker - soft
	(name: \blech,  x:   0.5, y: -0.6, z: 2.4, 	logicOut: 25, hwOut: 22, relAmp: 1.2),
	(name: \b_o,   	x:   1.0, y: -1.5, z: 1.0, 	logicOut: 14, hwOut: 23, relAmp: 1.2),

	// shaker - very soft
	(name: \harp,   x:  -2.5, y: -0.3, z: 3.5, 	logicOut: 26, hwOut: 24, relAmp: 1.2),
	(name: \braun1, x: -2.5, y: -0.1, z: 2.5, 	logicOut: 9, hwOut: 25, relAmp: 1.2),
	(name: \wd13, 	x: -4.5, y:  2.5, z: 0.3, 	logicOut: 1, hwOut:  26, relAmp: 1.2),
	(name: \bw6, 	x: -5.5, y:  4.0, z: 1.5, 	logicOut: 0, hwOut: 27, relAmp: 1.2),

	(name: \ldl8, 	x: -5.0, y: -1.5, z: 0.6, 	logicOut: 17, hwOut: 28, relAmp: 1.2),
	(name: \ldl7, 	x: -1.0, y:  4.0, z: 1.5, 	logicOut: 5, hwOut: 29, relAmp: 1.2),
	(name: \cryptA, x:  3.2, y:  4.0, z: 1.1, 	logicOut: 19, hwOut: 30, relAmp: 1.2),
	(name: \sub,   	x: -1.0, y:  2.5, z: 0.4, 	logicOut: 27, hwOut: 31, relAmp: 1.2),


];

NTSS.spk.data.size.postln;

NTSS.spk.active = NTSS.spk.data.reject { |spk| spk.name == \empty };
"*** NTSS.spk.active : % speakers.\n".postf(NTSS.spk.active.size);
// backwards compat for now:
NTSS.speakers = NTSS.spk.active.collect { |line| [line.x, line.y, line.z] * 0.16 };
NTSS.speakersActive = NTSS.spk.active.collect { |line| line.name };
NTSS.speakersTuning = NTSS.spk.active.collect { |line| line.relAmp };
NTSS.speakersOrder = NTSS.spk.data.copy.sort { |a, b| a.hwOut < b.hwOut }.collect(_.name);

// x = SpatioScope(NTSS.spk.data.collect { |line| line.x @ line.y * 0.16 }, bounds: Rect(0,0,800, 800));
// x.ampViews.do(_.background_(Color.grey(0.5, 0.5)));
// make 4 rings of 6 speakers each - may need to change!!!
///// bw5 not used, needs repair!

NTSS.spk.groups = (
	// rings: clockwise, always begin at center, so they can be one long twirl
	left: [\bw6, \wd13, \cabass1, \wd12,  \gene0, \ldl7 ],
	up: [\kef0, \kef1, \kef2, \braun1, \kef3, \kef4 ], // kefs,
	back: [ /*\noname,*/ \bluecab, \b_o, \gene1, \cabass0, \ldl8, \wd14],
	right: [ \cryptA, \crypt3, \wd11, \cabass2, \braun2, \behring],
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