extensions [ gis csv ]
globals [ countries-dataset jet-stream-dataset sunlight-dataset tick-counter temperature]
breed [ country-labels country-label ]
breed [ jet-streams jet-stream ]
breed [ smokes smoke ]
patches-own [ population country-name elevation u-component v-component patch-temperature]
smokes-own [ diffusion-rate ]

to setup
  clear-all
  ; Note that setting the coordinate system here is optional, as
  ; long as all of your datasets use the same coordinate system.
  gis:load-coordinate-system (word "data/WGS_84_Geographic.prj")
  ; Load all of our datasets
  set countries-dataset gis:load-dataset "data/countries.shp"
  ; Set the world envelope to the envelope of countries-dataset
  gis:set-world-envelope (gis:envelope-of countries-dataset)
  set jet-stream-dataset gis:load-dataset "data/jet_stream_data.geojson"
  set sunlight-dataset csv:from-file "data/preprocessed_sunlight_insolation_13_ticks.csv"
  display-jet-streams
  set tick-counter 0
  set-default-shape smokes "circle"
  set temperature 25
  ask patches [
    set patch-temperature temperature
  ]
  reset-ticks
end


; Drawing polygon data from a shapefile, and optionally loading some
; of the data into turtles, if label-countries is true
to display-countries
  ask country-labels [ die ]
  gis:set-drawing-color white
  gis:draw countries-dataset 1
  if label-countries
  [ foreach gis:feature-list-of countries-dataset [ vector-feature ->
      let centroid gis:location-of gis:centroid-of vector-feature
      ; centroid will be an empty list if it lies outside the bounds
      ; of the current NetLogo world, as defined by our current GIS
      ; coordinate transformation
      if not empty? centroid
      [ create-country-labels 1
        [ set xcor item 0 centroid
          set ycor item 1 centroid
          set size 0
          set label gis:property-value vector-feature "CNTRY_NAME"
        ]
      ]
    ]
  ]
  display-population-in-patches
end

; Using gis:apply-coverage to copy values from a polygon dataset
; to a patch variable
to display-population-in-patches
  gis:apply-coverage countries-dataset "POP_CNTRY" population
  ask patches
  [ ifelse (population > 0)
    [ set pcolor scale-color red population 500000000 100000 ]
    [ set pcolor blue ] ]
end


; Randomly choose n number of countries to bomb
; Print in console which ones are bombed
to drop-smoke
  foreach n-of number-of-countries-to-bomb gis:feature-list-of countries-dataset [ vector-feature ->

      ; print in console
      let country gis:property-value vector-feature "LONG_NAME"
      show word "Bombing " country

      let centroid gis:location-of gis:centroid-of vector-feature
      ; centroid will be an empty list if it lies outside the bounds
      ; of the current NetLogo world, as defined by our current GIS
      ; coordinate transformation
      if not empty? centroid
      [
         let x item 0 centroid
         let y item 1 centroid

       create-smokes amount-of-smoke [
       set size smoke-size
       set diffusion-rate random-normal 0 max-smoke-diffusion-rate
       ; Make the smoke move out a bit from point of explosion
       set xcor x + 0.5 + random-float -1
       set ycor y + 0.5 + random-float -1
       set color yellow]
      ]
  ]

end

to go
  throw-sunlight
  diffuse_smoke
  set tick-counter tick-counter + 1
  set tick-counter tick-counter mod 13
  tick
end


to throw-sunlight

  let noof-times-changes-made 0
  let total-change-in-temp 0
  foreach but-first sunlight-dataset [ [ feature ] ->
    let lon item 0 feature
    let lat item 1 feature
    let hour item 2 feature
    let heat item 3 feature
    if hour - 1 = tick-counter [
      let xcor-ycor gis:project-lat-lon lat lon

      if not empty? xcor-ycor [
      let patch-xcor item 0 xcor-ycor
      let patch-ycor item 1 xcor-ycor

        ask patch patch-xcor patch-ycor [
         let smoke-particles-in-patch count smokes-here
         let heat-loss-due-to-smoke heat - smoke-albedo * (0.5 + random-float 0.5) * smoke-particles-in-patch
         let new-temp 0.999 * patch-temperature + 0.001 * (12 + 0.05 * heat)

         set noof-times-changes-made noof-times-changes-made + 1
         let change-in-temp new-temp - patch-temperature
         set total-change-in-temp total-change-in-temp + change-in-temp

         set patch-temperature new-temp
      ]
      ]
    ]
  ]
  let average total-change-in-temp / noof-times-changes-made
  set temperature temperature + average

