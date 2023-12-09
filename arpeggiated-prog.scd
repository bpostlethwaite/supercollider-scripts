(
var beatsPerSecond = 0.5;
var beatFreq = 1 / beatsPerSecond;
TempoClock.default.tempo = beatsPerSecond;
)
(
SynthDef(\hugeHarmonicPad, {
	arg out=0, freq=440, amp=0.5, pan=0, detuneMod=0.5, att=0.01,
	decayTime=0.3, sustainLevel=0.8, releaseTime=1.0, peakLevel=1.0,
	curve=(-4.0), bias=0.0, gate = 1, detuneRate = 2, reverb = 0.5,
	delay=0.1, lpf = 0.0;

	var sumOsc = Mix.fill(8, { |i|
		var oscFreq = freq + freq * i;
		var detuneDelta = (i*detuneMod)/100;
		var detune = Lag.kr(
			LFNoise1.kr(detuneRate).range(1 - detuneDelta, 1 + detuneDelta),
			1/detuneRate);
		SinOsc.ar(oscFreq * detune, 0, 1/(10+i))
	});

	// Filter out highest harmonics
	var filtered = LPF.ar(sumOsc, freq * (lpf + 1.0));

    // Reverb
    var reverbed = FreeVerb.ar(filtered, mix: reverb, room: 0.8);

    // Amplitude envelope
	var adsr = Env.adsr(att, decayTime, sustainLevel,
		releaseTime, peakLevel, curve, bias);
    var env = EnvGen.kr(adsr, gate: gate, doneAction: 2);
    var signal = reverbed * env * amp;

    // Stereo Spreading with random delay lines
	var left = DelayC.ar(signal, 0.5,
		LFNoise1.kr(1/detuneRate).range(0.001, (delay + 0.001)*0.4));
    var right = DelayC.ar(signal, 0.5,
		LFNoise1.kr(1/detuneRate).range(0.001, (delay + 0.001) * 0.4));

    // Stereo output
    Out.ar(out, [left, right]);
}).add;



SynthDef(\pulseRQ, {
	| freq = 80, amp = 0.5, detune = 0.01, lfofreq = 2.0, rqFreq = 600.0, width = 1.0, phase = 0, |

	var sig = Mix.fill(5, { | i |
		var freqLo = freq * (i + 1) * (1.0 - detune);
		var freqHi = freq * (i + 1) * (1.0 + detune);
		var lfo = VarLag.kr(LFNoise0.kr(1), 1, warp: \sine).range(freqLo, freqHi);
		VarSaw.ar(
			freq: lfo,
			iphase: (i/4) * 2 * pi,
			width: width,
			mul: 1 / ((i * 2) + 3);
		)
	});

	var lfo = LFSaw.kr(lfofreq, phase);
	var lfoamp = lfo.range(0.0, amp);
	var ffreq = lfo.range(rqFreq, freq);
	var bandwidth = 50;
	var rq = bandwidth / ffreq;
	sig = RLPF.ar(sig, freq: ffreq, rq: rq);
	sig = Pan2.ar(sig, 0.0, lfoamp);
	Out.ar(0, sig);
}).add;
)



