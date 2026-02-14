q.topName = q.topName ? \BIOPHONIUM;

[Butz, Butz(\NTSS)].do(_.add(q.topName, { WinBounds.showOrMake(q.topName, true) }));

WinBounds.addMake(q.topName, {

	var f = Font("Monaco", 18);
	var f2 = Font("Monaco", 14);
	var w = Window(q.topName ++ " - Nontrivial Sound System",
		Rect(520, Window.availableBounds.height - 500, 900, 510)
	).front;
	var allViews, leftCol, volSlider;
	w.alpha = 0.8;
	w.addFlowLayout;

	leftCol = CompositeView(w, 60@440);
	leftCol.addFlowLayout;

	StaticText(leftCol, 60@40).string_("Main Vol").font_(f);

	volSlider = EZSlider(leftCol, 60@280, "", \amp, { |sl|
		MainFX(s).proxy.set('mainvol', sl.value);
	}, MainFX(s).proxy.get('mainvol'),
	layout: \vert
	);

	Button(leftCol, 60@60).font_(f2).states_([["Src\nNdefs"]])
	.action_({ WinBounds.showOrMake('allSrcNdefs'); });

	Button(leftCol, 60@30).font_(f)
	.states_([["MORE"], ["LESS"]])
	.action_({
		var bounds = w.bounds;
		var isBig = bounds.height > 700;
		bounds.height = if (isBig, 510, 900);
		w.bounds = bounds;
	});

	allViews = q.pchains.collect { |pch, i|
		var name = pch.key;
		var panna = pch.getHalo.panner;
		var widCol = w.bounds.width - 100 / 8.2, hi = w.bounds.height - 60;
		var wid = widCol - 4;
		var comp = CompositeView(w, widCol@hi).background_(pch.getHalo.backCol);
		var flow = comp.addFlowLayout(0@0, 0@0);
		var label = Button(comp, wid@30).states_([[name]]).font_(f)
		.action = { Butz(\NTSS).run(name) };

		var inPop = EZPopUpMenu(comp, wid@30, nil, q.inNames, { |pop|
			"%: input %, %\n".postf(pch, pop.value, pop.item);
			pch.set(\micBus, pop.value);
		}).font_(f2);

		var proxyDrag = DragBoth(comp, wid@30).font_(f2).object = "<proxy>";

		var sfDrag = DragBoth(comp, wid@30).font_(f2).object = "<sndfile>";

		var moni = MonitorGui(panna, comp, wid@220);

		var playBt = Button(comp, wid@30).states_([
			["PLAY"],["PLAY", Color.black, Color.green]
		]).font_(f)
		.action_({ |bt| panna.play; stopBt.value = 0 });

		var stopBt = Button(comp, wid@30).states_([
			["STOP"],
			["STOP", Color.white, Color.red],
		]).font_(f)
		.action_({ |bt| panna.stop; playBt.value = 0 });

		var panPop = EZPopUpMenu(comp, wid@30, nil, NTSS.panNames, { |pop|
			pop.item.postln;
			MFdef(\setPanner).(pch, pop.item);
		}).font_(f2);

		ProxyMeter.addMonitorGui(moni);

		proxyDrag.receiveDragHandler = { arg v;
			var drag = View.currentDrag.postcs;
			// MFdef setSrc accepts proxy, proxychain, or string
			var ok = MFdef(\setSrc).(pch, drag)[0].notNil;
			if (ok) { MFdef(\updatePchWin).(pch) };
		};
		// triggered when selected and return key pressed
		proxyDrag.action = { |drag|  "proxyDrag action".postln };

		sfDrag.receiveDragHandler = { arg v;
			var path = View.currentDrag.postln;
			if (MFdef(\setSndfile).(pch, path)[0].notNil) {
				v.object = pch.getHalo.sfpath;
				v.string = pch.getHalo.sfname;
			};
			MFdef(\updatePchWin).(pch);
		};

		[inPop, proxyDrag, sfDrag, playBt, stopBt, panPop]
	}.flop;

	SkipJack({
		var currVol = MainFX(s).proxy.get('mainvol');
		// mainVol slider
		if (volSlider.value != currVol) {
			volSlider.value = currVol
		};
		//// inPops:
		allViews[0].do { |pop, i|
			var micBusnum = q.pchains[i].proxy.get(\micBus).asInteger;
			if (pop.value != micBusnum) { pop.value = micBusnum };
		};
		// proxy drag:
		allViews[1].do { |drag, i|
			var pc = q.pchains[i];
			var inProxy = pc.getHalo.src;
			if (inProxy.notNil) {
				// [drag.object, inProxy].postcs;
				if (drag.object != inProxy) { drag.object = inProxy };
			};
		};

		// sndfile drag:
		allViews[2].do { |drag, i|
			var pch = q.pchains[i];
			var sfname = pch.getHalo.sfname;
			if (sfname.notNil) {
				if (drag.object != sfname) { drag.object = sfname };
			};
		};

		// play/stop buttons:
		q.pchains.do { |pch, i|
			var panner = pch.getHalo.panner;
			var playBt = allViews[3][i];
			var stopBt = allViews[4][i];
			var pannerPlaying = panner.monitor.isPlaying.binaryValue;
			if (pannerPlaying != playBt.value or: { 1-pannerPlaying != stopBt.value }) {
				playBt.value = pannerPlaying;
				stopBt.value = 1-pannerPlaying;
			};
		};
		//// panPops:
		allViews[5].do { |pop, i|
			var currPan = q.pchains[i].getHalo(\panName);
			var currPanIndex = pop.items.collect(_.key).indexOf(currPan) ? 0;
			if (pop.item != currPan) { pop.value = currPanIndex };
		};

	}, 0.5, { w.isClosed }, \bio);

	w;
});
