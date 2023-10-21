MiniLab {
	classvar ccKnobs = #[112, 74, 71, 76, 77, 93, 73, 75,
			            114, 18, 19, 16, 17, 91, 79, 72];
	var window = nil;
	var midifuncs;
	var guifuncs;

	*new {
		var self = super.new;
		self.init;
		^self;
	}

	init {
		midifuncs = Array.fill(16, { nil });
		guifuncs = Array.fill(16, { nil });
	}

	initMidi {
		if(MIDIClient.initialized.not) {
			MIDIClient.init;
			MIDIIn.connectAll;
		}
	}

	freeAll {
		midifuncs.do{ |kfunc| kfunc.free };
	}

	knob { |num, synth, ctlSym, range|
		var cc, midifunc;
		var ki = num - 1;
		// if an existing knob midi func exists free it
		if(midifuncs[ki] != nil) {
			midifuncs[ki].free;
		};

		cc = ccKnobs[ki];
		midifunc = MIDIFunc.cc({|v|
			var newv = v.linlin(0, 127, range[0], range[1]);
			synth.set(ctlSym, newv);
			if(guifuncs[ki] != nil) {
				{
					guifuncs[ki].value(v / 127, newv * 1.0);
				}.defer;
			}
		}, cc);
		midifuncs[ki] = midifunc;

		if(guifuncs[ki] != nil) {
			{
				var defname = synth.defName.asString;
				var ctlname = ctlSym.asString;
				var name = defname + "-" + ctlname;
				guifuncs[ki].value(0, 0.0, name);
			}.defer;
		}

		^midifunc;
	}

	gui {
		var numknob = {arg num;
			var layer, knob, valText, nameText;
			knob = Knob.new();

			nameText = StaticText();
			nameText.string = "---";
			nameText.align = \center;
			nameText.font = Font("Monaco", 18);

			valText = StaticText();
			valText.string = num.asString;
			valText.align = \center;
			valText.font = Font("Monaco", 18);

			guifuncs[num - 1] = {|knobval, textval, nameval|
				knob.value_(knobval);
				valText.string_(textval.asStringPrec(5));
				if(nameval.isNil.not) {
					nameText.string_(nameval);
				}
			};

			VLayout(knob, [nameText, align:\center], [valText, align:\center]);
		};

		var row1 = HLayout();
		var row2 = HLayout();

		8.do { arg item;
			row1.add(numknob.value(item + 1));
		};

		8.do { arg item;
			row2.add(numknob.value(item + 8));
		};


		window = Window(bounds:Rect(200,200,200,200)).layout_(
			VLayout(row1, row2)
		).front;
	}

	destroy {
		this.freeAll;
		window.close;
		if(MIDIClient.initialized) {
			MIDIClient.disposeClient;
		}
	}

}
