"NTSS panners to stereo.".postln;

/* Switchable panners for a Stereo Ndef bus going to rings of 4 * 6 speakers:

srcPos sets position in circle,
srcPosD sets position offset of  chan 2 in circle,
srcWidth opens to more chans
send levels to 4 rings are independent

pendRate and pendDepth modulate pos with a sinosc

Ndef(\pan1, ProxyChain.allSources[\ringFix2]);
Ndef(\pan1, ProxyChain.allSources[\ringFix2]);
Ndef(\pan1).gui;

Ndef(\pan1).gui;
*/


NTSS.addPanNames([ \ringSnake2, \ringFix2, \ringRoto2, \ringFeed2 ]);

// shared parameter names and ranges for dirrent panModes

// the input buses coming from the PMCs
Spec.add(\srcBus, [s.options.firstPrivateBus] + [0, 31] ++ [\lin, 1]);
// angle position on the ring
Spec.add(\srcPos, [-2, 2]);
Spec.add(\srcPosD, [-2, 2]);
// source width on the ring (scaled PanAz width)
Spec.add(\srcWidth, \unipolar);

ProxyChain.add3(\ringFix2, { |srcBus = 0, srcPos = 0, srcPosD = 0.5, srcWidth = 0|
	// \ringFix2
	var width = (srcWidth  ** 2).linlin(0, 1, 2, 6);
	var widAmp = srcWidth.linexp(0, 1, 1, 0.4);
	var ins = InFeedback.ar(srcBus, 2);

	var panned = NTSS.ringNames.collect { |ringname|
		var ringamp = ringname.kr(0.25, 1);
		var ringSize = NTSS.spk.groups[ringname].size;
		PanAz.ar(ringSize, ins, srcPos + [0, srcPosD], ringamp * widAmp, width, 0).sum
	}.flat;

	panned;
	NTSS.reorderRingsToSpeakers(panned);
});

