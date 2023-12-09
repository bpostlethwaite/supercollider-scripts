(
x = SynthDef("dreamcrusher",
    {
        arg hz=131.81, amp=0.5;
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
            VarLag.kr(LFNoise0.kr(0.3).range(ArrayMin.kr([hz,80]),16000),1/0.3,warp:\sine)
        );

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
).play;
)

(
x = SynthDef("dreamsculptor", {
    arg hz=131.81, amp=0.2;
    var local, ampcheck, sig;

    // Primary Oscillator setup using Pulse and SinOsc instead of VarSaw
    sig = Mix.ar([
		Pulse.ar(
			freq: Lag.kr(hz * SinOsc.kr(LFNoise1.kr(0.8)).range(0.95,1.05), 1.2),
			width: SinOsc.kr(
				VarLag.kr(LFNoise1.kr(0.5), 2)).range(0.2,0.8),
			mul: amp,
        ),
		SinOsc.ar(
			freq: Lag.kr(2*hz * SinOsc.kr(LFNoise1.kr(0.8)).range(0.95,1.05), 1.2),
            mul: amp/3,
        ),
        Pulse.ar(
            freq: Lag.kr(4*hz * SinOsc.kr(LFNoise1.kr(0.8)).range(0.95,1.05), 1.2),
            width: SinOsc.kr(LFNoise1.kr(0.5)).range(0.2,0.8),
            mul: amp/6,
	)], amp);

	// spread the signal
	sig = Splay.ar(sig);

	sig = Balance2.ar(sig[0] ,sig[1], VarLag.kr(LFNoise0.kr(0.1), 10, warp: \sine).range(-0.25,0.25));

    // Setup feedback using local in/out
    ampcheck = Amplitude.kr(sig);
    sig = sig * (ampcheck > 0.02);
    local = LocalIn.ar(2);
    local = OnePole.ar(local, 0.4);
	local = OnePole.ar(local, -0.08);
	local = Rotate2.ar(local[0], local[1],  VarLag.kr(LFNoise0.kr(0.12).range(-1.0,1.0), 1/0.12, warp:\sine));
    local = DelayN.ar(local, 0.4,
        VarLag.kr(LFNoise0.kr(0.12).range(0.1,0.35), 1/0.12, warp:\sine)
    );
    local = LeakDC.ar(local);
    sig = ((local + sig) * 1.2).softclip;


	sig = LPF.ar(sig,
		VarLag.kr(LFNoise0.kr(0.3).range(ArrayMax.kr([hz,80]),8000),1/0.3,warp:\sine)
	);
	// Add some FM synthesis for extra texture
	sig = sig + FMGrain.ar(
		Impulse.kr(10),
		VarLag.kr(LFNoise2.kr(0.5)).range(0.01, 0.2),
		VarLag.kr(LFNoise2.kr(0.5)).range(hz * 0.5, hz * 1.5),
		VarLag.kr(LFNoise2.kr(0.5)).range(1, 2),
	);


    // Feedback the signal back into itself
    LocalOut.ar(sig*
        VarLag.kr(LFNoise0.kr(1/5).range(0.85,1.2), 5, warp:\sine)
    );

    // Output the final signal
    Out.ar(0, sig);
}
).play;
)



