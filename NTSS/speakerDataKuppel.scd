/*
i = Image.new("~/Desktop/Kuppel.png");

	left: [\wd12, \cabass2, \wd14, \bw6, \ldl7, \gene0 ],
	up: [\kef3, \cabass1, \kef1, \kef0, \kef4, \kef2 ], // kefs,
	back: [ \noname, \bluecab, \bw5, \ldl8, \braun2, \cabass0 ],
	right: [ \wd11, \cryptA, \crypt3, \wd13, \braun1, \behring],

*/

// the speakers as in Kuppelhalle:

NTSS.speakersDict = (
	//      x    y    z   amp
	bw5: [ -0.5, 5.5, 0.0, 0.4],
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
	wd13: [ 5.6, 2.0, 1.0, 0.4],
	wd12: [ 0.0, 1.0, 0.2, 0.32],
	wd11: [ 1.5, 0.0, 0.2, 0.4],
	noname: [ 2.4, 4.2, 3.5, 0.5],
	braun1: [ 3.5, 2.5, 2.2, 1],
	braun2: [ -1.0, 4.0, 3.0, 0.8],
	crypt3: [ 5.5, -0.7, 0.0, 1],
	behring: [ 1.8, 1.5, 2.0, 0.6],
	cryptA: [ 3.5, -1.2, 1.0, 0.5],
	bluecab: [ 2.2, 5.5, 2.2, 0.3],

	// not in any group
	sub0: [ 0.0, 0.0, 0.0, 1],
	sub1: [ -4, 3, 0.0, 1],

);

NTSS.speakers = NTSS.speakersActive.collect {|key|
	var loc = NTSS.speakersDict[key];
	[loc[0], loc[1], loc[2]]
}.flat.normalize(-0.85,0.85).reshape(NTSS.speakersActive.size, 3);

try { Window.find("Spat").close };
Butz(\NTSS).run(\SpatioScope);
q.spat.parent.view.backgroundImage_(i);
