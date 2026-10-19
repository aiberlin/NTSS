// temp fix for playN usage to show something,
// should be in JITLibExt eventually
//
+ MonitorGui {
	checkUpdate {
		var newState = this.getState;

//			// don't know why early exit suppresses changes in play state. fix later...
//		if (newState == prevState) { ^this };


		if (newState[\object] != prevState[\object]) {
			zone.visible_(newState[\object].notNil);
		};

		if (newState[\isAudio] != prevState[\isAudio]) {
			zone.enabled_(newState[\isAudio]);
		};

		if (nameView.notNil) {
			if (newState[\name] != prevState[\name]) {
				nameView.object_(newState[\object])
					.string_(newState[\name].asString);
			};
		};

		if (newState[\vol] != prevState[\vol]) {
			ampSl.value_(newState[\vol]);
		};
		if (newState[\monPlaying] != prevState[\monPlaying]) {
			playBut.value_(newState[\monPlaying]);
		};
		if (newState[\out] != prevState[\out]) {
			if (newState[\out].isNumber) {
				setOutBox.value_(newState[\out]);
			} {
				setOutBox.numberView.string_(newState[\out].cs)
			}
		};
		if (fadeBox.notNil) {
			if (newState[\monFade] != prevState[\monFade]) {
				fadeBox.value_(newState[\monFade] ? 0.02);
			}
		};

		prevState = newState;
	}
}