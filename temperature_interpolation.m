%% interpolate temperature data from houly data to given time interval
% Input:
%      hourlyTemp: hourly temperature data, size of the data is 24*365
%       deltaT: minutes between every two interpolated data points
%                   total minutes in a day 24*60 should be divisible by deltaT
%
% Output:
%       outTemp: output temperature data
%
function outTemp = temperature_interpolation(hourlyTemp, deltaT)

% check if minutes in a day is divisible by deltaT
r = rem(24*60, deltaT);
if( r ~= 0)
    % not divisible
    warndlg('Input time duration is not valid, no interpolation!');
    outTemp = hourlyTemp;
    return;
end

T0 = 0:1:24*365; % hourly temperature time in hour
C0 = reshape(hourlyTemp, 24*365,1); % hourly temperature data in vector
C0 = [C0; C0(1)]; % add one more data point for interpolation

nRow = 24*60/deltaT; % # of rows for the output data
n = nRow*365;

T1 = 0:deltaT/60:24*365; % time for interpolated data points
C1 = zeros(n,1); % interpolated temperature data 
C1 = [C1;0];

if(deltaT < 60)
    % C1 has more data than C0
    
    [Ta,ia,ib] = intersect(T0, T1,'stable'); % find indices
    C1(ib) = C0(ia); % assign houly temperature first
    
    % linear interpolation
    for i = 1:length(C0)-1
         ca = C0(i);  % starting hour temperature
         cb = C0(i+1); % ending hour temperature
         diff_t = cb-ca; % temperature difference within this hour        
         idx_a = ib(i);  % index of starting hour in C1
         idx_b = ib(i+1);  % index of ending hour in C1
         
         if(diff_t == 0)
             % constant temperature within this hour
             C1(idx_a:idx_b) = ca;
         else
             % temperature changed within this hour
             nData = 60/deltaT;  % # of interpolated points in a hour
             tt = ca:diff_t/nData:cb;                         
             C1(idx_a:idx_b) = tt;  % assing interpolated temperature             
         end
    end
 
else
    % C1 has less data than C0    
    C1 = C1-9999;
    [Ta,ia,ib] = intersect(T0, T1,'stable'); % find indices
    C1(ib) = C0(ia); % assign houly temperature first
    
    for i = 1:length(C1);
        if(C1(i) == -9999)
            % linear interpolation                       
            currT = T1(i); % time of the data point needed to be interpolated
            tmp = abs(T0-currT);
            k = find(tmp < 1); % should have 2 values
            if(length(k) ~= 2)
                errordlg(['interpolation error; t = ',num2str(currT)]);
            else
                k1 = k(1);
                k2 = k(2);
                ta = T0(k1);
                tb = T0(k2);
                diff_t = tb-ta;
                ca = C0(k1);
                cb = C0(k2);
                diff_c = cb-ca;
                cIntp = ca+diff_c/diff_t*(currT-ta);
                C1(i) = cIntp;
            end                
        end        
    end       
end   

outTemp = C1;
outTemp = outTemp(1:end-1);

outTemp = reshape(outTemp,nRow,365);

end