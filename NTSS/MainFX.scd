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

Spec.add(\gainDB, [-12, 12]);
Spec.add(\treble, \gainDB);
Spec.add(\mid, \gainDB);
Spec.add(\bass, \gainDB);

ProxyChain.sourceDicts.molens.specs.keysValuesDo { |key, spec| Spec.add(key, spec) };

ProxyChain.add3(\eq3, \filter -> { |in, treble =0, mid = 0, bass = 0|
	in = BLowShelf.ar( in, 400, 1, bass);
	in = BPeakEQ.ar( in, 1200, 0.5, mid);
	in = BHiShelf.ar( in, 5000, 1, treble);
}, 1, (
	bass: [-12, 12],
	mid: [-12, 12],
	treble: [-12, 12]
));

ProxyChain.sourceDicts[\eq3].text =
"eq3 is a simple 3 band Equalizer with
bass, mid, and treble controls of +- 12 dB.";


ProxyChain.add3(\mix2stereo, \filter -> { |in|
	(Splay.ar(in) ++ DC.ar).clipExtend(in.size);
}, 1);

ProxyChain.sourceDicts[\mix2stereo].text =
"mix2stereo is a convenience for offline work on NTSS projects:
It mixes all input channels down to Stereo
on channels 1, 2 and mutes all other channels.";


ProxyChain.add3(\mix2four, \filter -> { |in|
	(SplayAz.ar(4, in) ++ DC.ar).clipExtend(in.size);
}, 1);

ProxyChain.sourceDicts[\mix2four]. text =
"mix2four is a convenience for offline work on NTSS projects:
It mixes all input channels down to quadro,
on channels 1, 2, 3, 4 and mutes all other channels.";


ProxyChain.add3(
	\mainMixer,  \filter -> { |in, mainvol = 0.25, subFreq = 100, mix2Sub = 0.25|
		var amps = NTSS.amp_names.collect {|name| name.kr(1, spec:\amp4) };

		var spkChans = in.keep(NTSS.speakers.size - 1);
		var mixSpks = RLPF.ar(
			spkChans.sum *  (1/ NTSS.speakers.size.sqrt),
			subFreq.lag(1)
		);
		var subChans = in.drop(NTSS.speakers.size - 1) + (mixSpks * mix2Sub);
		var allChans = spkChans ++ subChans;

		// measured in class: all speakers
		var tuning = NTSS.speakersTuning;

		var finalLogicalOut = allChans * (amps * mainvol);
		Out.ar(NTSS.spatbus, finalLogicalOut);

		finalLogicalOut  * tuning
	},
	1,
	specs: (\mainvol: \amp, subFreq: [20, 150, \exp], mix2Sub: \amp).putAll(
		NTSS.amp_names.collect { |name| [name, [0,1,\amp]] }.flatten.asDict
	)
);

ProxyChain.sourceDicts[\mainMixer]. text =
"    mainMixer has several functions:
mainvol: sets main volume of all channels
subFreq: the rolloff frequency for the subwoofer channel
mix2sub: the level of the mono mix (of all active channel) to the subwoofer
The last channel also plays directly to the subwoofer.
The controls after mix2sub are for each individual speaker by name. ";



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

ProxyChain.sourceDicts[\shiftSpeakers]. text =
"shiftSpeakers should always be ON, except when testing levels.
The sound channels come from the panners in a logical order,
and shiftSpeakers reorders them so they go to the right speakers.
NTSS.spk.data is the place where this info is stored.
E.g. NTSS.spk.data[12] is:
('name': wd11, 'x': 1.0, 'logicOut': 21, 'y': 5.5,
  'relAmp': 0.25, 'hwOut': 12, 'z': 1.1)
which means speaker wd11 has logical output 21 from the panners,
and shiftSpeakers reorders it to hardware output hwOut: 12.";



MainFX(s).clear;
MainFX(s, NTSS.speakersOrder.size,
	[\eq3, \mainMixer, \mix2four, \mix2stereo, \shiftSpeakers]
);
//MainFX(s).add(\levels, 1);
MainFX(s).add(\mainMixer, 1);
MainFX(s).add(\shiftSpeakers, 1);




WinBounds.addMake(\MainFX, {
	var mg = MainFXGui(MainFX(s), 34);
	var splainIndex = MainFX(s).slotNames.size + 2;
	mg.editGui.paramGui.paramViews[0].enabled_(false);
	mg.parent.name_(\MainFX);

	mg.buttons[splainIndex].visible_(true).states_([[\mainsplain]])
	.action_({ WinBounds.showOrMake(\mainsplain) });
	mg.parent;
});

Butz.add(\MainFX, { WinBounds.showOrMake(\MainFX) });

WinBounds.addMake(\mainsplain, {
	MFdef(\funxplainWin).value(\mainsplain,
		MainFX(s).proxyChain.slotNames.asArray)
	.first;
});

/*
(
[1,2,3,4,5] +.t [1000, 2000]
).flop.flat
MainFX(s).gui
*/
