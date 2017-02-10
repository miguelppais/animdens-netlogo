;AnimDens Model
;Original model implemented in R by Christine Ward-Paige et al.
;Adapted and implemented in NetLogo by Miguel Pessanha Pais

;FOR MORE INFORMATION, LOOK IN THE INFO TAB


;Global variables not represented in the main screen

globals[
  actual.area
  trans.viewangle
  stat.viewangle
  rov.viewangle
  transect.mean.speed
  roving.mean.speed
  transect.area
  stationary.area
]

;Agent types

breed [animals animal]

breed [transsurveyors transsurveyor] ;belt transect surveyor

breed [statsurveyors statsurveyor] ;stationary point count surveyor

breed [rovsurveyors rovsurveyor] ;roving surveyor     ; roving surveyors can't calculate densities accurately, yet they can estimate speceis richness and frequency of occurence.

;Agent variables

animals-own [
  speed
  species
]

transsurveyors-own [
  counted.animals
  speed
  memory
  t.bias
]


statsurveyors-own [
  counted.animals
  memory
  s.bias
]

rovsurveyors-own [
  counted.animals
  speed
  memory
]

;Setup and go procedures


to setup
  ca
  stop-inspecting-dead-agents                           ; clears surveyor detail windows from previous simulation runs
  resize-world 0 (area.width - 1) 0 (area.length - 1)
  set-patch-size (100 / area.length) * 10
  ask patches with [pycor mod 2 = 0 and pxcor mod 2 = 0] [set pcolor environment.color]   ; create background grid
  ask patches with [pycor mod 2 = 1 and pxcor mod 2 = 1] [set pcolor environment.color]
  ask patches with [pcolor = black] [set pcolor environment.color + 1]
  set actual.area world-height * world-width
  set trans.viewangle 180
  set stat.viewangle 160
  set rov.viewangle 160
  set transect.mean.speed (transect.speed / 60)  ; these 4 lines just convert interface speeds (in m/min) to m/s
  set roving.mean.speed (roving.speed / 60)

  ; on the original model, the final part of the sampled area of the transect is assumed to be a rectangle (transect.width x visibility.length)

  set transect.area transect.width * (transect.mean.speed * survey.time) + transect.width * visibility.length
  set stationary.area pi * stationary.radius ^ 2

; if animal density is set to some number, then use that to calculate the number of animals to deploy. Otherwise, just use the numb.animals.

  ifelse animal.density != 0 [set numb.animals ceiling actual.area * animal.density] [set animal.density numb.animals / actual.area]

  create-animals numb.animals [
   setxy random-xcor random-ycor
   set color animal.color
   set shape animal.shape
   set size 1
   set species "Sp1"                                          ; There is only one species, but this is what surveyors register and count
   set speed animal.mean.speed
  ]

if transect? [                                         ;transect surveyor setup
  create-transsurveyors 1 [
 set heading 0
 set shape surveyor.shape
 set color blue
 set size 2
 setxy (world-width / 2) (world-height / 2)
 if show.paths? [pen-down]                                                           ;this shows the path of the surveyor
 set speed transect.mean.speed
 set counted.animals [] ; sets counted.animals as an empty list
]
]

if stationary? [                                      ;stationary setup
  create-statsurveyors 1 [
 set heading 0
 set shape surveyor.shape
 set color red
 set size 2
 setxy (world-width / 2) (world-height / 2)
 set counted.animals [] ; sets counted.animals as an empty list
]
]

if roving? [                                          ;roving setup
  create-rovsurveyors 1 [
 set heading 0
 set shape surveyor.shape
 set color green
 set size 2
 setxy (world-width / 2) (world-height / 2)
 if show.paths? [pen-down]                                                           ;this shows the path of the surveyor
 set speed roving.mean.speed
 set counted.animals [] ; sets counted.animals as an empty list
]
]
 ask transsurveyors [                                           ; empty the memory of all surveyors
      set memory []
      ]
 ask statsurveyors [
      set memory []
      ]
 ask rovsurveyors [
      set memory []
    ]
reset-ticks
if show.surveyor.detail.windows? [
  if any? transsurveyors [inspect one-of transsurveyors]         ;here I had to use "if any?" because inspect will return an error if it finds nobody
  if any? statsurveyors [inspect one-of statsurveyors]
  if any? rovsurveyors [inspect one-of rovsurveyors]
]
end ;of setup procedure


