/*
PMC:
Pepsi Modifier Board Channel, or Proxy MultiFX Chain

input module has
* mic input selector and amp
* proxy mono input dropsink and amp
* noiseamp for quick testing

sndfile module has
* soundfile dropsink, bufnum,
* playrate, looping, modulation

FX chain has


wishlist:
- select already loaded buffers
- organize sndfiles and folder locally,
- with subfolders to load array of files at once

ProxyChainPreset:
- share stored presets between PCPs
- store one global preset collection of all ?


*/

q = q ? ();
NTSS.numPmcs = NTSS.numPmcs ? 8;

NTSS.allPcNames = [
	\ada, \bob, \cecilia, \dada, \eek,
	\fifi, \gogo, \hah, \ivy, \jay,
	\kiki, \lily, \mimi, \nana, \opo,
	\pepe, \qiqo, \roro, \sisu, \tata,
	\ubu, \vovo, \wawa, \xoxo, \yoyo, \zazie ];

NTSS.pcNames = NTSS.numPmcs.collect { |i|
	("ch" ++ (i+ 101).asString.keep(-2) ++ NTSS.allPcNames[i]).asSymbol
};
NTSS.pannerNames = NTSS.pcNames.collect { |name| name.asString.insert(2, "P").asSymbol };

NTSS.addPanNames = { |q ... names|
	names.flat.do { |name|
		if (NTSS.allPanNames.includes(name).not) {
			NTSS.allPanNames.add(name)
		}
	};
}

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


(
// just to put the config params on top
ProxyChain.add3(\top, { |micBus, proxyBus = -1, bufnum|
	Silent.ar;

}, 0, (
	micBus: [0, 32, \lin, 1],
	proxyBus: [-1, s.options.numAudioBusChannels, \lin, 1],
	bufnum: [0, s.bufferAllocator.size-1, \lin, 1],
)
);

// inputs: mic, pluggable bus-input,
// pinknoise to simulate analog electronics noise
ProxyChain.add3(\ins, \mix -> { |micBus = 0, micAmp = 0, proxyBus = 4, proxyAmp = 0, noiseAmp = 0.0|
	var micSnd = SoundIn.ar(micBus) * micAmp.lag(1);
	var busSnd = InFeedback.ar(proxyBus) * proxyAmp.lag(1);
	var pinkSnd = PinkNoise.ar(noiseAmp.lag(1));
	var snd = micSnd + busSnd + pinkSnd;

	// limit max level by clipping
	// snd = snd.softclip;
	// remove DC drift to avoid feedback to +1 or -1
	snd = LeakDC.ar(snd, 0.999);
	snd;
}, 1, (
	micBus: [0, 32, \lin, 1],
	micAmp: \amp4,
	proxyBus: [-1, s.options.numAudioBusChannels, \lin, 1],
	proxyAmp: \amp4,
	noiseAmp: \amp
)
)
);

(
// sndfile input: plays sndfiles
ProxyChain.add3(\sndfile, \mix -> { |amp = 0.25, bufnum = 0, playRate = 1, tune = 0, loop = 1,
	rtModFreq = 6, rtModDepth = 0|
	// play 100 Hz samplerate at speed * 10
	var bufRateMinRatio = (1000 / BufSampleRate.kr(bufnum)).max(1);
	var pbrate = playRate * SinOsc.kr(rtModFreq, 0, rtModDepth).midiratio;
	PlayBuf.ar(1, bufnum,
		pbrate * BufRateScale.kr(bufnum) * bufRateMinRatio * tune.midiratio,
		loop: loop)
	* amp;
}, 1, (
	bufnum: [0, s.bufferAllocator.size-1, \lin, 1],
	playRate: [-4, 4 ],
	tune: [-12, 12 ],
	loop: [0, 1, \lin, 1],
	rtModFreq: [0.06, 600, \exp, 0.001],
	rtModDepth: [0, 24, \amp, 0.001]
)
)
);

///// Mumma1: freq shift mod, with envelope following
///// todo:
///// - add vibrato mode, maybe parallel to shift?
///// - add envelope modulation (width)

