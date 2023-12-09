//beats
(
SynthDef(\kick, {
    |out = 0, pan = 0, amp = 0.3|
    var body, bodyFreq, bodyAmp;
    var pop, popFreq, popAmp;
    var click, clickAmp;
    var snd;

    // body starts midrange, quickly drops down to low freqs, and trails off
    bodyFreq = EnvGen.ar(Env([261, 120, 51], [0.035, 0.08], curve: \exp));
    bodyAmp = EnvGen.ar(Env.linen(0.005, 0.1, 0.3), doneAction: 2);
    body = SinOsc.ar(bodyFreq) * bodyAmp;
    // pop sweeps over the midrange
    popFreq = XLine.kr(750, 261, 0.02);
    popAmp = EnvGen.ar(Env.linen(0.001, 0.02, 0.001)) * 0.15;
    pop = SinOsc.ar(popFreq) * popAmp;
    // click is spectrally rich, covering the high-freq range
    // you can use Formant, FM, noise, whatever
    clickAmp = EnvGen.ar(Env.perc(0.001, 0.01)) * 0.15;
    click = LPF.ar(Formant.ar(910, 4760, 2110), 3140) * clickAmp;

    snd = body + pop + click;
    snd = snd.tanh;

    Out.ar(out, Pan2.ar(snd, pan, amp));
}).add;

SynthDef(\snare, {
    |out = 0, pan = 0, amp = 0.3|
    var pop, popAmp, popFreq;
    var noise, noiseAmp;
    var snd;

    // pop makes a click coming from very high frequencies
    // slowing down a little and stopping in mid-to-low
    popFreq = EnvGen.ar(Env([3261, 410, 160], [0.005, 0.01], curve: \exp));
    popAmp = EnvGen.ar(Env.perc(0.001, 0.11)) * 0.7;
    pop = SinOsc.ar(popFreq) * popAmp;
    // bandpass-filtered white noise
    noiseAmp = EnvGen.ar(Env.perc(0.001, 0.15), doneAction: 2);
    noise = BPF.ar(WhiteNoise.ar, 810, 1.6) * noiseAmp;

    snd = (pop + noise) * 1.3;

    Out.ar(out, Pan2.ar(snd, pan, amp));
}).add;

SynthDef(\hihat, {
    |out = 0, pan = 0, amp = 0.3|
    var click, clickAmp;
    var noise, noiseAmp;
    var snd;

    // noise -> resonance -> expodec envelope
    noiseAmp = EnvGen.ar(Env.perc(0.001, 0.3, curve: -8), doneAction: 2);
    noise = Mix(BPF.ar(ClipNoise.ar, [4010, 4151], [0.15, 0.56], [1.0, 0.6])) * 0.7 * noiseAmp;

    snd = noise;

    Out.ar(out, Pan2.ar(snd, pan, amp));
}).add;

// adapted from a post by Neil Cosgrove (other three are original)
SynthDef(\clap, {
    |out = 0, amp = 0.5, pan = 0, dur = 1|
    var env1, env2, snd, noise1, noise2;

    // noise 1 - 4 short repeats
    env1 = EnvGen.ar(
        Env.new(
            [0, 1, 0, 0.9, 0, 0.7, 0, 0.5, 0],
            [0.001, 0.009, 0, 0.008, 0, 0.01, 0, 0.03],
            [0, -3, 0, -3, 0, -3, 0, -4]
        )
    );

    noise1 = WhiteNoise.ar(env1);
    noise1 = HPF.ar(noise1, 600);
    noise1 = LPF.ar(noise1, XLine.kr(7200, 4000, 0.03));
    noise1 = BPF.ar(noise1, 1620, 3);

    // noise 2 - 1 longer single
    env2 = EnvGen.ar(Env.new([0, 1, 0], [0.02, 0.18], [0, -4]), doneAction:2);

    noise2 = WhiteNoise.ar(env2);
    noise2 = HPF.ar(noise2, 1000);
    noise2 = LPF.ar(noise2, 7600);
    noise2 = BPF.ar(noise2, 1230, 0.7, 0.7);

    snd = noise1 + noise2;
    snd = snd * 2;
    snd = snd.softclip;

    Out.ar(out, Pan2.ar(snd,pan,amp));
}).add;
)

(
var base;

base = Pbind(\amp, 0.3);

Ppar([
    Pbindf(
        base,
        \instrument, Pseq([\kick, \snare, \kick, \kick, \snare], inf),
        \dur, Pseq([4, 3, 3, 2, 4], inf)
    ),
    Pbindf(
        base,
        \instrument, Pseq([Pn(\hihat, 16), Pn(\clap, 16)], inf),
        \dur, Pseq([Rest(2), 2, Rest(2), 2], inf)
    )
]).play(TempoClock(2.3 * 4));
)



