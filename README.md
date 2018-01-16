# VBAT Overview

VBAT is a set of libraries for simulating thermostatically controlled electrical loads (TCL) under a set of "VirtualBattery" control schemes. Inputs include environmental information and control paramters, and the output is the timeseries behavior of the load modeled. The VirtualBattery control schemes keep the TCL operating within the lower half of its thermostat deadband hence providing energy savings. Modeled loads include water heaters, air conditioners, referigerators, and resistance heaters.

# Requirements and Installation

This code requires Matlab R2015a or Octave 4.2.

To install the code, just download the [zipped archive](https://github.com/dpinney/VBAT/archive/master.zip).

# Usage Walkthrough

To run all the tests, run the VB_test.m file.

You can run a custom simulation using the VB_func() where:

### VB_func(a,b,[c,d,e,f,g,h,i])
##### a (the temperature data):
Can either be one of the following:
 - A city written exactly as shown in the 3rd column of geodata.csv
 - A zipcode from the following options: 94128, 97218, 98158
 - 'default' verbatim including the apostrophes
 - A file location of a csv file that holds exactly 8760 values organized in a single column i.e. '/foo/bar/data.csv' including apostrophes
##### b (the device type):
1 for Air Conditioning, 2 for Heat Pump, 3 for Refridgerator, 4 for Water Heater
##### c (capacitance):
Must be a positive float
##### d (resistance):
Must be a positive float
##### e (power):
Must be a positive float
##### f (cop):
Must be a positive float
##### g (deadband):
Must be a positive float
##### h (setpoint):
Must be a positive float
##### i (number of devices):
Must be a positive int

The output is three sets of 8760 hourly results to the command window of Octave/Matlab: the load's minimum power, maximum power and energy consumed. If you would like to see the results plotted, uncomment lines 62 and after in VB_func.m.
