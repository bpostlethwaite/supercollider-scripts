MIDIClient.init;
MIDIIn.connectAll;
MIDIClient.disposeClient;
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

// Play the kick drum
Synth(\kick);


(
SynthDef(\simpleSynth, {
    arg freq=440, amp=0.5;
    var env, sig;

    // Simple envelope and sine oscillator
    env = EnvGen.kr(Env.perc(0.01, 0.5), gate:1, doneAction:2);
	sig = SinOsc.ar([freq, freq + 2]) * env;

    Out.ar(0, sig * amp);
}).add;
)

// MIDI listener
(
MIDIdef.noteOn(\myMIDIListener, { |vel, note, chan|
    // Convert MIDI note number to frequency
    var frequency = note.midicps;
    Synth(\simpleSynth, [freq: frequency, amp: vel/127]);
});
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

// Start the drone
d = Synth(\droneSynth);
l = MiniLab.new;
l.initMidi;

l.knob(3, d, \freq2, [200, 240]);

// After enjoying the drone, release it
d.free;
l.freeAll;
l.destroy;
(
m =  #[112, 74, 71, 76, 77, 93, 73, 75,
	   114, 18, 19, 16, 17, 91, 79, 72];
c = MIDIFunc.cc({arg ccval, num, chan, src;
			var val = ccval / 127.0;
			val.postln;
}, m[2-1]);
)

// Arturia CC Knob Numbers

c.free;
