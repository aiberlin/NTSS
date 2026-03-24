"// NTSS distance-based spat stereo Panners loading //".postln;

NTSS.spat2 = NTSS.spat2 ? ();

/** distance based amplitude panning:
k - small is very focused, big is wide
x, y are positions of left and right channels

**/
NTSS.getSpat2 = { arg ntss, name;
	{ arg srcBus;
		/// input is a stereo bus here:
		var in = InFeedback.ar(srcBus, 2);
		NTSS.spat2[name].(name, NTSS.spk.positions, in);
	};
};


NTSS.spat2.dbap2 = { arg name, speakers, snd;
	var d, g, norm, srcPosL, srcPosR;
	var x = \srcX.kr(0, spec:[-1,1]);
	var y = \srcY.kr(0, spec:[-1,1]).neg;
	var xd = \srcXD.kr(0, spec:[-1,1]);
	var yd = \srcYD.kr(0, spec:[-1,1]).neg;
	// because srcWidth is 0-1 generally, use that spec and rescale
	var k = \srcWidth.kr(1).linlin(0, 1, 10, 1);

	var sig = snd; // stereo

	srcPosL = [x-xd, y-yd];
	srcPosR = [x+xd,y+yd];

	// snd is 2 chans, so collect over the two channels
	// distances
	snd.collect { |chan, i|
		var srcPos = [srcPosL, srcPosR][i];
		d = speakers.collect { |p|
			var val = (srcPos - p);
			val[0].hypot(val[1])
		};
		// amps decrease with dist, k is high is narrower focus
		g = 1/(d.pow(k) + 1e-6);
		// normalize by power
		norm = (g.squared.sum).sqrt;
		g = g / norm;
		sig * g;
	}.sum;

};



/** distance based delay & amplitude panning:
k - small is very focused, big is wide
x, y are positions of left and right channels
z - is what?
spread is similar to k
**/
// was dlypan

/// not started yet with stereo mode:
NTSS.spat2.delayspat2 = { arg name, speakers, snd;
	var x = \srcX.kr(0, spec:[-1,1]);
	var y = \srcY.kr(0, spec:[-1,1]).neg;
	var xd = \srcXD.kr(0, spec:[-1,1]);
	var yd = \srcYD.kr(0, spec:[-1,1]).neg;
	var z = \spkScale.kr(1, spec:[1,30]);
	var k = \xyScale.kr(1, spec:[1,10]);
	var spread = \spread.kr(1, spec:[1,10]);

	var dists, g, norm;
	var scale = k * z;

	// x is center, xd is deviation from center
	var lx = x - xd * scale, ly = y - yd * scale;
	var rx = x + xd * scale, ry = y + yd * scale;


	dists = speakers.collect { |pt|
		pt = Point(*(pt)*z);
		[ (pt.x - lx).hypot(pt.y - ly),
			(pt.x - rx).hypot(pt.y - ry)
		];
	};

	dists = dists.lag(0.3);
	g = 1/(dists.pow(spread) + 1e-6);
	norm = (g.squared.sum).sqrt;
	g = g / norm;
	DelayC.ar(snd*g, 1, dists / 344, 1/(1+dists).sqrt).flop.sum;
};



// for each source channel, should be on/off for each speaker
NTSS.spat2.direct2 = { arg name, speakers, snd;
	var nchannels = speakers.size;
	var spec = [0,nchannels-1, 0, 1].asSpec;
	var outputL = \outChanL.kr(0, spec: spec);
	var outputR = \outChanR.kr(0, spec: spec);

	(0..nchannels-1).collect {|idx|
		snd * Select.kr(BinaryOpUGen('==', [outputL, outputR], idx), [DC.kr(0), DC.kr(1)]);
	}.flop.sum;
};

// for each source channel, set level for each speaker
NTSS.spat2.mixer2 = { arg name, speakers, snd;
	var nchannels = speakers.size;
	var outsL = NTSS.spk.names.collect {|name|
		(name ++ "_L").asSymbol.kr(0, spec: \amp)
	};
	var outsR = NTSS.spk.names.collect {|name|
		(name ++ "_R").asSymbol.kr(0, spec: \amp)
	};
	(snd * [outsL, outsR]).sum;
};

// removed taps, as it is the same without feedback.

