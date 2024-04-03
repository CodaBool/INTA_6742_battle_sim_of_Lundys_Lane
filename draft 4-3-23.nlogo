globals [
  victory
  isNight ; Determines if it is currently night or day
  num_americans
  american_casualties
  num_british
  british_casualties
  walk
]

breed [british-infantry-West british-infantry-West-s]      ;; British infantry
breed [british-infantry-Mid british-infantry-Mid-s]      ;; British infantry
breed [british-infantry-East british-infantry-East-s]      ;; British infantry
breed [british-cavalry british-cavalry-s]        ;; British cavalry
breed [british-cannon-6-pound british-cannon-6-pound-s]          ;; British 6 pound cannons
breed [british-cannon-24-pound british-cannon-24-pound-s]          ;; British 24 pound cannons
breed [british-congreves british-congreve-s]          ;; British congreves
breed [british-howitzers british-howitzers-s]    ;; British howitzers

breed [american-infantry american-infantry-s]    ;; American infantry
breed [american-volunteers american-volunteers-s];; American volunteers
breed [american-cavalry american-cavalry-s]      ;; American cavalry
breed [american-cannon-6-pound american-cannon-6-pound-s]        ;; American 6 pound cannons
breed [american-cannon-18-pound american-cannon-18-pound-s]        ;; American 18 pound cannons
breed [american-howitzers american-howitzers-s]  ;; American howitzers
breed [Jessups-infantry Jessups-infantry-s] ;; Jessup's 380 men on East Flank in woods

patches-own [
  terrain       ;; type of patch: "hill", "road", "plain", "woods"
  elevation     ;; elevation of the patch (feet)
  visibility    ;; visibility of the patch
]

turtles-own [
  energy                 ; Energy level of the turtle
  health                 ; health level of turtle
  speed                  ; patches (50 feet) per 10 seconds
  retreating            ; Whether the turtle is retreating
  firingrange            ; Range of attack for the turtle
  accuracy               ; Accuracy of the turtle's attack
  kills-per-hit          ; Number of kills per successful hit
  firing-rate            ; Rate of fire for the turtle
  max-shots              ; Maximum number of shots the turtle can fire

]

to setup
  clear-all
  setup-map
  set victory False
  setup-turtles
  reset-ticks
end



to setup-map
  clear-all
  resize-world -250 300 -250 250 ;; set the world size
  set-patch-size 1 ;; this is 6x6 ft real life

  ;; Set up hills, woods, and plains
  ask patches [
    let center-x -50 ;; x-coordinate of hill center
    let center-y 75  ;; y-coordinate of hill center
    let distance-to-center sqrt ((pxcor - center-x) ^ 2 + (pycor - center-y) ^ 2)

    ;; Calculate elevation, difficulty, and visibility based on distance from hill center
    ifelse distance-to-center <= 75 [
      set terrain "hill"
      set pcolor brown
      set elevation 2.5 - distance-to-center  ;; Decrease elevation towards the edge of the hill
      set visibility 0 ;; POSSIBLE PROBLEM need to see up hill, not through it
    ] [
      ifelse (3 * pxcor + pycor) >= 600 [
        set terrain "woods"
        set pcolor green
        set elevation 0
        set visibility 0.5 ;; Woods have visibility of 0.5
      ] [
        ifelse  (.1 * pxcor + pycor) <= -120 [
          set terrain "woods"
          set pcolor green
          set elevation 0
          set visibility 0.5 ;; Woods have visibility of 0.5
        ] [
          set terrain "plain"
          set pcolor [255 228 181] ;; light brown color
          set elevation 0
          set visibility 1 ;; Plains have full visibility
      ]
    ]
  ]]

  ;; Set up portage road
  let start-x 275
  let start-y -250
  ask patches [
    let road-width 10
    let x-dist -1 * pxcor + start-x
    let y-dist abs (pycor - (start-y + (3 * x-dist)))
    if x-dist <= 200 and y-dist <= road-width [
      set terrain "road"
      set pcolor gray
      set elevation 0
      set visibility 1 ;; Roads have full visibility
    ]
  ]

  ;; Set up Lundy's Lane road
  let road-y 100
  ask patches with [pycor >= road-y and pycor <= road-y + 5] [
    set terrain "road"
    set pcolor gray
    set elevation 0
    set visibility 1 ;; Roads have full visibility
  ]

  reset-ticks
end

