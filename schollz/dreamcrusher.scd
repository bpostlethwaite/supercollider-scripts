(
SynthDef(\dreamcrusher, {
	| hz=131.81, amp=0.5 |

	var local, ampcheck, sig;

	// the oscillator part
	sig = Mix.ar(
		VarSaw.ar(
			freq: Lag.kr(hz * SinOsc.kr(LFNoise0.kr(1)).range(0.99,1.01),1),
			width: SinOsc.kr(LFNoise0.kr(1)).range(0.4,0.6),
			mul: amp,
		) +
		VarSaw.ar(
			freq: Lag.kr(2*hz * SinOsc.kr(LFNoise0.kr(1)).range(0.99,1.01),1),
			width: SinOsc.kr(LFNoise0.kr(1)).range(0.4,0.6),
			mul: amp/2,
		) +
		VarSaw.ar(
			freq: Lag.kr(4*hz * SinOsc.kr(LFNoise0.kr(1)).range(0.99,1.01),1),
			width: SinOsc.kr(LFNoise0.kr(1)).range(0.4,0.6),
			mul: amp/4,
		)
	);

	// spread the signal
	sig = Splay.ar(sig);

	// pan
	sig = Balance2.ar(sig[0] ,sig[1],SinOsc.kr(
		LFNoise0.kr(0.1).range(0.05,0.5)
	)*0.1);

	// feedback directly taken from the docs
	// https://depts.washington.edu/dxscdoc/Help/Classes/LocalOut.html
	ampcheck = Amplitude.kr(sig);
	sig = sig * (ampcheck > 0.02); // noise gate
	local = LocalIn.ar(2);
	local = OnePole.ar(local, 0.4);
	local = OnePole.ar(local, -0.08);
	local = Rotate2.ar(local[0], local[1],0.2);
	local = DelayN.ar(local, 0.3,
		VarLag.kr(LFNoise0.kr(0.1).range(0.15,0.3),1/0.1,warp:\sine)
	);
	local = LeakDC.ar(local);
	sig = ((local + sig) * 1.25).softclip;

	// filter with drunken walk modulation
	sig = LPF.ar(sig,
		VarLag.kr(LFNoise0.kr(0.3).range(ArrayMax([hz,80]),16000),1/0.3,warp:\sine)
	);

	// of filter with MooglLadder
	/*		sig = MoogLadder.ar(sig,
	VarLag.kr(LFNoise0.kr(0.3).range(80,2000), 1/0.3, warp:\sine),
	VarLag.kr(LFNoise0.kr(5).range(0,1.0), 1/5, warp:\sine)
	);*/

	// sig = Greyhole.ar(sig,
	// 	VarLag.kr(LFNoise0.kr(5).range(0.3,5.0), 1.3, warp:\sine),
	// 	VarLag.kr(LFNoise0.kr(0.3).range(0,0.8), 0.7, warp:\sine),
	// 	VarLag.kr(LFNoise0.kr(5).range(0,1.0), 0.2, warp:\sine)
	// );

	// feedback
	LocalOut.ar(sig*
		VarLag.kr(LFNoise0.kr(2).range(0.9,1.2),1/2,warp:\sine)
	);

	// panning
	sig = Balance2.ar(sig[0] * 0.2,sig[1]*0.2,SinOsc.kr(
		LFNoise0.kr(0.1).range(0.05,0.2)
	)*0.1)*amp;

	// send it out
	Out.ar(0,sig);
}
).add;
