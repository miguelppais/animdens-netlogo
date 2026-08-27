## WHAT IS IT?

AnimDens NetLogo 4.0

This is a model that simulates surveyors counting animals while deploying belt-transect, stationary-point-count and roving (random path) techniques. The model demonstrates how non-instantaneous sampling techniques produce bias by overestimating the number of counted animals, when they move relative to the surveyor.

The model intends to reflect what happens with many animal censuses (underwater visual census of fish, aerial surveys, bird transects, etc.).

The model can be used to demonstrate that bias increases as the speed of the animals relative to the observer increases.

Using the provided bias calculator, it is possible to use the output of the model to apply bias correction to field data.

## HOW IT WORKS

The model assumes an area that is featureless and flat, sized by the `area.width` and `area.length` sliders (default 50 m by 80 m, that is, 4000 cells of one square meter each). The origin of the coordinate system is on the bottom left corner.

For each simulation, the surveyors start in the middle and face north. Animals and the transect and roving surveyors move every second, but the time step for counting can be set to 2 seconds for shorter computing times (set by default on the original model, but note that some animals may be missed, particularly if they are very fast).

At each counting time step, surveyors count the number of animals they can see, based on the direction the surveyor is facing, the viewing distance and the viewing angle:

- The transect surveyor sees within `visibility.length` over a fixed 180º arc.
- The stationary surveyor sees within `stationary.radius` over the arc set by the `stat.viewangle` slider (120º to 360º, default 360º). This is the only viewing angle exposed on the interface; at 360º the surveyor counts in every direction, regardless of where it is facing.
- The roving surveyor sees within `visibility.length` over a fixed 160º arc.

On the belt-transect method, only animals within the transect width are counted, while on the stationary-point-count method, only animals within a pre-determined radius are counted.

The transect surveyor moves in a fixed direction (north) at a constant speed (default is 6 m/minute).

The stationary surveyor does not move, and rotates `stationary.turning.angle` degrees clockwise every second (default is 0, so by default it stays facing north).

Animals move at a speed specified by the user, and travel in a direction that is restricted by a turning angle based on the previous direction.

Roving surveyors move similarly to animals and have their own speed and turning angle parameters. Turning happens every 2 seconds.

