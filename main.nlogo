globals [
  victory
  isNight ; Determines if it is currently night or day
  num_americans
  american_casualties
  num_british
  british_casualties
  walk
  reload-index
  hit-roll
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
  reload                 ; Determines how many ticks before the turtle is ready to fire
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
  set-patch-size 1 ;; this is 5x5 ft real life

  ;; Set up hills, woods, and plains
  ask patches [
    let center-x -50 ;; x-coordinate of hill center
    let center-y 75  ;; y-coordinate of hill center
    let distance-to-center sqrt ((pxcor - center-x) ^ 2 + (pycor - center-y) ^ 2)

    ;; Calculate elevation, difficulty, and visibility based on distance from hill center
    ifelse distance-to-center <= 82 [
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
  set walk 1
  ; Setup British infantry
  create-british-infantry-West 1125 [
    set color red
    set size 1.5
    setxy (-230 + random 100) (50 + random 5) ; Other half will form the second line
    set energy 100
    set retreating false
    set speed walk
    set firingrange 30
    set reload 17 ;; determines fire rate
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
    set reload 17 ;; determines fire rate
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
    set reload 17 ;; determines fire rate
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
    set reload 9 ;; determines fire rate
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
    set reload 30 ;; determines fire rate
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
    set reload 60 ;; determines fire rate
    set accuracy 0.5
    set speed 0
    set kills-per-hit 40
    set firing-rate 1 / 60 ; 1 per minute converted to per second
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
    set reload 60 ;; determines fire rate
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
    set reload 120 ;; determines fire rate
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
    set reload 17 ;; determines fire rate
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
    set reload 17 ;; determines fire rate
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
    set reload 30 ;; determines fire rate
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
    set reload 9 ;; determines fire rate
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
    set reload 30 ;; determines fire rate
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
    set reload 60 ;; determines fire rate
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
    set reload 60 ;; determines fire rate
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
  set reload-index 0
  set hit-roll 0
  while [not victory and ticks < 2000] [  ; Continue simulation until victory condition met
    set hit-roll random-float 1
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
    set reload-index reload-index + 1
    tick
    print word "Ticks: " ticks
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
  let nearby-enemies turtles in-radius 15 with [breed = british-infantry-east]

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
      ;; Fire the cannon once every 30 ticks
      if reload-index mod reload = 0 [
        ;; Check if the attack hits based on accuracy
        if hit-roll < .5 [
          ;; Reduce targets based on kills per hit
          ask n-of 4 targets [
            die
          ]
          set american_casualties american_casualties + 4
  			]
  		]
    ]
  ]
  ask british-cannon-24-pound [
    ;; Check for nearby enemies within firing range
    let targets (turtle-set american-infantry american-volunteers american-cavalry) with [distance myself <= 1200]
    ;; Check if there are any targets available
    if any? targets [
      ;; Fire the cannon once every 60 ticks
      if reload-index mod reload = 0 [
        ;; Check if the attack hits based on accuracy
        if hit-roll < .25 [
          ;; Reduce targets based on kills per hit
          ask n-of 20 targets [
            die]
          set american_casualties american_casualties + 20
  			]
  		]
    ]
  ]
  ask british-howitzers [
    ;; Check for nearby enemies within firing range
    let targets (turtle-set american-infantry american-volunteers american-cavalry) with [distance myself <= 2400]
    ;; Check if there are any targets available
    if any? targets [
      ;; Fire the cannon once every 60 ticks
      if reload-index mod reload = 0 [
        ;; Check if the attack hits based on accuracy
        if hit-roll < .2 [
          ;; Reduce targets based on kills per hit
          ask n-of 9 targets [
            die]
          set american_casualties american_casualties + 9
  			]
  		]
    ]
  ]
  ask british-congreves [
    ;; Check for nearby enemies within firing range
    let targets (turtle-set american-infantry american-volunteers american-cavalry) with [distance myself <= 1500]
    ;; Check if there are any targets available
    if any? targets [
      ;; Fire the cannon once every 120 ticks
      if reload-index mod reload = 0 [
        ;; Check if the attack hits based on accuracy
        if hit-roll < .005 [
          ;; Reduce targets based on kills per hit
          ask n-of 9 targets [
            die]
          set american_casualties american_casualties + 9
  			]
  		]
    ]
  ]

  ask british-infantry-West [
    ;; Check for nearby enemies within firing range
    let targets (turtle-set american-infantry american-volunteers american-cavalry) with [distance myself <= 30]
    ;; Check if there are any targets available
    if any? targets [
      ;; Fire the musket once every 17 ticks
      if reload-index mod reload = 0 [
        ;; Check if the attack hits based on accuracy
        if hit-roll < .01 [
          ;; Reduce targets based on kills per hit
          ask n-of 1 targets [
            die]
          set american_casualties american_casualties + 1
  			]
  		]
    ]
  ]
    ask british-infantry-Mid [
    ;; Check for nearby enemies within firing range
    let targets (turtle-set american-infantry american-volunteers american-cavalry) with [distance myself <= 30]
    ;; Check if there are any targets available
    if any? targets [
      ;;; Fire the musket once every 17 ticks
      if reload-index mod reload = 0 [
        ;; Check if the attack hits based on accuracy
        if hit-roll < .01 [
          ;; Reduce targets based on kills per hit
          ask n-of 1 targets [
            die]
          set american_casualties american_casualties + 1
  			]
  		]
    ]
  ]
    ask british-infantry-East [
    ;; Check for nearby enemies within firing range
    let targets (turtle-set american-infantry american-volunteers american-cavalry) with [distance myself <= 30]
    ;; Check if there are any targets available
    if any? targets [
      ;; Fire the musket once every 17 ticks
      if reload-index mod reload = 0 [
        ;; Check if the attack hits based on accuracy
        if hit-roll < .02 [
          ;; Reduce targets based on kills per hit
          ask n-of 1 targets [
            die]
          set american_casualties american_casualties + 1
  			]
  		]
    ]
  ]
  print (word "American casualties: " american_casualties)
end

to american-attack
   ask american-infantry [
    ;; Check for nearby enemies within firing range
    let targets (turtle-set british-infantry-West british-infantry-East british-infantry-Mid british-cavalry) with [distance myself <= 30]
    ;; Check if there are any targets available
    if any? targets [
      ;; Fire the musket once every 17 ticks
      if reload-index mod reload = 0 [
        ;; Check if the attack hits based on accuracy
        if hit-roll <= 0.02 [
          ;; Reduce targets based on kills per hit
          ask n-of 1 targets [
            die]
          set british_casualties british_casualties + 1
  			]
  	  ]
    ]
  ]
  ask jessups-infantry [
    ;; Check for nearby enemies within firing range
    let targets (turtle-set british-infantry-East british-cavalry) with [distance myself <= 30]
    ;; Check if there are any targets available
    if any? targets [
      ;; Fire the musket once every 17 ticks
      if reload-index mod reload = 0 [
        ;; Check if the attack hits based on accuracy
        if hit-roll <= 0.02 [
          ;; Reduce targets based on kills per hit
          ask n-of 1 targets [
            die]
            set british_casualties british_casualties + 1
  			]
  		]
    ]
  ]
     ask american-cavalry [
    ;; Check for nearby enemies within firing range
    let targets (turtle-set british-infantry-West british-infantry-East british-infantry-Mid british-cavalry) with [distance myself <= 6]
    ;; Check if there are any targets available
    if any? targets [
      ;; Fire the musket once every 9 ticks
      if reload-index mod reload = 0 [
        ;; Check if the attack hits based on accuracy
        if hit-roll <= 0.02 [
          ;; Reduce targets based on kills per hit
          ask n-of 1 targets [
          die]
            set british_casualties british_casualties + 1
  			]
  		]
    ]
  ]
       ask american-volunteers [
    ;; Check for nearby enemies within firing range
    let targets (turtle-set british-infantry-West british-infantry-East british-infantry-Mid british-cavalry) with [distance myself <= 25]
    ;; Check if there are any targets available
    if any? targets [
      ;; Fire the musket once every 30 ticks
      if reload-index mod reload = 0 [
          if hit-roll <= 0.015 [
          ;; Reduce targets based on kills per hit
          ask n-of 1 targets [
          die]
            set british_casualties british_casualties + 1
  			]
  		]
    ]
  ]
  ask american-cannon-6-pound [
    ;; Check for nearby enemies within firing range
    let targets (turtle-set british-infantry-east) with [distance myself <= 500]
    ;; Check if there are any targets available
    if any? targets [
      ;; Fire the musket once every 30 ticks
      if reload-index mod reload = 0 [
        ;; Check if the attack hits based on accuracy
        if hit-roll < .15 [
          ;; Reduce targets based on kills per hit
          ask n-of 4 targets [
            die]
          set british_casualties british_casualties + 4
  			]
  		]
    ]
  ]
  ask american-cannon-18-pound [
    ;; Check for nearby enemies within firing range
    let targets (turtle-set british-infantry-east) with [distance myself <= 900]
    ;; Check if there are any targets available
    if any? targets [
      ;; Fire the musket once every 60 ticks
      if reload-index mod reload = 0 [
        ;; Check if the attack hits based on accuracy
        if hit-roll < .15 [
          ;; Reduce targets based on kills per hit
          ask n-of 10 targets [
            die]
          set british_casualties british_casualties + 10
  			]
  		]
    ]
  ]
  ask american-howitzers [
    ;; Check for nearby enemies within firing range
    let targets (turtle-set british-infantry-east) with [distance myself <= 3000]
    ;; Check if there are any targets available
    if any? targets [
      ;; Fire the musket once every 60 ticks
      if reload-index mod reload = 0 [
        ;; Check if the attack hits based on accuracy
        if hit-roll < .15 [
          ;; Reduce targets based on kills per hit
          ask n-of 9 targets [
            die]
          set british_casualties british_casualties + 9
  			]
  		]
    ]
  ]
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
