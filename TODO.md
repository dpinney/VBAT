# Task List

* XXX Test on macOS with Octave? When I run virtual_battery_data_preparation.m, I get error: `housingData(_,256): but housingData has size 1x1 which is thrown from read_Housing_Data.m.` Maybe the Windows-style path variables or other things of that sort are messing things up.

* XXX Test on Windows 10 with Octave? Same error.

* OOO Next step? Debug. Looks like readtable isn't supported in Octave. Nor is the matrix.columnName access format supported in matlab.