(

d = (
	haunted: (
		chordProg: Pseq([
			[0, 3, 7, 12],               // Original progression
			[1, 4, 7, 13],
			[3, 6, 9],
			[6, 9, 12],
			[0, 3, 6],                   // Diminished chord for tension
			[1, 4, 8],                   // Augmented chord
			[2, 5, 8, 11],
			[3, 6, 10],                  // Another augmented chord
			[4, 7, 10],
			[5, 8, 11],
			[6, 9, 12, 14],              // Shifted tuning
			[7, 10, 14],
			[8, 11, 14],
			[0, 4, 7],                   // Key change
			[1, 4, 7, 10],
			[0, 3, 7, 12],               // Return to original progression
			[1, 4, 7, 13],
			[3, 6, 9],
			[6, 9, 12]
		], 1),
		chordSus: Pseq([
			[0.8, 0.7, 0.75, 0.85],
			[0.7, 0.6, 0.7, 0.9],
			[0.8, 0.9, 0.7],
			[0.7, 0.75, 0.85],
			[0.9, 0.8, 0.7],
			[0.7, 0.85, 0.8, 0.7],
			[0.6, 0.7, 0.7, 0.8],
			[0.75, 0.8, 0.7],
			[0.7, 0.8, 0.85],
			[0.7, 0.75, 0.8],
			[0.7, 0.8, 0.85, 0.8],
			[0.8, 0.7, 0.9],
			[0.8, 0.9, 0.8],
			[0.7, 0.8, 0.7],
			[0.7, 0.8, 0.7, 0.9],
			[0.8, 0.7, 0.75, 0.85],
			[0.7, 0.6, 0.7, 0.9],
			[0.8, 0.9, 0.7],
			[0.7, 0.75, 0.85]
		], 1),
		chordDur: Pseq([0.75, 0.5, 0.75, 0.5, 0.5,
			0.75, 0.5, 0.75, 0.5, 0.5, 0.75, 0.5, 0.5,
			0.75, 0.5, 0.75, 0.5, 0.75, 0.5], inf),
		arp: Pseq([
			Pseq([0, 3, 7, 12, 7, 3]),
			Pseq([1, 4, 7, 13, 7, 4]),
			Pseq([3, 6, 9, 6, 9, 3]),
			Pseq([6, 9, 12, 9, 6, 12]),
			Pseq([0, 3, 6, 3, 6, 0]),
			Pseq([1, 4, 8, 4, 8, 1]),
			Pseq([2, 5, 8, 11, 8, 5]),
			Pseq([3, 6, 10, 6, 3, 10]),
			Pseq([4, 7, 10, 7, 4, 10]),
			Pseq([5, 8, 11, 8, 5, 8]),
			Pseq([6, 9, 12, 14, 12, 9]),
			Pseq([7, 10, 14, 10, 7, 14]),
			Pseq([8, 11, 14, 11, 8, 11]),
			Pseq([0, 4, 7, 4, 0, 7]),
			Pseq([1, 4, 7, 10, 7, 4]),
			Pseq([0, 3, 7, 12, 7, 3]),
			Pseq([1, 4, 7, 13, 7, 4]),
			Pseq([3, 6, 9, 6, 3, 9]),
			Pseq([6, 9, 12, 9, 6, 12]),
		], 1),
	),
	classic: (
		chordProg: Pseq([
			[4, 7, 11],     // IV
			[5, 9, 12],     // V
			[6, 9, 13],     // vi
			[0, 4, 7],      // I
			[2, 5, 9],      // ii
			[5, 9, 12],     // V
			[0, 4, 7],      // I
			[1, 4, 8]       // II (augmented for a little twist)
		]),
		chordSus: Pseq([
			[0.8, 0.7, 0.75],
			[0.7, 0.75, 0.8],
			[0.8, 0.7, 0.9],
			[0.7, 0.8, 0.7],
			[0.7, 0.75, 0.8],
			[0.7, 0.8, 0.7],
			[0.8, 0.7, 0.9],
			[0.7, 0.6, 0.75],
		]),
		chordDur: Pseq([1, 1, 1, 1, 1, 1, 1, 1]),
		arp: Pseq([
			4, 7, 11, 7, 4, 11,      // Arpeggio for the IV
			5, 9, 12, 9, 5, 12,      // For the V
			6, 9, 13, 9, 6, 13,      // For the vi
			0, 4, 7, 4, 0, 7,        // For the I
			2, 5, 9, 5, 2, 9,        // For the ii
			5, 9, 12, 9, 5, 12,      // For the V again
			0, 4, 7, 4, 0, 7,        // For the I again
			1, 4, 8, 4, 1, 8,        // For the augmented II
		]),
	),
	classic2: (
	// Minor Progression
		chordProg: Pseq([
			[9, 12, 16],    // vi (A minor)
			[7, 11, 14],    // IV (F major)
			[0, 4, 7],      // I (C major)
			[5, 9, 12],     // V (G major)
		]),
		chordSus: Pseq([
			[0.9, 0.75, 0.8],
			[0.85, 0.7, 0.75],
			[0.8, 0.65, 0.7],
			[0.75, 0.6, 0.65],
		]),
		chordDur: Pseq([1, 1, 1, 1]),
		arp: Pseq([
			9, 12, 16, 12, 9, 16,  // Arpeggio for vi
			7, 11, 14, 11, 7, 14,  // Arpeggio for IV
			0, 4, 7, 4, 0, 7,      // Arpeggio for I
			5, 9, 12, 9, 5, 12,    // Arpeggio for V
		]),
	),
	classic3: (
	// Modulating Progression from C major to G major
		chordProg: Pseq([
			[0, 4, 7],      // I (C major)
			[9, 12, 16],    // vi (A minor)
			[5, 9, 12],     // V (G major) - Pivot chord
			[2, 7, 9],      // V/V (D major) - Secondary dominant
			[4, 7, 11],     // IV (G major) - New key
			[11, 14, 18],   // I (G major)
			[9, 12, 16],    // vi (E minor)
			[7, 11, 14],    // V (D major)
		]),
		chordSus: Pseq([
			[0.8, 0.7, 0.75],
			[0.85, 0.75, 0.8],
			[0.8, 0.7, 0.75],
			[0.85, 0.75, 0.8],
			[0.8, 0.7, 0.75],
			[0.85, 0.75, 0.8],
			[0.8, 0.7, 0.75],
			[0.85, 0.75, 0.8],
		]),
		chordDur: Pseq([1, 1, 1, 1, 1, 1, 1, 1]),
		arp: Pseq([
			0, 4, 7, 4, 0, 7,      // Arpeggio for I (C major)
			9, 12, 16, 12, 9, 16,  // Arpeggio for vi (A minor)
			5, 9, 12, 9, 5, 12,    // Arpeggio for V (G major)
			2, 7, 9, 7, 2, 9,      // Arpeggio for V/V (D major)
			4, 7, 11, 7, 4, 11,    // Arpeggio for IV (G major)
			11, 14, 18, 14, 11, 18,// Arpeggio for I (G major)
			9, 12, 16, 12, 9, 16,  // Arpeggio for vi (E minor)
			7, 11, 14, 11, 7, 14,  // Arpeggio for V (D major)
		]),
	),
	classicDone: (
		chordProg: Pseq([
			[5, 9, 12],     // V
			[6, 9, 13],     // vi
			[0, 4, 7],      // I
		]),
		chordSus: Pseq([
			[0.8, 0.7, 0.75],
			[0.7, 0.75, 0.8],
			[0.8, 0.7, 0.9],
		]),
		chordDur: Pseq([1, 1, 1]),
		arp: Pseq([
			5, 9, 12, 9, 5, 12,      // For the V
			6, 9, 13, 9, 6, 13,      // For the vi
			0, 4, 7, 4, 0, 7,        // For the I
		]),
	),
)
)

