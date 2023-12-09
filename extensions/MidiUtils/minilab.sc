MiniLab {
	classvar ccKnobs = #[112, 74, 71, 76, 77, 93, 73, 75,
			            114, 18, 19, 16, 17, 91, 79, 72];
	var window = nil;
	var midifuncs;
	var guifuncs;
	var values;

	*new {
		var self = super.new;
		self.init;
		^self;
	}

	init {
		midifuncs = Array.fill(16, { nil });
		guifuncs = Array.fill(16, { nil });
		values = Array.fill(16, { 0 });
		this.gui;
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

	synth { |num, syn, ctlSym, range|
		var cc, midifunc;
		var ki = num - 1;
		var name = syn.defName.asString + "-" + ctlSym.asString;

		// if an existing knob midi func exists free it
		if(midifuncs[ki] != nil) {
			midifuncs[ki].free;
		};

		cc = ccKnobs[ki];
		midifunc = MIDIFunc.cc({|v|
			var newv = v.linlin(0, 127, range[0], range[1]);
			syn.set(ctlSym, newv);
			{
				guifuncs[ki].value(v / 127, newv * 1.0);
			}.defer;
		}, cc);
		midifuncs[ki] = midifunc;

		// set initial values
		syn.get(ctlSym, { arg value;
			var knob_v = value.linlin(range[0], range[1], 0, 1);
			{
				guifuncs[ki].value(knob_v, value, name);
			}.defer;
		});

		^midifunc;
	}

	func { |nums, ranges, cb, name|
		if(nums.isArray.not) {
			nums = [nums];
		};

		if(ranges[0].isArray.not) {
			ranges = [ranges];
		};

		nums.do { arg num, ix;
			var ki = num - 1;
			var cc = ccKnobs[ki];

			// if an existing knob midi func exists free it
			if(midifuncs[ki] != nil) {
				midifuncs[ki].free;
			};

			midifuncs[ki] = MIDIFunc.cc({|v|
				var newv, vals;
				values[ki] = v;

				// iterate over existing knob values requested
				// and map into range
				vals = Array.new(nums.size);
				nums.do { arg num, i;
					var range;
					if (i < ranges.size) {
						range = ranges[i];
					} {
						range = ranges[ranges.size - 1];
					};
					vals.add(values[num-1].linlin(0, 127, range[0], range[1]));
				};
				newv = vals[ix];
				cb.value(*vals);
				{
					guifuncs[ki].value(v / 127, newv * 1.0);
				}.defer;
			}, cc);

			if(name.isNil) {
				name = "---";
			};
			{
				guifuncs[ki].value(0, 0.0, name);
			}.defer;
		}
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
					nameText.string_(format("%\n%", num, nameval));
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
			row2.add(numknob.value(item + 9));
		};

		window = Window(name: "SC-MiniLab", bounds: Rect(200,200,600,800)).layout_(
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

