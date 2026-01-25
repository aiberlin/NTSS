/***
example startupfile for basic NTSS.

Copy this file to your desired location,
modify to your taste, and use it to load NTSS with your config!

// If you use StartupFile, do
StartupFile.dialog;
// drop this file into the dragsink there,
// and save it with an easy to remember name.

This file loads NTSS first,
then runs a little NTSS.finalSetup function.

***/
//// Some things to set before loading:

// I want that sampleRate:
s.options.sampleRate = 48000;

// for general things:
q = q ? ();

// special ntss settings would go here...
NTSS.defaults;

// run NTSS, which configures and boots the server.
NTSS.run;

// tell ntss what to do when finished loading:
NTSS.finalSetup = {
	// wait a bit
	0.1.wait;

	// prepare groups for switchable NdefMixer:
	q.ndef = q.ndef ? ();
	q.ndef.groupNames = [\ntssChan, \ntssPan, \TEST];

	MainFX(s).proxy.set(\mainvol, 0.5);

};

