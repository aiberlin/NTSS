
MKtl(\nanoNTSS, NTSS.nanoID ? "*trol2");

MKtl(\nanoNTSS).elAt(\kn, 7).elemDesc.label = "mainVol";
MKtl(\nanoNTSS).elAt(\kn, 7).action = { |sl|
	("mainvol: " + sl.value.squared.round(0.001)).postln;
	MainFX(s).proxy.softSet(\mainvol, sl.value.squared);
};

MKtl(\nanoNTSS).elAt(\kn, 6).elemDesc.label = "mix2Sub";
MKtl(\nanoNTSS).elAt(\kn, 6).action = { |sl|
	("mix2Sub: " + sl.value.squared.round(0.001)).postln;
	MainFX(s).proxy.softSet(\mix2Sub, sl.value.squared);
};

MKtl(\nanoNTSS).elAt(\kn, 6).action = { |sl|
	("mix2Sub: " + sl.value.squared.round(0.001)).postln;
	MainFX(s).proxy.softSet(\mix2Sub, sl.value.squared);
};

MKtl(\nanoNTSS).elAt(\sl).do { |sl, i|
	sl.elemDesc.label = "vol" + (i+1);
	sl.action = {
		var pchain = NTSS.pchains[i];
		var panner = pchain.getHalo.panner;
		var newvol = sl.value.squared;
		("vol:" + panner.key + newvol.ampdb.round(0.1)).postln;
		panner.softVol_(sl.value.squared);
	}
};

MKtl(\nanoNTSS).elAt(\bt, \M).do { |bt, i|
	bt.elemDesc.label = "stop" + (i+1);
	bt.action = { |bt|
		var pchain = NTSS.pchains[i];
		var panner = pchain.getHalo.panner;
		if (bt.isOn) {
			panner.end;
			pchain.proxy.end;
		}
	}
};

MKtl(\nanoNTSS).elAt(\bt, \R).do { |bt, i|
	bt.elemDesc.label = "play" + (i+1);
	bt.action = { |bt|
		var pchain = NTSS.pchains[i];
		var panner = pchain.getHalo.panner;
		if (bt.isOn) {
			panner.play;
			pchain.proxy.send;
			if (pchain.getHalo.src.notNil) {
				pchain.getHalo.src.send;
			};
		}
	}
};


MKtl(\nanoNTSS).elAt(\bt, \S).do { |bt, i|
	bt.elemDesc.label = "gui" + (i+1);
	bt.action = { |bt|
		defer {
			var pchain = NTSS.pchains[i];
			if (bt.isOn) { Butz(\NTSS).run(pchain.key) }
		}
	}
};

MKtl(\nanoNTSS).elAt(\tr, \mset).elemDesc.label = "spat";
MKtl(\nanoNTSS).elAt(\tr, \mset).action = { |bt|
	defer { WinBounds.showOrMake(\SpatioScope).front }
};

MKtl(\nanoNTSS).elAt(\tr, \mleft).elemDesc.label = "srcs";
MKtl(\nanoNTSS).elAt(\tr, \mleft).action = { |bt|
	defer { WinBounds.showOrMake(\allSrcNdefs).front }
};

MKtl(\nanoNTSS).elAt(\tr, \mright).elemDesc.label = "mnFX";
MKtl(\nanoNTSS).elAt(\tr, \mright).action = { |bt|
	defer { WinBounds.showOrMake(\MainFX).front }
};

WinBounds.addMake(\nanoNTSS, {
	MKtl(\nanoNTSS).gui.showLabels.parent
});

Butz(\NTSS).actions.addAfter(\nanoNTSS, {WinBounds.showOrMake(\nanoNTSS) }, \allSrcNdefs); "";

defer ({ MKtl(\nanoNTSS).postln.gui.showLabels }, 1);
