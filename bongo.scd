(
var drumKeys = #[\Macho, \Hembra];
var drumFiles = #["high", "low"];
var strikeKeys = #[\Heel, \Toe, \MutedStrike, \Open, \Rimshot, \Slap, \Flick, \Rub];
var strikeFiles = #["heel", "toe", "muted-slap", "open", "rimshot", "slap", "flick", "rub"];
var weightKeys = [\Quiet, \Medium, \Loud];
var weightFiles = ["1", "2", "3"];

var basedir = "/home/ben/audio/bongos";
var basefilename = "bongos - ";

d = Dictionary.new;

drumKeys.do( { arg item, i;
	var dk = drumKeys[i];
	var df = drumFiles[i];
	strikeKeys.do( {arg item, i;
		var sk = strikeKeys[i];
		var sf = strikeFiles[i];
		weightKeys.do( {arg item, i;
			var buf;
			var wk = weightKeys[i];
			var wf = weightFiles[i];

			var fn = df ++ "-" ++ sf ++ "-" ++ wf ++ ".wav";
			var filepath = "/home/ben/audio/bongos/bongos - " ++ fn;
			var bufkey = dk ++ sk ++ wk;

			postln(bufkey);
			buf = Buffer.read(s, filepath);
			d.add(bufkey -> buf);
		});
	});
});

)
(
SynthDef(\playbuf, {| out = 0, bufnum = 0, amp=0.5, pos=0 |
    Out.ar(out,
        Pan2.ar(
			PlayBuf.ar(1, bufnum, BufRateScale.kr(bufnum), doneAction: 2),
			pos, amp)
    )
}).add;
)

