(
ProxyChain.add3(\levels, \filter -> { |in,
	inside = 0.25, shakers = 0.25, outside = 0.25, bigPA = 0.25,
	strings = 0.25, stereo = 0.25,
	insideLim = 0.5, shakersLim = 0.5, outsideLim = 0.5, bigPALim = 0.5,
	stringsLim = 0.5, stereoLim = 0.5|

	var inSize = ("****" + in.size).postln;
	var insideCh = Limiter.ar(in.copyRange(0, 4) * inside.lag(0.5), insideLim, 0.002);

	var shakersCh = Limiter.ar(in.copyRange(5, 7) * shakers.lag(0.5), shakersLim, 0.002);
	var stringsCh = Limiter.ar(in.copyRange(8, 9) * strings.lag(0.5), stringsLim, 0.002);

	var outsideCh = Limiter.ar(in.copyRange(10, 14) * outside.lag(0.5), outsideLim, 0.002);
	var bigPACh = Limiter.ar(in.copyRange(15, 19) * bigPA.lag(0.5), bigPALim, 0.002);

	var stereoCh = Limiter.ar(
		Splay.ar(in.keep(20) * stereo.lag(0.5), 1, 1, 0, false), stringsLim, 0.002);
	[insideCh, shakersCh, stringsCh, outsideCh, bigPACh, stereoCh].flat;

}, 1, (
	inside: \amp, shakers: \amp, outside: \amp, bigPA: \amp, strings: \amp, stereo: \amp,
	insideLim: \amp, shakersLim: \amp, outsideLim: \amp, bigPALim: \amp,
	stringsLim: \amp, stereoLim: \amp
)
);
);

(
// molens volans Doppler wheel panner.
// sums all input to mono; turns it in a ring of 5
// "ring" param chooses on which ring they play

ProxyChain.add3(\molens, \filter -> { | in, ampWh = 1, rotWh = 0.051, sizeWh=16, ampExp = 0.75, lagWheel=12.5, ring=0|

	var numSpk = 5; // constant here!
	var wheelXY, xys, dists, dt, ut, dAmp , rad=1;
	var poly = numSpk, listeners = numSpk;

	// wheelin
	var wheelRotAngle;
	sizeWh = sizeWh.lag3(lagWheel);
	wheelRotAngle = LFSaw.kr(rotWh.lag3(lagWheel), 0.5, pi);
	wheelXY = sizeWh.lag3(lagWheel)
	* [wheelRotAngle.cos, wheelRotAngle.sin ];

	xys = (((0,1..poly-1)*2*pi/poly).collect({ arg ang; [ang.sin, ang.cos]}) * rad).round(0.01).scramble;

	dists = xys.collect({ arg pair;
		(pair/xys.flat.sort.last * sizeWh
			- wheelXY).squared.sum + 1
	});

	dt = dists.sqrt / 330;	// ha amp compensated;
	dAmp = (dists
		** (ampExp.neg * (
			sizeWh ** 0.45
		)
	).reciprocal.lag3(1));
	in = Limiter.ar(in.sum  * dAmp * ampWh.lag(0.1) , 0.97, 0.1);
	ut = DelayC.ar(in, 0.5, dt);
	PanAz.ar(4, ut, ring-1 / 2.25).flop.postln; // how to scale ring pos properly?
},
1,
[
	\ampWh, \amp,
	\rotWh, [0, 100, 7],
	\sizeWh, [1, 50, 2],
	\ampExp, [0.1, 1, \exp],
	\lagWheel, [0, 60, 5],
	\ring, [1, 5]
]
)
);

ProxyChain.sourceDicts.molens.specs.keysValuesDo { |key, spec| Spec.add(key, spec) };



ProxyChain.add3(\mix2stereo, \filter -> { |in|
	Splay.ar(in.keep(20) ++ DC.ar).clipExtend(in.size);
}, 1);

ProxyChain.add3(\mix2four, \filter -> { |in|
	(SplayAz.ar(4, in.keep(20).clump(5).sum) ++ DC.ar).clipExtend(in.size);
}, 1);



ProxyChain.add3(
	\mainMixer,  \filter -> { |in|
		var snds = in;
		var mainvol = \mainvol.kr(0, spec:\amp);
		var amps = NTSS.amp_names.collect {|name| name.kr(1, spec:\amp) } ++ DC.ar(0!(32-NTSS.amp_names.size));
		// measured in class:
		//var tuning = (1!20) ++ (0.0!12);
		//var tuning = [0.4, 0.35, 0.13, 0.13, 0.14, 0.15, 0.3, 0.7, 0.5, 0.5, 0.5, 0.5, 0.5, 0.4, 0.4, 0.32, 0.4, 0.5, 1, 0.8, 1, 0.6, 0.5, 0.3, 1, 1] ++ (0.0!(32-NTSS.amp_names.size));
		var tuning = NTSS.speakersTuning ++ (0.0!(32-NTSS.speakersTuning.size));
		snds * (amps * mainvol * tuning);
	},
	1,
	NTSS.amp_names.collect { |name| [name, [0,1,\amp]] }.flatten.asDict
);

ProxyChain.add3(
	\shiftSound,  \filter -> { |in|
		Limiter.ar(LeakDC.ar(
			in[0..9] ++ DC.ar(0!2) ++ in[10..15],
			\maxVol.kr(0.99, spec:\amp)))
	},
	1,
);

ProxyChain.add3(\shiftSpeakers, \filter -> {|in|
	var currentSpeakers = NTSS.speakers.size;
	var outs = Silent.ar!s.options.numOutputBusChannels;
	var counter = 0;
	NTSS.speakersOrder.do {|speaker,i|
		if (speaker != \empty) {
			outs[i] = in[counter];
			counter = counter + 1;
		};
	};
	outs.size.postln;
	outs;
}, 1);


MainFX(s).clear;
MainFX(s, NTSS.speakersOrder.size, [\mainMixer, \mix2four, \mix2stereo, \shiftSpeakers]);
//MainFX(s).add(\levels, 1);
MainFX(s).add(\mainMixer, 1);
MainFX(s).add(\shiftSpeakers, 1);
WinBounds.addMake(\MainFX, {
	var mg = MainFXGui(MainFX(s), 32);
	mg.editGui.paramGui.paramViews[0].enabled_(false);
	mg.parent.name_(\MainFX);
});
WinBounds.showOrMake(\MainFX);
Butz.add(\MainFX, { WinBounds.showOrMake(\MainFX) });

/*
(
[1,2,3,4,5] +.t [1000, 2000]
).flop.flat
MainFX(s).gui
*/
 