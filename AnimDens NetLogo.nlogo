;Simulation model: AnimDens
;Original model implemented in R by Christine Ward-Paige
;Adapted and implemented in NetLogo by Miguel Pessanha Pais

;This is a model that simulates divers counting sharks while deploying the belt-transect and stationary-
;point-count underwater visual census techniques. The model assumes an area that is featureless and flat. The depth 
;is ignored and assumed constant. For each simulation, the divers start in the middle and face in the same 
;direction. At each time step (which is set by the user) divers count the number of fish they can see based
;on the direction the diver is facing, the visibility distance (set by the user) and the angle of which the 
;diver can see at a given time step (set by the user). The fish move at a speed specified by the user, and 
;travel in a direction that is restricted (selected angle is set by the user) based on the previous direction. 
;Fish that reach the boundaries of the area wrap around to the opposite side (in the original model they could leave the area).
;By default, divers do not recount fish.

;Global variables not represented in the main screen

globals[
  actual.area
  transdiver.viewangle
  statdiver.viewangle
  rovdiver.viewangle
  transect.diver.mean.speed
  roving.diver.mean.speed
  transect.area
  stationary.area
]

;Agent types

breed [sharks shark]

breed [transdivers transdiver] ;belt transect diver

breed [statdivers statdiver] ;stationary point count diver

breed [rovdivers rovdiver] ;roving diver     ; roving divers can't calculate densities accurately, yet they can estimate speceis richness and frequency of occurence.

;Agent variables

sharks-own [
  speed
  species
]

transdivers-own [
  counted.sharks
  speed
  memory
  t.bias
]


statdivers-own [
  counted.sharks
  memory
  s.bias
]

rovdivers-own [
  counted.sharks
  speed
  memory
]

;Setup and go procedures


to setup
  ca
  stop-inspecting-dead-agents                           ; clears diver detail windows from previous simulation runs
  set actual.area world-height * world-width
  set transdiver.viewangle 180
  set statdiver.viewangle 160
  set rovdiver.viewangle 160
  set transect.diver.mean.speed (transect.diver.speed / 60)  ; these 4 lines just convert interface speeds (in m/min) to m/s
  set roving.diver.mean.speed (roving.diver.speed / 60)
  
  ; on the original model, the final part of the sampled area of the transect is assumed to be a rectangle (transect.width x visibility.length)
  
  set transect.area transect.width * (transect.diver.mean.speed * survey.time) + transect.width * visibility.length
  set stationary.area pi * stationary.radius ^ 2
 
; if shark density is set to some number, then use that to calculate the number of sharks to deploy. Otherwise, just use the numb.sharks.
 
  ifelse shark.density != 0 [set numb.sharks ceiling actual.area * shark.density] [set shark.density numb.sharks / actual.area]
  
  create-sharks numb.sharks [
   setxy random-xcor random-ycor
   set color gray
   set shape "shark"
   set size 1      
   set species "Sp1"                                          ; in case of a single species
   ;set species item random 5 ["Sp1" "Sp2" "Sp3" "Sp4" "Sp5"]   ; in case there are multiple species (deactivate one of them)
   set speed shark.mean.speed
  ]
  
if transect.diver? = true [                                         ;transect diver setup
  create-transdivers 1 [
 set heading 0
 set shape "person"
 set color blue
 set size 1.7
 setxy (world-width / 2) (world-height / 2)
 if show.paths? = true [pen-down]                                                           ;this shows the path of the diver
 set speed transect.diver.mean.speed
 set counted.sharks [] ; sets counted.sharks as an empty list
]
]

if stationary.diver? = true [                                      ;stationary diver setup
  create-statdivers 1 [
 set heading 0
 set shape "person rotate"
 set color red
 set size 1.7
 setxy (world-width / 2) (world-height / 2)
 set counted.sharks [] ; sets counted.sharks as an empty list
]
]

