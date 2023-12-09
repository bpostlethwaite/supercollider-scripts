(
SynthDef(\kick, {
    arg freq=50, dur=1.0, amp=0.8, pitchDecay=0.3, filterFreq=600;

    // Noise burst simulating the beater impact
    var noise = WhiteNoise.ar;

    // Sine wave oscillator simulating the body resonance
    var osc = SinOsc.ar(freq * Line.kr(1, 0.5, pitchDecay));

    // Envelope for the amplitude
    var env = EnvGen.kr(Env.perc(0.01, 0.3), doneAction:2);

	var sig;

    // Filter to shape the noise
    noise = LPF.ar(noise, filterFreq);

    // Mix the noise and oscillator
    sig = (noise + osc) * env;

    // Final output
    Out.ar(0, sig * amp);
}).add;
)

// Define a drone synthesizer
(
SynthDef(\droneSynth, {
    |freq1 = 110, freq2 = 220 |

	var sig, mod1, mod2;

    // Slow modulation for some movement in the sound
    mod1 = SinOsc.kr(0.1).range(0.95, 1.05);
	mod2 = SinOsc.kr(0.05).range(0.95, 1.05);

    // Two layered oscillators with modulation
    sig = Saw.ar(freq1 * mod1) + SinOsc.ar(freq2 * mod2);


    // Apply reverb for spaciousness
    sig = FreeVerb.ar(sig, mix: 0.5, room: 0.8);

    Out.ar(0, sig!2); // Stereo output
}).add;
)

(
SynthDef(\richDrone, {
    var freq1, sig, env, mod, filterMod;

    freq1 = 110; // A1

    // Slow modulation for some movement in the sound
    mod = SinOsc.kr(0.1).range(0.95, 1.05);

    // Main sound source
    sig = Saw.ar(freq1 * mod);

    // Filters with slow modulation
    filterMod = SinOsc.kr(0.2).range(300, 1000);
    sig = RLPF.ar(sig, filterMod, 0.5);

    // Use Greyhole for a dense diffusing delay effect
    sig = Greyhole.ar(sig, delayTime: SinOsc.kr(0.2).range(1.5, 2.5), feedback: 0.9, modDepth: 0.1, modFreq: 2.0);

    // Pitch shifting
    sig = PitchShift.ar(sig, pitchRatio: SinOsc.kr(0.05).range(0.95, 1.05));

    // Delay
	sig = DelayC.ar(sig, maxdelaytime: 5, delaytime: 0.5);

    // Harmonic Layers
    sig = sig + SinOsc.ar(freq1 * 1.5 * mod);

    // Reverb
    sig = FreeVerb.ar(sig, mix: 0.5, room: 0.8);

    Out.ar(0, sig!2); // Stereo output
}).add;
)
