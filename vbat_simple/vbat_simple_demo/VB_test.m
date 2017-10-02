% Comment and uncomment to test
% VB_func(temperature,device#, custom_device_parameters)
% temperature is a csv containing a time stamp and a temperature
% custom_device_parameters

% VB_func('outdoor_temperature.csv',1,0) %AC

% VB_func('outdoor_temperature.csv',2,0) %HP

% VB_func('outdoor_temperature.csv',3,0) %RG

% VB_func('outdoor_temperature.csv',4,0) %WH

%%% User inputed parameters

% VB_func('outdoor_temperature.csv',2,'para_special.csv') 

VB_func('outdoor_temperature.csv',2,[1,2,3,4,5,6,7]) 