end

to diffuse_smoke
  ask smokes [
    fd random-float 0.01 * diffusion-rate
  ]
  ask patches [
    let u-component-value u-component
    let v-component-value v-component

    ask smokes-here [
      set xcor xcor + u-component-value * 0.01
      set ycor ycor + v-component-value * 0.01
    ]

  ]
end

to display-jet-streams
  foreach gis:feature-list-of jet-stream-dataset [ vector-feature ->

    let u-component-value gis:property-value vector-feature "U-component_of_wind"
    let v-component-value gis:property-value vector-feature "V-component_of_wind"

    let longitude-value gis:property-value vector-feature "longitude"
    let latitude-value gis:property-value vector-feature "latitude"

    let wind-location gis:project-lat-lon latitude-value longitude-value


    if not empty? wind-location [

      let wind-xcor item 0 wind-location
      let wind-ycor item 1 wind-location

      set wind-xcor round(wind-xcor)
      set wind-ycor round(wind-ycor)

      ask patch wind-xcor wind-ycor [

        set u-component u-component-value
        set v-component v-component-value

      ]

    ]
  ]
end

; Find the bounding rectangle of a country
; input-country : String (Country Name)
to-report find-envelope-of-country [ input-country ]
  let envelope nobody
  foreach gis:feature-list-of countries-dataset [ vector-feature ->
  let country gis:property-value vector-feature "LONG_NAME"
  if input-country = country
    [
      set envelope gis:envelope-of vector-feature
    ]
  ]

  report envelope
end




; Public Domain:
; To the extent possible under law, Uri Wilensky has waived all
; copyright and related or neighboring rights to this model.
@#$#@#$#@
GRAPHICS-WINDOW
242
10
1054
423
-1
-1
4.0
1
8
1
1
1
0
1
1
1
-100
100
-50
50
1
1
1
ticks
30.0

BUTTON
48
132
218
165
NIL
display-countries
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
0

BUTTON
45
19
215
52
NIL
setup\n
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
46
303
226
336
NIL
clear-drawing
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
1122
20
1294
53
smoke-size
smoke-size
0
5
1.5
0.5
1
NIL
HORIZONTAL

SLIDER
1122
89
1297
122
amount-of-smoke
amount-of-smoke
0
3000
1313.0
1
1
NIL
HORIZONTAL

BUTTON
85
249
182
282
Drop Smoke
drop-smoke
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
1137
157
1292
217
number-of-countries-to-bomb
2.0
1
0
Number

BUTTON
58
568
179
601
diffuse_smoke
diffuse_smoke
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
1132
245
1356
278
max-smoke-diffusion-rate
max-smoke-diffusion-rate
0
10
3.5
0.5
1
NIL
HORIZONTAL

BUTTON
99
362
162
395
go
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

SWITCH
63
76
199
109
label-countries
label-countries
1
1
-1000

MONITOR
716
491
798
536
NIL
temperature
17
1
11

SLIDER
1136
318
1308
351
smoke-albedo
smoke-albedo
0
100
50.0
1
1
NIL
HORIZONTAL

@#$#@#$#@
## WHAT IS IT?

This model was built as a tool to answer the question whether Nuclear Winter can solve Global Warming or not.

## HOW IT WORKS

The sequence of steps followed to answer the question are -

1. The countries data is loaded using GIS extension. And they are rendered on world map.
2. Then, jet stream data is loaded to create wind vectors.
3. Nukes are thrown at random countries.
4. Jet streams carry the smoke all around the world.
5. The sunlight temperature data is used as climate model. The equation is used to compute the total net temperature after sunlight is blocked by smoke particles.

## HOW TO USE IT

- Click on setup button and then click on display countries.
- Drop nukes using Drop Nukes button. 
- Click on go button to start the diffusion of smoke particles. 
- Click Display Jet Streams to carry the smoke all around globe.
- Monitor the temperate variable