(
ProxyChain.add3(\freqMod, \filter -> { |in, carrFreq=5000, filtRatio=1, freqShift=30|
	var freq2 = carrFreq + freqShift;
	var snd = in.asArray.mean * SinOsc.ar(carrFreq, [0, pi/2]);
	snd = LPF.ar(snd, (carrFreq * filtRatio).clip(20, (s.sampleRate * 0.45) - carrFreq));
	snd = snd * SinOsc.ar(freq2, [0, pi/2]);
	snd.sum;
}, 1, (
	carrFreq: [200, 6000, \exp],
	filtRatio: [1, 10, \exp],
	freqShift: [-1000, 1000]
	// freqShift: Env([-2000, 0, 2000], [0.5, 0.5], [-4, 4]),
)
)
);


// // Mumma2: amplitude modulation with envelope following
///// note: specs moved into add3
// Spec.add(\amFreq, [0.1, 1000, \exp, 0.1]);
// Spec.add(\amWidth, [0, 4, \amp]);
// Spec.add(\amRateMod, [-1, 1]);
(
ProxyChain.add3(\ampMod, \filter -> { |in, amFreq = 16, amWidth = 0.5, amRateMod = 0.5|
	var snd = in;
	var envel = Amplitude.kr(snd, 0.01, 0.5);
	var envmod = (48 * envel * amRateMod).midiratio;
	var modOsc = SinOsc.ar(amFreq.lag(3) * envmod).range(1, 1-amWidth);
	///// comment this line out for ring mod,
	//// comment in to create shorter pulses:
	modOsc = modOsc.clip(0, 1);
	snd * modOsc;
}, 1, (
	// specs go here:
	\amFreq: [0.1, 1000, \exp, 0.1],
	\amWidth: [0, 4, \amp],
	\amRateMod: [-1, 1],
)
)
);


(
ProxyChain.add3(\hiPass, \filter -> { |in, hpFreq = 200, hpWidth = 0.5, hpRate = 3, hpRateMod = 0.5|

	var envel = Amplitude.kr(in, 0.01, 0.5);
	var envmod = (48 * envel * hpRateMod.lag).midiratio; // +- 4 octaves max
	var modOsc = SinOsc.ar(hpRate.lag.lag(3) * envmod) * hpWidth.lag;
	var filtfreq = (hpFreq * (16 ** modOsc)).clip(20, 20000);
	HPF.ar(in, filtfreq);
}, 1, (
	// specs go here:
	\hpFreq: [20, 2000, \exp, 0.1],
	\hpWidth: [0, 1],
	\hpRate: [0.1, 100, \exp],
	hpRateMod: [-1, 1],
)
)
);

ProxyChain.add3(\gapz, \filter -> { |in, probkeep = 0.5, mindur = 0.01|
	var trig = Trig1.ar(in.sign, mindur.clip(0, 1));
	var passamp = Latch.ar(CoinGate.ar(probkeep, trig), trig);
	in * passamp;
}, 0.5, (
	\probkeep: [0, 1 ],
	\mindur: [0, 0.5, 5.5 ]
));

//// big DJ tilt filter that
//// goes from closing LPF to HPF
(
ProxyChain.add3(\tilta, \filter -> { |in,
	tilt = 0,
	// curve = 1, reso = 5,
	flWidth = 0.5, flRate = 3, flRateMod = 0.5|
	var lag = Ndef(\lag).kr[0];
	var curve = 1;

	var in2 = in;// + (PinkNoise.ar * 0.5);

	var envel = Amplitude.kr(in, 0.01, 0.5);
	var envmod = (24 * envel * flRateMod.lag(lag)).midiratio; // +-2 octaves max
	var modOsc = SinOsc.ar(flRate.lag(lag) * envmod);
	var freqmod = (modOsc * flWidth.lag(lag) * 0.5);

	var freqctl = (tilt + freqmod ** curve);
	var lpfreq = freqctl.linexp(-1, 0, 100, 20000);
	var hpfreq = freqctl.linexp(0, 1, 20, 4000);

	RHPF.ar(RLPF.ar(in2, lpfreq, 0.7), hpfreq, 0.7);
},
1,
(
	// specs go here:
	tilt: \pan,
	curve: \pan,
	reso: [1, 11],
	flWidth: [-1, 1],
	flRate: [0.1, 50, \exp],
	flRateMod: [-1, 1]
)
)
);

