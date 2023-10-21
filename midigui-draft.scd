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

var numknob = {arg num;
	var layer, knob, text;
	knob = Knob.new().value_(0.5);
	knob.action_({
		knob.value.postln;
	});
	text = StaticText();
	text.string = num.asString;
	text.align = \center;
	text.font = Font("Monaco", 25);
	VLayout(knob, [text, align:\center]);
};

var row1 = HLayout();
var row2 = HLayout();

8.do { arg item;
	row1.add(numknob.value(item + 1));
};

8.do { arg item;
	row2.add(numknob.value(item + 8));
};


w = Window(bounds:Rect(200,200,200,200)).layout_(
	VLayout(row1, row2)
).front;

)
