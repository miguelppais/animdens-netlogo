## WHAT IS IT?

AnimDens NetLogo 1.1

This is a model that simulates divers counting sharks while deploying belt-transect, stationary-point-count and roving underwater visual census techniques. The model demonstrates how non-instantaneous sampling techniques produce bias by overestimating the number of counted animals, when they move relative to the person counting them.

This is applied to divers and sharks, but is intended to reflect what happens with many other animal censuses (aerial surveys, bird transects, etc.).

The model can be used to demonstrate that bias increases as the speed of the animals relative to the observer increases.

Using the provided bias calculator, it is possible to use the output of the model to apply bias correction to field data.

## HOW IT WORKS

The model assumes an area that is featureless and flat, with a default size of 200x200 cells each with an area of 1 square meter. The origin of the coordinate system is on the bottom left corner and depth is ignored (assumed constant).

For each simulation, the divers start in the middle and face north. Sharks and transect divers move every second, but the time step for counting can be set to 2 seconds for shorter computing times (set by default on the original model, but note that some sharks may be missed, particularly if they are very fast).

At each counting time step, divers count the number of sharks they can see based on the direction the diver is facing, the visibility distance and angle. Viewing angles are fixed and cannot be changed on the interface. They are set to 160º for the stationary and roving divers and 180º for the transect diver.

On the belt-transect method, only fish within the transect width are counted, while on the stationary-point-count method, only fish within a pre-determined radius are counted.

Transect diver moves in a fixed direction at a constant speed (default is 4 m/minute).

Stationary diver rotates a given number of degrees clockwise every second (default is 4).

Sharks move at a speed specified by the user, and travel in a direction that is restricted by a turning angle based on the previous direction.

Roving divers move similarly to sharks and have their own speed and turning angle parameters. Turning happens every 2 seconds.