to go
  tick                                      ; time starts at 1 seconds (not 0)
  if ticks > survey.time [
    do.outputs
    stop]                                   ; end the simulation run when survey.time is reached, but include the last tick (if survey.time is 300, stop running at 301)
  if stationary.radius > visibility.length [
   output-print "ERROR: stationary.radius is set to a value greater than visibility.length"              ; if the stationary radius is higher than visibility, stop and output an error description
   output-print "The surveyor will not commit to sampling an area that it will not be able to see"
   output-print "Stopping simulation"
   stop
  ]
  ask transsurveyors [                                ; move the surveyors
   do.tsurveyor.movement
  ]
  ask statsurveyors [
   do.stsurveyor.movement
  ]
  ask rovsurveyors [
    do.rsurveyor.movement
  ]
  ask animals [                                    ; move the animals
    do.animal.movement
  ]
  ifelse count.time.step = 1 [                    ; if count.time.step is 1, ask surveyors to count animals every second
    ask transsurveyors [
     t.count.animals
   ]
    ask statsurveyors [
     s.count.animals
   ]
    ask rovsurveyors [
     r.count.animals
   ]] [                                          ; if count.time.step is not 1 (meaning it is 2), only ask every 2 seconds
   if ticks mod 2 = 0 [
    ask transsurveyors [
     t.count.animals
   ]
    ask statsurveyors [
     s.count.animals
   ]
    ask rovsurveyors [
     r.count.animals
   ]
     ]
   ]
end  ; of go procedure



;Observer procedures

to do.outputs
  ask transsurveyors [
    let real.count length counted.animals
    let expected.count animal.density * transect.area
    set t.bias (real.count - expected.count) / expected.count
    output-type "Transect surveyor bias was " output-print precision t.bias 2           ; outputs bias with 2 decimal places
  ]

 ask statsurveyors [
    let real.count length counted.animals
    let expected.count animal.density * stationary.area
    set s.bias (real.count - expected.count) / expected.count
    output-type "Stationary surveyor bias was " output-print precision s.bias 2
 ]

 ask rovsurveyors [
    let real.count length counted.animals
    output-type "Roving surveyor swam " output-type survey.time * roving.mean.speed output-type "m and counted " output-type real.count output-print " animals"                     ; the roving surveyor only tells how many animals it counted
 ]
end

to calculate.bias
ifelse choose.method = "transect" [
ifelse any? transsurveyors [
output-print "The real value using the transect method is"
output-print precision (observed.value / transect.factor.value) 3]
[output-print "You need to re-run the model with this method enabled"
  stop
]
] [
ifelse any? statsurveyors [
output-print "The real value using the stationary method is"
output-print precision (observed.value / stationary.factor.value) 3
] [
output-print "You need to re-run the model with this method enabled"
stop
]]
end



;animal PROCEDURES


;animal movement

to do.animal.movement
  set heading heading + random-float-between (- animal.dir.angle) animal.dir.angle
  fd speed ; each step is a second, so the speed is basically the distance
end




;SURVEYOR PROCEDURES


;Transect surveyor procedures

to do.tsurveyor.movement
  fd speed ; each step is a second, so the speed is basically the distance
end

to t.count.animals
  let myxcor xcor
  let seen.animals animals in-cone visibility.length trans.viewangle
  let eligible.animals seen.animals with [(xcor > myxcor - (transect.width / 2)) and (xcor < myxcor + (transect.width / 2))]  ; this only works for transects heading north, of course
  let surveyor.memory memory
  let new.animals eligible.animals with [not member? who surveyor.memory] ; only animals that were not previously counted are counted
  if any? new.animals [
    let new.records ([species] of new.animals)
    set counted.animals sentence counted.animals new.records
    set memory sentence memory [who] of new.animals
  ]
end


;Stationary surveyor procedures

to do.stsurveyor.movement
  set heading heading + stationary.turning.angle           ; each second the surveyor rotates "stationary.turning.angle" degrees clockwise

end

to s.count.animals
  let eligible.animals animals in-cone stationary.radius stat.viewangle
  let surveyor.memory memory
  let new.animals eligible.animals with [not member? who surveyor.memory] ;only animals that were not previously counted are counted
  if any? new.animals [
    let new.records ([species] of new.animals)
    set counted.animals sentence counted.animals new.records
    set memory sentence memory [who] of new.animals
  ]
