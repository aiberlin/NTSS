/*
This is Biophony-specific, not sure if adaptable to NTSS
NTSS could have rings or other meaningful groups
that are not concentric, but e.g. zones.
*/

MKtl.all[\LevelControl].free;

MKtl(\LevelControl, "*beatstep-rel*");

Butz.add(\LevelControl, { WinBounds.showOrMake(\LevelControl) });
WinBounds.addMake(\LevelControl, { MKtl(\LevelControl).gui.showLabels(true).parent });

// smaller devicespec range, makes gui less sensitive
MKtl(\LevelControl).desc.fullDesc.specs['midiCCrel_64_22'].minval_(54).maxval_(74);

// stop button
MKtl(\LevelControl).elAt(0, \play, \on).action = { s.volume_(-60) };

Spec.add(\volspec, [s.volume.min, s.volume.max, -3]);

// main volume
MKtl(\LevelControl).elAt(0, \bigKnob).deviceValue_(64)
.elemDesc.label = "MainVol";

MKtl(\LevelControl).elAt(0, \bigKnob).action = { |kn|
	var delta = (kn.deviceValue - 64).sign;
	var step = (delta * delta.abs.sqrt * 0.01);
	var volspec = \volspec.asSpec;
	var currvol = volspec.unmap(s.volume.volume);
	var newvol = volspec.map((currvol + step).clip(0, 1));
	("MainVol:" + newvol.round(0.01)).postln;
	s.volume.volume = newvol;
	defer { kn.deviceValue_(64) };
};

// main out subgroup levels
MKtl(\LevelControl).elAt(0, \kn, (0..4)).do({ |kn, i|
	var ctlName = [\inside, \shakers, \outside, \bigPA, \strings].at(i);
	kn.elemDesc.label = ctlName;
	kn.deviceValue_(64);
	kn.action = {
		var delta = (kn.deviceValue - 64);
		var step = delta * delta.abs.sqrt * 0.002;
		var mainPx = MainFX(s).proxy;
		var currval = mainPx.getUni(ctlName);
		"vol % to %\n".postf(ctlName, currval + step);
		mainPx.setUni(ctlName, currval + step);
		defer { kn.deviceValue_(64) };
	}
});

//
MKtl(\LevelControl).elAt(0, \pad, nil, \on).keep(8).do { |pad, i|
	pad.action = { |pad|
		if (pad.isOn) {
			"play ".post;
			NTSS.pchains[i].getHalo.panner.postln.play;
		}
	}
};
MKtl(\LevelControl).elAt(0, \pad, nil, \on).drop(8).do { |pad, i|
	pad.action = { |pad|
		if (pad.isOn) {
			"stop ".post;
			NTSS.pchains[i].getHalo.panner.postln.stop;
		}
	}
};


// chain 1-8 panner levels
MKtl(\LevelControl).elAt(0, \kn, (8..15)).do({ |kn, i|
	kn.elemDesc.label = "chain%".format(i+1);
	kn.deviceValue_(64);
	kn.action = {
		var delta = (kn.deviceValue - 64);
		var step = delta * delta.abs.sqrt * 0.002;
		var proxychain = NTSS.pchains[i];
		var panner = proxychain.getHalo.panner;
		var currval = \amp.asSpec.unmap(panner.vol);
		var newval = \amp.asSpec.map(currval + step);

		"vol % to %\n".postf(panner.key, newval);
		panner.vol_(newval);
		defer { kn.deviceValue_(64) };
	}
});