Sharks and divers that reach the boundaries of the area wrap around to the opposite side, to keep the density constant (on the original model they can leave the area, but that doesn't seem to have significant effects on the output, if the area is large enough.

Divers keep a memory of every individual shark counted and do not recount.

## HOW TO USE IT

In order to speed up model runs, please disable update view (at the top).

The "setup" button feeds all parameter values into the model, places the selected divers and spreads all the sharks across the area.

The "go" button runs the model for the time specified in survey.time (default is 300 seconds) and then stops. The model can be stopped or paused at any time by pressing the go button while it is running. The "go once" button avances the model run by 1 second each time.

The "setup with default parameter values" button sets all parameters to values used in the first experiment by Ward-Paige et al. (2010) with shark speed set to 1 m/s. The model is automatically setup and you just need to press "go".

"transect.width" sets the width of the belt transect that is sampled as the diver swims in the center (half of the width to each side of the diver).

To set the initial number of sharks, introduce the total number of sharks directly under "numb.sharks" on the interface. Alternatively (and preferably), you can set the real density needed under "shark.density" and the model will place the right number of sharks for the total area. If shark.density is set to a value greater than 0 when the model starts, it has priority over "numb.sharks".

Select the sampling methods that will be in the model run by turning their swiches on and off on the interface. Please note that the roving diver will not calculate densities and thus will not estimate bias. If you want to see the details of every diver in a floating window during the run, switch on "show.diver.detail.windows?".

If you want the transect and roving divers to draw a path as they move, switch on "show.paths?".

Stationary.radius must be set to a value lower than visibility.length.

In the end of each run, each diver reports its relative bias, calculated as:

(real count - expected count) / expected count

where "expected count" is basically the shark density in the model multiplied by the total sampled area.

For the stationary diver:

sampled area = pi * stationary.radius^2

For the transect diver:

sampled area = survey.time * (transect.diver.speed / 60) * transect.width + visibility length * transect.width

Notice that the final part of the transect is approximated to a rectangle of length equal to the visibility length, instead of taking into account the arc produced by the cone of vision. This was done in the original model and, with relatively large visibility lengths, does not seem to have much impact on the final result.

The model will also output the conversion factor value for each method (transect and stationary). The real count (in the field) divided by this factor value should provide an estimate that is corrected to account for bias (given that all parameters are realistically set).

## THINGS TO NOTICE

If "view updates" is enabled and speed is set to "normal", the model will run in real time (every second in the model will run in one second).

To understand the source of the bias, compare a model run with shark.mean.speed set to 0 m/s (stationary sharks) and another with shark.mean.speed set to 1 m/s. Keep everything else default.

In the first case (stationary sharks), the sampling method will be equivalent to taking a snapshot of the whole sampling area. The sharks will stand still and the diver will count every shark in the sampling area, not repeating any shark. This will produce little to no bias in the estimates.

In the case where sharks move 1 meter every second (while the diver is moving 4 meters every minute), there will be new sharks coming into the sampling area that were not there in the beginning. These sharks will all be counted as they pass in front of the diver, increasing the number of counted sharks, while the real number of sharks in the beginning was much lower. This produces the bias.

If the speed of the sharks is even higher, there are more sharks coming into the field of view of the diver and the bias will be even higher.

## THINGS TO TRY

- Switch on just the transect diver and see how increasing shark speeds increases bias. Why does this happen?

- Do the same for the stationary diver. The results are similar, why?

- With stationary sharks (speed 0) and moving divers, bias is almost zero, but what about stationary divers with moving sharks? Place a stationary diver with stationary.turning.angle set to 0 and sharks with speed > 0 and see the results.

- Run a model in real time (normal speed and "view updates" checked) with the default parameters. While it is running, press the follow button in front of the transect diver switch to focus the view on that diver. Now head to the top right corner of the world window and click "3D" to go to the 3D view. Observing the diver from this perspective as it counts sharks is a great way of understanding the bias in non-instantaneous sampling of moving animals.

- Going to tools -> behaviorSpace, you can see there are 2 experiments created that correspond to the experiments run by Ward-Paige et al. (2010). One to observe the increase in bias with increasing shark speed (30 replicates per run) and one to test every combination of values from a set of realistic candidates (a single run per combination) and observe the resulting bias (prepare for long computing times with this one).

## USING THE BIAS CALCULATOR

The model can be used as a tool to get better estimates from field surveys using the bias calculator at the bottom.

To make corrections to observed values (values observed in the field by non-instantaneous surveys):

1. Decide on targeted fish species and select an appropriate speed and turning angle for that species.
2. Select most appropriate sampling values (e.g. transect width, swim speed, survey time, etc.) Note: for visibility, select the distance you would be sure to detect the targeted fish.
3. Run the model with the selected parameters, making sure that your sampling method of choice is turned on in the switches.
4. After the survey time finishes the model stops and the conversion factor is calculated.
5. On the calculator, go to the "observed.value" box and input the number of fish from that species you counted in the field
6. Select the appropriate method on the calculator (transect or stationary)
7. Press calculate. The result is the "real" count, corrected for bias.
8. Repeat for other species.

## NOTES ON THE ADAPTATION TO NETLOGO

On the original model, the sharks could leave the area and come back (or leave permanently). Here the world is set to wrap around the edges. For an area that is large enough, this does not seem to affect the final results. In order to reflect what was made in the original model in R, one can set a buffer area around where no sharks are placed. If for some reason we want sharks to leave and never come back, we can just remove them when they reach the edges.

The sharks in NetLogo have a visual representation, unlike in the original R model, where they were just points. However, in the counting procedure only the coordinates of the sharks are checked to see if they are counted, so their size is basically ignored and does not influence results.

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

Another publication that uses the roving diver:

Ward-Paige, C.A., Lotze, H.K., 2011. Assessing the Value of Recreational Divers for Censusing Elasmobranchs. PLoS ONE 6(10): e25609. doi:10.1371/journal.pone.0025609

URL: http://journals.plos.org/plosone/article?id=10.1371/journal.pone.0025609

In order to cite the NetLogo implementation:

Pais, M.P., Ward-Paige, C.A. (2015). AnimDens NetLogo model. http://modelingcommons.org/browse/one_model/4408

In order to cite the NetLogo software:

Wilensky, U. (1999). NetLogo. http://ccl.northwestern.edu/netlogo/. Center for Connected Learning and Computer-Based Modeling, Northwestern Institute on Complex Systems, Northwestern University, Evanston, IL.

## COPYRIGHT AND LICENSE

Copyright 2015 Miguel Pessanha Pais and Christine Ward-Paige.

![CC BY-NC-SA 3.0](http://ccl.northwestern.edu/images/creativecommons/byncsa.png)

This work is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 3.0 License.  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-sa/3.0/ or send a letter to Creative Commons, 559 Nathan Abbott Way, Stanford, California 94305, USA.

## CHANGELOG

1.1
World size decreased to 100x100 by default.
Info tab text revised.
New shape for divers.
Added contact in info tab (for feedback).
World changed from black to dark blue with squares (for scale).

1.0
Added buttons to follow divers.
Added a "clear outputs" button.
Added some guides directly on the interface.
Diver.memory switch removed.
"reset to defaults" button now resets values and runs setup automatically.
Re-arranged the interface to fit the new text notes.

0.9
Added a bias calculator to use after model runs.
Input for shark movement parameters became free and not restricted to pre-determined options.
Re-arranged the interface.

0.8
Added all original parameters and model processes.
Timed transects, stationary diver, roving diver.
Added a button to turn off diver memory.