end

;Roving surveyor procedures

to do.rsurveyor.movement
  if ticks mod 2 = 0 [set heading heading + random-float-between (- roving.turning.angle) roving.turning.angle]         ;turn every 2 seconds
  fd speed ; each step is a second, so the speed is basically the distance
end

to r.count.animals
  let eligible.animals animals in-cone visibility.length stat.viewangle
  let surveyor.memory memory
  let new.animals eligible.animals with [not member? who surveyor.memory] ; only animals that were not previously counted are counted
  if any? new.animals [
    let new.records ([species] of new.animals)
    set counted.animals sentence counted.animals new.records
    ; ask new.animals [set color red wait 1 set color gray]   ;for troubleshooting
    set memory sentence memory [who] of new.animals
  ]
    end

;reporters

to-report random-float-between [a b]
  report random-float (b - a + 1) + a
end

to-report t.bias-result        ; these reporters are outputs for BehaviourSpace experiments
  report [t.bias] of one-of transsurveyors  ; one-of makes it output a single number instead of a list with one value (a list would be [34] instead of 34)
end

to-report s.bias-result
  report [s.bias] of one-of statsurveyors
end

to-report stationary.factor.value
  report s.bias-result + 1
end

to-report transect.factor.value
  report t.bias-result + 1
end
@#$#@#$#@
GRAPHICS-WINDOW
580
30
1588
1039
-1
-1
10.0
1
10
1
1
1
0
1
1
1
0
99
0
99
1
1
1
seconds
1.0

BUTTON
250
30
355
80
Setup
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
250
80
355
130
Go
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
0

BUTTON
250
130
355
180
Go once
go
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
0

MONITOR
250
200
380
245
Total area (sq. meters)
actual.area
0
1
11

SLIDER
10
360
235
393
transect.speed
transect.speed
1
10
4.0
1
1
m/min
HORIZONTAL

TEXTBOX
10
345
160
363
Transect diver movement
11
0.0
1

TEXTBOX
10
450
160
468
Stationary diver movement
11
0.0
1

SLIDER
10
465
235
498
stationary.turning.angle
stationary.turning.angle
0
90
4.0
1
1
degrees / sec
HORIZONTAL

TEXTBOX
255
420
405
438
Animal movement
11
0.0
1

CHOOSER
10
395
235
440
transect.width
transect.width
1 2 4 5 8 10 20
2

SLIDER
10
200
235
233
visibility.length
visibility.length
5
40
13.0
1
1
m
HORIZONTAL

SLIDER
10
500
235
533
stationary.radius
stationary.radius
1
20
7.5
0.5
1
m
HORIZONTAL

SLIDER
10
235
235
268
survey.time
survey.time
60
3600
300.0
10
1
seconds
HORIZONTAL

INPUTBOX
335
355
413
415
animal.density
0.1
1
0
Number

INPUTBOX
250
355
329
415
numb.animals
1000.0
1
0
Number

TEXTBOX
420
360
554
394
If this is >0, it has priority over numb.animals
11
15.0
1

TEXTBOX
420
390
570
408
animals / m2
11
0.0
1

TEXTBOX
34
418
60
437
m
11
0.0
1

OUTPUT
255
815
555
905
11

SLIDER
10
555
235
588
roving.speed
roving.speed
1
7
4.0
1
1
m/min
HORIZONTAL

TEXTBOX
10
540
160
558
Roving diver movement
11
0.0
1

SLIDER
10
590
235
623
roving.turning.angle
roving.turning.angle
0
45
4.0
1
1
º / 2 secs
HORIZONTAL

SWITCH
10
30
165
63
transect?
transect?
0
1
-1000

SWITCH
10
65
165
98
stationary?
stationary?
0
1
-1000

SWITCH
10
100
165
133
roving?
roving?
1
1
-1000

TEXTBOX
10
10
160
28
Select active sampling methods
11
0.0
1

SWITCH
10
690
235
723
show.paths?
show.paths?
0
1
-1000

SWITCH
10
655
235
688
show.surveyor.detail.windows?
show.surveyor.detail.windows?
1
1
-1000

TEXTBOX
15
640
245
666
DISPLAY OPTIONS_____________________
11
0.0
1

