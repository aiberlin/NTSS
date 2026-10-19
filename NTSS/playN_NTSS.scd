/*
*** play any Ndef to NTSS output channel groups with playN ***

this assumes that different kinds of groups are defined, at least:

// groups by loudspeaker color
NTSS.spk.colorNames = ['ldl', 'kef', 'wd', 'amps', 'crypt', 'shaka', 'braun', 'cabass'];

// groups by ring membership
NTSS.spk.ringNames = ['back', 'up', 'left', 'right'];

NTSS.run;

// test GUI:

Ndef(\x, { Ringz.ar(Dust2.ar([5, 5]), [300, 900], 0.2) });

MFdef(\playOnGui).(Ndef(\x), nil, nil, NTSS.spk.colorNames ++ NTSS.spk.ringNames);

*/

// Tell an Ndef to play to a specific group,
// or add that groups channels to the channels it plays at.

(
MFdef(\playOn).add(\add, { |ndef, groupsToPlayOn, add = false|
	var spksToPlayOn = List[], chansToPlayOn;

	groupsToPlayOn = groupsToPlayOn.asArray;
	// optionally keep existing groups
	if (add) {
		var currGroups = ndef.getHalo(\currGroups).asArray;
		currGroups.do { |name|
			if (groupsToPlayOn.includes(name).not) {
				groupsToPlayOn.add(name)
			};
		};
	};
	// only keep existing grpNames
	groupsToPlayOn = groupsToPlayOn.select { |grpName| NTSS.spk.groups[grpName].notNil };

	// collect indiv. speaker names, and their logicOut channel numbers
	groupsToPlayOn.do { |name|
		var group = NTSS.spk.groups[name];
		if (group.isNil) {
			warn("MFdef(\playOn): no group named %!".format(name));
		} {
			group.do { |spk| spksToPlayOn.add(spk) };
		};
	};

	chansToPlayOn = spksToPlayOn.collect { |spkName|
		NTSS.spk.atName(spkName).logicOut
	};
	// post in readable order
	"% plays on groups %,\n  spks: %,\n   logicOuts: %\n\n".postf(ndef,
		groupsToPlayOn, spksToPlayOn, chansToPlayOn);

	// randomize order
	chansToPlayOn = chansToPlayOn.scramble.clump((chansToPlayOn.size / ndef.numChannels).ceil);
	ndef.playN(chansToPlayOn);
	ndef.monitor.outs;
	ndef.addHalo(\currGroups, groupsToPlayOn);
	ndef.addHalo(\currSpks, spksToPlayOn);
});
);

/*
Ndef(\x, { Ringz.ar(Dust2.ar([5, 5]), [300, 900], 0.2) });

MFdef(\playOn).(Ndef(\x), \amps);
MFdef(\playOn).(Ndef(\x), \left);
MFdef(\playOn).(Ndef(\x), NTSS.spk.colorNames.choose, true);
MFdef(\playOn).(Ndef(\x), NTSS.spk.colorNames.choose);
MFdef(\playOn).(Ndef(\x), \wrong);

MFdef(\playOn).(Ndef(\x), \shaka, true);
MFdef(\playOn).(Ndef(\x), \right, true);

NdefMixer(s).addMeter;

MFdef(\playOn).(Ndef(\x)); // nothing
*/

(
MFdef(\playOnGui).add(\show, { |ndef, parent, bounds, groupNames|
	var comp, nameBut, playbut, groupbuts, chansView, butdict;

	bounds = (bounds ? Rect(0, 0, 220, 160)).asRect;
	parent = parent ?? {
		parent = Window(\playN ++ '_' ++ ndef.key, bounds).front;
		parent.view.addFlowLayout(1@1, 2@2);
		parent
	};

	comp = CompositeView(parent, Rect(0, 0, 220, 180)).background_(Color.rand);
	comp.addFlowLayout;

	nameBut = Button(comp, 100@20).states_([[ndef.cs, nil, Color.white]]).action = { ndef.gui };

	playbut = Button(comp, 100@20).states_([["playN"], ["playN", nil, Color.green]]);
	playbut.action = { |but|
		if (ndef.monitor.isPlaying) {
			ndef.stop; but.value = 0;
		} {
			ndef.play; but.value = 1
		}
	};

	MonitorGui(ndef, comp, 200@20).addMeter;

	ndef.addHalo(\playbut, playbut);
	butdict = ();
	ndef.addHalo(\butdict, butdict);
	ndef.addHalo(\currGroups, ndef.getHalo(\currGroups) ? []);

	groupbuts = groupNames.collect { |groupName|
		var but = Button(comp, 50@20).states_([[groupName],[groupName, nil, Color.green]]);
		butdict.put(groupName, but);
		but.action = { |but, mod = 0|
			var addGrp = mod > 0, currGroups;
				MFdef(\playOn).(ndef, groupName, addGrp);
				currGroups = ndef.getHalo(\currGroups);
		};
	};

	chansView = TextView(comp, 220@50);

	SkipJack ({
		butdict.keysValuesDo { |grpName, but|
			but.value = ndef.getHalo.currGroups.includes(grpName).binaryValue
		};
		playbut.value = ndef.monitor.isPlaying;
		chansView.string = ndef.monitor.outs.cs;

	}, 0.2, { parent.isClosed }, ndef.key)

});
);