/*** multitap comb filters on each speaker, with feedback
- details to follow ***/
// not made stereo yet
NTSS.spat2.tapsfb2 = { arg name, speakers, snd;
	var nspeakers = speakers.size;
	var dryKr = \dry.kr(1, 1, spec:\amp);
	var sendKr = \send.kr(1, 1, spec:\amp);
	var fbKr = \fb.kr(0, spec:\amp);
	var lag = \lag.kr(1, spec:[0.5,3]);
	// alternates in1 and in2 from one speaker to the next
	var in = snd + (BrownNoise.ar * 80.neg.dbamp);
	var fb = LocalIn.ar(nspeakers);
	var taps = NTSS.spk.names.collect {|name|
		name.kr(0, spec:[0,4,\amp]).lag(lag)
	};
	var delayline = DelayC.ar(in * sendKr + fb, 4, taps);

	delayline.postln;

	delayline = PitchShift.ar(delayline, 0.2, {rrand(1.01,0.99)}!nspeakers);
	LocalOut.ar(Limiter.ar(delayline * fbKr, 0.9));
	// safety, find out where in tapsfb bad numbers come from
	Limiter.ar(((in * dryKr) + delayline)).zap;
};

// hope this works ok for stereo...

NTSS.spat2.peatSoup2 = { arg name, speakers, snd;
 var polarity = 2 * \polarity.kr(0, spec:[0,1,\lin,1]) - 1;
 var sig = snd * \preamp.kr(1, spec:[0,10,\amp]);
 var weightedSound = BLowShelf.ar(MidEQ.ar(sig, 2000, 0.5, 12), 300, 1,  \bass.kr(12, spec:[-6,20,\lin]) * (-1));
 var lpass = BLowPass.ar(sig, 2500);
 var lim = Limiter.ar(lpass, \limiter.kr(-30, spec:[-50,-6,\db]).dbamp);
 var amp = Amplitude.ar(weightedSound, \atk.kr(2, spec:[0,10]), \rls.kr(2, spec:[0,10]));
 var db = amp.ampdb;

	var mid = \midDb.kr(-40, spec:[-60,-20]);
	var maxRot = \maxRotation.kr(1, spec:[0.01, 100, \exp]);
	var width = db.linlin(mid - 20, mid + 20, speakers.size/1, 2);
	var pan = LFSaw.ar(
		(
			(db.linexp(mid, -10, 0.01, maxRot)*polarity.neg) +
		(db.linexp(-80, mid, maxRot, 0.01)*polarity))
	);
	var panned = PanAz.ar(NTSS.spk.numLogicOuts, lim, pan, 1, width); //NTSS.ringsFlat.size
	panned.sum;

 //NTSS.reorderRingsToSpeakers(panned);
 //PanAz.ar(NTSS.speakers.size, lim, pan, 1, width);
};


NTSS.spat2.keys.do {|spatName|
	ProxyChain.add3(spatName, NTSS.getSpat2(spatName));
};

// infos also not updated yet:
ProxyChain.sourceDicts[\dbap2].put(\text,
	"DBAP is Distance Based Amplitude Panning:
srcX:      source center position on x-axis
srcY:      source center position on y-axis
srcXD:     source stereo distance on x-axis
srcY:      source stereo distance on y-axis

srcWidth:  small is very focused, big is wide field of speakers, 0 to 1."
);

ProxyChain.sourceDicts[\delayspat2].put(\text,
	"delayspat is Distance-Based delay & amp Panning:
srcX:      source center position on x-axis
srcY:      source center position on y-axis
srcXD:     source stereo distance on x-axis
srcY:      source stereo distance on y-axis
srcWidth:  small is very focused, big is wide field of speakers, 0 to 1.
spkScale:  scale size of speaker distances
xyScale:   scale size of xy position movement
"
);

ProxyChain.sourceDicts[\direct2].put(\text,
"direct plays each stereo channel to only one speaker at a time:
outChanL:   which speaker the left chan plays to
outChanR:   which speaker the left chan plays to");

// ProxyChain.sourceDicts[\mixer2].put(\text,
// 	"mixer allows setting level for each speaker by name:
// 	" ++ NTSS.speakersActive.cs
// );

ProxyChain.sourceDicts[\tapsfb2].put(\text,
"tapsfb2 allows setting individual delays for each speaker by name,
and adds global feedback on the delayed signals.
dry:   level of dry signal in all speakers
send:  level of delayed signal in all speakers
fb:    level of feedback in delayed signals
spk names: delay time in seconds for each speaker.
"
);

ProxyChain.sourceDicts[\peatSoup2].put(\text,
 "peatSoup2 is a NTSS version of Nic Collins' Pea Soup, where the negative feedback mechanism happens through rotating the playback position:
polarity:  rotation clockwise or counter-clockwise
preamp:    input gain before limiter
limiter:   limiter threshold
bass:      bass boost
atk:       attack time of amplitude follower
rls:       release time of amplitude follower
midDb:     comfortable mid level where feedback position stays still (above and below will rotate)
maxRotation: scaling/amount for rotation mechanism
"
);

NTSS.addPanNames(NTSS.spat2.keys(Array).sort);