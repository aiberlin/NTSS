/*
*/

// the speakers as in Kuppelhalle:

// NTSS.spatImagePath = // NTSS.dir.setup +/+ "Kuppel.png";

// cleanup :
NTSS.spk = NTSS.spk ? ();
NTSS.spk.data; // the current speaker set

NTSS.spk.numLogicOuts = 16;
NTSS.spk.numHWOuts = 32;


NTSS.spk.data = List[

	/*** on Mixer X32 : ****/
	///// group kefs as up
	(name: \kef0, 	x:   5.0, y:  0.5, z: 3.2, 	logicOut: 7, hwOut:  0, relAmp: 1.2),
	(name: \kef1, 	x:   3.8, y: -0.5, z: 3.2, 	logicOut: 7, hwOut:  6, relAmp: 1.2),
	(name: \kef2, 	x:  -2.5, y: -3.5, z: 2.5, 	logicOut: 7, hwOut:  3, relAmp: 1.2),
	(name: \kef3, 	x:  -0.8, y:  2.5, z: 2.5, 	logicOut: 7, hwOut: 26, relAmp: 1.2),
	(name: \kef4, 	x:  -2.3, y:  3.0, z: 3.5, 	logicOut: 7, hwOut:  4, relAmp: 1.2),

	// two cabasses on table
	(name: \cabass0, x: -2.5, y:  0.3, z: 0.8, 	logicOut: 0, hwOut:  5, relAmp: 1.2),
	(name: \cabass1, x: -2.5, y: -0.3, z: 0.8, 	logicOut: 7, hwOut:  1, relAmp: 1.2),

	// left side
	(name: \wd13, 	x: -4.5, y:  2.5, z: 0.3, 	logicOut: 7, hwOut:  2, relAmp: 1.2),
	(name: \braun1, x: -2.5, y: -0.1, z: 2.5, 	logicOut: 7, hwOut: 25, relAmp: 1.2),
	(name: \bw6, 	x: -5.5, y:  4.0, z: 1.5, 	logicOut: 7, hwOut: 27, relAmp: 1.2),
	(name: \ldl8, 	x: -5.0, y: -1.5, z: 0.6, 	logicOut: 7, hwOut: 28, relAmp: 1.2),
	(name: \ldl7, 	x: -1.0, y:  4.0, z: 1.5, 	logicOut: 7, hwOut: 29, relAmp: 1.2),

	// right side
	(name: \gene0, 	x:  0.8, y:  3.2, z: 0.8, 	logicOut: 7, hwOut: 7, relAmp: 1.2),
	not working until 30/31 disentangled
	(name: \cryptA, x: -2.5, y:  3.0, z: 0.8, 	logicOut: 7, hwOut: 30, relAmp: 1.2),

	// shaker - very soft
	(name: \harp,   x: -2.5, y: -0.3, z: 0.8, 	logicOut: 7, hwOut: 24, relAmp: 1.2),


	/*** on Expander S16 : ****/
	(name: \crypt3, x:  -2.5, y: -0.3, z: 0.8, 	logicOut: 7, hwOut:  8, relAmp: 1.2),
	(name: \wd12,  	x:  -2.5, y: -0.3, z: 0.8, 	logicOut: 7, hwOut:  9, relAmp: 1.2),
	(name: \braun2, x:  -2.5, y: -0.3, z: 0.8, 	logicOut: 7, hwOut: 10, relAmp: 1.2),
	(name: \cabass2,x:  -2.5, y: -0.3, z: 0.8, 	logicOut: 7, hwOut: 11, relAmp: 1.2),

	(name: \wd11,	x:  -2.5, y: -0.3, z: 0.8, 	logicOut: 7, hwOut: 12, relAmp: 1.2),
	(name: \empty,  x:  -2.5, y: -0.3, z: 0.8, 	logicOut: 7, hwOut: 13, relAmp: 1.2),
	(name: \empty,  x:  -2.5, y: -0.3, z: 0.8, 	logicOut: 7, hwOut: 14, relAmp: 1.2),
	(name: \empty,  x:  -2.5, y: -0.3, z: 0.8, 	logicOut: 7, hwOut: 15, relAmp: 1.2),

	/*** on RME ADAT : ****/
	(name: \guitar,	x:  -2.5, y: -0.3, z: 0.8, 	logicOut: 7, hwOut: 16, relAmp: 1.2),
	(name: \bass,   x:  -2.5, y: -0.3, z: 0.8, 	logicOut: 7, hwOut: 17, relAmp: 1.2),
	(name: \gene1,  x:  -2.5, y: -0.3, z: 0.8, 	logicOut: 7, hwOut: 18, relAmp: 1.2),
	(name: \empty,  x:  -2.5, y: -0.3, z: 0.8, 	logicOut: 7, hwOut: 19, relAmp: 1.2),

	(name: \wd14,  	x:  -2.5, y: -0.3, z: 0.8, 	logicOut: 7, hwOut: 20, relAmp: 1.2),
	(name: \noname, x:  -2.5, y: -0.3, z: 0.8, 	logicOut: 7, hwOut: 21, relAmp: 1.2),
	(name: \blech,  x:  -2.5, y: -0.3, z: 0.8, 	logicOut: 7, hwOut: 22, relAmp: 1.2),
	(name: \b_o,   	x:  -2.5, y: -0.3, z: 0.8, 	logicOut: 7, hwOut: 23, relAmp: 1.2),

];


