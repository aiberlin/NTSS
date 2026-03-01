// put default values for NTSS setups here

NTSS.defaults.sampleRate = 48000;
NTSS.defaults.numInputChannels = 30;
NTSS.defaults.numOutputChannels = 32;

// works for macOS, to test for others
NTSS.defaults.inDevice = "X-USB"; // Behringer X-32 mixer in macOS
NTSS.defaults.outDevice = "X-USB";
NTSS.defaults.device = "X-USB";
NTSS.defaults.numInputBusChannels = 30;
NTSS.defaults.numOutputBusChannels = 32;
NTSS.defaults.memSize = 8192 * 32; // boost to 256MB for delaylines
NTSS.defaults.numAudioBusChannels = 2048;
NTSS.defaults.maxNodes = 4096;
NTSS.defaults.numWireBufs = 512;
// safer to make it big, esp. for Windows
NTSS.defaults.hardwareBufferSize = 1024;

NTSS.defaults.reboot = true;

NTSS.defaults.speakerData = "speakerData/speakerData111_v3.scd";

NTSS.defaults.pcSlots = [\top, \ins, \sndfile,
	\eq3, \freqMod, \ampMod, \tilta, \gapz, \reverb, \limiter
];

// default names //
NTSS.topName = \N_T_S_S;



// still the inNames from Biophony...
NTSS.defaults.inNames = [
	\kiteMic, \richtMic, \funkMic1,\funkMic2,
	\micA_innen, \micB_innen, \micC_innen,
	\stringGang, \stringWind,
	\plonkBauL, \plonkBauM, \plonkBauR,
	\line1, \line2, \line3, \line4,
	\echoShure, \geoLom,
	\hydroWheel, \hydroFount,
	\angel, \arianeFunk
].collect { |name, i| ((i+1).asString ++ name).asSymbol };

NTSS.defaults.numPmcs = 8;
NTSS.defaults.allPcNames = [
	\ada, \bob, \cecilia, \dada, \eek,
	\fifi, \gogo, \hah, \ivy, \jay,
	\kiki, \lily, \mimi, \nana, \opo,
	\pepe, \qiqo, \roro, \sisu, \tata,
	\ubu, \vovo, \wawa, \xoxo, \yoyo, \zazie
];
