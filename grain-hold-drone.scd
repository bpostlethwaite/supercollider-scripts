/*
GrainFreeze.scd
prm
SynthDef for capturing and holding incoming audio as a drone
patrickryanmcminn@gmail.com
http://www.patrickmcminn.com/
*/

// execute within the parentheses:
(
SynthDef(\prm_GrainFreeze, {
  |
  inBus = 0, outBus = 0, amp = 1,
  trigRate = 60, grainDur = 0.35, pos = 0.3, rate = 1,
  attackTime = 0.5, decayTime = 0, sustainLevel = 1, releaseTime = 2, gate = 1,
  lowPassCutoff = 7000, highPassCutoff = 100, postDistCutoff = 18000, distAmt = 1
  |

  var input, record, localBuf;
  var grainTrig, granulation, env, lpf, hpf, dist, sig;

  // Record (into a 1 second, mono buffer)
  input = In.ar(inBus, 1);
  localBuf = LocalBuf.new(SampleRate.ir * 1, 1).clear;
  record = RecordBuf.ar(input, localBuf, loop: 0);

  //// Granulate:
  // Random distribution of triggers prevents amplitude modulation artifacts
  grainTrig = Dust.ar(trigRate);
  granulation = GrainBuf.ar(1, grainTrig, grainDur, localBuf, rate, pos);

  // Filter and distort
  lpf = LPF.ar(granulation, lowPassCutoff);
  hpf = HPF.ar(lpf, highPassCutoff);
  dist = (hpf * distAmt).distort;
  dist = LPF.ar(dist, postDistCutoff);

  // Envelope -- delays start until recording has finished
  env = EnvGen.kr(Env.dadsr(1, attackTime, decayTime, sustainLevel, releaseTime), gate, amp, doneAction: 2);
  sig = dist * env;

  // Output
  sig = Out.ar(outBus, sig);
}).add;
)



//// examples:

// execute this:
a = Bus.audio;
// then this:
b = { Out.ar(a, SoundIn.ar(0)) }.play;



// sing, whistle, or play a steady held note, then execute this line of code:
c = Synth(\prm_GrainFreeze, [\inBus, a, \outBus, 0, \attackTime, 4], addAction: \addToTail);


// play at half the speed, (one octave down):
c.set(\rate, 0.5);

// set lowpass cutoff:
c.set(\lowPassCutoff, 2500);

// set high pass cutoff:
c.set(\highPassCutoff, 1000);

// reset it:
c.set(\highPassCutoff, 20);

// set distortion (CAREFUL!! Gets loud):
(
c.set(\postDistCutoff, 1500);
c.set(\distAmt, 60.dbamp);
)

// increase release time and free:
(
c.set(\releaseTime, 10);
c.set(\gate, 0);
)