/*
i = Image.new("~/Desktop/Kuppel.png");

	left: [\wd12, \cabass2, \wd14, \bw6, \ldl7, \gene0 ],
	up: [\kef3, \cabass1, \kef1, \kef0, \kef4, \kef2 ], // kefs,
	back: [ \noname, \bluecab, \bw5, \ldl8, \braun2, \cabass0 ],
	right: [ \wd11, \cryptA, \crypt3, \wd13, \braun1, \behring],


Considerations/constraints>
• The Kuppelhalle is 15m diameter.
• Stage in the center, triangle of tables/stage elements
• mixer, sub, and player tables in the center
• expander + adat  to go up to balcony
• speakers on balcony point up, hori, down
• speakers near center point up, 45 deg,
• speakers near walls point inward, at angles

center:
denon amp patched to left ring passives,
small amps for central 2 of the right and back rings
actives could be ring around center  ?
mixer line outs to actives and sub and small amps

right bottom side:
e.g. S-16 expander feeds bottom 4 and right 4,
and ADAT feeds the top ring - the kefs on balcony.
cable lengths:
from center 3, 6, 8-10m
from side also max 10m, can go along walls
LOTS of gaffa tape for the floor!
with a long ADAT cable, we can put the ADAT
and its amps up on the balcony, near cabass1 speaker
cables around balcony are max 20m, 12m, 8m, all passive.
extra ring:
6 little mrs + amp + cables.

*/

// the speakers as in Kuppelhalle:

NTSS.spatImagePath = NTSS.dir.setup +/+ "Kuppel.png";

NTSS.speakersDict = (
	//      x    y    z   amp		//      x    y    z   amp
	//      x    y    z   amp
	bw5: [ -1.0, 4.0, 0.0, 0.4],
	bw6: [ -3.5, -1.0, 1.3, 0.35],
	cabass2: [ -1.5, 2.0, 0.8, 0.13],
	cabass0: [ 2.0, 2.9, 0.8, 0.13],
	cabass1: [ 5.0, 4.0, 3.5, 0.14],
	ldl7: [ -1.5, -3.3, 2.0, 0.15],
	ldl8: [ -0.5, 2.9, 0.0, 0.3],
	gene0: [ 0.0, -1.5, 1.0, 0.7],

	///// group as up
	kef0: [ -3.0, 4.0, 3.2, 0.5],
	kef1: [ 0.5, 6.0, 3.2, 0.5],
	kef2: [ 0.5, -4.0, 3.2, 0.5],
	kef3: [ 5.0, -2.5, 2.9, 0.5],
	kef4: [ -4.0, 0.0, 3.0, 0.5],

	wd14: [ -3.5, 1.0, 0.5, 0.4],
	wd13: [  3.5, 2.5, 1.0, 0.4],
	wd12: [ -1.0, 1.0, 0.2, 0.32],
	wd11: [ 1.5, 0.0, 0.2, 0.4],
	noname: [ 2.4, 4.2, 3.5, 0.5],
	braun1: [ 5.6, 2.0, 2.2, 1],
	braun2: [ -0.5, 5.5, 3.0, 0.8],
	cryptA: [ 5.5, -0.7, 0.0, 1],
	behring: [ 1.8, 1.5, 2.0, 0.6],
	crypt3: [ 3.5, -1.2, 1.0, 0.5],
	bluecab: [ 2.2, 5.5, 2.2, 0.3],

	///// group as up
	mr0: [ 1.0, 0.0, 1.0, 0.2],
	mr1: [ 0.5, 0.87, 1.0, 0.2],
	mr2: [ -0.5, 0.87, 1.0, 0.2],
	mr3: [ -1.0, 0.0, 1.0, 0.2],
	mr4: [ -0.5, -0.87, 1.0, 0.2],
	mr5: [ 0.5, -0.87, 1.0, 0.2],
	mr0: [ 0.5, 0.5, 1.5, 0.2],
	mr1: [ 0.5, 0.5, 1.5, 0.2],
	mr2: [ -0.5, -0.5, 1.5, 0.2],
	mr3: [ -0.5, 0.5, 1.5, 0.2],
	mr4: [ -0.5, 2, 1.5, 0.2],
	mr5: [ 0.5, 2, 1.5, 0.2],

	// not in any group
	gene1: [ -2.5, 6, 1.5, 1],
	sub1: [ -4, 3, 0.0, 1],

);

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

