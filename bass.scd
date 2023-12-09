(
SynthDef(\deepBass, {
    arg freq=50, gate=1, detune=0.2, cutoff=500, res=0.3, amp=1.0,
	att=2, decay=0.5, sustain=0.75, release=1.0, peak=1.0;

	var sinlag = {|lag, low, hi, warp=\sine|
		VarLag.kr(LFNoise0.kr(1/lag).range(low, hi), lag, warp: warp)
	};
	var dlm = 1 - detune;
	var drm = 1 + detune;

	var env = EnvGen.kr(
		Env.adsr(att, decay, sustain, release, peak, -4),
		gate, doneAction:2);

	var sig = Mix.ar([
        Pulse.ar(
			freq: sinlag.value(0.5, freq * dlm, freq * drm),
			width: sinlag.value(0.2, 0.2, 0.8),
            mul: amp,
        ),
		SinOsc.ar(
			freq: sinlag.value(0.8, freq / 2 * dlm, freq / 2 * drm),
            mul: amp/3,
        ),
        Pulse.ar(
            freq: sinlag.value(0.4, freq * 1.5 * dlm, freq * 1.5 * drm),
			width: sinlag.value(0.5, 0.2, 0.8),
            mul: amp/6,
		),
		SinOsc.ar(
			freq: sinlag.value(0.2, freq * 2 * dlm, freq * 2 * drm),
			mul: amp/9,
        ),
	]);

    // Apply a low pass filter
	sig = RLPF.ar(sig, cutoff.clip(50, 20000), res.clip(0.1, 1.0));

    // Envelope to shape the amplitude

	sig = Greyhole.ar(sig, delayTime: 0.5, damp: 0.2, size: 1.0, diff: 0.707, feedback: 0.9, modDepth: 0.1, modFreq: 2.0);

	sig = FreeVerb.ar(sig, mix: 0.33, room: 0.5, damp: 0.5, mul: 1.0, add: 0.0);

    // Final amplitude
	sig = Pan2.ar(sig * env, amp);

    Out.ar(0, sig);

}).add;
)
(
// You can play it with:
x = Synth(\deepBass, [
    \freq, 90,
    \detune, 0.05,
    \cutoff, 500,
    \res, 0.5,
    \amp, 0.5
]);
)

x.set(\freq, 50);
x.set(\res, 0.1);
x.set(\res, 0.7);
x.set(\release, 5);
x.release();
