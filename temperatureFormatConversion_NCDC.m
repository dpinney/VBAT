% convert NCDC temperature data from one vector into a 24*365 matrix

function tempOut = temperatureFormatConversion_NCDC(tempF,tempTime)

%% read in the temperature file
%tempData = readtable(tempFile);
% look like this data missed on hour, it only has 8759 rows, instead of 8760 rows
%tempTime = tempData.DATE;
%tempF = tempData.HLY_TEMP_NORMAL;

if(nanmedian(tempF) > 150)
    tempF = tempF/10; % for OR and WA data
end
    

tempOut = ones(24,365);
tempOut = -999*tempOut;
tempDay = datenum(tempTime,'yyyymmdd HH:MM');
baseDay = tempDay(1)-1;
for i = 1:length(tempTime)
   currDay = tempDay(i);
   currT = tempTime{i};
   %currTemp = tempF(i)/10; %data downloaded for OR and WA needs this
   currTemp = tempF(i);
   % convert temperature from F to C
   currTemp = (currTemp-32)*5/9;
   
   k1 = strfind(currT,' ');
   k2 = strfind(currT,':');
   currHour = currT(k1+1:k2-1);
   
   colIdx = floor(currDay-baseDay);
   rowIdx = str2num(currHour)+1;
   tempOut(rowIdx,colIdx) = currTemp;
   
end

%% interploate missing data points or set to NAN
% no interpolation if missing two consecutive data points
for j = 1:size(tempOut,2)
    k = find(tempOut(:,j) == -999);
    if(~isempty(k))
        for idx = 1:length(k)
            i = k(idx);
            if(i == 1 && j == 1)
                %temperature of the 1st hour of the year, can't interpolate
                tempOut(i,j) = NaN;
            else
                if(i == 24 && j == 365)
                    % temperature of the last hour of the year, can't interpolate
                    tempOut(i,j) = NaN;
                else
                    if(i == 1) % first hour of the day
                        if(tempOut(24,j-1) > -499 && tempOut(2,j) > -499)
                            tempOut(i,j) = (tempOut(24,j-1)+tempOut(2,j))/2;
                        else
                            tempOut(i,j) = NaN;
                        end
                    elseif(i == 24)
                        if(tempOut(1,j+1) > -499 && tempOut(23,j) > -499)
                            tempOut(i,j) = (tempOut(1,j+1)+tempOut(23,j))/2;
                        else
                            tempOut(i,j) = NaN;
                        end
                    else
                        if(tempOut(i-1,j) > -499 && tempOut(i+1,j) > -499)
                            tempOut(i,j) = (tempOut(i-1,j)+tempOut(i+1,j))/2;
                        else
                            tempOut(i,j) = NaN;
                        end
                    end
                end
            end
        end
    end
end