if roving.diver? = true [                                          ;roving diver setup
  create-rovdivers 1 [
 set heading 0
 set shape "person"
 set color green
 set size 1.7
 setxy (world-width / 2) (world-height / 2)
 if show.paths? = true [pen-down]                                                           ;this shows the path of the diver
 set speed roving.diver.mean.speed
 set counted.sharks [] ; sets counted.sharks as an empty list
]
]


ifelse diver.memory? = true [                                   ;enable or disable diver memory (ability to remember counted sharks)
    ask transdivers [
      set memory []
      ] 
    ask statdivers [
      set memory []
      ]
    ask rovdivers [
      set memory [] 
    ]
    ]
   [
    ask transdivers [
      set memory false
      ]
    ask statdivers [
      set memory false
      ]
    ask rovdivers [
      set memory false 
    ]
    ]
reset-ticks
if show.diver.detail.windows? = true [
  if any? transdivers [inspect one-of transdivers]         ;here I had to use "if any?" because inspect will return an error if it finds nobody
  if any? statdivers [inspect one-of statdivers]
  if any? rovdivers [inspect one-of rovdivers]
]
end ;of setup procedure


to go
  tick
  if ticks > survey.time [
    do.outputs
    stop]                                   ; end the simulation run when survey.time is reached
  if stationary.radius > visibility.length [
   output-print "ERROR: stationary.radius is set to a value greater than visibility.length"              ; if the stationary radius is higher than visibility, stop and output an error description
   output-print "The diver will not commit to sampling an area that it will not be able to see"
   output-print "Stopping simulation"
   stop 
  ]
  ask transdivers [
   do.tdiver.movement 
  ]
  ask statdivers [
   do.stdiver.movement 
  ]
  ask rovdivers [
    do.rdiver.movement
  ]
  ask sharks [
    do.shark.movement
  ]
  ifelse time.step = 1 [                      ; checks time.step to see if sharks are counted every tick or every 2 ticks
   ask transdivers [
     t.count.sharks
   ]
   ask statdivers [
     s.count.sharks
   ]
   ask rovdivers [
     r.count.sharks
   ]
  ] [if ticks mod time.step = 0 [
    ask transdivers [
      t.count.sharks
      ]
    ask statdivers [
      s.count.sharks
      ]
    ask rovdivers [
      r.count.sharks
    ]]]
end  ; of go procedure



;Observer procedures

to do.outputs
  ask transdivers [
    let real.count length counted.sharks
    let expected.count shark.density * transect.area
    set t.bias (real.count - expected.count) / expected.count
    output-type "Transect diver bias was " output-print precision t.bias 2           ; outputs bias with 2 decimal places
  ]
  
 ask statdivers [
    let real.count length counted.sharks
    let expected.count shark.density * stationary.area
    set s.bias (real.count - expected.count) / expected.count
    output-type "Stationary diver bias was " output-print precision s.bias 2
 ]
 
 ask rovdivers [
    let real.count length counted.sharks
    output-type "Roving diver swam " output-type survey.time * roving.diver.mean.speed output-type "m and counted " output-type real.count output-print " sharks"                     ; the roving diver only tells how many sharks it counted
 ]
end

to calculate.bias
ifelse choose.method = "transect" [
ifelse any? transdivers [
output-print "The real value using the transect method is"
output-print precision (observed.value / transect.factor.value) 3]
[output-print "You need to re-run the model with this method enabled"
  stop
]
] [
ifelse any? statdivers [
output-print "The real value using the stationary method is"
output-print precision (observed.value / stationary.factor.value) 3
] [
output-print "You need to re-run the model with this method enabled"
stop
]]
end



;SHARK PROCEDURES


;Shark movement

to do.shark.movement
  set heading heading + random-float-between (- shark.dir.angle) shark.dir.angle
  fd speed ; each step is a second, so the speed is basically the distance
end




;DIVER PROCEDURES


;Transect diver procedures

to do.tdiver.movement
  fd speed ; each step is a second, so the speed is basically the distance
end

