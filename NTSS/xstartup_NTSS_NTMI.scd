/***
example startupfile for combining NTSS with another setup, here the NTMI.

Copy this file to your desired location,
modify to your taste, and use it to load your NTSS!

// If you use StartupFile, do
StartupFile.dialog;
// drop this file into the dragsink there,
// and save it with a name you remember well.

This file loads NTSS first,
then NTMI with no MainFX and no reboot.
adds a window for dragsources for NTMI processes,
so one can drag them to NTSS channels.

***/
//// some things to set before loading anything:


// I want that sampleRate:
s.options.sampleRate = 48000;

// for general things:
q = q ? ();

// special ntss settings would go here...
NTSS.defaults;



// first run NTSS, which configures and boots the server.
NTSS.run;
// run can be directed to a custom load file:
// NTSS.run("~/folder/path/to/myLoadMe_NTSS.scd")

// tell ntss what to do when finished loading:
NTSS.finalSetup = {
	// wait a bit
	0.1.wait;

	// prepare groups for switchable NdefMixer:
	q.ndef.groupNames = [\ntssChan, \ntssPan, \NTMI];
	q.ndef.groups.put(\NTMI, NTMI.processes);

	MainFX(s).proxy.set(\mainvol, 0.25);

	// then load NTMI, with some special settings:
	NTMI.reboot = false;
	NTMI.usesMainFX = false;

	NTMI.run;

	// tell NTMI what to do when done:
	NTMI.finalSetup = {
		//make sure the NTMI sounds play directly:
		NTMI.processes.do(_.set(\amp, 0.5));
		q.ndef.groups.keys.postcs;
		q.ndef.groups.put(\NTMI, NTMI.slots.zz ++ NTMI.processes);

		q.ndef.groups.keys;

		// for choosing Ndefs as NTSS sources,
		// get these from NTMI:
		NTSS.getSrcNdefs = {
			NTMI.slots.zz ++
			NTMI.ndefs ++
			NTMI.processes.copy.removeAll(NTMI.ndefs);
		};

		NTMI.slots.zz.do(_.play(vol: 0));

		NTMI.slots.zz.do { |zz, i|
			MFdef(\setSrc).(NTSS.pchains[i], zz);
			NTSS.pchains[i].set(\proxyAmp, 1);
			NTSS.pchains[i].getHalo(\panner).vol_(0);
		};

		0.5.wait;

		NTMI.slots.addActive(0, NTMI.ndefs[0]);
		NTMI.slots.addActive(1, NTMI.ndefs[1]);
		NTMI.slots.addActive(2, NTMI.ndefs[2]);
		NTMI.slots.addActive(3, NTMI.ndefs[3]);

		MFdef(\setPanner).(NTSS.pchains[0], \ringRoto2);
		MFdef(\setPanner).(NTSS.pchains[1], \ringSnake2);
		MFdef(\setPanner).(NTSS.pchains[2], \ringFeed2);
		MFdef(\setPanner).(NTSS.pchains[3], \peatSoup2);

		// finetune Butzes
		Butz(\NTMI).remove(\miniNTMI); // not fully working
		Butz(\NTMI).add(\allSrcNdefs, { WinBounds.showOrMake(\allSrcNdefs) });
		// redirect to new flexible NdefMixer
		Butz(\NTMI).add(\ndefMixer, { WinBounds.showOrMake(\NdefMixer) });
		// redirect to general MainFX
		Butz(\NTMI).add(\mainFX, { WinBounds.showOrMake(\MainFX) });

		// end with NTSS Butz and N_T_S_S window in front
		Butz.curr = \NTSS;
		Butz.run(\N_T_S_S);
	};
};