// make 4 rings of 6 speakers each - may need to change!!!

NTSS.spkGroups = (
	// 4 rings: clockwise, always begin at center, so they can be one long twirl
	left: [\wd12, \cabass2, \wd14, \bw6, \ldl7, \gene0 ],
	up: [\kef3, \cabass1, \kef1, \kef0, \kef4, \kef2 ], // kefs,
	back: [ \noname, \bluecab, \braun2, \bw5, \ldl8, \cabass0 ],
	right: [ \wd11, \crypt3, \cryptA, \braun1, \wd13, \behring],
	center: [ \mr0, \mr1, \mr2, \mr3, \mr4, \mr5],
	// the subs:
	subs: [\sub0, \sub1],
	// same-speakers:
	wd: [\wd11, \wd12, \wd13, \wd14],
	kef: [\kef0, \kef1, \kef2, \kef3, \kef4],
	cabass: [\cabass0, \cabass1, \cabass2],
	// pairs by brand/type
	bw: [\bw5, \bw6],
	ldl: [\ldl7, \ldl8],
	braun: [\braun1, \braun2],
	amps: [\behring, \bluecab],
	crypt: [\cryptA, \crypt3],
);


// in order of physical outputs :
NTSS.speakersOrder = [
	// 7 XLR outs from X32, 7 to Denon amp
	\wd12,
	\wd13,
	\ldl7,
	\bw6,
	\behring,
	\wd11,
	\wd14,

	// last XLR out from X32
	\gene0,

	// 8 XLR outs total from s16
	// 5 XLRs go to stereoamps and kefs
	//   ch 8
	\kef0,
	\kef1, // DEAD
	\kef2,
	\cabass0,
	\kef3,
	\kef4, // DEAD

	// ch  14
	\crypt3,
	\cryptA,

	// 5 JACK outs from s16-RME-ADAT to Yamaha Amp
	// ch-16
	\cabass1,
	\cabass2,
	\noname,
	\ldl8,

	\bw5,

	// 2 JACK outs from s16-RME-ADAT to stereo amp 1
	\braun1,
	\braun2,

	// 1 JACK out from s16-RME-ADAT to stereo amp 2
	\bluecab,

	// aux 1-6 jacks from x32 to active speakers
	//   ch24
	\mr0,
	\mr1,
	\mr2,
	\mr3,
	\mr4,
	\mr5,

	// X32 monitor out
	\gene1,
	\sub1,
];

// ringnames for NTSS are a subset - 4 ring-zones of 6 speakers each
NTSS.ringNumSpks = 6;
NTSS.ringNames = ['left', 'right', 'back', 'up', 'center']; // leave out subs
NTSS.ringNames.do (Spec.add(_, \amp));

// we play only to the connected speakers, so select these:
NTSS.speakersActive = NTSS.speakersOrder.reject {|spk| spk == \empty };

NTSS.speakersTuning = NTSS.speakersActive.collect {|spk| NTSS.speakersDict[spk][3] };
NTSS.speakers = NTSS.speakersActive.collect {|key|
	var loc = NTSS.speakersDict[key];
	[loc[0], loc[1], loc[2]]
}.flat.normalize(-0.85,0.85).reshape(NTSS.speakersActive.size, 3);

// names to use for setting output amps
NTSS.amp_names = NTSS.speakersActive;