to t.count.sharks
  let myxcor xcor
  let seen.sharks sharks in-cone visibility.length transdiver.viewangle
  let eligible.sharks seen.sharks with [(xcor > myxcor - (transect.width / 2)) and (xcor < myxcor + (transect.width / 2))]  ; this only works for transects heading north, of course
  ifelse memory = false [
    let new.sharks eligible.sharks   ; if divers have no memory, then all sharks they see are counted
    if any? new.sharks [
    let new.records ([species] of new.sharks)
    set counted.sharks sentence counted.sharks new.records
    ; ask new.sharks [set color red wait 1 set color gray]   ;for troubleshooting
    ]] [
  let diver.memory memory
  let new.sharks eligible.sharks with [not member? who diver.memory] ; if memory is enabled, only sharks that were not previously counted are counted
  if any? new.sharks [
    let new.records ([species] of new.sharks)
    set counted.sharks sentence counted.sharks new.records
    set memory sentence memory [who] of new.sharks
  ]]
    
end


;Stationary diver procedures

to do.stdiver.movement
  set heading heading + stationary.turning.angle
  
end

to s.count.sharks
  let eligible.sharks sharks in-cone stationary.radius statdiver.viewangle
  ifelse memory = false [
    let new.sharks eligible.sharks   ; if divers have no memory, then all sharks they see are counted
    if any? new.sharks [
    let new.records ([species] of new.sharks)
    set counted.sharks sentence counted.sharks new.records
    ]] [
  let diver.memory memory
  let new.sharks eligible.sharks with [not member? who diver.memory] ; if memory is enabled, only sharks that were not previously counted are counted
  if any? new.sharks [
    let new.records ([species] of new.sharks)
    set counted.sharks sentence counted.sharks new.records
    set memory sentence memory [who] of new.sharks
  ]]
end

;Roving diver procedures

to do.rdiver.movement
  if ticks mod 2 = 0 [set heading heading + random-float-between (- roving.diver.turning.angle) roving.diver.turning.angle]         ;turning happens every 2 seconds
  fd speed ; each step is a second, so the speed is basically the distance
end

to r.count.sharks
  let eligible.sharks sharks in-cone visibility.length statdiver.viewangle
  ifelse memory = false [
    let new.sharks eligible.sharks   ; if divers have no memory, then all sharks they see are counted
    if any? new.sharks [
    let new.records ([species] of new.sharks)
    set counted.sharks sentence counted.sharks new.records
    ]] [
  let diver.memory memory
  let new.sharks eligible.sharks with [not member? who diver.memory] ; if memory is enabled, only sharks that were not previously counted are counted
  if any? new.sharks [
    let new.records ([species] of new.sharks)
    set counted.sharks sentence counted.sharks new.records
    ; ask new.sharks [set color red wait 1 set color gray]   ;for troubleshooting
    set memory sentence memory [who] of new.sharks
  ]]
    end

;reporters

to-report random-float-between [a b]
  report random-float (b - a + 1) + a
end

to-report t.bias-result        ; these reporters are outputs for BehaviourSpace experiments
  report [t.bias] of one-of transdivers  ; one-of makes it output a single number instead of a list with one value (a list would be [34] instead of 34)
end

to-report s.bias-result
  report [s.bias] of one-of statdivers
end

to-report stationary.factor.value
  report s.bias-result + 1
end

to-report transect.factor.value
  report t.bias-result + 1
end
@#$#@#$#@
GRAPHICS-WINDOW
479
16
889
447
-1
-1
1.0
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
399
0
399
1
1
1
seconds
1.0

BUTTON
899
68
963
101
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
967
68
1030
101
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
1

BUTTON
1035
68
1112
101
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
1

MONITOR
899
16
997
61
Total area (m2)
actual.area
0
1
11

SLIDER
26
41
228
74
transect.diver.speed
transect.diver.speed
1
7
4
1
1
m/min
HORIZONTAL

TEXTBOX
29
21
179
39
Transect diver movement
11
0.0
1

TEXTBOX
27
140
177
158
Stationary diver movement
11
0.0
1

SLIDER
24
168
247
201
stationary.turning.angle
stationary.turning.angle
0
90
4
1
1
degrees / sec
HORIZONTAL

TEXTBOX
262
139
412
157
Shark movement
11
0.0
1

