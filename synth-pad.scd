(
SynthDef(\hugeHarmonicPad, {
	arg out=0, freq=440, amp=0.5, pan=0, modulate=0.5, att=0.01,
	decayTime=0.3, sustainLevel=0.8, releaseTime=1.0, peakLevel=1.0,
	curve=(-4.0), bias=0.0, gate = 1, detuneRate = 2;

	var sumOsc = Mix.fill(15, { |i|
		// ADD variable for Detune intensity
		var oscFreq = freq + freq * i;
		var detuneDelta = (i+modulate)/200;
		var detune = Lag.kr(
			LFNoise1.kr(detuneRate).range(1 - (i/200), 1 + (i/200)),
			1/detuneRate);
		SinOsc.ar(oscFreq * detune, 0, 1/(10+i))
	});

    // Filtering for modulation between sharp and deep sound
	var filtered = LPF.ar(sumOsc, freq * (modulate + 1.0));

    // Reverb
    var reverbed = FreeVerb.ar(filtered, mix: modulate, room: 0.8);

    // Amplitude envelope
	var adsr = Env.adsr(att, decayTime, sustainLevel,
		releaseTime, peakLevel, curve, bias);
    var env = EnvGen.kr(adsr, gate: gate, doneAction: 2);
    var signal = reverbed * env * amp;

    // Stereo Spreading
	var left = DelayC.ar(signal, 0.5,
		LFNoise1.kr(1/detuneRate).range(0.001, (modulate + 0.001)*0.4));
    var right = DelayC.ar(signal, 0.5,
		LFNoise1.kr(1/detuneRate).range(0.001, (modulate + 0.001) * 0.4));

    // Stereo output
    Out.ar(out, [left, right]);
}).add;
)


// Test the SynthDef:
s.boot;
Synth.new(\hugeHarmonicPad, [freq: 120, modulate: 0.5, amp: 0.9]);