BUTTON
365
130
565
180
Set default parameter values
set transect.speed 4\nset transect.width 4\nset stationary.turning.angle 4\nset stationary.radius 7.5\nset transect? true\nset stationary? true\nset roving? false\nset roving.speed 4\nset roving.turning.angle 4\nset animal.mean.speed 1\nset animal.dir.angle 45\nset animal.density 0.1\nset visibility.length 13\nset survey.time 300\nset count.time.step 2\nset show.surveyor.detail.windows? false\nset show.paths? true\nset animal.shape \"fish\"\nset animal.color 9\nset environment.color 102\nset surveyor.shape \"person\"
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

MONITOR
410
655
550
700
Transect factor value
transect.factor.value
2
1
11

MONITOR
410
700
550
745
Stationary factor value
stationary.factor.value
2
1
11

TEXTBOX
255
520
450
556
BIAS CORRECTION CALCULATOR (use after model run)
13
0.0
1

BUTTON
255
750
550
786
4. CALCULATE
calculate.bias
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
0

INPUTBOX
410
550
550
610
observed.value
10.0
1
0
Number

TEXTBOX
260
565
410
593
1. Input the real count / density from the field survey:
11
15.0
1

CHOOSER
410
610
550
655
choose.method
choose.method
"transect" "stationary"
0

BUTTON
255
905
555
945
Clear output
clear-output
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
170
30
236
63
Follow
if any? transsurveyors [follow one-of transsurveyors]
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
170
65
236
98
Follow
if any? statsurveyors [follow one-of statsurveyors]
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
170
100
236
133
Follow
if any? rovsurveyors [follow one-of rovsurveyors]
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
10
135
235
168
Stop following divers
reset-perspective
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

TEXTBOX
370
40
570
82
1. Press setup to populate the world and feed the parameters into the model
11
15.0
1

TEXTBOX
375
90
570
118
2. Press Go to run the model until \"survey.time\" is reached
11
15.0
1

SLIDER
10
270
235
303
count.time.step
count.time.step
1
2
2.0
1
1
seconds
HORIZONTAL

TEXTBOX
10
305
225
335
Divers count sharks every 2 seconds (original model) or every second.
11
15.0
1

TEXTBOX
10
180
245
206
SAMPLING PARAMETERS___________
11
0.0
1

TEXTBOX
255
330
575
356
ANIMAL POPULATION PARAMETERS_____________________
11
0.0
1

TEXTBOX
260
610
410
651
2. Choose a sampling method (activate it in the model run as well)
11
15.0
1

TEXTBOX
260
675
410
716
3. Run the model to calculate the factor value for the selected method.
11
15.0
1

TEXTBOX
295
790
555
808
Results appear in the output box below.
13
15.0
1

CHOOSER
10
790
235
835
animal.shape
animal.shape
"sheep" "shark" "fish" "bird" "wolf" "cow" "circle"
2

INPUTBOX
10
725
235
785
animal.color
9.0
1
0
Color

CHOOSER
10
840
235
885
surveyor.shape
surveyor.shape
"person" "diver" "arrow"
0

SLIDER
390
220
565
253
area.length
area.length
0
150
100.0
1
1
m
HORIZONTAL

SLIDER
390
185
565
218
area.width
area.width
0
150
100.0
1
1
m
HORIZONTAL

SLIDER
250
440
460
473
animal.mean.speed
animal.mean.speed
0
10
1.0
0.5
1
m/s
HORIZONTAL

SLIDER
250
475
460
508
animal.dir.angle
animal.dir.angle
0
180
45.0
1
1
deg.
HORIZONTAL

TEXTBOX
470
465
560
515
animal turns between minus and plus this angle
11
15.0
1

INPUTBOX
250
255
565
315
environment.color
102.0
1
0
Color

@#$#@#$#@
## WHAT IS IT?

AnimDens NetLogo 2.0

This is a model that simulates surveyors counting aninmals while deploying belt-transect, stationary-point-count and roving (random path) techniques. The model demonstrates how non-instantaneous sampling techniques produce bias by overestimating the number of counted animals, when they move relative to the surveyor.

The model intends to reflect what happens with many animal censuses (underwater visual census of fish, aerial surveys, bird transects, etc.).

The model can be used to demonstrate that bias increases as the speed of the animals relative to the observer increases.

Using the provided bias calculator, it is possible to use the output of the model to apply bias correction to field data.