CHOOSER
26
80
118
125
transect.width
transect.width
1 2 4 5 8 10 20
2

SLIDER
899
236
1071
269
visibility.length
visibility.length
5
40
13
1
1
m
HORIZONTAL

SLIDER
23
207
195
240
stationary.radius
stationary.radius
1
20
7.5
0.5
1
NIL
HORIZONTAL

SLIDER
900
273
1018
306
time.step
time.step
1
2
2
1
1
seconds
HORIZONTAL

TEXTBOX
1024
282
1174
304
Time step at which counts are made by the divers
9
0.0
1

SLIDER
901
311
1055
344
survey.time
survey.time
60
3600
300
10
1
seconds
HORIZONTAL

TEXTBOX
369
193
398
211
m/s
11
0.0
1

INPUTBOX
899
109
977
169
shark.density
0.2
1
0
Number

INPUTBOX
899
172
978
232
numb.sharks
32000
1
0
Number

TEXTBOX
981
109
1131
137
This has priority if it is set to a number > 0
11
0.0
1

TEXTBOX
983
146
1133
164
sharks / m2
11
0.0
1

TEXTBOX
127
104
153
123
m
11
0.0
1

SWITCH
902
350
1040
383
diver.memory?
diver.memory?
0
1
-1000

OUTPUT
479
457
890
544
12

SLIDER
261
41
451
74
roving.diver.speed
roving.diver.speed
1
7
4
1
1
m/min
HORIZONTAL

TEXTBOX
263
21
413
39
Roving diver movement
11
0.0
1

SLIDER
261
82
469
115
roving.diver.turning.angle
roving.diver.turning.angle
0
45
4
1
1
º / 2 secs
HORIZONTAL

SWITCH
24
287
165
320
transect.diver?
transect.diver?
0
1
-1000

SWITCH
25
325
165
358
stationary.diver?
stationary.diver?
0
1
-1000

SWITCH
26
362
165
395
roving.diver?
roving.diver?
1
1
-1000

TEXTBOX
24
264
174
282
Select active divers
11
0.0
1

SWITCH
1098
404
1224
437
show.paths?
show.paths?
0
1
-1000

SWITCH
903
404
1089
437
show.diver.detail.windows?
show.diver.detail.windows?
0
1
-1000

TEXTBOX
905
389
1055
407
Display options
11
0.0
1

TEXTBOX
172
368
322
396
This diver does not estimate densities
11
0.0
1

TEXTBOX
1045
355
1195
383
Ability to remember counted sharks (usually on)
11
0.0
1

BUTTON
1001
28
1128
61
Reset to defaults
set transect.diver.speed 4\nset transect.width 4\nset stationary.turning.angle 4\nset stationary.radius 7.5\nset transect.diver? true\nset stationary.diver? true\nset roving.diver? false\nset roving.diver.speed 4\nset roving.diver.turning.angle 4\nset shark.mean.speed 1\nset shark.dir.angle 45\nset shark.density 0.2\nset visibility.length 13\nset time.step 2\nset survey.time 300\nset diver.memory? true\nset show.diver.detail.windows? false\nset show.paths? true\n
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
202
224
231
242
m
11
0.0
1

TEXTBOX
367
257
422
275
degrees
11
0.0
1

MONITOR
480
581
612
626
Transect factor value
transect.factor.value
2
1
11

MONITOR
481
631
612
676
Stationary factor value
stationary.factor.value
2
1
11

TEXTBOX
482
549
850
587
Bias correction calculator (use after model run)
15
0.0
1

BUTTON
629
684
748
724
CALCULATE
calculate.bias
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

INPUTBOX
639
614
735
674
observed.value
100
1
0
Number

TEXTBOX
623
577
773
605
Input the real count / density from the field survey:
11
0.0
1

CHOOSER
755
621
893
666
choose.method
choose.method
"transect" "stationary"
0

BUTTON
399
458
476
543
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

INPUTBOX
259
156
361
216
shark.mean.speed
1
1
0
Number

INPUTBOX
260
219
362
279
shark.dir.angle
45
1
0
Number

