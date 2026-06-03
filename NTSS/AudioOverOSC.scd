/*
Provide AudioOverOSC send and receive functions,
so multiple NTSS players can send to the one receiving
NTSS that is physically connected to the speakers.

receiving and sending happens in MainFX,
with the logical channels being sent.
receive still goes through levels in mainMixer;
send is after mainMixer, so one can send with mainMixer adjustments.

Best connect vial local Ethernet cable;
make sure to change destAddr to local receiver address.

TEST:

// test
NTSS.run

// run this file, then:
MainFX(s).add(\aooReceive, 1);
// -> shows up on MainFX gui

// test 32 chan sinewaves
MFdef(\makeAooTestSend).value
NTSS.aoo.verbose = false;
// works, but warns:

AooSend: stream format: AooFormatPCM(32, 256, 48000, float32)
WARNING: AooSink: couldn't find source [::ffff:127.0.0.1]:30001|1 for /ping message


// not working yet - to debug:
// proxychain func aooSend does not send format properly yet;
MainFX(s).add(\aooSend, 1);
// this posts:
---
*** aooSend connecting:
40
a SynthDefControl
('nodeID': 1096, 'server': localhost)
an AooSendCtl
AooFormatPCM(32, 256, auto, float32)
FAILURE IN SERVER /u_cmd Node 0 not found
FAILURE IN SERVER /u_cmd Node 0 not found
---


*/
(
// put all basic aoo config here;
// to be modified before starting aooSend or aooRecv!
NTSS.aoo = (
	recvID: 42,
	recvport: 39999,
	destAddr: AooAddr("192.168.111.183", 39999),
	//format: AooFormatPCM(32, 256),
	format: AooFormatOpus(32, 512),
	// index in MainFX proxy objects is needed for AooReceiveCtl
	mfxIndexRecv: 20,
	// index in MainFX proxy objects is needed for AooSendCtl
	mfxIndexSend: 40,
	// toggle verbose on/off to see debug info
	verbose: false
);

// switch NetAddr on the fly
Butz(\NTSS).add(\setAoo, {
	Document("setAoo",
		"// set Aoo address:\n"
		"NTSS.aoo.destAddr = AooAddr(%, %);\n".format(
			NTSS.aoo.destAddr.ip.cs, NTSS.aoo.destAddr.port)
	);
});



// start/stop it here in MainFX

ProxyChain.add3(\aooReceive, \mix -> {
	var aoo = NTSS.aoo;
	var synthCtl;
	var receivedChans = AooReceive.ar(aoo.recvport, aoo.recvID, aoo.format.channels);

	// wait for server sync, then build recvCtl:
	fork {
		0.2.wait;
		s.sync;
		"*** aooRecv connecting:".postln;
		synthCtl = MainFX(s).proxy.objects[aoo.mfxIndexRecv.postln].postln;
		aoo.recv = AooReceiveCtl(
			(server: s, nodeID: synthCtl.nodeID), nil,
			synthCtl.synthDef);

		// listen to ping, start and stop events
		aoo.recv.addListener(\ping, { |sink|
			if (aoo.verbose) {
				"aooRecv: got ping from %".format(sink).postln;
			}
		});
		aoo.recv.addListener(\start, { |sink|
			if (aoo.verbose) {
				"aooRecv: stream started by %".format(sink).postln;
			}
		});
		aoo.recv.addListener(\stop, { |sink|
			if (aoo.verbose) {
				"aooRecv: stream stopped by %".format(sink).postln;
			}
		});
	};

	receivedChans
}, 1);

ProxyChain.add3(\aooSend, \filter -> { |logicOuts|
	var aoo = NTSS.aoo;
	var synthCtl;
	var sendingChans = AooSend.ar(aoo.recvport, aoo.recvID, logicOuts);

	// wait for server sync, then build sendCtl:
	fork {
		0.2.wait;
		s.sync;
		"*** aooSend connecting:".postln;
		synthCtl = MainFX(s).proxy.objects[aoo.mfxIndexSend.postln].postln;
		// create Synth + controller
		aoo.sendCtl = AooSendCtl(
			Synth.basicNew(\wht, s, synthCtl.nodeID).postln, nil,
			synthCtl.synthDef);
		// wait until fully initialized
		0.2.wait;
		s.sync;
		aoo.sendCtl.postln;
		// listen to ping events
		aoo.sendCtl.addListener(\ping, { |sink|
			if (aoo.verbose) {
				"AooSend: got ping from %".format(sink).postln;
			}
		});

		// add destination sink
		aoo.sendCtl.addSink(aoo.destAddr, aoo.recvID);
		// // set stream format
		aoo.sendCtl.setFormat(aoo.format.postln, { |format|
			if (format.notNil) {
					"AooSend: stream format: %".format(format).postln;
				// start stream
				aoo.sendCtl.start;
			}
		});
	};

	logicOuts
}, 1);
);

/// MFdef to make a test sender with SynthDef/Synth construction
(
MFdef(\makeAooTestSend).add(\makeSender, { |senderID = 1|
	var sendPort, defName, sendCtl;
	sendPort = 30000 + senderID;
	defName = (\aoo_send ++ senderID).asSymbol.postln;

	("makeAooSend:" + defName.cs).postln;

	fork {
		SynthDef(defName, { |bus|
			var sig = SinOsc.ar(Array.rand(32, 200.0, 800), 0, 0.1);
			AooSend.ar(sendPort, senderID, sig);
		}).add;

		s.sync;

		// create Synth + controller
		sendCtl = AooSendCtl(Synth(defName));
		// wait until fully initialized
		s.sync;
		// listen to ping events
		sendCtl.addListener(\ping, { |sink|
			if (NTSS.aoo.verbose) {
				"testSender AooSend: got ping from %".format(sink).postln;
			}
		});

		// add destination sink
		sendCtl.addSink(NTSS.aoo.destAddr, NTSS.aoo.recvID);
		// set stream format
		sendCtl.setFormat(NTSS.aoo.format, { |format|
			if (format.notNil) {
				"AooSend: stream format: %".format(format).postln;
				// start stream
				sendCtl.start;
			}
		});
	}
})
)