(
x = SynthDef(\dreamslag, {
    arg freq=60, amp=0.5, grainAmp = 0.1, detune = 0.05;
    var local, ampcheck, sig;
	var arr1 = [
		[0, 0],
		[1, -0.3],
		[2, -0.5],
		[3, -0.1],
		[4, 0.2],
		[5, -0.1],
		[6, -0.7],
		[7, -1.0],
		[8, -0.3],
		[9, 0.3],
		[10, 0.7],
		[11, 0.8],
		[12, 0.9],
		[13, 0.8],
		[14, 0.5],
		[15, 0.1],
		[16, -0.1],
		[17, 0.0]
	];
	var walk1 = EnvGen.kr(Env.pairs(arr1, \welch), timeScale: 4.0);
	var walk2 = EnvGen.kr(Env.pairs(arr1.reverse, \welch), timeScale: 4.0);
	//var walk1 = VarLag.kr(LFNoise0.kr(1/10), 10, warp: \sine);

	var dlm = 1 - detune;
	var drm = 1 + detune;
	var slag = {|lag, low, hi, warp=\sine|
		VarLag.kr(LFNoise0.kr(1/lag).range(low, hi), lag, warp: warp)
	};

    // Primary Oscillator setup using Pulse and SinOsc instead of VarSaw
    sig = Mix.ar([
        VarSaw.ar(
			freq: slag.value(1, freq * dlm, freq * drm),
			width: slag.value(5, 0.2, 0.8),
            mul: amp,
        ),
		SinOsc.ar(
			freq: slag.value(1.25, freq * 2 * dlm, freq * 2 * drm),
            mul: amp/3,
        ),
        Pulse.ar(
            freq: slag.value(1.25, freq * 3 * dlm, freq * 3 * drm),
			width: slag.value(2, 0.2, 0.8),
            mul: amp/6,
		),
		SinOsc.ar(
			freq: slag.value(5, freq * 4 * dlm, freq * 4 * drm),
			mul: amp/9,
        ),
	]);

	// spread the signal
	sig = Splay.ar(sig);

	// pan
	sig = Balance2.ar(sig[0] ,sig[1], walk1.range(-0.25, 0.25), amp);

    // Setup feedback using local in/out
    ampcheck = Amplitude.kr(sig);
    sig = sig * (ampcheck > 0.02);
    local = LocalIn.ar(2);
	local = OnePole.ar(local, walk1.range(0.3, 0.5));
	local = OnePole.ar(local, walk2.range(-0.1, -0.01));

	// local = Rotate2.ar(local[0], local[1], slag.value(10 , -0.6, 0.6));
	local = Rotate2.ar(local[0], local[1], walk2.range(-0.6, 0.6));
	//local = DelayN.ar(local, 0.5, slag.value(10, 0.1, 0.5));
	local = DelayN.ar(local, 0.5, walk2.abs.range(0.1, 0.5));
    local = LeakDC.ar(local);
    sig = ((local + sig) * 1.25).softclip;

	// Add some FM synthesis for extra texture
	// sig = sig + FMGrain.ar(
	// 	Impulse.kr(freq/2), 0.2, freq, freq/2,
	// 	walk2.range(1/20, 1/10),
	// grainAmp);

	//sig = LPF.ar(sig, slag.value(5, ArrayMax.kr([freq, 50]), 5000));
	sig = LPF.ar(sig, walk1.range(ArrayMax.kr([freq, 50]), 1000));

    // Apply a Comb filter for metallic resonance

    // Feedback the signal back into itself
//	LocalOut.ar(sig * walk2.range(0.5, 1.2));

	sig = LeakDC.ar(sig);
	LocalOut.ar(sig * slag.value(2, 0.5, 1.2));


    // Output the final signal
    Out.ar(0, sig);
}
);
x.metadata[\specs] = (
	freq: ControlSpec.specs[\freq].copy.default_(131.81),
	amp: ControlSpec.specs[\amp].copy.default_(0.5),
	grainAmp: ControlSpec.specs[\amp].copy.default_(0.0),
	detune: ControlSpec.new(0.0, 0.2, default: 0.05, units: "%"),
);
x.add;
// You can play it with:
x = Synth(\dreamslag, [
    \freq, 120,
    \detune, 0.05,
    \amp, 0.3,
	\grainAmp, 0.00,
]);

)
FreqScope.new(400, 200, 0, server: s);
x.set(\freq, 120);
x.set(\grainAmp, 0.15);
x.set(\res, 0.7);
x.release();


(
SynthDef(\fm_grain_test, {arg gate = 1, amp = 1;

	var func = {arg v; Impulse.ar(v)};

    Out.ar(0,
		FMGrain.ar(func.value(20), 0.2, 440, 200,
            LFNoise1.kr(1).range(1, 10),
            EnvGen.kr(
                Env([0, 1, 0], [1, 1], \sin, 1),
                gate,
                levelScale: amp,
                doneAction: 2)
        )
    )
}).add;
)

(
var td = 0.1;
{EnvGen.kr(Env.pairs([
	[0*td, 0],
	[1*td, -0.3],
	[2*td, -0.5],
	[3*td, -0.1],
	[4*td, 0.2],
	[5*td, -0.1],
	[6*td, -0.7],
	[7*td, -1.0],
	[8*td, -0.3],
	[9*td, 0.3],
	[10*td, 0.7],
	[11*td, 0.8],
	[12*td, 0.9],
	[13*td, 0.8],
	[14*td, 0.5],
	[15*td, 0.1],
	[16*td, -0.1],
	[17*td, 0.0]], \welch)
).range(1, 100)}.plot(2);
)

(
var ts = 0.1;
{EnvGen.kr(Env.pairs([
	[0, 0],
	[1, -0.3],
	[2, -0.5],
	[3, -0.1],
	[4, 0.2],
	[5, -0.1],
	[6, -0.7],
	[7, -1.0],
	[8, -0.3],
	[9, 0.3],
	[10, 0.7],
	[11, 0.8],
	[12, 0.9],
	[13, 0.8],
	[14, 0.5],
	[15, 0.1],
	[16, -0.1],
	[17, 0.0]], \welch), timeScale: ts).range(-0.6, 0.6)}.plot(2);
)

(
{
	var hz = 120;
	Pan2.ar(FMGrain.ar(
		trigger: Impulse.kr(120),
		dur: VarLag.kr(LFNoise0.kr(0.5), 2, warp: \sine).range(1/140, 1/100),
		carfreq: VarLag.kr(LFNoise0.kr(0.5), 2, warp: \sine).range(hz * 0.5, hz * 1.5),
		modfreq: 50, //VarLag.kr(LFNoise0.kr(50).range(1, 20), 1/50),
		index: 2, //VarLag.kr(LFNoise0.kr(1/10).range(1, 40), 10),
	), 0.5);
}.play
)

s.sendMsg(\s_new, \fm_grain_test, a=s.nextNodeID, 0, 1, \amp, 0.1);
s.sendMsg(\n_set, a, \gate, 0);

{VarLag.kr(LFNoise0.kr(1), 1, warp: \sine).range(2, 3)}.plot(3);
{ Ringz.ar(WhiteNoise.ar(0.005), XLine.kr(100,3000,10), 0.5) }.play

{ OnePole.ar(WhiteNoise.ar(0.5), -2) }.play