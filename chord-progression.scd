(
SynthDef(\bespokeOSC, {
    |buf, basefreq = 60, detuneMod = 1, lagtime = 3, pan = 0, amp = 1 |
	var harmonics = 7;
	var sig = Mix.fill(harmonics, {arg n;
		var freq = basefreq*(n+1);
		var detune = n * detuneMod;
		var defreq = Lag.kr(SinOsc.kr(LFNoise0.kr(1/lagtime)).range(freq - detune,freq + detune), lagtime);
		Osc.ar(buf, freq: defreq!2, phase: 0.0, mul: 1/(harmonics+(n*2)), add: 0.0);
	});
	sig = Pan2.ar(sig, pan, amp);
    Out.ar(0, sig);
}).add;
)

m = MiniLab.new;
m.initMidi;
p = MultiPlot.new.updateEnv(1, Env([-1, 1, -1, 1, -1], [1, 0, 1, 0], \lin));
b = Buffer.alloc(s, 2048);

(
m.func([4, 5, 6], [[0.0, 1.0], [0.0, 1.0], [0.0, 1.0]], { arg xi, yi, pw;
	var wt;
	var sin = Env([-1, -1, 1, -1, -1, 1, -1], [pw, 1-xi, xi, pw, 1-xi, xi], \sine).asSignal(1024);
	var lin = Env([-1, -1, 1, -1, -1, 1, -1], [pw, 1-xi, xi, pw, 1-xi, xi], \lin).asSignal(1024);
	var sig = ((1 - yi) * sin) + (lin * yi);
	{
		p.update(1, sig.flat);
	}.defer;
	w = sig.asWavetable;
});
)
b.loadCollection(w);
~oscs = Group.new;
x = Synth(\bespokeOSC, [\buf, b, \freq, 55], ~oscs);
y = Synth(\bespokeOSC, [\buf, b, \freq, 65.40639], ~oscs);
z = Synth(\bespokeOSC, [\buf, b, \freq, 82.40689], ~oscs);

l.synth(2, ~oscs, \basefreq, [60, 090]); // soften

x.free;
y.free;
z.free;
b.free;
l.freeAll;
m.freeAll;