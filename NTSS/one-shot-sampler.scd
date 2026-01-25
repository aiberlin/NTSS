// biophony : play sombat files also on Biophonium

// one-shot-sampler for playing the short SomBat sounds on the computer/PA

/*
how to play:

- number keys 1 to 4 determine CIRCLE
- +/- keys skip sample group;
- {/} changes amplitude
- all other keys trigger one sample
- Mouse vertical axis determines pitch at start
- Mouse horix axis determines rotation speed within the given circle


*/
if (Quarks.installed.collect(_.name).includesEqual("KeyPlayer").not) {
	Quarks.install("KeyPlayer");
};


(
q=q?();
q.oneshot = ();

q.oneshot.paths1 =
"~/Seafile/BiophonySetup/soundsMono/SomBat_sounds/short/*"
.pathMatch;

// q.oneshot.paths1 = "/Users/laVulega/Music/SuperCollider Recordings/*".pathMatch;

q.oneshot.paths = (q.oneshot.paths1);

q.oneshot.paths = q.oneshot.paths.select{|p| SoundFile.openRead(p).notNil };

q.oneshot.paths = q.oneshot.paths.scramble.keep(50);
"! % samples ready to load for oneShot \n".postf( q.oneshot.paths.size);

// free olde ones
try{ q.oneshot.bufs.do{|b| try {b.free}}};

q.oneshot.bufs = q.oneshot.paths.collect{|p| Buffer.readChannel(s, p, channels: [0]) };

// q.oneshot.bufs.choose.play(mul: [1,1]);

);

Butz.add(\KeyPlayer, { WinBounds.showOrMake(\KeyPlayer) });
WinBounds.addMake(\KeyPlayer, {
	var kpgui = KeyPlayerGui(k);
	var window = kpgui.parent.name_(\KeyPlayer);
	NdefGui(Ndef(\oneShot), 6, window);
	window.bounds_(window.bounds.postln.height_(window.bounds.height + 150));
	window
});

//#######################################
/*"
HFPMO
HaHo
NeverRunAChangingSystem";
*/
///////////////////////////////////////////////////////////////
//  KeyPlayer Sample Playing a'la live14 / Toni16   ///////////
///////////////////////////////////////////////////////////////
/*
release slow with R
release fast with F
Loop wit L
*/


// var k;
q = q ? ();
q.keypl = q.keypl ? ();
// q.keypl.keyPlayerGui = q.keypl.keyPlayerGui ?? { KeyPlayerGui() }; //(options: [\useList]);

k = KeyPlayer(\bufs);
// KeyPlayer(\loop).gui;
// KeyPlayer(\loop).makeLoop;
k.makeLoop;




Ndef(\oneShot, {Silent.ar( 20 )}).play(vol: 1);
/*Ndef(\oneShot)[5] = \filter -> {
arg in, gain=0.8, lag=10;
Limiter.ar(in * gain.lag(lag))
};*/

Ndef(\oneShot)[5] = \filter -> {
	arg in, gain=0.8, balance = 0.4, xOver=800, lag=6;
	var lo = LPF.ar(in, xOver);
	var hi = in - lo;
	Limiter.ar( lo.madd(1-balance.lag(lag)) + hi.madd(balance.lag(lag)) *2* gain)
};


(
/*
//// big DJ tilt filter that
//// goes from closing LPF to HPF
Ndef(\oneShot)[10] = \filter -> { |in,
	tilt = 0,
	// curve = 1, reso = 5,
	flWidth = 0.5, flRate = 3, flRateMod = 0.5|
	var lag = Ndef(\lag).kr[0];
	var curve = 1;

	var in2 = in;// + (PinkNoise.ar * 0.5);

	var envel = Amplitude.kr(in, 0.01, 0.85);
	var envmod = (24 * envel * flRateMod.lag(lag)).midiratio; // +-2 octaves max
	var modOsc = SinOsc.ar(flRate.lag(lag) * envmod);
	var freqmod = (modOsc * flWidth.lag(lag) * 0.5);

	var freqctl = (tilt + freqmod ** curve);
	var lpfreq = freqctl.linexp(-1, 0, 100, 20000);
	var hpfreq = freqctl.linexp(0, 1, 20, 4000);

	RHPF.ar(RLPF.ar(in2, lpfreq, 0.7), hpfreq, 0.7);
};*/

Ndef(\oneShot).addSpec(\tilt, \pan);
Ndef(\oneShot).addSpec(\curve, \pan);
Ndef(\oneShot).addSpec(\reso, [1, 11]);
Ndef(\oneShot).addSpec(\flWidth, [-1, 1]);
Ndef(\oneShot).addSpec(\flRate, [0.1, 50, \exp]);
Ndef(\oneShot).addSpec(\flRateMod, [-1, 1]);
);

