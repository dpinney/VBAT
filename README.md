# VBAT Overview

VirtualBatteries core load models and data preparation scripts.

# Requirements and Installation

This code requires Matlab R2015a to Run.

To install the code, just download the [zipped archive](https://github.com/dpinney/VBAT/archive/master.zip).

# Usage Instructions

To prepare the data for calculating VirtualBattery capacity, run the virtual_battery_data_preparation.m script in Matlab.

Run updateVB_capacity.m to calculate residential capacities for HVAC and waterheaters in California, Washington, and Oregon.

Run update_commercial_CA_update1.m to calculate only for commercial buildings in California (note that this script will take many hours to run).

All output is placed in virtualBatteryData.mat.

A GUI for inspecting the output is available by running GUI_code/virtualBattery.m
