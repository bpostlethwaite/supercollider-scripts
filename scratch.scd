///////////////////////////////////////////////////////////
// Start the drone
d = Synth(\richDrone);

l = MiniLab.new;
l.initMidi;
l.gui;
l.knob(3, d, \freq2, [200, 240]);

// After enjoying the drone, release it
d.free;
l.freeAll;
l.destroy;


///////////////////////////////////////////////////////////
(
SynthDef(\drunkenwalk, {
	| outCtlBus, freq = 0.3 |
	var minfreq, sig;
	minfreq = ArrayMax.kr([0.01, freq]);
	sig = VarLag.kr(LFNoise0.kr(minfreq), 1/minfreq, warp:\sine);
	Out.kr(outCtlBus, sig);
}).add;
)

~bus = Bus.control(s, 1);
x = Synth(\drunkenwalk, [\outCtlBus, ~bus, \freq, 3]);

~bus.plot(3);


x.free;
~bus.free;

///////////////////////////////////////////////////////////
(
// a stereo version
SynthDef(\tutorial_DecaySin2, { arg outBus = 0, effectBus, direct = 0.5, freq = 440;
    var source;
    // 1.0.rand2 returns a random number from -1 to 1, used here for a random pan
    source = Pan2.ar(Decay2.ar(Impulse.ar(Rand(0.3, 1), 0, 0.125), 0.3, 1,
        SinOsc.ar(SinOsc.kr(0.2, 0, 110, freq))), Rand(-1.0, 1.0));
    Out.ar(outBus, source * direct);
    Out.ar(effectBus, source * (1 - direct));
}).add;

SynthDef(\tutorial_Reverb2, { arg outBus = 0, inBus;
    var input;
    input = In.ar(inBus, 2);
    16.do({ input = AllpassC.ar(input, 0.04, Rand(0.001,0.04), 3)});
    Out.ar(outBus, input);
}).add;
)

// now we create groups for effects and synths
(
~sources = Group.new;
~effects = Group.after(~sources); // make sure it's after
~bus = Bus.audio(s, 2);           // this will be our stereo effects bus
)

// now synths in the groups. The default addAction is \addToHead
(
x = Synth(\tutorial_Reverb2, [\inBus, ~bus], ~effects);
y = Synth(\tutorial_DecaySin2, [\effectBus, ~bus, \outBus, 0], ~sources);
z = Synth(\tutorial_DecaySin2, [\effectBus, ~bus, \outBus, 0, \freq, 660], ~sources);
)

s.plotTree;

// we could add other source and effects synths here

~sources.free; ~effects.free; // this frees their contents (x, y, z) as well
~bus.free;

// remove references to ~sources and ~effects environment variables:
currentEnvironment.clear;
///////////////////////////////////////////////////////////
(
x = SynthDef("tutorial-map", { arg freq = 220, width = 0.5;
	Out.ar(0,Pulse.ar(freq, width)!2, 0.5);
}).play;
)
(
x = SynthDef("tutorial-map", { arg freq = 220, width = 0.5;
	Out.ar(0, VarSaw.ar(freq!2, 0, width), 0.5);
}).play;
)

l = MiniLab.new;
l.initMidi;
l.gui;
s.scope;
l.knob(3, x, \width, [0.1, 0.9]); // soften

x.free;
l.freeAll;

////////////////////////////////////////////////////////////