to setup-turtles
  set walk 3.3
  ; Setup British infantry
  create-british-infantry-West 1125 [
    set color red
    set size 1.5
    setxy (-230 + random 100) (50 + random 5) ; Other half will form the second line
    set energy 100
    set retreating false
    set speed walk
    set firingrange 30
    set health 100
    set accuracy 0.05
    set kills-per-hit 0.13
    set firing-rate 3.5 / 60 ; 3.5 per minute converted to per second
    set max-shots 80
    set retreating False
  ]

    create-british-infantry-Mid 1125 [
    set color red
    set size 1.5
    setxy (-110 + random 100) (100 + random 5) ;
    set energy 100
    set retreating false
    set speed walk
    set firingrange 30
    set health 100
    set accuracy 0.05
    set kills-per-hit 0.13
    set firing-rate 3.5 / 60 ; 3.5 per minute converted to per second
    set max-shots 80
    set retreating False
  ]

    create-british-infantry-East 1125 [
    set color red
    set size 1.5
    setxy (40 + random 100) (100 + random 5)
    set energy 100
    set retreating false
    set speed walk
    set firingrange 30
    set health 100
    set accuracy 0.05
    set kills-per-hit 0.13
    set firing-rate 3.5 / 60 ; 3.5 per minute converted to per second
    set max-shots 80
    set retreating False
  ]

  ; Setup British cavalry
  create-british-cavalry 125 [
    set color red
    set size 2
    setxy (-110 + random 100) (100 + random 5)  ;
    set shape "circle"
    set energy 100
    set speed walk * 3
    set health 100
    set retreating false
    set firingrange 8
    set accuracy 0.05
    set kills-per-hit 0.13
    set firing-rate 7 / 60 ; 7 per minute converted to per second
    set max-shots 40
    set retreating False
  ]

  ; Setup British cannons
  create-british-cannon-6-pound 2 [
    set color red
    set size 10
    setxy -50 77  ;; Position for the first turtle
    set shape "triangle"
    set energy 100
    set health 800
    set speed 0
    set health 800
    set firingrange 500
    set accuracy 0.5
    set kills-per-hit 9
    set firing-rate 2 / 60 ; 2 per minute converted to per second
    set max-shots 110
    set retreating False
  ]

    create-british-cannon-24-pound 2 [
    set color red
    set size 10
    setxy -42 77  ;; Position for the first turtle
    set shape "triangle"
    set energy 100
    set health 100
    set health 1300
    set firingrange 200
    set accuracy 0.5
    set speed 0
    set kills-per-hit 40
    set firing-rate 1 / 60 ; 2 per minute converted to per second
    set max-shots 150
    set retreating False
  ]

  ; Setup British howitzers
  create-british-howitzers 1 [
    set color red
    set size 10
    setxy -34 77  ;; Position for the first turtle
    set shape "triangle"
    set energy 100
    set health 800
    set firingrange 400
    set speed 0
    set accuracy 0.4
    set kills-per-hit 9
    set firing-rate 1 / 60 ; 1 per minute converted to per second
    set max-shots 110
    set retreating False
  ]

    ; Setup British congreves
  create-british-congreves 2 [
    set color red
    set size 10
    setxy -26 77  ;; Position for the first turtle
    set shape "triangle"
    set energy 100
    set health 2500
    set firingrange 1500
    set speed 0
    set accuracy 0.01
    set kills-per-hit 9
    set firing-rate 2 / 60 ; 1 per minute converted to per second
    set max-shots 110
    set retreating False
  ]

  ; Setup American infantry
  create-american-infantry 1504 [
    set color blue
    set size 1.5
    setxy (50 + random 150) (-100 + random 5)
    set energy 100
    set retreating false
    set firingrange 30
    set accuracy 0.03
    set speed walk
    set kills-per-hit 0.13
    set firing-rate 2 / 60 ; 2 per minute converted to per second
    set max-shots 80

  ]
    create-Jessups-infantry 380 [
    set color blue
    set size 1.5
    setxy (250 + random 10) (-100 + random 25)
    set energy 100
    set firingrange 30
    set accuracy 0.03
    set speed walk
    set kills-per-hit 0.13
    set firing-rate 2 / 60 ; 2 per minute converted to per second
    set max-shots 80
    set retreating False
  ]

  ; Setup American volunteers
  create-american-volunteers 546 [
    set color cyan
    set size 1.5
    setxy (0 + random 50) -100 + random 5
    set energy 100
    set firingrange 25
    set accuracy 0.03
    set speed walk
    set kills-per-hit 0.13
    set firing-rate 2 / 60 ; 2 per minute converted to per second
    set max-shots 80
    set retreating False
  ]

  ; Setup American cavalry
  create-american-cavalry 70 [
    set color blue
    set shape "circle"
    set size 2
    setxy (220 + random 10) -100 + random 5
    set energy 100
    set firingrange 8
    set accuracy 0.05
    set speed walk * 3
    set kills-per-hit 0.13
    set firing-rate 7 / 60 ; 7 per minute converted to per second
    set max-shots 40
    set retreating False
  ]

  ; Setup American cannons
  create-american-cannon-6-pound 4 [
    set color blue
    set size 10
    setxy (220 + random 5) -90 + random 5
    set energy 100
    set shape "triangle"
    set health 800
    set firingrange 500
    set speed 0
    set accuracy 0.5
    set kills-per-hit 9
    set firing-rate 2 / 60 ; 2 per minute converted to per second
    set max-shots 110
    set retreating False
  ]

    ; Setup American cannons
  create-american-cannon-18-pound 4 [
    set color blue
    set size 10
    setxy (217 + random 5) -80 + random 5
    set energy 100
    set shape "triangle"
    set health 1200
    set firingrange 900
    set speed 0
    set accuracy 0.5
    set kills-per-hit 10
    set firing-rate 1 / 60 ; 2 per minute converted to per second
    set max-shots 110
    set retreating False
  ]

  ; Setup American howitzers
  create-american-howitzers 2 [
    set color blue
    set size 10
    set shape "triangle"
    setxy (214 + random 5) -70 + random 5
    set energy 100
    set health 800
    set speed 0
    set firingrange 400
    set accuracy 0.4
    set kills-per-hit 9
    set firing-rate 1 / 60 ; 1 per minute converted to per second
    set max-shots 110
    set retreating False
  ]
