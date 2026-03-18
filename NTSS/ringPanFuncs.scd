"NTSS mono panners loading.".postln;

/* Switchable panners for a Mono Ndef bus going to rings of 4 * 6 speakers:

srcPos sets position in circle,
srcWidth opens to more chans
send levels to 4 rings are independent

pendRate and pendDepth modulate pos with a sinosc

Ndef(\pan1, ProxyChain.allSources[\panFixed]);
Ndef(\pan1, ProxyChain.allSources[\panFixed]);
Ndef(\pan1).gui;

Ndef(\pan1).gui;

*/

/// rings-based Panners from BIOPHONY: //////

// was q...panNames = [ \panFixed, \panRoto, \panSnake, \panFeed];
// // these were the ringnames for biophony ...
// q.ringNames = [\inside, \shakers, \outside, \bigPA];
// // separate levels on 4 rings:
// q.ringNames.do (Spec.add(_, \amp));

// spkGroups have more types of groups:
// NTSS.spkGroups;
// NTSS.spkGroups.keys.postcs;

// // ringnames for NTSS are a subset - 4 ring-zones of 6 speakers each
// NTSS.ringNumSpks = 6;
// NTSS.ringNames = ['left', 'right', 'back', 'up', 'center']; // leave out subs
NTSS.ringNames.do (Spec.add(_, \amp4));

NTSS.ringsFlat = NTSS.ringNames.collect { |name| NTSS.spkGroups[name] }.flat;

NTSS.spk.atName = { |spk, name| spk.data.detect { |dict| dict.name == name } ? () };

NTSS.spk.atName(\bw6).logicOut;
NTSS.spk.atName(\cab0).logicOut; // wrong name
NTSS.spk.atName(\cabass0).logicOut; //

// array is in order of NTSS.ringsFlat;
// output should be to logical order
// if overlap in logic channels;
// maybe add them up if already replaced.
NTSS.reorderRingsToSpeakers = { |ntss, array|
	var nameList = NTSS.ringsFlat;
	var outSigs = array.class.fill(NTSS.spk.numLogicOuts, Silent.ar);
	array.do { |chan, i|
		var spkDict = NTSS.spk.atName(nameList[i]);
		var logicOut = if (spkDict.notNil) { spkDict.logicOut };
		case { logicOut.isNil } {
			warn("reorderRingsToSpeakers: no spkIndex at %\n".format(i));
		} { logicOut >= NTSS.spk.numLogicOuts } {
			warn("reorderRingsToSpeakers: spkIndex % outside range.\n".format(logicOut));
		} {
			outSigs.put(logicOut, chan);
		};
	};
	outSigs // in logic order
};

NTSS.addPanNames = { |q ... names|
	names.flat.do { |name|
		if (NTSS.allPanNames.includes(name).not) {
			NTSS.allPanNames.add(name)
		}
	};
};

NTSS.updatePanNames = { |newNames|
	if (newNames.notNil) {
		NTSS.pchains.do { |pch|
			var panpop = pch.getHalo(\panPop);
			if (panpop.notNil and: { panpop.view.isClosed.not }) {
				panpop.items = newNames
			}
		}
	}
};

/**** tests
// all speakers in rings are unique
NTSS.ringsFlat
NTSS.ringsFlat.size == NTSS.ringsFlat.asSet.size
// reordering ringNames by indices
NTSS.reorderRingsToSpeakers(NTSS.ringsFlat) == NTSS.spk.names;


// should switch between 4 rings!
Ndef(\testRings, {
	var snd24 = (LFPulse.ar(0.25, [0, 1, 2, 3] / 4, 0.25) * PinkNoise.ar).collect(_.dup(6)).flat;
	var arr = Silent.ar ! 24;
	NTSS.reorderRingsToSpeakers(snd24);
}).play;

// test one ring:
Ndef(\testRings, {
	var arr = Silent.ar ! 24, snd = Dust2.ar(500);
	var ring = NTSS.spk.groups[NTSS.ringNames.choose.postln];
	ring.do { |name|
		var index = NTSS.spk.names.indexOf(name);
		(name.cs + index).postln;
		arr.put(index, snd);
	};
	arr;
}).play;

****/

NTSS.addPanNames([ \panFixed, \panRoto, \panSnake, \panFeed]);

