// Biophony - not sure what this sketch was for
(
var win, pop, uv, xy = 400;
var cols;
var grey = Color.grey(0.1, 0.8);

~numRings = 4;

~pointerHeight = 1;
~pointerWidth = 1;
~pointerAngle = pi;
~pointerRad = 6.5;    // make fit with rings ...
// rings radii are [9.5, 7.5, 5.5, 3.5];
// ~pointerRad shd be between

try{~panwin.close};
win = Window("pañ", Rect(0,0, xy, xy), border: true).front;

uv = UserView(win, win.bounds.moveTo(0,0))
.resize_(5)
.background_(grey);

pop = EZPopUpMenu(win, 100@20, "", q.rotoNames, { |pop|
	~ndefToShow = Ndef(pop.item);
}, 0, true, labelWidth: 0);

~panwin = win;

thisThread.randSeed = 1126;
thisThread.randSeed = 1970;

cols = { Color.rand } ! 12; // enough Colors
uv.drawFunc = {
	var uextent = uv.bounds.extent;
	var width = uextent.x, height = uextent.y;
	var newSize = min(width, height);
	var rescaler = (newSize / xy);
	var rado = 9.5;

	// "width: % height: % newSize: % rescaler: %\n".postf(
	// width, height, newSize, rescaler);
	// ~pointerAngle = pi.rand;

	Pen.translate(newSize * 0.5, newSize * 0.5);
	// scale by window size first ...
	Pen.scale(rescaler, rescaler);


	~numRings.do { |wheel, i|
		// var rad = [ 9, 8,7,6,5 ][i] -2 / 10 * xy / 2;
		var rad = rado / 10 * xy / 2;
		Pen.use {
			// Pen.color_( cols[i] );
			Pen.addArc(0@0, rad, 0, 2pi);
			Pen.fillAxialGradient(
				rad.neg@rad.neg, rad@rad,
				cols[i], cols@@(i+3)
			);
			//					*fillRadialGradient { arg innerCircleCenter, outerCircleCenter, startRadius, endRadius, startColor, endColor;
		};
		rado = rado - 2;
	};

	Pen.fillColor_(grey);
	Pen.addArc(0@0, rado / 10 * xy / 2, 0, 2pi);
	Pen.fill;

	// draw pointer as circle
	Pen.use {
		Pen.rotate(~pointerAngle);
		Pen.translate(0, ~pointerRad / 10 * xy / 2);
		Pen.fillColor_(Color.white);
		// Pen.addArc(0@0, ~pointerSize/40* xy, 0, 2pi);
		Pen.addOval(Rect.aboutPoint(0@0, ~pointerHeight/20 * xy, ~pointerWidth/20*xy));
		Pen.fill;
	}
};

// get all 4
~guifork.stop;
~guifork = fork{
	inf.do{|i|
		var ndef = ~ndefToShow;
		var data = ndef.getHalo(\krBus).getnSynchronous(4);
		~pointerAngle = data[0] * pi;
		~pointerHeight = data[1] / 2;

		~pointerRad = data[2].linlin(0, 1.5,   2.5, 8.5);
		~pointerWidth = data[3].linlin(2,6,   1, 4);

		defer{~panwin.refresh};
		0.03.wait;

	}
};


~pointerHeight = 1;
~pointerWidth = 1;
)