Ndef(\oneShot).addSpec(\lag, [0.5, 210, \exp, 0.5]);
Ndef(\oneShot).addSpec('wet5', [0, 1]);
Ndef(\oneShot).addSpec('wet10', [0, 1]);
Ndef(\oneShot).addSpec(\balance, [0, 1]);
Ndef(\oneShot).addSpec(\gain, [0, 4, \amp]);
Ndef(\oneShot).addSpec(\gainHi, [0, 4, \amp]);
Ndef(\oneShot).addSpec(\gainLo, [0, 4, \amp]);
Ndef(\oneShot).addSpec(\xOver, [30, 13000, \exp, 10]);
Ndef(\oneShot).fadeTime=4;
// Ndef(\oneShot).edit;

q.keypl.eventHistory = List[];

q.keypl.bufEvent = (amp: 0.25, bufOffs: 0, loopsy: 0); // global event for anything in this player system;
(



q.keypl.kStrings = q.keypl.kStrings ?
[
	"1234567890-=",
	"qwertyuiop[]",
	"asdfghjkl;'\\",
	"`zxcvbnm,./"
];

q.keypl.upperStrings = [
	"!@#$%^&*()_+",
	"QWERTYUIOP",
	"ASDFGHJKL:\"|",
	"~ZXCVBNM<>?"
];

q.keypl.upperStrings .do{|word, y|
	var outBus = y * 5;
	word.do{|char, x|
		// per y different circle
		// per x different buffer index
		KeyPlayer(\bufs).put(char, {
			var event, playEvent;

			var bufIndex = x + q.keypl.bufEvent.bufOffs;
			var buf = q.oneshot.bufs @@ bufIndex;

			"%, %, % sec\n".postf(
				char, buf.path.split($/).last.split($.).first,
				buf.duration.round(0.1)
			);
		}
		)
	}
};

q.keypl.kStrings .do{|word, y|
	var outBus = y * 5;
	word.do{|char, x|
		// per y different circle
		// per x different buffer index
		KeyPlayer(\bufs).put(char, {
			var event, playEvent;

			var instr = "wheel5";
			var numPanChans = 5;
			var bufIndex = x + q.keypl.bufEvent.bufOffs;
			var buf = q.oneshot.bufs @@ bufIndex;
			var out =  Ndef(\oneShot).index + outBus;
			var group = Ndef(\oneShot).group;

			Ndef(\oneShot).play;

			"%, %, % sec\n".postf(
				char, buf.path.split($/).last.split($.).first,
				buf.duration.round(0.1)
			);

			// cat.postln;
			event = q.keypl.bufEvent.copy.putAll(
				(	instrument: instr,
					buf: buf.bufnum,
					numPanChans: numPanChans,
					offs: x + 1.0.rand,
					out: out,
					group: group,
					addAction: \addToHead,
					sustain: 9999
				)
			)
			.put(\amp, q.keypl.bufEvent.amp * exprand(0.5,1));

			playEvent = event.play;
			q.keypl.eventHistory.add(playEvent);
		}
		)
	}
};

);

/*
q.keyStringMap = ();
q.stringKeyMap = ();

q.mapKeysToStrings = {
q.keyStringMap.clear;
q.stringKeyMap.clear;
q.keypl.kStrings.do{|word, y|
word.do{|char, x|
var bufIndex = x + q.keypl.bufEvent.bufOffs;
var cat = q.caz[y];
var bufGroup =  q.mySort[q.currMovement][cat];
// var bufGroup = q.bufs[ q.currMovement ][cat];
var bufname = bufGroup.wrapAt(bufIndex);
var buf = q.bufMap [ bufname.asSymbol ];
q.keyStringMap.put(char, bufname);
q.stringKeyMap.put(bufname.asSymbol, char);
}
}
};
q.mapKeysToStrings.value;
*/