end



to go
  set american_casualties 0
  set british_casualties 0

  while [not victory and ticks < 200] [  ; Continue simulation until victory condition met
    move-turtles
    british-attack
    american-attack
    update-energy
    update-environment
    check-victory-condition
    retreat-if-loss american-cavalry 70 * .9 180 -210
    retreat-if-loss american-volunteers 546 * .6 180 -210
    retreat-if-loss american-infantry 1504 * .6 180 -210
    retreat-if-loss Jessups-infantry 380 * .6 180 -210
    retreat-if-loss british-infantry-East 1125 * .7 0 200
    retreat-if-loss British-Infantry-Mid 1125 * .7 0 200
    retreat-if-loss British-Infantry-West 1125 * .7 0 200
    tick
    print word "Ticks: " ticks
    if ticks > 150 [stop]
  ]
end
to move-turtles
  if ticks >= 60[
  ask american-infantry [
      ; Calculate the angle towards the target position
      let angle -45

      ; Set the heading to the calculated angle
      set heading angle

      ; Move the turtle forward
      if ycor <= 75 [
      fd speed
    ]
      ; Check if they are within a certain range of the hill to simulate capturing it
      ifelse terrain = "hill" [
        ; If the turtle is on the hill, simulate capturing it
        ; Your capture logic goes here
      ] [
        ; If the turtle is not on the hill, check if it's close to the hill
        let distance-to-hill sqrt ((pxcor + 50 ) ^ 2 + (pycor - 75) ^ 2)
        if ycor >= 70 [
          stop
        ]
      ]
    ]

    ask american-volunteers [
      ; Calculate the angle towards the target position
      let angle -45

      ; Set the heading to the calculated angle
      set heading angle

      ; Move the turtle forward
      if ycor <= 75 [
      fd speed
    ]
      ; Check if they are within a certain range of the hill to simulate capturing it
      ifelse terrain = "hill" [
        ; If the turtle is on the hill, simulate capturing it
        ; Your capture logic goes here
      ] [
        ; If the turtle is not on the hill, check if it's close to the hill
        let distance-to-hill sqrt ((pxcor + 50 ) ^ 2 + (pycor - 75) ^ 2)
        if ycor >= 70 [
          stop
        ]
      ]
    ]
   ask american-cavalry [
  ; Set the heading to -10 degrees
  set heading -19.5

  ; Move the turtle forward until it reaches y-coordinate 80
  if ycor <= 100  [
        if ycor >= -200[
          fd speed]
  ]]]