## THINGS TO TRY

Tweak the sliders smoke-size, amount-of-smoke, number-of-countries-to-bomb, max-smoke-diffusion-rate and observe the temperate variable.


## EXTENDING THE MODEL

This model is built as a tool. Things can be extended using -

- Advanced climate model data.
- Sequential jet stream data.
- Which countries to bomb.
- Amount of smoke carried by each nuke.


## NOTES

### Details on sunlight temperate data

Sunlight data: NASA POWER Project (https://power.larc.nasa.gov/)

Assumptions:

- Sunlight data has the following features (latitude, longitude, time, insolation)
    - Insolation has units of W/m^2 but we've directly used it to calculate temperature using formula from 'Climate Change' model without conversions.
      Ideally you'd expect use of formulae that converts thermal energy into temperature based on heat capacity of receiving object but time doesn't permit.
    - Time feature values range in [1, 13]. Couldn't find data description and have assumed that it is day count (day 1 - day 13).

- CO2 hasn't been accounted for considering model size. To counter this, we are not releasing any heat. Our assumption is that heat will anyway get trapped because of CO2 and increase temperature.

Issues:

- Patch temperature and global temperature are set as the same (25) initially. We have temperature dataset that needs little preprocessing before it can be used to fix this. If time permits, that can be done.

### Details on Jet Streams

#### Jet Stream Data source

- Jet Streams are air currents flowing at 10 KM above Earth's surface. Source: [[1]](#1) 
- The atmospheric layer at 10 KM from Earth's surface is the junction of Troposhere and Stratosphere, which is named Tropopause. Source: [[2]](#2)
- So, the Air Current Data at Tropopause is taken from [National Centers for Environmental Prediction (NCEP), America](https://www.ncep.noaa.gov/) which form the Jet Stream Data.

#### About Jet Stream Data

- Any place on Earth's surface is identified by unique Longitude Latitude position. Source: [[3]](#3)
- For each Longitude Latitude combination, air currents are described as wind vectors in the data.
- In data, each wind vector has a U component and a V component which describes the direction of flow of wind for each patch.

Mathematically:

$wind\hspace{0.1cm}vector = U i^{hat} + V j^{hat}$

#### Jet Stream Data Preprocessing

##### Convert data to geojson

- The Jet Stream Data is in .anl format.
- We used [grib2json](https://github.com/cambecc/grib2json/) library to convert .anl files to geojson so that it can be loaded in Netlogo.

##### Fix Longitude scales

- Longitude vary from 0 to 360 degrees and Latitudes vary from -90 to 90 degrees in the data. Source: [[4]](#4)
- The Netlogo GIS Extension has Longitude defined from -180 to 180. Source: [[5]](#5)
- So, the Longitude range in data is changed from (0:360 scale) to (-180:180) scale. The equation to change the scales is taken from [this stack-overflow post](https://stackoverflow.com/questions/46962288/change-longitude-from-180-to-180-to-0-to-360).

### Sources

#### <a name="1"></a> 1. [Earth Project](http://www.nims.go.kr:8080/en/about.html) by [National Institute of Meteorological Sciences (NIMS), South Korea](http://www.nims.go.kr/AE/MA/main.jsp)
#### <a name="2"></a> 2. [Atmosphere Layers study](https://niwa.co.nz/education-and-training/schools/students/layers) by [National Institute of Water and Atmospheric Research (NIWA), New Zealand](https://niwa.co.nz/)

#### <a name="3"></a> 3. [Longitude Latitudes article](https://www.britannica.com/science/latitude) by [britannica.com](https://www.britannica.com/science/latitude)

#### <a name="4"></a> 4. [Earth Project](https://github.com/cambecc/earth/blob/master/public/libs/earth/1.0.0/products.js#L607-L631) by [National Institute of Meteorological Sciences (NIMS), South Korea](http://www.nims.go.kr/AE/MA/main.jsp)

#### <a name="5"></a> 5. [GIS Netlogo docs](https://ccl.northwestern.edu/netlogo/docs/gis.html#gis:set-transformation)


<!-- 2021 -->
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

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.2.0
@#$#@#$#@
setup
display-cities
display-countries
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