(

k.put($F, { Ndef(\oneShot).group.set(\fadeTime, 1, \gate, 0); q.keypl.eventHistory.clear; "fast freeing all!".postln; });
k.put($R, { Ndef(\oneShot).group.set(\fadeTime, 6, \gate, 0); q.keypl.eventHistory.clear; "slow freeing all!".postln; }); // gentle fade out..


k.put ( $U, { q.keypl.eventHistory.pop.release(2); "\n UNDO! % remaining in List\n".postf(q.keypl.eventHistory.size) });

k.put ( $Y, { q.keypl.eventHistory.removeAt(0).release(2); "\n OLDEST Go! % remaining in List\n".postf(q.keypl.eventHistory.size) });

k.put ( ${, { q.keypl.bufEvent.amp = (q.keypl.bufEvent.amp / 1.3).max(0.001).round(0.001); "\n nu amp == %\n".postf(q.keypl.bufEvent.amp) });

k.put ( $}, { q.keypl.bufEvent.amp = (q.keypl.bufEvent.amp * 1.35).min(4).round(0.001); "\n nu amp == %\n".postf(q.keypl.bufEvent.amp)});

// dec
k.put ( $_, { q.keypl.bufEvent.bufOffs = (q.keypl.bufEvent.bufOffs - 5); "\n nu bufOffset == %\n".postf(q.keypl.bufEvent.bufOffs); q.mapKeysToStrings.value; });

k.put ( $-, { q.keypl.bufEvent.bufOffs = (q.keypl.bufEvent.bufOffs - 5); "\n nu bufOffset == %\n".postf(q.keypl.bufEvent.bufOffs); q.mapKeysToStrings.value;  });
// inc
k.put ( $+, { q.keypl.bufEvent.bufOffs = (q.keypl.bufEvent.bufOffs + 5); "\n nu bufOffset == %\n".postf(q.keypl.bufEvent.bufOffs); q.mapKeysToStrings.value; });

k.put ( $=, { q.keypl.bufEvent.bufOffs = (q.keypl.bufEvent.bufOffs + 5); "\n nu bufOffset == %\n".postf(q.keypl.bufEvent.bufOffs); q.mapKeysToStrings.value;  });


//=== from live 14
k.put ( $L, {
	q.keypl.bufEvent.loopsy = q.keypl.bufEvent.loopsy + 1%2;
	Ndef(\oneShot).group.set(\loopsy, q.keypl.bufEvent.loopsy);
	"bufEvent.loop == %\n".postf(q.keypl.bufEvent.loopsy);

});
);

/*
k.put ( $,, { k.rec.toggleRec; });
k.put ( $., { k.rec.togglePlay; });
k.put ( $/, { k.rec.toggleLooped; "loop toggl: ".post; k.rec.looped.postln});

// ? // quant
k.put ( $?, { k.rec.quantize; "quantize".postcln});
// > // unquant
k.put ( $>, { k.rec.unquantize; "UNquantize".postcln});

k.putUni ( 63234, { k.rec.tempo_(k.rec.tempo / 2.pow(1/8)); postf("speed down to %\n", k.rec.tempo.round(0.01))});
k.putUni ( 63235, { k.rec.tempo_(k.rec.tempo * 2.pow(1/8)); postf("speed up to %\n", k.rec.tempo.round(0.01))});

k.rec.ignore($,, $., $/);
*/


(
// thisThread.randSeed = Date.getDate.year; // so scrambling stays persistent
SynthDef("wheel5", { arg buf=0, amp=0.1, out=0, rateDev=1.5, width=2.2, offs=0, numPanChans=5, loopsy=0, start=0;

	var numChans = 5; // hardcoded 5 chans here
	var speed, rate, sig;
	var modAmp = numPanChans / numChans;
	rate = Latch.kr(MouseY.kr(rateDev.reciprocal, rateDev, 1), Impulse.kr(0))
	* (MouseX.kr > 0.9).madd(-2, 1); // blays backwards if Mous all the way on the right

	speed = Line.kr( // decelerating Speed
		(MouseX.kr(0.3, 15.01, 1) * ExpRand(0.5, 2)),
		0.0123,
		(BufDur.ir(buf)/rate).max(10)
	);

	speed =  Latch.kr(
		MouseX.kr(0, 1).pow(4).madd(12, 0.01)
		* ExpRand(0.5, 1),
		Impulse.kr(0)
	);

	sig = PlayBuf.ar(
		1, buf,
		rate
		* BufRateScale.ir(buf), 1, start * BufDur.ir(buf),
		loopsy,
		doneAction: 2
	);

	sig = PanAz.ar(
		numChans,
		sig,
		SinOsc.ar(speed, Rand(0.0, 2pi), modAmp)
		+ (offs / numChans * 2),
		amp,
		width, 0
	);
	// sig = sig.scramble; // rendered scramble. Verschlungene Pfade.
	Out.ar(out,
		Limiter.ar(
			sig
			* EnvGate.new() // provides fadetime and gate for external release !-)
		)
	)
}).add;
);



"Oneshot Buf Key Player";