ask Jessups-infantry [
  ; Set the heading to -10 degrees
  set heading -15

  ; Check if there are nearby enemies within 5 patches
    let nearby-enemies (turtle-set british-infantry-West british-infantry-East british-infantry-Mid british-cavalry) with [distance myself <= 15]

  ifelse any? nearby-enemies [
    ; If there are nearby enemies, stop moving
    stop
  ] [
    ; If no nearby enemies, continue moving
    if ticks >= 53  [
      set heading -90
    ]
    fd speed * 1.1
  ]
]
end



to retreat-if-loss [breed-name threshold retreat-direction regroup-position]
  if  count turtles with [breed = breed-name] < threshold [
    print word breed-name "retreating!"
    ask turtles with [breed = breed-name] [
      ifelse ( abs ycor >= abs regroup-position)[
        stop
      ]
      [set heading retreat-direction
      fd speed

      ]
      ]

  ]
end

to british-attack
  ask british-cannon-6-pound [
    ;; Check for nearby enemies within firing range
    let targets (turtle-set american-infantry american-volunteers american-cavalry) with [distance myself <= 3000]
    ;; Check if there are any targets available
    if any? targets [
      ;; Fire the cannon once every 6 ticks
      if ticks mod  1 = 0 [
        ;; Check if the attack hits based on accuracy
        if random-float 1 < .5 [
          ;; Reduce targets based on kills per hit
          ask n-of 4 targets [
            die]
          set american_casualties american_casualties + 4
  ]]]]
  ask british-cannon-24-pound [
    ;; Check for nearby enemies within firing range
    let targets (turtle-set american-infantry american-volunteers american-cavalry) with [distance myself <= 1200]
    ;; Check if there are any targets available
    if any? targets [
      if ticks mod 2 = 0 [
        ;; Check if the attack hits based on accuracy
        if random-float 1 < .25 [
          ;; Reduce targets based on kills per hit
          ask n-of 20 targets [
            die]
          set american_casualties american_casualties + 20
  ]]]]
  ask british-howitzers [
    ;; Check for nearby enemies within firing range
    let targets (turtle-set american-infantry american-volunteers american-cavalry) with [distance myself <= 2400]
    ;; Check if there are any targets available
    if any? targets [
      ;; Fire the cannon once every 6 ticks
      if ticks mod 2 = 0 [
        ;; Check if the attack hits based on accuracy
        if random-float 1 < .2 [
          ;; Reduce targets based on kills per hit
          ask n-of 9 targets [
            die]
          set american_casualties american_casualties + 9
  ]]]]
  ask british-congreves [
    ;; Check for nearby enemies within firing range
    let targets (turtle-set american-infantry american-volunteers american-cavalry) with [distance myself <= 1500]
    ;; Check if there are any targets available
    if any? targets [
      ;; Fire the cannon once every 6 ticks
      if ticks mod 1 = 0 [
        ;; Check if the attack hits based on accuracy
        if random-float 1 < .005 [
          ;; Reduce targets based on kills per hit
          ask n-of 9 targets [
            die]
          set american_casualties american_casualties + 9
  ]]]]

  ask british-infantry-West [
    ;; Check for nearby enemies within firing range
    let targets (turtle-set american-infantry american-volunteers american-cavalry) with [distance myself <= 30]
    ;; Check if there are any targets available
    if any? targets [
      ;;fire
      if ticks mod .4 = 0 [

        ;; Check if the attack hits based on accuracy
        if random-float 1 < .01 [
          ;; Reduce targets based on kills per hit
          ask n-of 1 targets [
            die]
          set american_casualties american_casualties + 1

  ]]]]
    ask british-infantry-Mid [
    ;; Check for nearby enemies within firing range
    let targets (turtle-set american-infantry american-volunteers american-cavalry) with [distance myself <= 30]
    ;; Check if there are any targets available
    if any? targets [
      ;;fire
      if ticks mod .2 = 0 [
        ;; Check if the attack hits based on accuracy
        if random-float 1 < .01 [
          ;; Reduce targets based on kills per hit
          ask n-of 1 targets [
            die]
          set american_casualties american_casualties + 1
  ]]]]
    ask british-infantry-East [
    ;; Check for nearby enemies within firing range
    let targets (turtle-set american-infantry american-volunteers american-cavalry) with [distance myself <= 30]
    ;; Check if there are any targets available
    if any? targets [
      ;;fire
      if ticks mod 2 = 0 [
        ;; Check if the attack hits based on accuracy
        if random-float 1 < .02 [
          ;; Reduce targets based on kills per hit
          ask n-of 1 targets [
            die]
          set american_casualties american_casualties + 1
  ]]]]
  print (word "American casualties: " american_casualties)
