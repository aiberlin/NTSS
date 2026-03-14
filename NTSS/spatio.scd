NTSS.showRing = { |nt, ringName, show=true|
	if (show, "SHOWING %:\n", "HIDING %:\n").postf(ringName);
	NTSS.ringDict[ringName].do { |spkName|
		var index = NTSS.spk.names.indexOf(spkName);
		q.spat.ampViews[index].visible_(show);
		"  %: %\n".postf(index, spkName);
	};
};

/*
NTSS.showRing(\subs, false);
NTSS.showRing(\subs);
NTSS.showRing(\left, false);
NTSS.showRing(\left);
NTSS.showRing(\up, false);
NTSS.showRing(\up);
NTSS.showRing(\right, false);
NTSS.showRing(\right);
NTSS.showRing(\back, false);
NTSS.showRing(\back);
*/

NTSS.spatbus = NTSS.spatbus ?? { Bus.audio(s, NTSS.spk.ordered.size) };

WinBounds.addMake(\SpatioScope, {
	q.spat = SpatioScope.new(
		NTSS.spk.positions.collect {|sp| Point(*sp)}, bounds: Rect(0,0,500,500),
		busOffset: NTSS.spatbus.index
	);

	q.spat.parentView.mouseDownAction = nil;
	q.spat.magnify_(10);
	q.spat.parent.background_(Color.blue(0.5));
	// make amps semitransparent for overlapping speakers
	q.spat.ampAlpha = 0.5;

	q.spat.ampViews.do(_.stringColor_(Color.white));
	q.spat.ampViews.do {|view,i|
		var spkDict = NTSS.spk.ordered[i];
		view.bounds = view.bounds.height_(30);
		view.string = spkDict.name;
		view.mouseDownAction = {
			"*** q.spat: %, %: %\n".postf(i, spkDict.name, spkDict);
		};
	};
	if (NTSS.spatImagePath.notNil) {
		q.spat.parent.view.backgroundImage_(
			Image(NTSS.spatImagePath)
		);
	};
	q.spat.parent.moveTo(120, 480);
	q.spat.parent
});
