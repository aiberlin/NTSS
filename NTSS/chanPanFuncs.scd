
"/// NTSS distance-based spat mono Panners: //////".postln;

NTSS.spat = NTSS.spat ? ();

/** distance based amplitude panning:
k - small is very focused, big is wide
x, y are positions of left and right channels

**/
NTSS.getSpat = { arg ntss, name;
	{ arg srcBus;
		var in = InFeedback.ar(srcBus);
		NTSS.spat[name].(name, NTSS.spk.positions, in);
	};
};

// subs should not be in speakers I guess?
NTSS.spat.dbap = { arg name, speakers, snd;
	var d, g, norm, srcPos;
	var x = \srcX.kr(0, spec:[-1,1]);
	var y = \srcY.kr(0, spec:[-1,1]).neg;
	// because srcWidth is 0-1 generally, use that spec and rescale
	var k = \srcWidth.kr(1).linlin(0, 1, 10, 1);
	var sig;
	srcPos = [x,y];
	sig = snd;
	// distances
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
};



/** distance based delay & amplitude panning:
k - small is very focused, big is wide
x, y are positions of left and right channels
z - is what?
spread is similar to k
**/

// was dlypan


NTSS.spat.delayspat = { arg name, speakers, snd;
	var x = \srcX.kr(0, spec:[-1,1]);
	var y = \srcY.kr(0, spec:[-1,1]).neg;
	var z = \spkScale.kr(1, spec:[1,30]);
	var k = \xyScale.kr(1, spec:[1,10]);
	var spread = \spread.kr(1, spec:[1,10]);

	var dists, g, norm;

	var scale = k * z;
	x = x * scale; y = y * scale;

	dists = speakers.collect { |pt|
		pt = Point(*(pt)*z);
		(pt.x - x).hypot(pt.y - y)
	};

	dists = dists.lag(0.3);
	g = 1/(dists.pow(spread) + 1e-6);
	norm = (g.squared.sum).sqrt;
	g = g / norm;
	DelayC.ar(snd*g, 1, dists / 344, 1/(1+dists).sqrt);
};



// for each source channel, on/off for each speaker
NTSS.spat.direct = { arg name, speakers, snd;
	var nchannels = speakers.size;
	var output = \outChan.kr(0, spec:[0,nchannels-1, 0, 1]);
	(0..nchannels-1).collect {|idx|
		snd * Select.kr(BinaryOpUGen('==', output, idx), [Silent.ar, DC.ar(1)]);
	};
};

// for each source channel, set level for each speaker
NTSS.spat.mixer = { arg name, speakers, snd;
	var nchannels = speakers.size;
	var outs = NTSS.spk.names.collect {|name|
		name.kr(0, spec: [0,4, \amp])
	};
	snd * outs;
};

/*** multitap comb filters on each speaker
- details to follow
***/

NTSS.spat.taps = { arg name, speakers, snd;
	var nspeakers = speakers.size;
	var dryKr = \dry.kr(1, 1, spec:\amp);
	var sendKr = \send.kr(1, 1, spec:\amp);
	var lag = \lag.kr(1, spec:[0.5,3]);
	var taps = NTSS.spk.names.collect {|name|
		name.kr(0, spec:[0,4, \amp]).lag(lag)
	};
	//(snd*\dry.kr(1, spec:\amp)) + CombC.ar(snd * \send.kr(0, spec:\amp), 4, taps, 6);
	(snd*dryKr) + CombC.ar(snd * sendKr, 4, taps, 0);
};

/*** multitap comb filters on each speaker, with feedback
- details to follow
***/
NTSS.spat.tapsfb = { arg name, speakers, snd;
	var nspeakers = speakers.size;
	var dryKr = \dry.kr(1, 1, spec:\amp);
	var sendKr = \send.kr(1, 1, spec:\amp);
	var fbKr = \fb.kr(0, spec:\amp);
	var lag = \lag.kr(1, spec:[0.5,3]);
	var in = snd + (BrownNoise.ar * 80.neg.dbamp);
	var fb = LocalIn.ar(nspeakers);
	var taps = NTSS.spk.names.collect {|name|
		name.kr(0, spec: [0,4, \amp]).lag(lag)
	};
	var delayline = DelayC.ar(in * sendKr + fb, 4, taps);

	delayline = PitchShift.ar(delayline, 0.2, {rrand(1.01,0.99)}!nspeakers);
	LocalOut.ar(Limiter.ar(delayline * fbKr, 0.9));
	// safety, find out where in tapsfb bad numbers come from
	Limiter.ar(((in * dryKr) + delayline)).zap;
};


NTSS.spat.peatSoup = { arg name, speakers, snd;
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
 var panned = PanAz.ar(NTSS.spk.names.size, lim, pan, 1, width); //NTSS.ringsFlat.size
 panned;
 //NTSS.reorderRingsToSpeakers(panned);
 //PanAz.ar(NTSS.speakers.size, lim, pan, 1, width);
};

NTSS.spat.keys.do {|spatName|
	ProxyChain.add3(spatName, NTSS.getSpat(spatName));
};

ProxyChain.sourceDicts[\dbap].put(\text,
	"DBAP is Distance Based Amplitude Panning:
srcX:      source position on x-axis
srcY:      source position on y-axis
srcWidth:  small is very focused, big is wide field of speakers, 0 to 1."
);

ProxyChain.sourceDicts[\delayspat].put(\text,
	"delayspat is Distance-Based delay & amp Panning:
srcX:      source position on x-axis
srcY:      source position on y-axis
srcWidth:  small is very focused, big is wide field of speakers, 0 to 1.
spkScale:  scale size of speaker distances
xyScale:   scale size of xy position movement
"
);

ProxyChain.sourceDicts[\direct].put(\text,
	"direct plays to only one speaker at a time:
outChan:   which speakers to play to."
);

ProxyChain.sourceDicts[\mixer].put(\text,
	"mixer allows setting level for each speaker by name:
" ++ NTSS.spk.names.cs
);

ProxyChain.sourceDicts[\taps].put(\text,
	"taps allows setting individual delays for each speaker by name.
dry:   level of dry signal in all speakers
send:  level of delayed signal in all speakers
bw5..sub1: delay time in seconds for each speaker.
"
);

ProxyChain.sourceDicts[\tapsfb].put(\text,
	"taps allows setting individual delays for each speaker by name,
and adds global feedback on the delayed signals.
dry:   level of dry signal in all speakers
send:  level of delayed signal in all speakers
fb:    level of feedback in delayed signals
bw5..sub1: delay time in seconds for each speaker.
"
);

ProxyChain.sourceDicts[\peatSoup].put(\text,
 "peatSoup is a NTSS version of Nic Collins' Pea Soup, where the negative feedback mechanism happens through rotating the playback position:
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

NTSS.addPanNames(NTSS.spat.keys(Array).sort);