end

to american-attack
   ask american-infantry [
    ;; Check for nearby enemies within firing range
    let targets (turtle-set british-infantry-West british-infantry-East british-infantry-Mid british-cavalry) with [distance myself <= 30]
    ;; Check if there are any targets available
    if any? targets [
      ;;fire
      if ticks mod 2 = 0 [
        ;; Check if the attack hits based on accuracy
        if random-float 1 <= 0.02 [
          ;; Reduce targets based on kills per hit
          ask n-of 1 targets [
            die]
          set british_casualties british_casualties + 1
  ]]]]
     ask jessups-infantry [
    ;; Check for nearby enemies within firing range
    let targets (turtle-set british-infantry-West british-infantry-East british-infantry-Mid british-cavalry) with [distance myself <= 30]
    ;; Check if there are any targets available
    if any? targets [
      ;;fire
      if ticks mod 2 = 0 [
        ;; Check if the attack hits based on accuracy
        if random-float 1 <= 0.02 [
          ;; Reduce targets based on kills per hit
          ask n-of 1 targets [
            die]
            set british_casualties british_casualties + 1
  ]]]]
     ask american-cavalry [
    ;; Check for nearby enemies within firing range
    let targets (turtle-set british-infantry-West british-infantry-East british-infantry-Mid british-cavalry) with [distance myself <= 6]
    ;; Check if there are any targets available
    if any? targets [
      ;;fire
      if ticks mod 2 = 0 [
        ;; Check if the attack hits based on accuracy
        if random-float 1 <= 0.02 [
          ;; Reduce targets based on kills per hit
          ask n-of 1 targets [
          die]
            set british_casualties british_casualties + 1
  ]]]]
       ask american-volunteers [
    ;; Check for nearby enemies within firing range
    let targets (turtle-set british-infantry-West british-infantry-East british-infantry-Mid british-cavalry) with [distance myself <= 25]
    ;; Check if there are any targets available
    if any? targets [
      ;;comb
      if ticks mod 2 = 0 [
          if random-float 1 <= 0.015 [
          ;; Reduce targets based on kills per hit
          ask n-of 1 targets [
          die]
            set british_casualties british_casualties + 1
  ]]]]
  ask american-cannon-6-pound [
    ;; Check for nearby enemies within firing range
    let targets (turtle-set british-infantry-east) with [distance myself <= 500]
    ;; Check if there are any targets available
    if any? targets [
      ;; Fire the cannon once every 6 ticks
      if ticks mod  2 = 0 [
        ;; Check if the attack hits based on accuracy
        if random-float 1 < .15 [
          ;; Reduce targets based on kills per hit
          ask n-of 4 targets [
            die]
          set british_casualties british_casualties + 4
  ]]]]
  ask american-cannon-18-pound [
    ;; Check for nearby enemies within firing range
    let targets (turtle-set british-infantry-east) with [distance myself <= 900]
    ;; Check if there are any targets available
    if any? targets [
      ;; Fire the cannon once every 6 ticks
      if ticks mod  4 = 0 [
        ;; Check if the attack hits based on accuracy
        if random-float 1 < .15 [
          ;; Reduce targets based on kills per hit
          ask n-of 10 targets [
            die]
          set british_casualties british_casualties + 10
  ]]]]
  ask american-howitzers [
    ;; Check for nearby enemies within firing range
    let targets (turtle-set british-infantry-east) with [distance myself <= 3000]
    ;; Check if there are any targets available
    if any? targets [
      ;; Fire the cannon once every 6 ticks
      if ticks mod  4 = 0 [
        ;; Check if the attack hits based on accuracy
        if random-float 1 < .15 [
          ;; Reduce targets based on kills per hit
          ask n-of 9 targets [
            die]
          set british_casualties british_casualties + 9
  ]]]]
  print (word "British casualties: " british_casualties)
end




;; Update energy for all moving turtles; this will be called whenever a turtle moves.
to update-energy
  ask turtles [
    ifelse terrain = "flat" or terrain = "clear"
      [ set energy energy - 1 ] ;; Energy cost for moving on flat/clear terrain.
      [ set energy energy - 1.5 ] ;; Energy cost for moving on difficult terrain (hills/forests).

    ;; Turtles stop moving or reduce their activity if energy is too low.
    if energy < 20 [
      ;; Possible behavior: turtle stops moving. We could simulate resting or reduced combat effectiveness.
      set heading 0 ;;
    ]
  ]
