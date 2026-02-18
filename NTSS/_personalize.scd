/*
Examples for things you can personalize in NTSS setups.
more to follow!
*/

/***** TO run BEFORE NTSS.run : *****/

// hardwareBufferSize: bigger is safer,
// default of 1024 is tested, solid for Windows
// can try to tune faster to 512, 256 on macOS, linux
NTSS.hardwareBufferSize
NTSS.hardwareBufferSize = 1024;

// speakerData is filename for speaker position info.
 // default is "speakerData.scd"
NTSS.defaults.speakerData;
// switch to Silent Green Kuppelhalle:
NTSS.speakerData = "speakerDataKuppel.scd";

// names for the audio inputs
NTSS.defaults.inNames;

// set to your own names:
NTSS.inNames = [\A, \B, \C, \D];

// set how many mixer channels you want:
NTSS.defaults.numPmcs // defaults to 8
NTSS.numPmcs = 12;    // set to 12


// panNames: choose which ones to show on the GUIs:
NTSS.panNames = [\dbap, \taps, \tapsfb];
// default is all available panNames:
NTSS.allPanNames;
// -> List[-, panFixed, panRoto, panSnake, panFeed, dbap, delayspat, direct, mixer, peatSoup, taps, tapsfb]

/***** Anything to run AFTER NTSS.run,
you can put in NTSS.finalSetup function:  *****/

NTSS.finalSetup = {
	// anything to prepare after NTTS is loaded,
	// e.g. load a saved setup file:
	"~/myNTSS/silentGreen.ntssSave.scd".loadPaths;
};