(
var piece, joinParts, part1, part2, part3;
TempoClock.default.tempo = 90/60;

part1 = (
  left: (
    dur: Pseq([
      0.25, Rest(0.25), 0.5, Rest(0.25), 0.25, Rest(0.25),
      0.25, Rest(0.5), 0.25, Rest(0.25), 0.5, Rest(0.25),
      0.5, Rest(0.25), 0.25, Rest(0.25), 0.25, Rest(0.5),
      0.25, Rest(0.25), 0.25, Rest(0.5), 0.5, Rest(0.25),
      0.25, Rest(0.25), 0.25, Rest(0.5), 0.25, Rest(0.25),
      0.25, Rest(0.25), 0.5, Rest(0.25), 0.25, Rest(0.25),
      0.25, Rest(0.5), 0.25, Rest(0.25), 0.25, Rest(0.25),
      0.5, Rest(0.25), 0.25, Rest(0.5), 0.25, Rest(0.25),
      0.25, Rest(0.25), 0.25, Rest(0.25), 0.5, Rest(0.25),
      0.25, Rest(0.25), 0.5, Rest(0.25), 0.25, Rest(0.5),
      0.25, Rest(0.25), 0.25, Rest(0.5), 0.5, Rest(0.25),
      0.25, Rest(0.25), 0.25, Rest(0.5), 0.25, Rest(0.25),
      0.25, Rest(0.25), 0.5, Rest(0.25), 0.25, Rest(0.25)
    ]),
    bufkey: Pseq([
      \HembraHeelQuiet, \MachoToeMedium, \HembraSlapLoud,
      \MachoOpenMedium, \HembraHeelQuiet, \MachoSlapMedium,
      \HembraToeMedium, \MachoOpenQuiet, \HembraSlapMedium,
      \MachoFlickLoud, \HembraSlapMedium, \MachoRimshotMedium
    ])
  ),
  right: (
    dur: Pseq([
      0.5, Rest(0.25), 0.25, Rest(0.5),
      0.25, Rest(0.25), 0.5, Rest(0.25),
      0.25, Rest(0.25), 0.25, Rest(0.25),
      0.25, Rest(0.25), 0.5, Rest(0.5),
      0.5, Rest(0.25), 0.25, Rest(0.25),
      0.25, Rest(0.25), 0.25, Rest(0.25),
      0.25, Rest(0.5), 0.5, Rest(0.25),
      0.25, Rest(0.25), 0.25, Rest(0.5),
      0.25, Rest(0.25), 0.5, Rest(0.25),
      0.25, Rest(0.25), 0.5, Rest(0.25),
      0.25, Rest(0.25), 0.25, Rest(0.5),
      0.25, Rest(0.5), 0.25, Rest(0.25),
      0.5, Rest(0.25), 0.25, Rest(0.25),
      0.25, Rest(0.25), 0.5, Rest(0.25)
    ]),
    bufkey: Pseq([
      \MachoOpenLoud, \HembraSlapMedium, \MachoRimshotQuiet,
      \HembraToeMedium, \MachoHeelQuiet, \HembraMutedStrikeMedium,
      \MachoSlapLoud, \HembraOpenQuiet, \MachoToeMedium,
      \HembraRimshotLoud, \MachoFlickMedium, \HembraSlapQuiet
    ])
  ),
);

part2 = (
  left: (
    dur: Pseq([
      // Building the main rhythm
      0.25, Rest(0.25), 0.5, Rest(0.5), 0.25, Rest(0.25), 0.25, Rest(0.25),
      0.5, Rest(0.5), 0.25, Rest(0.25), 0.25, Rest(0.25), 0.25, Rest(0.5),
      // A little variation
      0.25, Rest(0.25), 0.25, Rest(0.25), 0.25, Rest(0.25), 0.75, Rest(0.5),
      // Repeat main rhythm
      0.25, Rest(0.25), 0.5, Rest(0.5), 0.25, Rest(0.25), 0.25, Rest(0.25),
      0.5, Rest(0.5), 0.25, Rest(0.25), 0.25, Rest(0.25), 0.25, Rest(0.5),
      // Drum 'solo' break - faster, playful rhythm
      0.125, 0.125, 0.125, Rest(0.125), 0.125, 0.125, Rest(0.125), 0.125,
      0.125, 0.125, 0.125, Rest(0.125), 0.125, 0.125, Rest(0.125), 0.125,
      // Return to main rhythm
      0.25, Rest(0.25), 0.5, Rest(0.5), 0.25, Rest(0.25), 0.25, Rest(0.25),
      0.5, Rest(0.5), 0.25, Rest(0.25), 0.25, Rest(0.25), 0.25, Rest(0.5),
    ]),
    bufkey: Pseq([
      \HembraHeelMedium, \MachoToeQuiet, \HembraOpenLoud,
      \MachoSlapMedium, \HembraToeQuiet, \MachoHeelMedium,
      // Drum 'solo' break - different strikes, more playful
      \MachoSlapLoud, \HembraOpenMedium, \MachoRimshotLoud, \HembraSlapMedium,
      \MachoFlickQuiet, \HembraFlickMedium,
    ])
  ),
  right: (
    dur: Pseq([
      // Building the main rhythm
      0.5, Rest(0.25), 0.25, Rest(0.25), 0.5, Rest(0.25), 0.25, Rest(0.5),
      // A little variation
      0.25, Rest(0.25), 0.25, Rest(0.25), 0.5, Rest(0.25), 0.25, Rest(0.5),
      // Repeat main rhythm
      0.5, Rest(0.25), 0.25, Rest(0.25), 0.5, Rest(0.25), 0.25, Rest(0.5),
      // Drum 'solo' break - faster, playful rhythm
      0.125, 0.125, 0.125, Rest(0.125), 0.125, 0.125, Rest(0.125), 0.125,
      0.125, 0.125, 0.125, Rest(0.125), 0.125, 0.125, Rest(0.125), 0.125,
      // Return to main rhythm
      0.5, Rest(0.25), 0.25, Rest(0.25), 0.5, Rest(0.25), 0.25, Rest(0.5),
    ]),
    bufkey: Pseq([
      \MachoHeelMedium, \HembraSlapLoud, \MachoOpenQuiet,
      \HembraToeMedium, \MachoRimshotQuiet, \HembraMutedStrikeMedium,
      // Drum 'solo' break - different strikes, more playful
      \HembraFlickQuiet, \MachoFlickLoud, \HembraSlapMedium, \MachoOpenMedium,
      \HembraHeelQuiet, \MachoToeMedium,
    ])
  ),
);


part3 = (
	left: (
		dur: Pseq([
			Pseq([0.5, 0.5, Rest(1), 0.5, 0.5, Rest(1), 0.5, Rest(0.5), 0.5, Rest(1), 0.5, Rest(0.5)]),
			Pseq([0.5, Rest(0.5), 0.5, Rest(1), 0.5, Rest(0.5), 0.5, Rest(1), 0.5, Rest(0.5), 0.5, Rest(1)]),  // second 4 beat bar
			Pseq([0.5, 0.5, Rest(1), 0.5, Rest(0.5), 0.5, Rest(1), 0.5, Rest(0.5), 0.5, Rest(1), 0.5]),  // third 4 beat bar
			Pseq([0.5, Rest(0.5), 0.5, Rest(1), 0.5, 0.5, Rest(1), 0.5, Rest(0.5), 0.5, Rest(1), 0.5]),  // fourth 4 beat bar
		]),
		bufkey: Pseq([
			Pseq([\MachoSlapLoud, \HembraOpenMedium, \MachoHeelMedium, \HembraOpenMedium, \MachoToeQuiet, \HembraSlapMedium, \MachoSlapQuiet]),  // first 4 beat bar
			Pseq([\MachoOpenMedium, \HembraHeelQuiet, \MachoToeQuiet,  \HembraSlapLoud, \MachoRimshotMedium, \HembraMutedStrikeQuiet]),  // second 4 beat bar
			Pseq([\MachoFlickQuiet, \HembraToeMedium, \MachoSlapLoud, \HembraSlapQuiet, \MachoOpenMedium, \HembraHeelQuiet, \MachoRimshotMedium]),  // third 4 beat bar
			Pseq([\MachoHeelMedium, \HembraSlapLoud, \MachoMutedStrikeQuiet, \HembraOpenMedium, \MachoToeQuiet, \HembraFlickQuiet, \MachoOpenLoud]),  // fourth 4 beat bar
		]),
	),
	right: (
		dur: Pseq([
			Pseq([Rest(0.5), 0.5, 0.5, Rest(1), Rest(0.5), 0.5, 0.5, Rest(1), 0.5, Rest(0.5), 0.5, Rest(1)]),  // first 4 beat bar
			Pseq([0.5, Rest(0.5), 0.5, Rest(1), 0.5, Rest(0.5), 0.5, Rest(1), Rest(0.5), 0.5, 0.5, Rest(1)]),  // second 4 beat bar
			Pseq([Rest(0.5), 0.5, 0.5, Rest(1), 0.5, Rest(0.5), 0.5, Rest(1), Rest(0.5), 0.5, 0.5, Rest(1)]),  // third 4 beat bar
			Pseq([0.5, Rest(0.5), 0.5, Rest(1), Rest(0.5), 0.5, 0.5, Rest(1), 0.5, Rest(0.5), 0.5, Rest(1)]),  // fourth 4 beat bar
		]),
		bufkey: Pseq([
			Pseq([\MachoHeelQuiet, \HembraOpenMedium, \MachoToeMedium, \HembraRimshotQuiet, \MachoSlapLoud, \HembraHeelQuiet]),  // first 4 beat bar
			Pseq([\MachoOpenLoud, \HembraToeQuiet, \MachoFlickQuiet, \HembraOpenMedium, \MachoSlapMedium, \HembraSlapQuiet]),  // second 4 beat bar
			Pseq([\MachoRimshotMedium, \HembraMutedStrikeLoud, \MachoHeelMedium, \HembraToeQuiet, \MachoOpenLoud, \HembraSlapMedium]),  // third 4 beat bar
			Pseq([\MachoMutedStrikeQuiet, \HembraOpenMedium, \MachoSlapLoud, \HembraSlapQuiet, \MachoFlickQuiet, \HembraToeMedium]),  // fourth 4 beat bar
		]),
	),
);

joinParts = { |parts|
	var nd;
	var leftdur = [];
	var leftbk = [];
	var rightdur = [];
	var rightbk = [];
	parts.do({ |part|
		leftdur = leftdur.add(part.at(\left).at(\dur));
		leftbk = leftbk.add(part.at(\left).at(\bufkey));
		rightdur = rightdur.add(part.at(\right).at(\dur));
		rightbk = rightbk.add(part.at(\right).at(\bufkey));
	});
	(
		left: (
			dur: Pseq(leftdur),
			bufkey: Pseq(leftbk),
		),
		right: (
			dur: Pseq(rightdur),
			bufkey: Pseq(leftbk),
		),
	);
};

piece = joinParts.value([
	part1,
	part3,
	part1,
	part3,
	part2,
	part3,
	part2,
	part1,
]);


p = Ppar([
	Pbind(
		\instrument, \playbuf,
		\pos, 0.2,
		\amp, 0.7,
		\dur, piece[\left][\dur],
		\bufnum, piece[\left][\bufkey].collect({ |x| d[x.asString]; }),
	),
	Pbind(
		\instrument, \playbuf,
		\pos, -0.2,
		\amp, 0.7,
		\dur, piece[\right][\dur],
		\bufnum, piece[\right][\bufkey].collect({ |x| d[x.asString]; }),
	),
], 1).play;

)

f = SoundFile.new;
f.openRead("/home/ben/audio/bongo/bongos - low-toe-3.wav");
f.inspect;



