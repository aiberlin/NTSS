/*
4 kinds of panners for the Pmcs:

fixedPan, rotoPan, feedPan, molens

NTSS.pchains.choose.getHalo;

ProxyChainGui([0]);

MFdef(\setPanner).([0], 1);
MFdef(\setPanner).([0], 0);

q.inNames;
[0].slotNames.size
[0].getHalo
*/

(
MFdef(\updatePchWin).add(\proxySource, { |pch|
	var h = pch.getHalo;
	if (h.pxDrag.notNil) {
		if (h.pxDrag.object != h.src) {
			h.pxDrag.object = h.src
		};
	}
});

MFdef(\updatePchWin).add(\bufPath, { |pch|
	var h = pch.getHalo;
	var filename;
	if (h.pxDrag.notNil) {
		if (h.mybuf.notNil and: h.mybuf.path.notNil) {
			filename = h.mybuf.path.basename;
			if (h.sfDrag.string != filename) {
				h.sfDrag.string = filename;
			};
		};
	}
});

MFdef(\updatePchWin).add(\panMode, { |pch|
	var h = pch.getHalo;
	var panName = h.panName;
	var pop = h.panPop;
	var popCurrItem = pop.item;
	if (popCurrItem != panName) {
		// [panName, popCurrItem].postcs;
		// "here? panMode".postln;
		pop.value = pop.items.collect(_.key).indexOf(panName) ? 0;
	};
});

/*
MFdef(\updatePchWin).(NTSS.pchains[0]);
MFdef(\updatePchWin).(NTSS.pchains[2]);
*/
);

// get all desired source Ndefs :
// everything audio except the chains and panners,
NTSS.getSrcNdefs = {
	var sources = Ndef.all[s.name].envir.asArray;
	sources = sources.select { |px| px.rate == \audio };
	NTSS.pchains.do { |chain|
		sources.remove(chain.proxy);
	};
	NTSS.pchains.do { |chain|
		sources.remove(chain.getHalo(\panner));
	};
	sources.sort { |a, b| a.key < b.key };
};

WinBounds.addMake(\allSrcNdefs, {
	var w = Window("allSrcNdefs", Rect(595.0, 360.0, 400.0, 400.0)).front;
	w.background_(Color.grey);
	w.view.layout = GridLayout.rows(
		*NTSS.getSrcNdefs.collect { |ndef|
			DragSource(w).object_(ndef) }.clump(4)
	);
	w;
});

/*
// choose source Ndef for one pchain from buttons:
MFdef(\allSrcChoose).(NTSS.pchains[0]);
MFdef(\allSrcChoose).(NTSS.pchains[0], 400@500);
*/
MFdef(\allSrcChoose).add(\choose, { |pchain, xy|
	var w = Window("choose src for % :".format(pchain),
		Rect(500, 400, 400.0, 400.0)).front;

	w.background_(Color.grey);
	w.view.layout = GridLayout.rows(
		*NTSS.getSrcNdefs.collect { |ndef|
			Button(w).states_([[ndef.key]])
			.action_({ MFdef(\setSrc).(pchain, ndef); w.close })
		}.clump(4)
	);
	if (xy.postln.notNil) {
		var top = Window.availableBounds.height - xy.y - w.bounds.height;
		w.moveTo(xy.x - 200.postln, top.postln);
	};
	w;
});