@#$#@#$#@
## WHAT IS IT?

This is a model that simulates divers counting sharks while deploying the belt-transect, stationary-point-count and roving underwater visual census techniques. The model demonstrates how non-instantaneous sampling techniques produce bias by overestimating the number of counted animals, when they move relative to the person counting them.

This is applied to divers and sharks, but is intended to reflect what happens with many other animal censuses (aerial surveys, bird transects, etc.).

The model can be used to demonstrate that bias increases as the speed of the animals relative to the observer increases.

The model assumes an area that is featureless and flat, with a default size of 400x400 cells with an area of 1 square meter. The origin of the coordinate system is on the bottom left corner and depth is ignored (assumed constant).

## HOW IT WORKS

For each simulation, the divers start in the middle and face north. Sharks and transect divers move every second, but the time step for counting can be set to 2 seconds for better computing performance (set by default on the original model).

At each counting time step, divers count the number of sharks they can see based on the direction the diver is facing, the visibility distance and angle.

On the belt-transect method, only fish within the transect width are counted, while on the stationary-point-count method, only fish within a pre-determined radius are counted.

Transect diver moves in a fixed direction at a constant speed (default is 4 m/s).

Stationary diver rotates a given number of degrees clockwise every two seconds (default is 4).

Sharks move at a speed specified by the user, and travel in a direction that is restricted by a turning angle based on the previous direction.