(

var joinTheme = { |themes|
	var nd = Dictionary.new;
	var chordProg = [];
	var chordSus = [];
	var chordDur = [];
	var arp = [];
	themes.do({ |theme|
		chordProg = chordProg.add(theme.at(\chordProg));
		chordSus = chordSus.add(theme.at(\chordSus));
		chordDur = chordDur.add(theme.at(\chordDur));
		arp = arp.add(theme.at(\arp));
	});

	nd.put(\chordProg, Pseq(chordProg));
	nd.put(\chordSus, Pseq(chordSus));
	nd.put(\chordDur, Pseq(chordDur));
	nd.put(\arp, Pseq(arp));
	nd;
};

var theme = joinTheme.value([
	d.at(\classic),
	d.at(\classic3),
	d.at(\classic2),
	d.at(\classic),
	d.at(\classicDone),
]);
Ppar([
	Pbind(
		\instrument, \hugeHarmonicPad,
		\degree, theme.at(\chordProg),
		\sustain, theme.at(\chordSus),
		\dur, theme.at(\chordDur),
		\decayTime, 0.4,
		\releaseTime, 1.5,
		\octave, 2,
		\amp, 1.0,
		\detuneMod, 0.0,
		\reverb, 0.4,
		\delay, 0.0,
		\lpf, 6,
	),
	Pbind(
		\instrument, \hugeHarmonicPad,
		\degree, theme.at(\arp),
		\dur, Pdup(6, (1/6) * theme.at(\chordDur)),
		\octave, 4,
		\decayTime, 0.2,
		\releaseTime, 1.5,
		\detuneMod, 0.0, //Pseries(0, 0.02, 96),
		\reverb, 0.3, //Pseries(0.0, 0.01, 96),
		\delay, 0.1, //Pseries(0.0, 0.01, 96),
		\amp, 0.6, //Pseries(0.5, 0.005, 96),
		\lpf, 3,
	),
	Pmono(
		\pulseRQ,
		\degree, theme.at(\chordProg).collect({ |triad| triad.choose; }),
		\octave, 2,
		\amp, 0.8,
		\lfofreq, 3,
		\phase, pi,
	),
]).play(quant: 1);
)