(
NTSS.pchains.do { |pch, i|
	Butz(\NTSS).add(pch.key, { WinBounds.showOrMake(pch.key) });

	WinBounds.addMake(pch.key, {
		var horizStagger = (Window.screenBounds.width - 200 - 500 / NTSS.pchains.size).round;
		var vertiStagger = (Window.availableBounds.height - 830 / NTSS.pchains.size).round;
		var winrect = Rect(horizStagger * i + 200, NTSS.pchains.size - i * vertiStagger, 500, 820);
		var w = Window(pch.key, winrect.postln).front.background_(pch.getHalo.backCol);
		var flow = w.addFlowLayout;
		var font = Font(Font.defaultMonoFace, 14);

		var inputPop, pxDrag, sfDrag, pchgui, pannerGui, panPop, panguibounds;

		// make input selections: audio inputs
		inputPop = EZPopUpMenu(w, 160@30, \anaIn, q.inNames,
			{ |pop|
				"%: input %, %\n".postf(pch, pop.value, pop.item);
				pch.set(\micBus, pop.value);
			}, labelWidth: 45
		).font_(font)
		.value_(pch.proxy.get(\micBus).asInteger)
		;

		// dragsink for playing in proxies
		pxDrag = DragBoth(w, 150@30).align_(\center).font = font;
		pxDrag.string = "drop a proxy/chain!";
		pxDrag.receiveDragHandler = { arg v;
			var drag = View.currentDrag.postcs;
			if ((drag == v.object).not) {
				// MFdef setSrc accepts proxy, proxychain, or string
				if (MFdef(\setSrc).(pch, drag).notNil) {
					MFdef(\updatepchWin).(pch)
				}
			};
		};
		// when select, on keypress
		pxDrag.action = { |b|
			var where = b.absoluteBounds.center + (0 @ (b.bounds.height * 0.5));
			MFdef(\allSrcChoose).(pch, where)
		};

		pch.addHalo(\pxDrag, pxDrag);
		if (pch.getHalo(\src).notNil) {
			pxDrag.object = pch.getHalo(\src);
		};

		flow.shift(-15, 0);
		Button(w, 20@30).alpha_(0.7).states_([["?"]]).font_(font)
		.action_{ |b|
			var where = b.absoluteBounds.center + (0 @ (b.bounds.height * 0.5));
			MFdef(\allSrcChoose).(pch, where)
		};

		// dragsink for dropping in soundfiles into buffer
		sfDrag = DragBoth(w, 150@30).align_(\center).font = font;
		if (pch.getHalo(\sfname).notNil) {
			sfDrag.string = pch.getHalo(\sfname);
		} {
			sfDrag.string = "drop a soundfile!";
		};
		pch.addHalo(\sfDrag, sfDrag);

		flow.shift(-15, 0);
		Button(w, 20@30).alpha_(0.7).states_([["?"]]).font_(font)
		.action_{ |b|
			Dialog.openPanel({ |path|
				if (MFdef(\setSndfile).(pch, path)[0]) {
					sfDrag.object = pch.getHalo.sfpath;
					sfDrag.string = pch.getHalo.sfname;
				};
			});
		};


		sfDrag.receiveDragHandler = { arg v;
			var path = View.currentDrag.postln;
			if (MFdef(\setSndfile).(pch, path)[0]) {
				v.object = pch.getHalo.sfpath;
				v.string = pch.getHalo.sfname;
			};
			MFdef(\updatepchWin).(pch);
		};

		pchgui = ProxyChainGui(pch, 18, w);
		pchgui.editGui.paramGui.paramViews[(0..2)].do(_.enabled_(false));
		q.tuneNameView(pchgui.editGui);
		pchgui.buttons.first.enabled_(false);
		pchgui.buttons[pch.slotNames.size - 1].enabled_(false);
		ProxyMeter.addNdefGui(pchgui.editGui);

		pchgui.buttons[0].valueAction_(0);
		defer ({ pchgui.buttons[0].valueAction_(1) }, 0.25);

		panPop = EZPopUpMenu(w, 200@20, "panMode", NTSS.panNames, { |pop|
			pop.item.postln;
			MFdef(\setPanner).(pch, pop.item);
		}).font_(font);

		pch.addHalo(\panPop, panPop);

		Button(w, 80@20).font_(font).states_([["explain"]])
		.action_({ |bt|
			var panDict = ProxyChain.sourceDicts[pch.getHalo(\panName)];
			var text = "Sorry, no panDict found";
			var loc = bt.absoluteBounds.postln;
			if (panDict.notNil) { text = panDict.text };
			text = text ? "Sorry, no explanation found";
			TextView(nil, Rect.aboutPoint(Window.availableBounds.center, 200, 100))
				.string_(text).front;
		});

		pannerGui = NdefGui(pch.getHalo(\panner), 18, w, 490@250);
		pannerGui.paramGui.paramViews[0].enabled_(false);
		q.tuneNameView(pannerGui);
		ProxyMeter.addNdefGui(pannerGui);
		defer({
			SkipJack({ MFdef(\updatePchWin).(pch) }, 0.5, { w.isClosed });
		}, 0.5);

		w;
	});
	};
);

