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