Sharks and divers that reach the boundaries of the area wrap around to the opposite side, to keep the density constant (on the original model they can leave the area, but that doesn't seem to have significant effects on the output, if the area is large enough.

By default, divers keep a memory of every individual shark counted and do not recount.

## HOW TO USE IT

In order to speed up model runs, please disable update view.

The "setup" button feeds all parameter values into the model, places the selected divers and spreads all the sharks across the area.

The "go" button runs the model for the time specified in survey.time (default is 300 seconds) and then stops. The model can be stopped or paused at any time by pressing the go button while it is running. The "go once" button avances the model run by 1 second each time.

The "reset to defaults" sets all parameters to values used in the first experiment by Ward-Paige et al. (2010) with shark speed set to 1 m/s. You still need to press "setup" after reseting model parameters to defaults.

Viewing angles are fixed and cannot be changed on the interface. They are set to 160º for the stationary and roving divers and 180º for the transect diver.

"transect.width" sets the width of the belt transect that is sampled as the diver swims in the center (transect.width/2 to each side of the diver).

To set the initial number of sharks, introduce the total number of sharks directly under "numb.sharks" on the interface. Alternatively (and preferably), you can set the real density needed under "shark.density" and the model will place the right number of sharks for the total area. If shark.density is set to a value greater than 0 when the model starts, it has priority over "numb.sharks".

Select the divers that will be in the model by turning their swiches on and off on the interface. Please note that the roving diver will not calculate densities and thus will not estimate bias. If you want to see the details of every diver in a floating window during the run, switch on "show.diver.detail.windows?".

If you want the transect and roving divers to draw a path as they move, switch on "show.paths?".

Stationary.radius must be set to a value lower than visibility.length.

In the end of each run, each diver reports its relative bias, calculated as:

(real count - expected count) / expected count

where "expected count" is basically the real shark.density multiplied by the sampled area.

For the stationary diver:

sampled area = pi * stationary.radius^2

For the transect diver:

sampled area = survey.time * (transect.diver.speed / 60) * transect.width + visibility length * transect.width

Notice that the final part of the transect is approximated to a rectangle of length equal to the visibility length, instead of taking into account the arc produced by the cone of vision. This was done in the original model and, With relatively large visibility lengths, does not seem to have much impact on the final result.

The model will also output the conversion factor value for each method (transect and stationary). The real count (in the field) divided by this factor value should provide an estimate that is corrected to account for bias (given that all parameters are realistically set).

## THINGS TO NOTICE

If "view updates" is enabled, the model will run in real time (every second in the model will run in one second).

To understand the source of the bias, compare a model wun with shark.mean.speed set to 0 m/s (stationary sharks) and another with shark.mean.speed set to 1 m/s. Keep everything else default.

In the first case (stationary sharks), the sampling method will be equivalent to taking a snapshot of the whole sampling area. The sharks will stand still and the diver will count every shark in the sampling area, not repeating any shark (given that "diver.memory?" is switched on). This will produce little to no bias in the estimates.

In the case where sharks move 1 meter every second (while the diver is moving 4 meters every minute), there will be new sharks comming into the sampling area that were not there in the beginning. These sharks will all be counted as they pass in front of the diver, increasing the number of counted sharks, while the real number of sharks in the beginning was much lower. This produces the bias.

If the speed of the sharks is even higher, there are more sharks coming into the field of view of the diver and the bias will be even higher.

## THINGS TO TRY

- The model can be used as a tool to get better estimates from field surveys.

To make corrections to observed values (values observed in the field by non-instantaneous surveys):

1. Decide on Targeted fish and select an appropriate speed and turning angle for that species for a given dive.
2. Select most appropriate sampling values (e.g. transect width, swim speed, survey time, etc.) Note: for visibility, select the distance you would be sure to detect the targeted fish.
4. Divide your observed count, density, or biomass by the factor value to get the corrected value. 
5. Repeat for other species.

- Switch on just the transect diver and see how increasing shark speeds increases bias. Why does this happen?

- Do the same for the stationary diver. Were the results expected?

- With stationary sharks (speed 0) and moving divers, bias is almost zero, but what about stationary divers with moving sharks? Place a stationary diver with stationary.turning.angle set to 0 and sharks with speed > 0 and see the results.

- There are two experiments in behaviorSpace that correspond to the experiments run by Ward-Paige et al. (2010). One to observe the increase in bias with increasing shark speed (30 replicates per run) and one to test every combination of values from a set of realistic candidates (a single run per combination) and observe the resulting bias.

## EXTENDING THE MODEL

Since divers are counting species, more species can be introduced, with different densities and parameter values (by creating new breeds).

Fixed distance transects can be implemented, or other survey methods.

Different animal behavior models can be coupled to this model to generate better bias estimates.

## NETLOGO FEATURES

On the original model, the sharks could leave the area and come back (or leave permanently). Here the world is set to wrap around the edges. For an area that is large enough, this does not seem to affect the final results. In order to reflect what was made in the original model in R, one can set a buffer area around where no sharks are placed. If for some reason we want sharks to leave and never come back, we can just make them die when they reach the edges.

## RELATED MODELS

The orignial AnimDens model was implemented in R by Christine Ward-Paige, Joanna Mills Flemming and Heike K. Lotze. The code can be downloaded at:

http://journals.plos.org/plosone/article/asset?unique&id=info:doi/10.1371/journal.pone.0011722.s001

## CREDITS AND REFERENCES

Original model by Christine Ward-Paige (2009)

Implemented in NetLogo by Miguel Pessanha Pais (2015)

If you use this model, please cite the original publication:

Ward-Paige, C.A., Flemming, J.M., Lotze, H.K., 2010. Overestimating Fish Counts by Non-Instantaneous Visual Censuses: Consequences for Population and Community Descriptions. PLoS ONE 5(7): e11722. doi:10.1371/journal.pone.0011722

URL: http://journals.plos.org/plosone/article?id=10.1371/journal.pone.0011722

Another publication that uses the roving diver:

Ward-Paige, C.A., Lotze, H.K., 2011. Assessing the Value of Recreational Divers for Censusing Elasmobranchs. PLoS ONE 6(10): e25609. doi:10.1371/journal.pone.0025609

URL: http://journals.plos.org/plosone/article?id=10.1371/journal.pone.0025609

In order to cite the NetLogo implementation:

Pais, M.P., Ward-Paige, C.A. (2015). AnimDens model NetLogo implementation. http://modelingcommons.org/model/

NetLogo software citation:

Wilensky, U. (1999). NetLogo. http://ccl.northwestern.edu/netlogo/. Center for Connected Learning and Computer-Based Modeling, Northwestern Institute on Complex Systems, Northwestern University, Evanston, IL.

## COPYRIGHT AND LICENSE

Copyright 2015 Miguel Pessanha Pais and Christine Ward-Paige.

![CC BY-NC-SA 3.0](http://ccl.northwestern.edu/images/creativecommons/byncsa.png)

This work is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 3.0 License.  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-sa/3.0/ or send a letter to Creative Commons, 559 Nathan Abbott Way, Stanford, California 94305, USA.
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
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

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
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

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
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

person rotate
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
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

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
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270

@#$#@#$#@
NetLogo 5.2.0
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
<experiments>
  <experiment name="How does fish speed affect relative bias?" repetitions="30" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <metric>t.bias-result</metric>
    <metric>s.bias-result</metric>
    <enumeratedValueSet variable="stationary.turning.angle">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="shark.range.speed">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="shark.density">
      <value value="0.2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="shark.mean.speed">
      <value value="0"/>
      <value value="0.0010"/>
      <value value="0.01"/>
      <value value="0.1"/>
      <value value="0.2"/>
      <value value="0.4"/>
      <value value="0.6"/>
      <value value="0.8"/>
      <value value="1"/>
      <value value="2"/>
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="survey.time">
      <value value="300"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="range.speed">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="diver.memory?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="transect.diver.speed">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="shark.spread.speed">
      <value value="0.1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="shark.dir.angle">
      <value value="45"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="transect.width">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="time.step">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="transect.diver.spread.speed">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="visibility.length">
      <value value="13"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="stationary.radius">
      <value value="7.5"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="Experiment 2: Influence of all parameters" repetitions="1" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <metric>t.bias-result</metric>
    <metric>s.bias-result</metric>
    <enumeratedValueSet variable="diver.memory?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="shark.mean.speed">
      <value value="0"/>
      <value value="0.0010"/>
      <value value="0.01"/>
      <value value="0.1"/>
      <value value="0.2"/>
      <value value="0.4"/>
      <value value="0.6"/>
      <value value="0.8"/>
      <value value="1"/>
      <value value="2"/>
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="time.step">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="transect.width">
      <value value="1"/>
      <value value="2"/>
      <value value="4"/>
      <value value="5"/>
      <value value="8"/>
      <value value="10"/>
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="shark.spread.speed">
      <value value="0.1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="shark.density">
      <value value="0.1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="stationary.turning.angle">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="transect.diver.spread.speed">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="shark.range.speed">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="visibility.length">
      <value value="10"/>
      <value value="20"/>
      <value value="30"/>
      <value value="40"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="shark.dir.angle">
      <value value="1"/>
      <value value="22.5"/>
      <value value="45"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="transect.diver.speed">
      <value value="1"/>
      <value value="4"/>
      <value value="7"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="range.speed">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="stationary.radius">
      <value value="7.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="survey.time">
      <value value="60"/>
      <value value="300"/>
      <value value="600"/>
      <value value="900"/>
      <value value="1200"/>
      <value value="1800"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="How does fish speed affect relative bias? (count every second)" repetitions="30" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <metric>t.bias-result</metric>
    <metric>s.bias-result</metric>
    <enumeratedValueSet variable="stationary.turning.angle">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="shark.range.speed">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="shark.density">
      <value value="0.2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="shark.mean.speed">
      <value value="0"/>
      <value value="0.0010"/>
      <value value="0.01"/>
      <value value="0.1"/>
      <value value="0.2"/>
      <value value="0.4"/>
      <value value="0.6"/>
      <value value="0.8"/>
      <value value="1"/>
      <value value="2"/>
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="survey.time">
      <value value="300"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="range.speed">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="diver.memory?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="transect.diver.speed">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="shark.spread.speed">
      <value value="0.1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="shark.dir.angle">
      <value value="45"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="transect.width">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="time.step">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="transect.diver.spread.speed">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="visibility.length">
      <value value="13"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="stationary.radius">
      <value value="7.5"/>
    </enumeratedValueSet>
  </experiment>
</experiments>
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
0
@#$#@#$#@