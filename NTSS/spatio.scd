/*

NTSS.spk.selected = NTSS.spk.groups.choose.postln; "";
NTSS.spk.selected = NTSS.spk.groups.choose.postln; "";

NTSS.spk.selected = [];
*/

NTSS.spatbus = NTSS.spatbus ?? { Bus.audio(s, NTSS.spk.ordered.size) };

WinBounds.addMake(\SpatioScope, {
	var spkDataName = NTSS.speakerDataPath.basename.splitext.first;
	q.spat = SpatioScope.new(
		NTSS.spk.positions.collect {|sp| Point(*sp)}, bounds: Rect(0,0,500,500),
		busOffset: NTSS.spatbus.index
	);

	q.spat.parent.name = "SpatioScope" + spkDataName;
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

	/////// show groups:
	Button(q.spat.parent, Rect(2, 30, 100, 20)).states_([["open dataFile"]])
	.action = { Document.open(NTSS.speakerDataPath) };
	NTSS.spk.selected = Set[];
	NTSS.spk.groups.skeys.do { |groupName, i|
		Button(q.spat.parent, Rect(2, 20 * i + 50, 50, 20))
		.states_([[groupName, Color.grey(0.8), Color.grey(0.5, 0.5)],
			[groupName, Color.grey(1.0), Color.grey(0.8, 0.6)]])
		.action_{ |bt|
			if (bt.value > 0) {
				NTSS.spk.selected.addAll(NTSS.spk.groups[groupName]);
			} {
				NTSS.spk.selected.removeAll(NTSS.spk.groups[groupName])
			}
		};
	};

	q.spat.getHalo(\groupShow).stop;
	q.spat.addHalo(\groupShow, SkipJack({
		NTSS.spk.selected.do { |spkName|
			var index = NTSS.spk.names.indexOf(spkName);
			if (index.isNil) {
				"q.spat: speaker % not found.\n".postf(spkName.cs);
			} {
				var view = q.spat.ampViews[index];
				view.background_(Color.rand(0.3, 0.8))
			}
		};
	}, 0.2, { q.spat.parent.isClosed }));

	q.spat.parent
});
