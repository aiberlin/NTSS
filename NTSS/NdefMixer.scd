/*** make ndefmixer flexible:
can show or hide groups of Ndefs by group name

q.ndef.groupNames = [ \ntssChan, \ntssPan, \NTMI];
WinBounds.showOrMake(\NdefMixer);
q.ndef.groups.put(\NTMI, NTMI.processes);

***/

thisProcess.nowExecutingPath.postcs;
// a dict for ndef info
q.ndef = q.ndef ? ();
// make several groups
q.ndef.groups = q.ndef.groups ? ();
// a ProxySpace for the selection of ndefs to show on the mixer
q.ndef.mixspace = q.ndef.mixspace ?? { ProxySpace.new };
// the names of the groups to show/hide
q.ndef.groupNames = q.ndef.groupNames ? q.ndef.groups.keys(Array).sort;


q.ndef.groupNames = q.ndef.groupNames ++ (q.ndef.groups.keys(Array).sort.removeAll(q.ndef.groupNames));

// each button adds or removes Ndefs for that group:
MFdef('mixBut').add(\mixBut, { |bt, mod = 0|
	var name = bt.states[0][0].asSymbol;
	var group = q.ndef.groups[name].value; // value to allow
	// hold alt key to show only one group
	if (group.isNil) {
		"*** q.ndef group % not found!\n".postf(name.cs);
	} {
		case { mod.isAlt } {
			"*** ndefmix shows only: %\n".postf(name.cs);
			q.ndef.mixspace.envir.clear;
			group.do { |ndef| q.ndef.mixspace.envir.put(ndef.key, ndef) };
			q.ndef.mixbuts.do(_.value_(0));
			bt.value = 1;

		} { bt.value > 0 } {
			"ndefmix adding: %\n".postf(name.cs);
			group.do { |ndef| q.ndef.mixspace.envir.put(ndef.key, ndef) };
		} {
			"ndefmix removing: %\n".postf(name.cs);
			group.do { |ndef| q.ndef.mixspace.envir.removeAt(ndef.key) };
		}
	}
});

Butz.add(\NdefMixer, { WinBounds.showOrMake('NdefMixer') });

q.ndef.defaultGroupsToShow = q.ndef.defaultGroupsToShow ? [\ntssChan, \ntssPan];

WinBounds.addMake(\NdefMixer, {
	q.ndef.mixwin = Window(\NdefMixer, Rect(700, 94.0, 806.0, 491.0)).front;
	q.ndef.mixwin.addFlowLayout;

	q.ndef.mixbuts = q.ndef.groupNames.collect { |name, i|
		Button(q.ndef.mixwin, 60@24).font_(Butz.style.midfont)
		.states_([[ name, Color.white, Color.grey ], [ name, Color.white, Color.red(0.8) ]])
		.action_(MFdef('mixBut'));
	};
	q.ndef.mixer = ProxyMixer(q.ndef.mixspace, 24, q.ndef.mixwin);
	q.ndef.mixer.arGuis.do(q.tuneNameView(_));
	ProxyMeter.addMixer(q.ndef.mixer);
	ProxyMeter.hideKrs;
	// which ones to show by default?
	try {
		q.ndef.defaultGroupsToShow.do { | groupName|
			var butIndex = q.ndef.groupNames.indexOf(groupName);
			butIndex !? { q.ndef.mixbuts[butIndex].valueAction_(1) };
		};
	};

	q.ndef.mixwin;
});