## HOW IT WORKS

The model assumes an area that is featureless and flat, with a default size of 200x200 cells each with an area of 1 square meter. The origin of the coordinate system is on the bottom left corner.

For each simulation, the surveyors start in the middle and face north. aninmals and transect surveyors move every second, but the time step for counting can be set to 2 seconds for shorter computing times (set by default on the original model, but note that some aninmals may be missed, particularly if they are very fast).

At each counting time step, surveyors count the number of aninmals they can see based on the direction the surveyor is facing, the visibility distance and angle. Viewing angles are fixed and cannot be changed on the interface. They are set to 160º for the stationary and roving surveyors and 180º for the transect surveyor.

On the belt-transect method, only animals within the transect width are counted, while on the stationary-point-count method, only animals within a pre-determined radius are counted.

Transect surveyor moves in a fixed direction at a constant speed (default is 4 m/minute).

Stationary surveyor rotates a given number of degrees clockwise every second (default is 4).

Aninmals move at a speed specified by the user, and travel in a direction that is restricted by a turning angle based on the previous direction.

Roving surveyors move similarly to aninmals and have their own speed and turning angle parameters. Turning happens every 2 seconds.

Aninmals and surveyors that reach the boundaries of the area wrap around to the opposite side, to keep the density constant (on the original model they can leave the area, but that doesn't seem to have significant effects on the output, if the area is large enough.

Surveyors keep a memory of every individual aninmal counted and do not recount.

## HOW TO USE IT

The model runs in real time by default, which is slow (1 second in the model equals 1 second in real life). In order to speed up model runs, increase the speed in the slider or disable update view (at the top).

The "setup" button feeds all parameter values into the model, places the selected surveyors and spreads all the aninmals across the area.

The "go" button runs the model for the time specified in survey.time (default is 300 seconds) and then stops. The model can be stopped or paused at any time by pressing the go button while it is running. The "go once" button avances the model run by 1 second each time.

"transect.width" sets the width of the belt transect that is sampled as the surveyor swims in the center (half of the width to each side of the surveyor).

To set the initial number of aninmals, introduce the total number of aninmals directly under "numb.aninmals" on the interface. Alternatively (and preferably), you can set the real density needed under "aninmal.density" and the model will place the right number of aninmals for the total area. If aninmal.density is set to a value greater than 0 when the model starts, it has priority over "numb.aninmals".

Select the sampling methods that will be in the model run by turning their swiches on and off on the interface. Please note that the roving surveyor will not calculate densities and thus will not estimate bias. If you want to see the details of every surveyor in a floating window during the run, switch on "show.surveyor.detail.windows?".

If you want the transect and roving surveyors to draw a path as they move, switch on "show.paths?".

Stationary.radius must be set to a value lower than visibility.length.

In the end of each run, each surveyor reports its relative bias, calculated as:

(real count - expected count) / expected count

where "expected count" is basically the aninmal density in the model multiplied by the total sampled area.

For the stationary surveyor:

sampled area = pi * stationary.radius^2

For the transect surveyor:

sampled area = survey.time * (transect.surveyor.speed / 60) * transect.width + visibility length * transect.width

Notice that the final part of the transect is approximated to a rectangle of length equal to the visibility length, instead of taking into account the arc produced by the cone of vision. This was done in the original model and, with relatively large visibility lengths, does not seem to have much impact on the final result.

The model will also output the conversion factor value for each method (transect and stationary). The real count (in the field) divided by this factor value should provide an estimate that is corrected to account for bias (given that all parameters are realistically set).

## THINGS TO NOTICE

If "view updates" is enabled and speed is set to "normal", the model will run in real time (every second in the model will run in one second).

To understand the source of the bias, compare a model run with aninmal.mean.speed set to 0 m/s (stationary aninmals) and another with aninmal.mean.speed set to 1 m/s. Keep everything else default.

In the first case (stationary aninmals), the sampling method will be equivalent to taking a snapshot of the whole sampling area. The aninmals will stand still and the surveyor will count every aninmal in the sampling area, not repeating any aninmal. This will produce little to no bias in the estimates.

In the case where aninmals move 1 meter every second (while the surveyor is moving 4 meters every minute), there will be new aninmals coming into the sampling area that were not there in the beginning. These aninmals will all be counted as they pass in front of the surveyor, increasing the number of counted aninmals, while the real number of aninmals in the beginning was much lower. This produces the bias.

If the speed of the aninmals is even higher, there are more aninmals coming into the field of view of the surveyor and the bias will be even higher.

## THINGS TO TRY

- Switch on just the transect surveyor and see how increasing aninmal speeds increases bias. Why does this happen?

- Do the same for the stationary surveyor. The results are similar, why?

- With stationary aninmals (speed 0) and moving surveyors, bias is almost zero, but what about stationary surveyors with moving aninmals? Place a stationary surveyor with stationary.turning.angle set to 0 and aninmals with speed > 0 and see the results.

- Run a model in real time (normal speed and "view updates" checked) with the default parameters. While it is running, press the follow button in front of the transect surveyor switch to focus the view on that surveyor. Now head to the top right corner of the world window and click "3D" to go to the 3D view. Observing the surveyor from this perspective as it counts aninmals is a great way of understanding the bias in non-instantaneous sampling of moving animals.


## USING THE BIAS CALCULATOR

The model can be used as a tool to get better estimates from field surveys using the bias calculator at the bottom.

To make corrections to observed values (values observed in the field by non-instantaneous surveys):

1. Decide on targeted aninmal species and select an appropriate speed and turning angle for that species.
2. Select most appropriate sampling values (e.g. transect width, swim speed, survey time, etc.) Note: for visibility, select the distance you would be sure to detect the targeted aninmal.
3. Run the model with the selected parameters, making sure that your sampling method of choice is turned on in the switches.
4. After the survey time finishes the model stops and the conversion factor is calculated.
5. On the calculator, go to the "observed.value" box and input the number of aninmals from that species you counted in the field
6. Select the appropriate method on the calculator (transect or stationary)
7. Press calculate. The result is the "real" count, corrected for bias.
8. Repeat for other species.

## NOTES ON THE ADAPTATION TO NETLOGO

On the original model, the aninmals could leave the area and come back (or leave permanently). Here the world is set to wrap around the edges. For an area that is large enough, this does not seem to affect the final results. In order to reflect what was made in the original model in R, one can set a buffer area around where no aninmals are placed. If for some reason we want aninmals to leave and never come back, we can just remove them when they reach the edges.

The aninmals in NetLogo have a visual representation, unlike in the original R model, where they were just points. However, in the counting procedure only the coordinates of the aninmals are checked to see if they are counted, so their size is basically ignored and does not influence results.

## RELATED MODELS

The original AnimDens model was implemented in R by Christine Ward-Paige, Joanna Mills Flemming and Heike K. Lotze. The code can be downloaded at:

http://journals.plos.org/plosone/article/asset?unique&id=info:doi/10.1371/journal.pone.0011722.s001

## CREDITS AND REFERENCES

Original model by Christine Ward-Paige (2009)

Implemented in NetLogo by Miguel Pessanha Pais (2015)

For suggestions/bug reports, please e-mail Miguel P. Pais: mppais AT fc.ul.pt

If you use this model, please cite the original publication:

Ward-Paige, C.A., Flemming, J.M., Lotze, H.K., 2010. Overestimating Fish Counts by Non-Instantaneous Visual Censuses: Consequences for Population and Community Descriptions. PLoS ONE 5(7): e11722. doi:10.1371/journal.pone.0011722

URL: http://journals.plos.org/plosone/article?id=10.1371/journal.pone.0011722

Another publication that uses a roving diver:

Ward-Paige, C.A., Lotze, H.K., 2011. Assessing the Value of Recreational surveyors for Censusing Elasmobranchs. PLoS ONE 6(10): e25609. doi:10.1371/journal.pone.0025609

URL: http://journals.plos.org/plosone/article?id=10.1371/journal.pone.0025609

In order to cite the NetLogo implementation:

Pais, M.P., Ward-Paige, C.A. (2015). AnimDens NetLogo model. http://modelingcommons.org/browse/one_model/4408

In order to cite the NetLogo software:

Wilensky, U. (1999). NetLogo. http://ccl.northwestern.edu/netlogo/. Center for Connected Learning and Computer-Based Modeling, Northwestern Institute on Complex Systems, Northwestern University, Evanston, IL.

## COPYRIGHT AND LICENSE

Copyright 2015 Miguel Pessanha Pais and Christine Ward-Paige.

![CC BY-NC-SA 4.0](http://ccl.northwestern.edu/images/creativecommons/byncsa.png)

This work is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 4.0 License.  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-sa/4.0/ or send a letter to Creative Commons, 559 Nathan Abbott Way, Stanford, California 94305, USA.
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

bird
true
0
Polygon -7500403 true true 180 0 210 45 210 75 180 105 180 150 165 240 180 285 165 285 150 300 150 240 135 195 105 255 105 210 90 150 105 90 120 60 165 45
Circle -16777216 true false 188 38 14

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
true
0
Polygon -7500403 true true 193 100 249 103 249 121 196 123 187 134 189 160 191 207 179 222 211 228 209 251 181 252 149 263 120 275 89 275 72 255 84 197 75 121 76 102 64 48 81 28 103 7 121 15 121 45 118 58 167 76
Polygon -7500403 true true 210 227 251 214 249 238 208 252
Polygon -7500403 true true 114 275 195 284 204 291 213 277 200 275 123 261

cylinder
false
0
Circle -7500403 true true 0 0 300

diver
true
0
Polygon -7500403 true true 105 90 120 180 120 270 105 300 135 300 150 210 165 300 195 300 180 270 180 180 195 90
Rectangle -7500403 true true 135 75 165 90
Polygon -7500403 true true 180 120 195 30 210 45 210 105
Polygon -7500403 true true 120 120 105 30 90 45 90 105
Rectangle -1184463 true false 135 90 165 195
Circle -16777216 true false 120 30 60

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
true
0
Polygon -1 true false 131 256 87 279 86 285 120 300 150 285 180 300 214 287 212 280 166 255
Polygon -1 true false 195 165 235 181 218 205 210 224 204 254 165 240
Polygon -1 true false 45 225 77 217 103 229 114 214 78 134 60 165
Polygon -7500403 true true 136 270 77 149 81 74 119 20 146 8 160 8 170 13 195 30 210 105 212 149 166 270
Circle -16777216 true false 106 55 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
true
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

shark
true
0
Polygon -7500403 true true 153 17 149 12 146 29 145 -1 138 0 119 53 107 110 117 196 133 246 134 261 99 290 112 291 142 281 175 291 185 290 158 260 154 231 164 236 161 220 156 214 160 168 164 91
Polygon -7500403 true true 161 101 166 148 164 163 154 131
Polygon -7500403 true true 108 112 83 128 74 140 76 144 97 141 112 147
Circle -16777216 true false 129 32 12
Line -16777216 false 134 78 150 78
Line -16777216 false 134 83 150 83
Line -16777216 false 134 88 150 88
Polygon -7500403 true true 125 222 118 238 130 237
Polygon -7500403 true true 157 179 161 195 156 199 152 194

sheep
true
15
Circle -1 true true 65 9 88
Circle -1 true true 65 68 162
Circle -1 true true 105 30 120
Polygon -7500403 true false 120 82 165 60 165 45 120 22
Circle -7500403 true false 72 19 67
Rectangle -1 true true 223 121 298 136
Polygon -1 true true 285 255 285 270 240 270 195 285 210 255
Circle -1 true true 83 147 150
Rectangle -1 true true 221 220 296 235
Polygon -1 true true 285 105 285 90 240 90 210 60 210 105
Polygon -7500403 true false 85 24 105 15 99 -2 83 6
Polygon -7500403 true false 85 81 105 90 99 107 83 99

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
true
0
Polygon -16777216 true false 133 47 131 55 133 55
Polygon -7500403 true true 194 298 197 287 191 270 193 262 205 262 226 280 257 280 265 273 266 262 260 260 253 269 230 269 206 240 198 232 209 225 228 234 243 235 261 218 268 216 267 200 261 197 239 223 231 221 207 200 196 202 201 181 202 157 195 140 210 134 213 128 238 127 251 133 248 140 265 146 264 131 247 122 240 114 260 102 271 100 271 83 262 81 258 93 230 105 198 108 184 90 164 73 144 58 145 41 151 16 141 23 140 7 134 1 127 3 119 27 105 30
Polygon -7500403 true true 195 301 180 286 166 264 153 260 140 247 131 218 133 166 126 141 115 112 108 73 102 64 98 62 86 32 92 31 87 19 103 31 113 31

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.0
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
1
@#$#@#$#@
