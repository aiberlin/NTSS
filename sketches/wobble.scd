// shared params:
Spec.add(\wobFreq, [0.0, 11, \amp]);
Spec.add(\ampWob, [0.003, 1, \amp]);
Spec.add(\delayWob, [0.0, 11, \amp]);

ProxyChain.add3(\wobble, { |srcBus = 0,
	wobFreq = 0.1, ampWob = 0.5, delayWob = 0.5|

	var numCh = NTSS.ringsFlat.size;
	var in = InFeedback.ar(srcBus);
	var ampLFOs = LFDNoise3.kr(wobFreq.lag(1)!numCh,
		0.5, ampWob.lag(1)).squared;
	var delayLFOs = LFDNoise3.kr(wobFreq.lag(1)!numCh)
	.exprange(0.001, delayWob.lag(1));

	DelayC.ar(in, 11, delayLFOs, ampLFOs);
});

q.panNames = q.panNames.add(\wobble);
q.panNames.lastIndex
MFdef(\setPanner).(q.pchains[0], 10);

Ndef(\x, { LFPulse.kr(1, 0, 0.1) * SinOsc.ar });