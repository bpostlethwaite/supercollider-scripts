MultiPlot {

	var window = nil;
    var plots;

	*new {
		var self = super.new;
		self.init;
		^self;
	}

	init {
		plots = Array.fill(2, { nil });
		this.gui;
	}


	gui {
		| title = "multiplot" |
		window = Window(title, Rect(20, 30, 1600, 800));
		plots[0] = Plotter("plot1", Rect(0, 0, 800, 800), parent: window);
		plots[1] = Plotter("plot2", Rect(0, 800, 800, 800), parent: window);

		window.front;
	}

	update {
		| plotnum, value, plotname |
		plots[plotnum-1].value = value;
		if(plotname.isNil.not) {
			plots[plotnum-1].name = plotname;
		}
		^this;
	}

	updateEnv {
		| plotnum, env, plotname |
		^this.update(plotnum,
			env.asMultichannelSignal(400).flop.flat,
			plotname);
	}
}