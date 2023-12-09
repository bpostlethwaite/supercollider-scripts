s.options.memSize_(65536 * 4);
s.reboot;
(
SynthDef(\richPiano, {
    |out = 0, wet = 0.5, att= 0.01, freq = 440, amp = 0.5, gate = 1, relTime = 1|
    var env, sig, harmonics, stereoSpread;

    // Enampope to simulate piano's hammer mechanics
    env = EnvGen.kr(
		Env.perc(att, amp, amp, \welch),
		gate,
		doneAction: 2,
	);

    // Karplus-Strong algorithm for string sounds
    sig = Pluck.ar(
        in: WhiteNoise.ar(amp),
        trig: gate,
        maxdelaytime: 1.0,
        delaytime: freq.reciprocal,
        decaytime: relTime * 2,
        coef: 0.2
    );

    // Additional Harmonics
    harmonics = [2, 3, 4.7];
    sig = sig + Mix.new(harmonics.collect { |mult|
        Pluck.ar(
            in: WhiteNoise.ar(amp * 0.1),
            trig: gate,
            maxdelaytime: 1.0,
            delaytime: (freq * mult).reciprocal,
            decaytime: relTime * 2,
            coef: 0.2
        )
    });

    // Filter based on velocity
    sig = RLPF.ar(sig, freq * [1, 1.01] * (1 + amp), 0.1);

    // Stereo spread
    stereoSpread = 0.02;
	sig = Pan2.ar(sig, SinOsc.kr(0.5).range(-1 * stereoSpread, stereoSpread));

	sig = sig * env;
    // Output
    Out.ar(out, wet * sig);
	Out.ar(0, (1 - wet) * sig);
}).add;
)

(
SynthDef(\jpverb, { arg out = 0, inBus;
	var in = In.ar(inBus, 2);
	var sig = JPverb.ar(in, t60: 1.0, damp: 0.0, size: 1.0, earlyDiff: 0.707, modDepth: 0.1, modFreq: 2.0, low: 1.0, mid: 1.0, high: 1.0, lowcut: 500.0, highcut: 2000.0);
	Out.ar(out, sig);
}).add;
)

// now we create groups for effects and synths
(
~sources = Group.new;
~effects = Group.after(~sources);     // make sure it's after
~bus = Bus.audio(s, 2);         // this will be our stereo effects bus
x = Synth(\jpverb, [\inBus, ~bus], ~effects);
)
(
TempoClock.default.tempo = 90/60;
p = Pbind(
	\instrument, \simpSaw4,
	// \midinote, Pseq([
	// 	Pseq([0, 12, 24, 36], 1) +.x Pseq([48, 50, 52, 55], 1),
	// 	Pseq([36, 24, 12, 0], 1) +.x Pseq([60, 55, 52, 50], 1),
	// ]),
	\scale, Pdup(32, Pseq([Scale.major.degrees, Scale.minor.degrees])),
	\root, Pdup(32, Pseq([0, -3])),
	\degree, Pn(Pseq([0, 1, 2, 4], 4) ++ Pseq([7, 4, 2, 1], 4)),
	\octave, Pn(Pdup(4, Pseq([3, 4, 5, 6]) ++ Pseq([6, 5, 4, 3]))),
	\wet, 0.3,
    \dur, 0.25,
	\amp, Pseq([0.6, 0.5, 0.5, 0.5], inf),
	// \group, ~sources,
	// \out, ~bus,
).play;
)


(
TempoClock.default.tempo = 1;

~bass = Pbind(
    \degree, Pwhite(0, 7, inf),
    \octave, 3,    // down 2 octaves
    \dur, Pwhite(1, 4, inf),
    \legato, 1,
	\group, ~sources,
    \amp, 0.2
).collect({ |event|
    ~lastBassEvent = event;
}).play(quant: Quant(quant: 1, timingOffset: 0.1));

// shorter form for the Quant object: #[1, 0, 0.1]

~chords = Pbind(
	\instrument, \richPiano,
    \topNote, Pseries(7, Prand(#[-2, -1, 1, 2], inf), inf).fold(2, 14),
    \bassTriadNotes, Pfunc { ~lastBassEvent[\degree] } + #[0, 2, 4],
        // merge triad into topnote
        // raises triad notes to the highest octave lower than top note
        // div: is integer division, so x div: 7 * 7 means the next lower multiple of 7
    \merge, (Pkey(\topNote) - Pkey(\bassTriadNotes)) div: 7 * 7 + Pkey(\bassTriadNotes),
        // add topNote to the array if not already there
    \degree, Pfunc { |ev|
        if(ev[\merge].detect({ |item| item == ev[\topNote] }).isNil) {
            ev[\merge] ++ ev[\topNote]
        } {
            ev[\merge]
        }
    },
    \dur, Pwrand([Pseq([0.5, Pwhite(1, 3, 1), 0.5], 1), 1, 2, 3], #[1, 3, 2, 2].normalizeSum, inf),
    \amp, 0.3,
	\wet, 0.3,
	\group, ~sources,
	\out, ~bus,
).play(quant: 1);
)

~bass.stop;
~chords.stop;