end

; Update the day/night cycle and adjust opacity.
to update-environment
  ; Condition to toggle day/night
  ifelse ticks < 180 [
    set isNight false
    ;ask patches [ set pcolor scale-color green elevation 0 10 ]
  ] [
    set isNight true
    ask patches [ set pcolor scale-color green ticks 20 00 ]
  ]
end

; Modify turtle behavior based on isNight.
to update-turtle-behavior
  ask turtles [
    ifelse isNight [
      ; Adjust turtle behavior for night, e.g., reduce visibility range and increase energy consumption.
      set energy energy - 1.5 ; Increase energy depletion rate at night.
      set firingrange firingrange * 0.5  ; Decrease firing range and accuracy by 50%
      set accuracy accuracy * 0.5
    ] [
      ; Daytime behavior, normal energy consumption.
      set energy energy - 1
    ]
  ]
end


to check-victory-condition
  ; Code to check if any side has won the battle
  ; Example: If one side loses more than 70% of their forces, declare the other side as the winner
  if  british_casualties >= 3500 * .7 [
      set victory True
    output-print (word "Victory for the Americans!")
    ]
  if  american_casualties >= 2500 * 0.7 [
      set victory True
    output-print (word "Victory for the British!")
    ]
end



;;CHANGES made 3/21
;;PATCH IS 6 FT X 6 FT
;;TICK IS 1 MIN


;; TO DO BEFORE RECORD
;; VICTORY PROCEDURE (done)
;; RETREAT PROCEDURE (done)
;; ALL TROOPS ATTACKING (done)
;; BRITISH TROOP DISTRIBUTION



;;AFTER RECORD
;; implement the nightfall
;; Minimum effective range for artillery?
;; cavalry don't shoot jessusp
;; convert spaghetti code into clean code (make functions)
;; Effect of elevation on cannon range
;; Victory procedure
;; Who holds the hill procedure
;; retreat procedure
;; implement musket and bayonet fire (right now only the artillery is active)
@#$#@#$#@
GRAPHICS-WINDOW
210
10
769
520
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
-250
300
-250
250
0
0
1
ticks
30.0

BUTTON
59
89
126
123
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
0
127
201
160
Go (toggle forever to stop)
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

PLOT
4
527
772
703
Casualties
Time
Count
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"British" 1.0 0 -2674135 true "" "plot british_casualties"
"American" 1.0 0 -13791810 true "" "plot american_casualties"

SLIDER
7
298
179
331
location-policy
location-policy
0
10
2.0
1
1
NIL
HORIZONTAL

MONITOR
29
338
169
427
Americans
count american-infantry +\ncount american-volunteers +\ncount american-cavalry +\ncount american-cannon-6-pound +\ncount american-cannon-18-pound +\ncount american-howitzers +\ncount Jessups-infantry
17
1
22

MONITOR
30
431
170
520
  British     
count british-infantry-West +\ncount british-infantry-Mid +\ncount british-infantry-East +\ncount british-cavalry +\ncount british-cannon-6-pound +\ncount british-cannon-24-pound +\ncount british-congreves +\ncount british-howitzers
17
1
22

BUTTON
10
168
187
201
Stop (not working atm)
stop
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

@#$#@#$#@
## WHAT IS IT?

(a general understanding of what the model is trying to show or explain)

## HOW IT WORKS

(what rules the agents use to create the overall behavior of the model)

## HOW TO USE IT

(how to use the model, including a description of each of the items in the Interface tab)

## THINGS TO NOTICE

(suggested things for the user to notice while running the model)

## THINGS TO TRY

(suggested things for the user to try to do (move sliders, switches, etc.) with the model)

## EXTENDING THE MODEL

(suggested things to add or change in the Code tab to make the model more complicated, detailed, accurate, etc.)

## NETLOGO FEATURES

(interesting or unusual features of NetLogo that the model uses, particularly in the Code tab; or where workarounds were needed for missing features)

## RELATED MODELS

(models in the NetLogo Models Library and elsewhere which are of related interest)

## CREDITS AND REFERENCES

(a reference to the model's URL on the web if it has one, as well as any other necessary credits, citations, and links)
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
NetLogo 6.4.0
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
0
@#$#@#$#@