(
var reps, bars, beat;
TempoClock.default.tempo = 1.2;

bars = (
	// HH  |HH |HH |HH |
	// KD  |   |KD |   |
	// DB  |   |DB |   |
	//     |SN |   |SN |
	hihaDur1: 0.25 *Pseq([1, 1, 1, 1]),
	kickDur1: 0.25 * Pseq([1, Rest(1), 1, Rest(1)]),
	clapDur1: 0.25 * Pseq([1, Rest(1), 1, Rest(1)]),
	snarDur1: 0.25 * Pseq([Rest(1), 1, Rest(1), 1]),

	// HH  |HH |HH |HH |HH |.  |HH |.  |
	// KD  |   |KD |KD |   |KD |   |KD |
	// DB  |   |DB |   |DB |   |DB |   |
	//     |SN |   |SN |   |SN |   |SN |
	hihaDur2: 0.25 *Pseq([
		Pseq([1, 1, 1, 1]),
		Pseq([1, Rest(1), 1, Rest(1)])
	]),
	kickDur2: 0.25 * Pseq([
		Pseq([1, Rest(1), 1, 1]),
		Pseq([Rest(1), 1, Rest(1), 1]),
	]),
	clapDur2: 0.25 * Pseq([
		Pseq([1, Rest(1), 1, Rest(1)]),
		Pseq([1, Rest(1), 1, Rest(1)]),
	]),
	snarDur2: 0.25 * Pseq([
		Pseq([Rest(1), 1, Rest(1), 1]),
		Pseq([Rest(1), 1, Rest(1), 1]),
	]),

	// HH  |.  |HH |.  |HH |HH |.  |HH |HH |.  |HH |.  |HH |HH |.  |HH |
	hihaDur4: 0.25 * Pseq([
		Pseq([1, Rest(1), 1, Rest(1)]),
		Pseq([1, 1, Rest(1), 1]),
		Pseq([1, Rest(1), 1, Rest(1)]),
		Pseq([1, 1, Rest(1), 1]),
	]),
	// KD  |KD |   |KD |   |KD |KD |   |KD |   |KD |KD |   |KD |KD |   |
	kickDur4: 0.25 * Pseq([
		Pseq([1, 1, Rest(1), 1]),
		Pseq([Rest(1), 1, 1, Rest(1)]),
		Pseq([1, Rest(1), 1, 1]),
		Pseq([Rest(1), 1, 1, Rest(1)]),
	]),
	// DB  |   |DB |   |DB |   |DB |DB |   |DB |   |DB |DB |   |DB |   |
	clapDur4: 0.25 * Pseq([
		Pseq([1, Rest(1), 1, Rest(1)]),
		Pseq([1, Rest(1), 1, 1]),
		Pseq([Rest(1), 1, Rest(1), 1]),
		Pseq([1, Rest(1), 1, Rest(1)]),
	]),
	//     |SN |   |SN |SN |   |SN |   |SN |   |SN |SN |   |SN |   |SN |
	snarDur4: 0.25 * Pseq([
		Pseq([Rest(1), 1, Rest(1), 1]),
		Pseq([1, Rest(1), 1, Rest(1)]),
		Pseq([1, Rest(1), 1, 1]),
		Pseq([Rest(1), 1, Rest(1), 1]),
	]),

);
reps = 4;
beat = (
	hihaDur: Pn(Pseq([
		bars.at(\hihaDur1),
		bars.at(\hihaDur2),
		bars.at(\hihaDur4),
		bars.at(\hihaDur1),
	]), reps),
	kickDur: Pn(Pseq([
		bars.at(\kickDur1),
		bars.at(\kickDur2),
		bars.at(\kickDur4),
		bars.at(\kickDur1),
	]), reps),
	clapDur: Pn(Pseq([
		bars.at(\clapDur1),
		bars.at(\clapDur2),
		bars.at(\clapDur4),
		bars.at(\clapDur1),
	]), reps),
	snarDur: Pn(Pseq([
		bars.at(\snarDur1),
		bars.at(\snarDur2),
		bars.at(\snarDur4),
		bars.at(\snarDur1),
	]), reps),
);

Pbind(
	\instrument, \kick,
	\dur, beat.at(\kickDur),
).play(quant: 1);
Pbind(
	\instrument, \clap,
	\dur, beat.at(\clapDur),
).play(quant: 1);
Pbind(
	\instrument, \snare,
	\dur, beat.at(\snarDur),
).play(quant: 1);
Pbind(
	\instrument, \hihat,
	\dur, beat.at(\hihaDur),
).play(quant: 1);

)