ProxyChain.add3(\reverb, \filterIn -> { |in, revTime = 2, animRate = 0.1, animDepth = 0.3|

	AdCVerb2.ar(in.zap.asArray.sum * 0.2,
		revTime.lag(0.5),
		animRate.lag(0.5),
		animDepth.lag(0.5),
		hfDamping: 0.1,
		nOuts: 1,         // fixed number of decorrelated output channels
		predelay: 0.03.lag(0.5),
		numCombs:     8,     // fixed number - increase for more density
		numAllpasses: 4,     // fixed number - increase for more diffuseness
		inFilter: 0.6,
		leakCoeff: 0.99
	);
},
0.1,
(
\revTime: [0.01, 100, \exp],
\animRate: [0.01, 10, \exp],
\animDepth: [0, 1, \amp],
\hfDamping: [0, 1],
\predelay: [0.0, 0.2, \amp],
\revTime: [0.01, 100, \exp],
\inFilter: [-0.99, 0.99]
)
);

(
ProxyChain.add3(\limiter, \filter -> { |in,
	drive = 1, maxLevel = 0.5|
	Limiter.ar(in.zap.tanh * drive.lag(Ndef(\lag)), maxLevel.lag(Ndef(\lag)), 0.002);
}, 1, (
	// specs go here:
	drive: [ 0, 10, 4.4],
	maxLevel: [0.1, 1.0, \exp, 0.001, 0.6],
)
)
);

/*
ProxyChain.all.do(_.clear);

ProxyChain(\pmc1).proxy.addSpec(\micBus, [0, 15, \lin, 1])
*/
// instancing

NTSS.pcSlots = NTSS.pcSlots ? [\top, \ins, \sndfile, \freqMod, \ampMod, \tilta, \gapz, \reverb, \limiter ];

// make the pchains
NTSS.pchains.do(_.free);

NTSS.pchains = NTSS.pcNames.collect { |name, i|
	Ndef(name).ar(2);
	Ndef(name).vol_(0.25);
	ProxyChain.from(Ndef(name), NTSS.pcSlots).set(\micBus, i);
};

// backwards compat, just in case
q.pchains = NTSS.pchains;

NTSS.pchainIndices = NTSS.pchains.collect(_.proxy).collect(_.index);

Spec.add(\srcBus, [ NTSS.pchainIndices.minItem, NTSS.pchainIndices.maxItem] ++ [\lin, 1]);


// make the buffer and panner for each pch:
(
NTSS.pchains.do { |pc, i|
	var mybuf, panNdefName, panner;
	panNdefName = NTSS.pannerNames[i];
	panner = Ndef(panNdefName);
	panner.ar(NTSS.speakers.size);
	panner.fadeTime = 3;
	panner.vol = 0.25;
	panner.set(\srcBus, pc.proxy.index);
	pc.addHalo(\panner, panner);
	// pc.getHalo(\mybuf).postln;
	if (pc.getHalo(\mybuf).isNil) {
		mybuf = Buffer.sendCollection(s, 0!16, 1);
		pc.addHalo(\mybuf, mybuf);
		pc.set(\bufnum, pc.getHalo(\mybuf).bufnum);
	};

	pc.addHalo(\backCol, Color.hsv(i / NTSS.numPmcs, 0.7, 0.8))
};
);

// put them in ndef groups
// a dict for all ndef info
q.ndef = q.ndef ? ();
// make several groups
q.ndef.groups = q.ndef.groups ? ();
q.ndef.groups.put(\ntssChan, NTSS.pchains.collect(_.proxy));
q.ndef.groups.put(\ntssPan, NTSS.pchains.collect(_.getHalo(\panner)));
q.ndef.groupNames = q.ndef.groupNames ? [\ntssChan, \ntssPan];
q.ndef.groupNames.postcs;

MFdef(\setSndfile).add(\setFile, { |pc, pathOrSF|
	var sfname;
	if(pathOrSF.isKindOf(String)) {
		pathOrSF = SoundFile.collect(pathOrSF).first
	};
	if(pathOrSF.isKindOf(SoundFile).not) {
		"*** % is not a soundfile!\n".postf(pathOrSF);
		nil
	} { // we have a soundfile
		sfname = pathOrSF.path.basename.splitext[0].asSymbol;
		"OK! loading %\n".postf(sfname);
		pc.getHalo(\mybuf).allocReadChannel(pathOrSF.path, channels: [0]);
		pc.addHalo(\sfname, sfname);
		pc.addHalo(\sfpath, pathOrSF);
		pathOrSF;
	};
});

/*
// q.bio.soundfiles are in biophony
MFdef(\setSndfile).(NTSS.pchains[0], q.bio.sndfiles.choose.path);
*/