// shared parameter names and ranges for dirrent panModes

// the input buses coming from the PMCs
Spec.add(\srcBus, [s.options.firstPrivateBus] + [0, 31] ++ [\lin, 1]);
// angle position on the ring
Spec.add(\srcPos, [-2, 2]); // +2 is one full rotation
// source width on the ring (scaled PanAz width)
Spec.add(\srcWidth, \unipolar);

ProxyChain.add3(\panFixed, { |srcBus = 0, srcPos = 0, srcWidth = 0|
	// \panFixed
	var width = (srcWidth  ** 2).linlin(0, 1, 2, 6);
	var widAmp = srcWidth.linexp(0, 1, 1, 0.4);
	var in = InFeedback.ar(srcBus);

	var panned = NTSS.ringNames.collect { |ringname|
		var ringamp = ringname.kr(0.25, 1);
		var ringSize = NTSS.spk.groups[ringname].size;
		// "panFixed: % has % spks.\n".postf(ringname, ringSize);
		PanAz.ar(ringSize, in, srcPos * 1, ringamp * widAmp, width, 0)
	};
	// panned.printAll.shape.postln;
	NTSS.reorderRingsToSpeakers(panned.flat);
});

ProxyChain.sourceDicts[\panFixed].put(\text,
	"panFixed pans into 4 rings of 6 speakers:
srcPos:  circular position on the ring,
srcWidth: 0 is max 2 speakers on the ring, 1 is all speakers
left, right, back, up: volume levels for the 4 rings.");


Spec.add(\rotRate, [-5, 5]);
Spec.add(\pendRate, [0, 5, 8]);
Spec.add(\pendDepth, [0, 5, 3]);
Spec.add(\circle, [0, 3]);
Spec.add(\cirWidth, \unipolar);


ProxyChain.add3(\panRoto, { |srcBus = 64,
	srcPos = 0, srcWidth = 0,
	circle  = 0, cirWidth = 0,
	rotRate = 0, pendRate = 0.05, pendDepth = 1|
	// \panRoto

	var in = Limiter.ar(InFeedback.ar(srcBus, 1), 1, 0.001);

	var circleAmp = cirWidth.linexp(0, 1, 1, 0.4);
	var cirPan2 = Pan2.ar(in, cirWidth ** 2 * 2 - 1, circleAmp);
	var cirWidth2 = (cirWidth  ** 2).linlin(0, 1, 2, 6);
	var circleMagnet =  circle + ((circle * -2pi).sin * 0.15)/2;
	var circles = PanAz.ar(NTSS.ringNames.size, cirPan2[0], circleMagnet.lag(1), 1, cirWidth2, 0)
	+ cirPan2[1].dup(4);

	var posAmp = srcWidth.linexp(0, 1, 1, 0.4);
	var srcWidth2 = (srcWidth  ** 2).linlin(0, 1, 2, 6);
	var panPos2 = srcWidth ** 2 * 2 - 1;
	var rotPos = LFSaw.kr(rotRate ** 2);
	var posMod = SinOsc.kr((pendRate / pendDepth.lag(2).max(1)).lag(2), 0, pendDepth.lag(2));
	var posAll = (srcPos.lag(2) * 0.4) + posMod + rotPos;
	// Out.kr(krBus, [posAll, srcWidth2, circleMagnet.lag(1), cirWidth2]);

	var panned = circles.collect { |cirChan, i|
		var ringname = NTSS.ringNames[i];
		var ringSize = NTSS.spk.groups[ringname].size;
		var posPan2 = Pan2.ar(cirChan, panPos2, posAmp);
		PanAz.ar(ringSize, posPan2[0], posAll, 1, srcWidth2, 0) + posPan2[1].dup(5);
	}.flat;

	NTSS.reorderRingsToSpeakers(panned);

}, 0.25);

ProxyChain.sourceDicts[\panRoto].put(\text,
	"panRoto pans into 4 rings of 6 speakers,
with a pendulum-like back and forth swing option,
and fixed-speed rotation, which are added together.

srcPos:    circular position on the ring,
srcWidth:  0 is max 2 speakers on the ring, 1 is all speakers
circle:    position in a ring of the 4 circles, as on a torus.
cirWidth:  width across the rings, 0 is max 2 rings , 1 is all rings
rotRate:   rate of rotation around the circles of 6, in Hertz.
pendRate:  rate of one full pendulum swing in Hertz, i.e.
           from center to left to center to reight to center.
pendDepth: depth of pendulum swing, 1 is 180 deg left, 180 right.");


ProxyChain.add3(\panSnake, { |srcBus = 0, srcPos = 0, srcWidth = 0, amp = 0.25,
	rotRate = 0, pendRate = 0.05, pendDepth = 1|

	var width = (srcWidth  ** 2).linlin(0, 1, 2, 6);
	var widAmp = srcWidth.linexp(0, 1, 1, 0.2);
	var in = InFeedback.ar(srcBus);
	var rotPos = LFSaw.kr(rotRate ** 2);
	var posMod = SinOsc.kr((pendRate / pendDepth.lag(2).max(1)).lag(2), 0, pendDepth.lag(2));
	var posAll = (srcPos.lag(2)) + posMod + rotPos;

	var panned = PanAz.ar(NTSS.ringsFlat.size, in, posAll, (amp * widAmp).lag(1), width, 0);

	NTSS.reorderRingsToSpeakers(panned);
});

ProxyChain.sourceDicts[\panSnake].put(\text,
	"panSnake pans into one long ring of all 24 speakers,
with fixed-speed rotation and pendulum movement options.
srcPos:    circular position, now on the long ring,
srcWidth:  0 is max 2 speakers on the ring, 1 is all speakers
rotRate:   rate of rotation around the circles of 6, in Hertz.
pendRate:  rate of one full pendulum swing in Hertz, i.e.
           from center to left to center to reight to center.
pendDepth: depth of pendulum swing, 1 is 180 deg left, 180 right.");


Spec.add(\direct, \amp);
Spec.add(\delayed, \amp);
Spec.add(\feedback, \amp);
Spec.add(\rotate, NTSS.ringNumSpks * [-1,1]);

ProxyChain.add3(\panFeed, { |srcBus, srcPos = 0, srcWidth = 0,
	direct = 1, delayed = 0.8, feedback = 0.8, delaytime = 2, rotate = 1|

	var numCh = NTSS.ringNumSpks;
	var ringAmps = NTSS.ringNames.collect { |name|
		name.kr(0.5, 1, spec: \amp);
	};
	var width = (srcWidth  ** 2).linlin(0, 1, 2, numCh);
	var in = PanAz.ar(numCh, InFeedback.ar(srcBus), srcPos.lag(2) * 2 / numCh, 1, width, 0);
	var feedy = LocalIn.ar(NTSS.ringNumSpks) * feedback.lag(2);
	var dts = delaytime.lag(5) * LFDNoise3.kr(0.03 ! numCh, 0.02, 0.98);
	var delays = DelayL.ar(LeakDC.ar(in + feedy, 0.998), 10, dts);

	var mixedouts, panned;

	// better rotate with PanAz:
	var rotated = delays.collect { |chan, i|
		var rotatedpos = i + rotate * (2 / numCh);
		PanAz.ar(NTSS.ringNumSpks, chan, rotatedpos, 1, 2, 0);
	}.sum;

	rotated = Limiter.ar(rotated, 1, 0.001);
	LocalOut.ar(rotated);

	// numCh outs, table-multiplied by ring amps

	mixedouts = ((in * direct.lag(2)) + (rotated * delayed.lag(2)));
	panned = (mixedouts *.t ringAmps).flop.flat;

	// should be adjustable for different ringsizes ...
	// leave the 24 for now, should be OK

	NTSS.reorderRingsToSpeakers(panned);

});

ProxyChain.sourceDicts[\panFeed].put(\text,
	"panFeed pans into 4 rings of 6 speakers each,
with delay and feedback that can be rotated.
srcPos:    circular position, now on the long ring,
srcWidth:  0 is max 2 speakers on the ring, 1 is all speakers
direct:    level of direct panned sound
delayed:   level of delayed sound
feedback:  level of feedback in delayed sound
delaytime: delaytime of delayed sound
rotate:    number of speakers by which delay is rotated against source.
           0 is none, 1 is 1 spk. clockwise, 3 is opposite on ring of 6."
);