ProxyChain.sourceDicts[\ringFix2].put(\text,
	"ringFix2 pans into 4 rings of 6 speakers:
srcPos:  circular position on the ring,
srcPosD:  offset of chan2 on circular position on the ring,
srcWidth: 0 is max 2 speakers on the ring, 1 is all speakers
left, right, back, up: volume levels for the 4 rings.");


(
Spec.add(\rotRate, [-5, 5]);
Spec.add(\pendRate, [0, 5, 8]);
Spec.add(\pendDepth, [0, 5, 3]);
Spec.add(\circle, [0, 3]);
Spec.add(\cirWidth, \unipolar);

ProxyChain.add3(\ringRoto2, { |srcBus = 64,
	srcPos = 0, srcPosD, srcWidth = 0,
	circle  = 0, cirWidth = 0,
	rotRate = 0, pendRate = 0.05, pendDepth = 1|

	// was mono, now stereo:
	var ins = Limiter.ar(InFeedback.ar(srcBus, 2), 1, 0.001);

	// prepare the circles
	var circleAmp = cirWidth.linexp(0, 1, 1, 0.4);
	var cirWidth2 = (cirWidth  ** 2).linlin(0, 1, 2, 6);
	var circleMagnet =  circle + ((circle * -2pi).sin * 0.15)/2;
	// prepare positions
	var posAmp = srcWidth.linexp(0, 1, 1, 0.4);
	var srcWidth2 = (srcWidth  ** 2).linlin(0, 1, 2, 6);
	var panPos2 = srcWidth ** 2 * 2 - 1;
	var rotPos = LFSaw.kr(rotRate ** 2);
	var posMod = SinOsc.kr((pendRate / pendDepth.lag(2).max(1)).lag(2), 0, pendDepth.lag(2));
	var posAll = (srcPos.lag(2) * 0.4) + posMod + rotPos;
	var posAll2 = posAll + [0, srcPosD];
	// Out.kr(krBus, [posAll, srcWidth2, circleMagnet.lag(1), cirWidth2]);


	var panned = ins.collect { |in, stereoIdx|
		var panAzPos = posAll2[stereoIdx];
		var cirPan2 = Pan2.ar(in, cirWidth ** 2 * 2 - 1, circleAmp).postln;

		var circles = PanAz.ar(4, cirPan2[0], circleMagnet.lag(1), 1, cirWidth2, 0) + cirPan2[1].dup(4);

		circles.collect { |cirChan, i|
			var posPan2 = Pan2.ar(cirChan, panPos2, posAmp);
			PanAz.ar(NTSS.ringNumSpks, posPan2[0], panAzPos, 1, srcWidth2, 0) + posPan2[1].dup(5);
		}.flat;
	}.sum;

	panned.shape.postln;
	// panned.postln;

	NTSS.reorderRingsToSpeakers(panned);

}, 0.25);


ProxyChain.sourceDicts[\ringRoto2].put(\text,
	"ringRoto2 pans into 4 rings of 6 speakers,
with a pendulum-like back and forth swing option,
and fixed-speed rotation, which are added together.

srcPos:    circular position on the ring,
srcPosD:   offset of channel2 position on the ring,

srcWidth:  0 is max 2 speakers on the ring, 1 is all speakers
circle:    position in a ring of the 4 circles, as on a torus.
cirWidth:  width across the rings, 0 is max 2 rings , 1 is all rings
rotRate:   rate of rotation around the circles of 6, in Hertz.
pendRate:  rate of one full pendulum swing in Hertz, i.e.
from center to left to center to reight to center.
pendDepth: depth of pendulum swing, 1 is 180 deg left, 180 right.");
);

ProxyChain.add3(\ringSnake2, { |srcBus = 0, srcPos = 0, srcPosD = 0.5, srcWidth = 0, amp = 0.25,
	rotRate = 0, pendRate = 0.05, pendDepth = 1|

	var width = (srcWidth  ** 2).linlin(0, 1, 2, 6);
	var widAmp = srcWidth.linexp(0, 1, 1, 0.2);
	var ins = InFeedback.ar(srcBus, 2);
	var rotPos = LFSaw.kr(rotRate ** 2);
	var posMod = SinOsc.kr((pendRate / pendDepth.lag(2).max(1)).lag(2), 0, pendDepth.lag(2));
	var posesAll = (srcPos + [0, srcPosD]).lag(2) + posMod + rotPos;

	var panned = PanAz.ar(NTSS.ringsFlat.size, ins, posesAll, (amp * widAmp).lag(1), width, 0).sum;

	NTSS.reorderRingsToSpeakers(panned);
});

ProxyChain.sourceDicts[\ringSnake2].put(\text,
	"ringSnake2 pans into one long ring of all 24 speakers,
with fixed-speed rotation and pendulum movement options.
srcPos:    circular position, now on the long ring,
srcPosD:  offset of chan2 on circular position on the ring,
srcWidth:  0 is max 2 speakers on the ring, 1 is all speakers
rotRate:   rate of rotation around the circles of 6, in Hertz.
pendRate:  rate of one full pendulum swing in Hertz, i.e.
from center to left to center to reight to center.
pendDepth: depth of pendulum swing, 1 is 180 deg left, 180 right.");

(
Spec.add(\direct, \amp);
Spec.add(\delayed, \amp);
Spec.add(\feedback, \amp);
Spec.add(\rotate, NTSS.ringNumSpks * [-1,1]);

ProxyChain.add3(\ringFeed2, { |srcBus, srcPos = 0, srcPosD = 0.5, srcWidth = 0,
	direct = 1, delayed = 0.8, feedback = 0.8, delaytime = 2, rotate = 1|

	var numCh = NTSS.ringNumSpks;
	var ringAmps = NTSS.ringNames.collect { |name|
		name.kr(0.5, 1, spec: \amp);
	};
	var width = (srcWidth  ** 2).linlin(0, 1, 2, numCh);
	// var ins = PanAz.ar(numCh, InFeedback.ar(srcBus), srcPos.lag(2) * 2 / numCh, 1, width, 0);
	var inChans = InFeedback.ar(srcBus, 2);
	var ins = inChans.collect { |in, i|
		PanAz.ar(numCh, in, (srcPos + [0, srcPosD][i]).lag(2), 1, width, 0);
	}.sum;

	var feedy = LocalIn.ar(NTSS.ringNumSpks) * feedback.lag(2);
	var dts = delaytime.lag(5) * LFDNoise3.kr(0.03 ! numCh, 0.02, 0.98);
	var delays = DelayL.ar(LeakDC.ar(ins + feedy, 0.998), 10, dts);

	var mixedouts, panned;

	// better rotate with PanAz:
	var rotated = delays.collect { |chan, i|
		var rotatedpos = i + rotate * (2 / numCh);
		PanAz.ar(NTSS.ringNumSpks, chan, rotatedpos, 1, 2, 0);
	}.sum;

	rotated = Limiter.ar(rotated, 1, 0.001);
	LocalOut.ar(rotated);

	// numCh outs, table-multiplied by ring amps

	mixedouts = ((ins * direct.lag(2)) + (rotated * delayed.lag(2)));
	panned = (mixedouts *.t ringAmps).flop.flat;

	NTSS.reorderRingsToSpeakers(panned);

});

ProxyChain.sourceDicts[\ringFeed2].put(\text,
	"ringFeed2 pans into 4 rings of 6 speakers each,
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
)