MFdef(\setSrc).add(\setSrc, { |pc, drag|
	// drag should be a nodeproxy, or a string of a NodeProxy
	var proxy, name;
	if (drag.isKindOf(String)) { drag = try { drag.interpret } };
	if (drag.isKindOf(ProxyChain)) { proxy = drag.proxy };

	if (drag.isKindOf(NodeProxy)) {
		proxy = drag;
		if (proxy.rate != \audio) {
			"*** % is not an ar proxy!\n".postf(proxy);
			nil
		}{
			pc.addHalo(\src, proxy);
			pc.postln;
			pc.set(\proxyBus, proxy.index);
			proxy.wakeUp;
		}
	} {
		"*** % : drag % is not a valid source!\n".postf(pc, drag.cs);
		"Must be an Ndef or ProxyChain!".postln;
		nil;
	}
});

/*
MFdef(\setSrc).(NTSS.pchains[0]);
MFdef(\setSrc).(NTSS.pchains[0], \x);
MFdef(\setSrc).(NTSS.pchains[0], Ndef(\x));
MFdef(\setSrc).(NTSS.pchains[0], Ndef(\x, { Dust2.ar(30, 0.3) }));
*/

MFdef(\setSlots).add(\setSlots, { |pc, slotsToSet|
	var slotsToAdd, slotsToRemove;
	var currActive = pc.activeSlotNames.copy;
	" setSlots: - slotsToSet: %\n".postf(slotsToSet);
	slotsToAdd = slotsToSet.copy.removeAll(currActive);
	slotsToRemove = currActive.removeAll(slotsToSet);
	" slotsToAdd: %\n".postf(slotsToSet);
	slotsToAdd.do { |name| pc.add(name.postcs) };
	" slotsToRemove: %\n".postf(slotsToRemove);
	slotsToRemove.do { |name| pc.remove(name.postcs) };
});

/*
NTSS.pchains[0].add(\top)
MFdef(\setSlots).(NTSS.pchains[0], [\top]);
MFdef(\setSlots).(NTSS.pchains[0], [\ins, \sndfile]);
*/



// function to switch pan modes:
MFdef(\setPanner).add(\choose, { |pc, panNameOrIndex = 0|

	var panner = pc.getHalo(\panner);
	var newPanName, panIndex, newPanSource;
	if (panNameOrIndex.isKindOf(Number)) {
		newPanName = NTSS.panNames[panNameOrIndex];
		panIndex = panNameOrIndex;
	} {
		newPanName = panNameOrIndex;
		panIndex = NTSS.panNames.indexOf(newPanName);
	};

	newPanSource = ProxyChain.allSources[newPanName];

	if (newPanSource.isNil) {
		"no pan source called %!\n".format(newPanName).warn;
		nil;
	} {
		panner.source = newPanSource;
		pc.addHalo(\panName, newPanName);
		if (panner.monitor.isPlaying.not) {
			panner.play
		};
		defer ({  panner.cleanNodeMap }, panner.fadeTime + 0.1);

		MFdef(\panButs).(pc, panIndex);
		"setPanner: % -> %\n".postf(pc, newPanName);
		newPanName;
	};
});
/*
MFdef(\setPanner).(ProxyChain(\ch01ada), 7.rand.postln);
MFdef(\setPanner).(ProxyChain(\ch01ada), NTSS.panNames.choose.postln);

MFdef(\setPanner).(NTSS.pchains[0], 7);
*/

MFdef(\randPanPars).add(\rand, { |pc, rand = 0.01|
	var panner = pc.getHalo.panner;
	var controlKeys = panner.controlKeys.drop(1);
	var values = panner.getUnis(*controlKeys);
	var newValues = values.collect { |val| val + rand.rand2 };
	panner.setUni(*[controlKeys, newValues].flop.flat);
});

/*
MFdef(\randPanPars).(NTSS.pchains[4], 0.1);
*/

// initialize inputs
NTSS.pchains.do { |pc, i|

	pc.add(\top, 0);
	pc.add(\limiter, 1);
	pc.add(\ins, 1);
	pc.add(\sndfile, 1);

	pc.set(\bufnum, pc.getHalo(\mybuf).bufnum);

	// random FX on init?
	// if (0.5.coin) { pc.add(\freqMod, 1) };
	// if (0.5.coin) { pc.add(\ampMod, 1) };
	// if (0.5.coin) { pc.add(\hiPass, 1) };
	// if (0.5.coin) { pc.add(\gapz, 1) };
};
