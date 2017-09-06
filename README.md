# VBAT
VirtualBatteries core load models and data preparation scripts

# Original Documentation
1. virtual_battery_data_preparation.m
	*	Load housing data and climate zone data for each county in US
	*	Load temperature data and saturation rate data for CA, WA, and OR
	*	Input
		*	Housing data: ‘.\housing_county_DP04\ACS_12_5YR_DP04_with_ann.xlsx’ 
		*	Climate Zone data: '.\climate_zone_files\climate_zones.xlsx'
		*	CA temperature data: '.\temperature_files\CA_all_stations.csv'
		*	CA NCDC observation station names and counties they are located: '.\temperature_files\NCDC_obs_locations_county_CA.csv'
		*	File to map CA counties to CA NCDC observation station indices: '.\temperature_files\CA_county_station_map.csv'
		*	Temperature data for WA: 
			*	Climate Zone #4: '.\temperature_files\Washington_zone_4_Temperature.csv';
			*	Climate Zone #5: '.\temperature_files\Washington_zone_5_Temperature.csv';
			*	Climate Zone #6: '.\temperature_files\Washington_zone_6_Temperature.csv';
		*	Temperature data for OR
			*	Climate Zone #4: '.\temperature_files\Oregon_zone_4_Temperature.csv'
			*	Climate Zone #5: '.\temperature_files\Oregon_zone_5_Temperature.csv'
		*	Saturation rate data for CA, WA, and OR: '.\saturation_rate.csv'
	*	Output: 'virtualBatteryData_org.mat'

2. updateVB_capacity.m
	*	Update virtual battery capacity for CA, WA, and OR
	*	Input: 'virtualBatteryData_org.mat'
	*	Function called: 
		*	updateVB_capacity_Temperrature_data() to update virtual battery capacities for CA
		*	updateVB_capacity_State() to update virtual battery capacities for WA and OR
	*	Output: updated virtual battery data structure with residential building virtual battery capacities for CA, WA, and OR: 'virtualBatteryData.mat'
	*	Note: this is probably what needs to be exposed in the OMF to user inputs.

3. update_commercial_CA_update1.m (only for commercial buildings, likely not used)
	*	Update commercial building virtual battery capacities for CA
	*	Input
		*	Virtual battery data structure: 'virtualBatteryData.mat'
		*	CA NCDC observation station names and counties they are located: '.\temperature_files\NCDC_obs_locations_county_CA.csv'
		*	Daily virtual battery capacities from simulation for counties that NCDC observation station are located: '.\SEB_CA_county_daily_temperature\';
		*	Commercial building floor space for CA counties: '.\commercial_buildings\DS_California_County_Commercial_Space_for_input.xlsx'
		*	File to map CA counties to CA NCDC observation station indices: '.\temperature_files\CA_county_station_map.csv'
	*	Output: updated virtual battery data structure with CA commercial building virtual battery capacities: 'virtualBatteryData.mat'
	*	Note: takes a very long time, over 24 hours to run. Long-running code is some kind of optimization routine.
# Additional Steps required if using Octave
1. Run 'read_Housing_Data_Octave.m' at least once in Matlab to initiate variables, then can be used in Octave
