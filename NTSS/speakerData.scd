/*
z = [0.4, 0.35, 0.13, 0.13, 0.14, 0.15, 0.3, 0.7, 0.5, 0.5, 0.5, 0.5, 0.5, 0.4, 0.4, 0.32, 0.4, 0.5, 1, 0.8, 1, 0.6, 0.5, 0.3, 1, 1]
NTSS.speakers.size
NTSS.speakersDict[NTSS.speakersActive[0]]
NTSS.speakersActive.collect { |sp,i| [sp] ++ NTSS.speakersDict[sp][..2] ++ [z[i]] }.do {|el| "%: [ %, %, %, %],".format(*el).postln }
*/

// the speakers as in Medienhaus 111
NTSS.speakersDict = (
	//      x    y    z   amp
	bw5: [ 1.2, 5.3, 0.0, 0.4],
	bw6: [ -4.0, -1.0, 1.3, 0.35],
	cabass2: [ -0.5, 2.7, 0.8, 0.13],
	cabass0: [ -0.5, 2.9, 0.8, 0.13],
	cabass1: [ 6.0, 3.8, 3.5, 0.14],
	ldl7: [ 0.5, -1.0, 2.0, 0.15],
	ldl8: [ -3.5, 5.2, 0.0, 0.3],
	gene0: [ 2.0, -0.5, 1.0, 0.7],

	///// group as up
	kef0: [ -3.0, 3.0, 3.2, 0.5],
	kef1: [ 0.5, 6.0, 3.2, 0.5],
	kef2: [ 0.5, -0.6, 3.2, 0.5],
	kef3: [ 1.5, 1.1, 2.9, 0.5],
	kef4: [ -3.5, 2.5, 3.0, 0.5],

	wd14: [ -3.5, 1.0, 0.5, 0.4],
	wd13: [ 6.0, 1.5, 1.0, 0.4],
	wd12: [ 1.5, 0.5, 0.2, 0.32],
	wd11: [ 3.5, 0.5, 0.2, 0.4],
	noname: [ 2.4, 4.0, 3.5, 0.5],
	braun1: [ 4.5, 2.0, 2.2, 1],
	braun2: [ -1.0, 3.8, 3.0, 0.8],
	crypt3: [ 5.5, 0.0, 0.0, 1],
	behring: [ 2.5, 3.0, 2.0, 0.6],
	cryptA: [ 4.5, -0.5, 1.0, 0.5],
	bluecab: [ 2.2, 5.5, 2.2, 0.3],

	// not in any group
	sub0: [ 0.0, 0.0, 0.0, 1],
	sub1: [ -4, 3, 0.0, 1],

);

// make 4 rings of 6 speakers each
NTSS.spkGroups = (
	// 4 rings: clockwise, always begin at center, so they can be one long twirl
	left: [\wd12, \cabass2, \wd14, \bw6, \ldl7, \gene0 ],
	up: [\kef3, \cabass1, \kef1, \kef0, \kef4, \kef2 ], // kefs,
	back: [ \noname, \bluecab, \bw5, \ldl8, \braun2, \cabass0 ],
	right: [ \wd11, \cryptA, \crypt3, \wd13, \braun1, \behring],
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
	\bw5,
	\bw6,
	\cabass2,
	\cabass0,
	\cabass1,
	\ldl7,
	\ldl8,

	// last XLR out from X32
	\gene0,

	// 8 XLR outs from s16 to Stereo amps
	\kef0,
	\kef1,
	\kef2,
	\kef3,
	\kef4,

	\empty,
	\empty,
	\empty,

	// 5 JACK outs from s16-RME-ADAT to Yamaha Amp
	\wd14,
	\wd13,
	\wd12,
	\wd11,
	\noname,

	// 2 JACK outs from s16-RME-ADAT to stereo amp 1
	\braun1,
	\braun2,

	// 1 JACK out from s16-RME-ADAT to stereo amp 2
	\crypt3,

	// aux 1-6 from x32 to active speakers
	\behring,
	\cryptA,
	\bluecab,
	\empty,
	\empty,
	\empty,

	// X32 monitor out
	\sub0,
	\sub1,
];

// we play only to the connected speakers, so select these:
NTSS.speakersActive = NTSS.speakersOrder.reject {|spk| spk == \empty };

NTSS.speakersTuning = NTSS.speakersActive.collect {|spk| NTSS.speakersDict[spk][3] };
NTSS.speakers = NTSS.speakersActive.collect {|key|
	var loc = NTSS.speakersDict[key];
	[loc[0], loc[1], loc[2]]
}.flat.normalize(-0.85,0.85).reshape(NTSS.speakersActive.size, 3);

// names to use for setting output amps
NTSS.amp_names = NTSS.speakersActive;

