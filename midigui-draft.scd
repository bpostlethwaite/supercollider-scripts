(
var kdim = 50;
var kpad = 10;
var win = Window.new("MiniLab", Rect(200,200,255,100));
var knob1, knob2, numknob;

var numknob = {arg num, bound;
	var knob, text;
	knob = Knob.new(win, bound).value_(0.5);
	knob.action_({
		knob.value.postln;
	});
};

knob1 = Knob.new(win, Rect(10, 10, kdim, kdim)).value_(0.5).step_(0.05);
knob1.action_({
	knob1.value.postln;
});
a = StaticText(w, Rect(10, 10, 200, 20));
a.string = 1.asString;

knob2 = Knob.new(win, Rect(10+kpad+kdim, 10, kdim, kdim)).value_(0.5).step_(0.05);
knob2.action_({
	knob2.value.postln;
});


win.front;
)

(

var window, size = 32; // try different sizes - from 15 to 200 or more!
window = Window.new("Knob", Rect(640,630,270,70)).front;
k = Knob.new(window, Rect(20, 10, size, size));
k.action_({|v,x,y,m| postf("action func called: %\n", v.value); });


)

k.value_(0.8);