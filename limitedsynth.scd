(
Ndef(\limited).addSpec(\freq, [50, 500, \exp]);
Ndef(\limited).addSpec(\amp, [0, 0.8, \lin]);
Ndef(\limited).addSpec(\detune, [0.00, 0.1, \lin]);
Ndef(\limited).addSpec(\lfofreq, [0.1, 8, \exp]);
Ndef(\limited).addSpec(\rqFreq, [50, 1000, \exp]);
Ndef(\limited).addSpec(\width, [0.1, 1.0, \lin]);

Ndef(\limited, {
	var bandwidth = 50;
	var freq = \freq.kr(90, 0.1);
	var amp = \amp.kr(0.5, 0.5);
	var detune = \detune.kr(0.01, 0.5);
	var lfofreq = \lfofreq.kr(1.0, 0.5);
	var rqFreq = \rqFreq.kr(180, 0.2);
	var width = \width.kr(1.0, 0.2);

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

	var lfo = LFSaw.kr(lfofreq);
	var lfoamp = lfo.range(0.0, amp);
	var ffreq = lfo.range(rqFreq, freq);
	var rq = bandwidth / ffreq;
	sig = RLPF.ar(sig, freq: ffreq, rq: rq);
	Pan2.ar(sig, 0.0, lfoamp);
});
)

Ndef(\limited).gui


Ndef(\limited).play; // play to hardware output.
Ndef(\limited).fadeTime = 2; // fadeTime specifies crossfade
// set the source
Ndef(\limited, { SinOsc.ar([350, 351.3], 0, 0.2) });
Ndef(\limited, { Pulse.ar([350, 351.3] / 4, 0.4, 0.2) });

