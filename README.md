ABMS project for Group 17


Data sources:

World map and polygons : Official GIS Extension (https://github.com/NetLogo/GIS-Extension)
Jetstream: *Sayam insert*
Sunlight data: NASA POWER Project (https://power.larc.nasa.gov/)
Temperature data: If we end up using it, I'll cite the source

Assumptions:
- Sunlight data has the following features (latitude, longitude, time, insolation)
    - Insolation has units of W/m^2 but we've directly used it to calculate temperature using formula from 'Climate Change' model without conversions.
      Ideally you'd expect use of formulae that converts thermal energy into temperature based on heat capacity of receiving object but time doesn't permit.
    - Time feature values range in [1, 13]. Couldn't find data description and have assumed that it is day count (day 1 - day 13).

- CO2 hasn't been accounted for considering model size. To counter this, we are not releasing any heat. Our assumption is that heat will anyway get trapped because of CO2 and increase temperature.

Issues:
- Patch temperature and global temperature are set as the same (25) initially. We have temperature dataset that needs little preprocessing before it can be used to fix this. If time permits, that can be done.

## Jet Streams

### Jet Stream Data source

- Jet Streams are air currents flowing at 10 KM above Earth's surface. Source: [[1]](#abcd) 
- The atmospheric layer at 10 KM from Earth's surface is the junction of Troposhere and Stratosphere, which is named Tropopause. Source: [Atmosphere Layers study](https://niwa.co.nz/education-and-training/schools/students/layers) by [National Institute of Water and Atmospheric Research (NIWA), New Zealand](https://niwa.co.nz/) 
- So, the Air Current Data at Tropopause is taken from [National Centers for Environmental Prediction (NCEP), America](https://www.ncep.noaa.gov/) which form the Jet Stream Data.

### About Jet Stream Data

- Any place on Earth's surface is identified by unique Longitude Latitude position. Source: [Longitude Latitudes article](https://www.britannica.com/science/latitude) by [britannica.com](https://www.britannica.com/science/latitude)
- For each Longitude Latitude combination, air currents are described as wind vectors in the data.
- In data, each wind vector has a U component and a V component which describes the direction of flow of wind for each patch.

Mathematically:

$wind\hspace{0.1cm}vector = U i^{hat} + V j^{hat}$

### Jet Stream Data Preprocessing

- Longitude vary from 0 to 360 degrees and Latitudes vary from -90 to 90 degrees. Source: [Earth Project](https://github.com/cambecc/earth/blob/master/public/libs/earth/1.0.0/products.js#L607-L631) by [National Institute of Meteorological Sciences (NIMS), South Korea](http://www.nims.go.kr/AE/MA/main.jsp)
- The Netlogo GIS Extension has Longitude defined from -180 to 180. Source [GIS Netlogo docs](https://ccl.northwestern.edu/netlogo/docs/gis.html#gis:set-transformation)
- So, the Longitude range in data is changed from (0:360 scale) to (-180:180) scale. The equation to change the scales is taken from [this stack-overflow post](https://stackoverflow.com/questions/46962288/change-longitude-from-180-to-180-to-0-to-360).

## Sources

#### <a name="abcd"></a> [Earth Project](http://www.nims.go.kr:8080/en/about.html) by [National Institute of Meteorological Sciences (NIMS), South Korea](http://www.nims.go.kr/AE/MA/main.jsp)