Animals and surveyors that reach the boundaries of the area wrap around to the opposite side, to keep the density constant (on the original model they can leave the area, but that doesn't seem to have significant effects on the output, if the area is large enough).

Surveyors keep a memory of every individual animal counted and do not recount.

## HOW TO USE IT

The model runs in real time by default, which is slow (1 second in the model equals 1 second in real life). In order to speed up model runs, increase the speed in the slider or disable update view (at the top).

The "setup" button feeds all parameter values into the model, places the selected surveyors and spreads all the animals across the area.

The "go" button runs the model for the time specified in `survey.time` (default is 200 seconds) and then stops. The model can be stopped or paused at any time by pressing the go button while it is running. The "go once" button advances the model run by 1 second each time.

Select the sampling methods that will be in the model run by turning their switches on and off on the interface (by default, transect and stationary are on and roving is off). Please note that the roving surveyor will not calculate densities and thus will not estimate bias. Each method has a "Follow" button that locks the view onto that surveyor during a run, and "Stop following divers" returns to the normal view.

The "Set default parameter values" button restores every slider, switch and chooser to the default stated for it below. It leaves three boxes alone: `numb.animals`, because setup recomputes it from `animal.density` whenever that is above 0, and `observed.value` and `choose.method`, because those hold your own field data for the bias calculator rather than model parameters.

### Sampling parameters

- `visibility.length` (default 13 m): how far a surveyor can see. It is the viewing radius of the transect and roving surveyors, and the upper limit for `stationary.radius`.
- `survey.time` (default 200 seconds): duration of the survey. The run stops when it is reached.
- `count.time.step` (default 2 seconds): how often surveyors count. 2 seconds is the original model's behaviour; 1 second misses fewer animals but takes longer to run.
- `transect.speed` (default 6 m/min): swimming speed of the belt-transect surveyor.
- `transect.width` (default 4 m): width of the belt transect that is sampled as the surveyor swims in the center (half of the width to each side of the surveyor).
- `transect.length` (default 50 m): the length of transect you intend to survey. This slider does not feed the model directly. It exists for the "set survey.time for this length" button, which converts it into the `survey.time` that the transect surveyor needs to swim that length at the current `transect.speed`.
- `stationary.radius` (default 6.5 m): radius sampled by the stationary surveyor. It must not be set higher than `visibility.length`, because the surveyor would be committing to sample an area it cannot see. If it is, setup refuses the configuration: it explains the problem in the output box and builds nothing, and go will not run until you lower the radius or raise the visibility and press setup again.
- `stat.viewangle` (default 360º): the arc the stationary surveyor counts over.
- `stationary.turning.angle` (default 0 degrees/second): how fast the stationary surveyor rotates clockwise.
- `roving.speed` (default 4 m/min): swimming speed of the roving surveyor.
- `roving.turning.angle` (default 4º): the roving surveyor turns by a random angle between minus and plus this value, every 2 seconds.

### Animal population parameters

To set the initial number of animals, introduce the total number of animals directly under `numb.animals` on the interface (default 400). Alternatively (and preferably), you can set the real density needed under `animal.density` (default 0.1 animals per square meter) and the model will place the right number of animals for the total area. If `animal.density` is set to a value greater than 0 when the model starts, it has priority over `numb.animals`.

- `animal.mean.speed` (default 0.2 m/s): how far each animal travels every second.
- `animal.dir.angle` (default 45 degrees): each animal turns by a random angle between minus and plus this value at every step.

### Area and display options

- `area.width` (default 50 m) and `area.length` (default 80 m): the dimensions of the sampled area. Both are read at setup, which resizes the world and rescales the patches to fit.
- `show.surveyor.detail.windows?` (default off): opens a floating inspector window for each surveyor during the run.
- `show.paths?` (default on): the transect and roving surveyors draw their path as they move.
- `animal.shape` (default fish), `animal.color` (default 9), `surveyor.shape` (default diver) and `environment.color` (default 102) are cosmetic and do not affect results.

### Sampled areas and outputs

The "Total area (sq. meters)" monitor reports the size of the world. The "Stationary area (m2)" and "Transect area (m2)" monitors report the area each method samples. They are recalculated at every setup, and the "calculate areas" button recalculates them without running the model, so that parameter combinations can be compared before committing to a run.

At the end of each run, the transect and the stationary surveyor each report three lines in the output box: the relative bias, the raw count, and the density estimate that count implies. The roving surveyor reports the distance it swam and how many animals it counted, and nothing else. It has no defined sampled area, so it cannot estimate density or bias.

If a run is set up with no animals at all (both `animal.density` and `numb.animals` at 0), relative bias is undefined rather than zero, and the model says so instead of printing a 0 that would read as "unbiased".

Relative bias is calculated as:

`(real count - expected count) / expected count`

where "expected count" is basically the animal density in the model multiplied by the total sampled area.

For the stationary surveyor, the sampled area takes into account how much the surveyor rotates during the survey. The arc it will have swept by the end of the run is `stat.viewangle + stationary.turning.angle * survey.time`. If that reaches a full circle, the sampled area is the whole disc:

`sampled area = pi * stationary.radius ^ 2`

Otherwise, only the swept fraction of the disc is sampled:

`sampled area = ((stat.viewangle + stationary.turning.angle * survey.time) / 360) * pi * stationary.radius ^ 2`

With the default `stat.viewangle` of 360º the surveyor already sees all around itself, so the first case applies and the rotation makes no difference. Narrow the slider and the rotation speed starts to matter.

For the transect surveyor:

`sampled area = survey.time * (transect.speed / 60) * transect.width + visibility.length * transect.width`

Notice that the final part of the transect is approximated to a rectangle of length equal to the visibility length, instead of taking into account the arc produced by the cone of vision. This was done in the original model and, with relatively large visibility lengths, does not seem to have much impact on the final result.

The model will also output the conversion factor value for each method (transect and stationary), shown in the "Transect factor value" and "Stationary factor value" monitors. The real count (in the field) divided by this factor value should provide an estimate that is corrected to account for bias (given that all parameters are realistically set).

## THINGS TO NOTICE

If "view updates" is enabled and speed is set to "normal", the model will run in real time (every second in the model will run in one second).

To understand the source of the bias, compare a model run with `animal.mean.speed` set to 0 m/s (stationary animals) and another with `animal.mean.speed` set to 1 m/s. Keep everything else default.

In the first case (stationary animals), the sampling method will be equivalent to taking a snapshot of the whole sampling area. The animals will stand still and the surveyor will count every animal in the sampling area, not repeating any animal. This will produce little to no bias in the estimates.

In the case where animals move 1 meter every second (while the transect surveyor is moving 6 meters every minute), there will be new animals coming into the sampling area that were not there in the beginning. These animals will all be counted as they pass in front of the surveyor, increasing the number of counted animals, while the real number of animals in the beginning was much lower. This produces the bias.

If the speed of the animals is even higher, there are more animals coming into the field of view of the surveyor and the bias will be even higher.

## THINGS TO TRY

- Switch on just the transect surveyor and see how increasing animal speeds increases bias. Why does this happen?

- Do the same for the stationary surveyor. The results are similar, why?

- With stationary animals (speed 0) and moving surveyors, bias is almost zero, but what about stationary surveyors with moving animals? Place a stationary surveyor with `stationary.turning.angle` set to 0 and animals with speed above 0 and see the results.

- Reduce `stat.viewangle` from 360º to 180º and run the stationary method again. The surveyor now samples half a disc instead of a whole one, and the sampled area, the count and the bias move together. Then raise `stationary.turning.angle` and watch the surveyor sweep that narrower cone around until it has covered the full circle anyway.

- Run a model in real time (normal speed and "view updates" checked) with the default parameters. While it is running, press the follow button in front of the transect surveyor switch to focus the view on that surveyor. Now head to the top right corner of the world window and click "3D" to go to the 3D view. Observing the surveyor from this perspective as it counts animals is a great way of understanding the bias in non-instantaneous sampling of moving animals.

## USING THE BIAS CALCULATOR

The model can be used as a tool to get better estimates from field surveys using the bias calculator at the bottom.

To make corrections to observed values (values observed in the field by non-instantaneous surveys):

1. Decide on targeted animal species and select an appropriate speed and turning angle for that species.
2. Select most appropriate sampling values (e.g. transect width, swim speed, survey time, etc.) Note: for visibility, select the distance you would be sure to detect the targeted animal.
3. Run the model with the selected parameters, making sure that your sampling method of choice is turned on in the switches.
4. After the survey time finishes the model stops and the conversion factor is calculated.
5. On the calculator, go to the `observed.value` box and input the number of animals from that species you counted in the field.
6. Select the appropriate method on the calculator (transect or stationary).
7. Press calculate. The result is the "real" count, corrected for bias.
8. Repeat for other species.

## EXTENDING THE MODEL

The model carries a single animal species, with one speed and one turning angle. The counting procedures already record a species name rather than just a tally, so giving animals more than one species identity would let a single run compare bias across species that differ in mobility, which is a comparison the original paper makes across separate runs.

Animal movement is an unconstrained random walk. Schooling, territoriality, and attraction to or avoidance of the surveyor are all absent, and any of them would change how quickly new animals enter the sampled area, which is where the bias comes from.

The transect counting procedure only works for a transect heading north, because it filters animals by their horizontal distance from the surveyor. Letting the transect follow an arbitrary heading means rewriting that filter in terms of the distance to the surveyor's own axis.

## NETLOGO FEATURES

The surveyors are three separate breeds rather than one breed with a method variable, so each carries only the variables its own method needs, and each has its own movement and counting procedure.

Detection uses `in-cone`, which combines the viewing distance and the viewing angle in a single primitive. That is what makes the three viewing geometries described above a one-line difference between the methods.

Each surveyor keeps a `memory` list of the `who` numbers it has already counted and filters new sightings against it, so an animal seen twice is only counted once. This is what makes a count non-instantaneous, and therefore what produces the bias the model is about.

The world is not fixed at compile time: `setup` calls `resize-world` and `set-patch-size` using the `area.width` and `area.length` sliders, so the view rescales to the area being simulated.

The `t.bias-result`, `s.bias-result`, `transect.factor.value` and `stationary.factor.value` reporters exist so that BehaviorSpace experiments can harvest bias and correction factors directly, instead of parsing the output box.

## NOTES ON THE ADAPTATION TO NETLOGO

On the original model, the animals could leave the area and come back (or leave permanently). Here the world is set to wrap around the edges. For an area that is large enough, this does not seem to affect the final results. In order to reflect what was made in the original model in R, one can set a buffer area around where no animals are placed. If for some reason we want animals to leave and never come back, we can just remove them when they reach the edges.

The animals in NetLogo have a visual representation, unlike in the original R model, where they were just points. However, in the counting procedure only the coordinates of the animals are checked to see if they are counted, so their size is basically ignored and does not influence results.

## WHAT'S NEW IN VERSION 4.0

This is version 4.0 of the NetLogo implementation, running on NetLogo 7. It fixes five defects that were found while this documentation was being checked line by line against the code.

Two of those fixes change numerical results. **Output from version 4.0 is not comparable with output from version 3.0 or earlier.** If you have results from an earlier version, re-run them under 4.0 rather than comparing across the two. All five defects were present in 3.0, and the 3.0 release distributed elsewhere still carries them.

### Animal and surveyor turns were biased clockwise (changes results)

The reporter that draws a random turn angle drew from `[a, b + 1)` instead of `[a, b)`. Both places that call it pass a symmetric pair of angles and expect a mean of zero, so every draw carried a mean offset of half a degree clockwise: for every animal every second, and for the roving surveyor every two seconds. The offset was half a degree regardless of what the turning angle was set to, which is worst at `animal.dir.angle` 0 — where animals should swim in a straight line, and instead every one of them curled clockwise at half a degree per second. The draw could also exceed the maximum the slider names: at `animal.dir.angle` 45 the old reporter could return a turn of +45.9995º.

The proof of the defect is at the level of the reporter itself, and it is unambiguous: over 500,000 draws at `animal.dir.angle` 45, the mean turn was +0.486º before the fix and indistinguishable from zero after it.

How much this moves survey counts is a separate question, and it is not settled. A first comparison at 10 replicates suggested around 10% for the transect method; that difference disappeared at 40 replicates, and at 120 replicates the two survey methods swapped which of them showed the larger effect. What survives all three attempts is that every one of the six comparisons had the same sign, which would be unlikely (roughly a 3% chance) if there were no effect at all. So there is probably a real effect on counts, consistent in direction, of at most a few percent — with the magnitude unresolved until someone runs a proper sweep. No single number from those trials is quoted here, because choosing one would mean choosing the most flattering one.

### The roving surveyor used the stationary surveyor's viewing angle (changes results for the roving method)

The roving surveyor has always had a declared viewing angle of 160º, and this documentation has always said so, but the counting procedure read the stationary surveyor's angle instead. While both angles were fixed at 160º the substitution was invisible. It stopped being invisible in version 3.0, which turned the stationary angle into a slider defaulting to 360º: the roving surveyor then counted over a full circle rather than its intended 160º arc, inflating its counts by around 44% at the default settings, with no overlap between the two versions' ranges over five replicates. The roving surveyor now counts over 160º, as documented.

### A survey with no animals never terminated

If a run was set up with no animals at all, the end-of-run report divided by an expected count of zero. The division threw an error, which aborted the reporting procedure before it could stop the run — so the model kept ticking past its own survey time, printing a fresh error every tick, and **exited with a success code**. A run that never terminates, produces garbage, and reports success is invisible to anything a caller can check, which is why this survived undetected for a decade. Such a run now ends at its survey time and reports the bias as undefined rather than as zero.

### The world could be sized to zero

The `area.width` and `area.length` sliders had a minimum of 0. At 0, setup asked NetLogo to resize the world to a negative extent and to divide by zero while scaling the patches. Both sliders now start at 1. This changes no result: it removes a configuration that could never have run.

### The visibility guard ran after the clock had started

The check that `stationary.radius` does not exceed `visibility.length` sat inside the go procedure, after the tick counter had advanced, so it fired once per tick and only after the model had built a full population it was never going to survey. It now runs during setup, before the world is built, and go refuses to run on a configuration that setup rejected. This changes no result.

### The "Set default parameter values" button agrees with the sliders

This is not a defect fix but it is a difference worth knowing about. That button is the model's own statement of its defaults, and it is the only such statement that survives someone saving the model with the sliders left wherever a test run put them. Every parameter it sets is set to the value the interface ships with, and to the value stated for it above. In version 3.0 as distributed elsewhere the button contradicts the sliders on several parameters and never sets another, so pressing it moves the model away from its own defaults while appearing to restore them.

## RELATED MODELS

The original AnimDens model was implemented in R by Christine Ward-Paige, Joanna Mills Flemming and Heike K. Lotze. The code can be downloaded at:

<http://journals.plos.org/plosone/article/asset?unique&id=info:doi/10.1371/journal.pone.0011722.s001>

## CREDITS AND REFERENCES

Original model by Christine Ward-Paige (2009)

Implemented in NetLogo by Miguel Pessanha Pais (2015)

For suggestions/bug reports, please e-mail Miguel P. Pais: mppais AT fc.ul.pt

If you use this model, please cite the original publication:

Ward-Paige, C.A., Flemming, J.M., Lotze, H.K., 2010. Overestimating Fish Counts by Non-Instantaneous Visual Censuses: Consequences for Population and Community Descriptions. PLoS ONE 5(7): e11722. doi:10.1371/journal.pone.0011722

URL: <http://journals.plos.org/plosone/article?id=10.1371/journal.pone.0011722>

Another publication that uses a roving diver:

Ward-Paige, C.A., Lotze, H.K., 2011. Assessing the Value of Recreational Divers for Censusing Elasmobranchs. PLoS ONE 6(10): e25609. doi:10.1371/journal.pone.0025609

URL: <http://journals.plos.org/plosone/article?id=10.1371/journal.pone.0025609>

In order to cite the NetLogo implementation:

Pais, M.P., Ward-Paige, C.A. (2015). AnimDens NetLogo model. <http://modelingcommons.org/browse/one_model/4408>

In order to cite the NetLogo software:

Wilensky, U. (1999). NetLogo. <http://ccl.northwestern.edu/netlogo/>. Center for Connected Learning and Computer-Based Modeling, Northwestern Institute on Complex Systems, Northwestern University, Evanston, IL.

## COPYRIGHT AND LICENSE

Copyright 2015 Miguel Pessanha Pais and Christine Ward-Paige.

![CC BY-NC-SA 4.0](http://ccl.northwestern.edu/images/creativecommons/byncsa.png)

This work is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 4.0 License.  To view a copy of this license, visit <http://creativecommons.org/licenses/by-nc-sa/4.0/> or send a letter to Creative Commons, 559 Nathan Abbott Way, Stanford, California 94305, USA.
