% read housing data downloaded from US Census web site

function housingData = read_Housing_Data(housingFile)
housingFile = './housing_county_DP04/ACS_12_5YR_DP04_with_ann.csv';
housingData = readtable(housingFile);
%housingData = importdata(housingFile,',',1);
save('housingData_all.mat','housingData');
load('housingData_all.mat.BAK');

% the columns that we are interested
usedColumns = [1,2,3,4,28,244,256];
housingData = housingData(:,usedColumns);

% check data using Los Angeles data
str = 'Los Angeles';
n = length(str);
idx = find(strncmp(housingData.Geography,str,n));

dataLA = housingData(idx,:);

% update table header names
housingData.Properties.VariableNames(4:7) = {'totalHousing', 'detachedHousing', 'occupiedHousing', 'elecHeatingOccupiedHousing'};

% need to delete couple counties in Alaske to match climate zone
str = 'Hoonah-Angoon Census Area';
k = find(strncmp(housingData.Geography, str,length(str)));
housingData(k,:) = [];

str = 'Petersburg Census Area';
k = find(strncmp(housingData.Geography, str,length(str)));
housingData(k,:) = [];

end