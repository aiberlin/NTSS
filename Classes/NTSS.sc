// flexible project class, redirects everything to internal dict:
NTSS {
	classvar <q;
	*initClass {
		q = (
			run: {|dict, path|
				path = (path ? (NTSS.dir.loadMe));
				path.postcs.loadPaths
			},
			// init necessary dicts
			defaults: (),
			process: (),
			pre: (),
			slots: (),
			inph: (),
			mfx: (),
			dir: ()
		);
		// use defaults automatically if nil:
		NTSS.q.parent = NTSS.q.defaults;

		NTSS.dir.setup = NTSS.filenameSymbol.asString.dirname.dirname +/+ "NTSS";
		NTSS.dir.loadMe = NTSS.dir.setup  +/+ "00_loadMe_NTSS.scd";

		NTSS.allPanNames = List['-']; // so we can add dynamically
		// use NTSS.addPanNames to add
	}

	// redirect everything to NTSS.q:
	*doesNotUnderstand { |selector ... args|
		^q.performList(selector, args)
	}
}
