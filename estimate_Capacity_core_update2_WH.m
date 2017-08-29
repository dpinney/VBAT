% Code was modified from estimate_Capacity_v1
%
% Author: He Hao
% Last update time: June 21, 2017
% This script is to estimate the power and energy capacities for a
% population of WHs with water draw

% 
% 11/28/2016 
%   modified from estimate_Capacity_core.m to improve computational speed
%
% 1/16/2016
%   added appliance saturation rate as input
%

function [e_lower, e_upper, e_int] = estimate_Capacity_core_update2_WH(N, saturationRate)
% theta_a is the ambient temperature
theta_a = (72-32)*5/9*ones(365, 24*60);
[nRow,nCol] = size(theta_a);
theta_a = reshape(theta_a,nRow*nCol,1);

% h is the model time discretization step in seconds
h = 60;

% T is the number of time step considered, i.e., T = 365*24*60 means a year
% with 1 minute time discretization
T = length(theta_a);

% saturationRate_wh is the percentage of households having electric resistance WHs
saturationRate_wh = saturationRate.wh;
 
% N_wh is the number of water heaters
N_wh = round(saturationRate_wh*N);

%N_wh = 500;

% rho is the amount of heterogeneity in the WH model parameter
rho = 0.1;
% C is the termal capacitance
C_wh = 0.4*(1 + rho*(rand(N_wh,1)-0.5));
% R is the thermal resistance
R_wh = 120*(1 + rho*(rand(N_wh,1)-0.5));
% P is the rated power (kW) of each TCL
P_wh = 4.5*ones(N_wh,1);
% eta is the coefficient of performance
eta_wh = 1*ones(N_wh,1);
% delta is the deadband
delta_wh = 3*(1 + rho*(rand(N_wh,1)-0.5));
% theta_s is the temperature setpoint 
theta_s_wh = 48.5*(1 + rho*(rand(N_wh,1)-0.5));
% theta_lower is the temperature lower bound
theta_lower_wh = theta_s_wh - delta_wh/2;
% theta_upper is the temperature upper bound
theta_upper_wh = theta_s_wh + delta_wh/2;





% m_water is the water draw in unit of gallon per minute
m_water = csvread('Flow_raw_1minute_BPA.csv', 1, 1)*0.00378541178*1000/h;

water_draw = m_water;

for i = 1:N_wh
    k = unidrnd(size(m_water,2));
    water_draw(:,i) = circshift(m_water(:, k), [1, unidrnd(15)-15]) + m_water(:, k)*0.1*(rand-0.5);
end

Po = zeros(T, N_wh);

for t = 1:T
    for i = 1:N_wh
        Po(t, i) = -(theta_a(t)-theta_s_wh(i))/R_wh(i) - 4.2*water_draw(t, i)*((55-32)*5/9 - theta_s_wh(i));
    end
end

% Po_total is the analytically predicted aggregate baseline power
Po_total = sum(Po,2);
Po_total(find(Po_total>sum(P_wh))) = sum(P_wh);
    
    

% theta is the temperature of TCLs
theta = zeros(N_wh, T);
theta(:,1) = theta_s_wh;

% m is the indicator of on-off state: 1 is on, 0 is off
m = ones(N_wh,T);
m(1:N_wh*0.8,1) = 0;


for t=1:1:T-1

    for i=1:N_wh

        theta(i,t+1) = (1-h/(C_wh(i)*3600)/R_wh(i))*theta(i,t) + h/(C_wh(i)*3600)/R_wh(i)*theta_a(t)...
            + h/(C_wh(i)*3600)*m(i,t)*P_wh(i) ;
         
        if theta(i,t+1) > theta_upper_wh(i)
            m(i,t+1) = 0;
        elseif theta(i,t+1) < theta_lower_wh(i)
            m(i,t+1) = 1;
        else
            m(i,t+1) = m(i,t);
        end
    end
    
end


% initialize the temperature and on/off state of WHs at stead-state
theta(:,1) = theta(:,end);
m(:,1) = m(:,end);

% Po_total_sim is the predicted aggregate baseline power using simulations
Po_total_sim = zeros(T,1);
Po_total_sim(1) = sum(m(:,1).*P_wh);

for t=1:1:T-1

    for i=1:N_wh

        theta(i,t+1) = (1-h/(C_wh(i)*3600)/R_wh(i))*theta(i,t) + h/(C_wh(i)*3600)/R_wh(i)*theta_a(t)...
            + h/(C_wh(i)*3600)*m(i,t)*P_wh(i) + h*4.2*water_draw(t,i)*((55-32)*5/9 - theta(i,t))/(C_wh(i)*3600);
         
        if theta(i,t+1) > theta_upper_wh(i)
            m(i,t+1) = 0;
        elseif theta(i,t+1) < theta_lower_wh(i)
            m(i,t+1) = 1;
        else
            m(i,t+1) = m(i,t);
        end
    end
    
    Po_total_sim(t+1) = sum(m(:,t+1).*P_wh);
    
end


index_available = ones(N_wh, T);

for t=1:1:T-1

    for i=1:N_wh
        if theta(i,t) < theta_lower_wh(i)-0.5 || theta(i,t) > theta_upper_wh(i)+0.5
           index_available(i, t) = 0; 
        end

    end 
end




% Virtual battery parameters
e_upper_wh = sum(P_wh) - Po_total_sim;
e_lower_wh = Po_total_sim;
e_int_wh = sum((C_wh*ones(1, T).*(delta_wh*ones(1, T))/2).*index_available)';


% figure
% subplot(2,1,1)
% plot(e_upper_wh(1:1440))
% hold on
% plot(-e_lower_wh(1:1440),'r')
% plot(zeros(1440,1),'k--')
% ylabel('Power (kW)')
% xlabel('Time (timestep)')
% subplot(2,1,2)
% plot(e_int_wh(1:1440))
% hold on
% plot(-e_int_wh(1:1440),'r')
% plot(zeros(1440,1),'k--')
% ylabel('Energy (kWh)')
% xlabel('Time (timestep)')

% format the data
e_lower_wh = reshape(e_lower_wh, nRow, nCol); 
e_upper_wh = reshape(e_upper_wh, nRow, nCol);  
e_int_wh = reshape(e_int_wh, nRow, nCol);


e_lower = e_lower_wh';
e_upper = e_upper_wh';
e_int = e_int_wh';

