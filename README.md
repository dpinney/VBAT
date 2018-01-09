# VBAT Overview

VirtualBatteries core load models and data preparation scripts.

# Requirements and Installation

This code requires Matlab R2015a or Octave.

To install the code, just download the [zipped archive](https://github.com/dpinney/VBAT/archive/master.zip).

# Usage Instructions

To run the data use the VB_test.m file

You can write your own VB_func() inputs where:

#### VB_func(a,b,[c,d,e,f,g,h,i])
#### a (the temperature data)
Can either be one of the following:
 - A city written exactly as shown in the 3rd column of geodata.csv
 - A zipcode from the following options: 94128, 97218, 98158
 - 'default' verbatim including the apostrophes
 - A file location of a csv file that holds exactly 8760 values organized in a single column i.e. 'C:\filename\anotherfilename\data.csv' including apostrophes
#### b (the device type):
1 for Air Conditioning, 2 for Heat Pump, 3 for Refridgerator, 4 for Water Heater
#### c (capacitance) - must be a positive float
#### d (resistance) - must be a positive float
#### e (power) - must be a positive float
#### f (cop) - must be a positive float
#### g (deadband) - must be a positive float
#### h (setpoint) - must be a positive float
#### i (number of devices) - must be a positive int
