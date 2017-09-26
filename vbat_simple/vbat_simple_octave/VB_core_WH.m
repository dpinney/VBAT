function [P_upper_wh, P_lower_wh, E_UL_wh] = VB_core_WH(paraFile)
% Author: He Hao (PNNL)
% Last update time: September 19, 2017
% This function is used to characterize VB capacity from a population of WH considering water draw
para = csvread(paraFile);
% para = xlsread(paraFile);

N_wh = size(para,1); % number of TCL
C_wh = para(:,1); % thermal capacitance
R_wh = para(:,2); % thermal resistance
P_wh = para(:,3); % rated power (kW) of each TCL
delta_wh = para(:,5); % temperature deadband
theta_s_wh = para(:,6); % temperature setpoint

% theta_a is the ambient temperature
theta_a = (72-32)*5/9*ones(365,24*60);
[nRow,nCol] = size(theta_a);
theta_a = reshape(theta_a,nRow*nCol,1);

% h is the model time discretization step in seconds
h = 60;

% T is the number of time step considered, i.e., T = 365*24*60 means a year
% with 1 minute time discretization
T = length(theta_a);

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

Po = -(repmat(theta_a,1,N_wh)-repmat(theta_s_wh',T,1))./repmat((R_wh'),T,1)...
    - 4.2*water_draw.*((55-32).*5/9 - repmat(theta_s_wh',T,1));

% Po_total is the analytically predicted aggregate baseline power
Po_total = sum(Po,2);
Po_total(find(Po_total>sum(P_wh))) = sum(P_wh);


% theta is the temperature of TCLs
theta = zeros(N_wh, T);
theta(:,1) = theta_s_wh;

% m is the indicator of on-off state: 1 is on, 0 is off
m = ones(N_wh,T);
m(1:N_wh*0.8,1) = 0;

theta1 = theta;
n = m;

start1 = clock;

for t=1:1:T-1
    theta1(:,t+1) = (1-h./(C_wh(:).*3600)./R_wh(:)).*theta1(:,t)...
        + h./(C_wh(:).*3600)./R_wh(:).*theta_a(t)...
        + h./(C_wh(:).*3600).*n(:,t).*P_wh(:);
    for i=1:N_wh
        if theta1(i,t+1) > theta_upper_wh(i)
            n(i,t+1) = 0;
        elseif theta1(i,t+1) < theta_lower_wh(i)
            n(i,t+1) = 1;
        else
            n(i,t+1) = n(i,t);
        end
    end
end
end1 = clock-start1;

% start2 = clock;
% for t=1:1:T-1
%     for i=1:N_wh
%         theta(i,t+1) = (1-h/(C_wh(i)*3600)/R_wh(i))*theta(i,t) ...
%             + h/(C_wh(i)*3600)/R_wh(i)*theta_a(t)...
%             + h/(C_wh(i)*3600)*m(i,t)*P_wh(i) ;
%         if theta(i,t+1) > theta_upper_wh(i)
%             m(i,t+1) = 0;
%         elseif theta(i,t+1) < theta_lower_wh(i)
%             m(i,t+1) = 1;
%         else
%             m(i,t+1) = m(i,t);
%         end
%     end
% end
% end2 = clock-start2;
% initialize the temperature and on/off state of WHs at stead-state
theta(:,1) = theta(:,end);
m(:,1) = m(:,end);

% Po_total_sim is the predicted aggregate baseline power using simulations
Po_total_sim = zeros(T,1);
Po_total_sim(1) = sum(m(:,1).*P_wh);

for t=1:1:T-1
    for i=1:N_wh
        theta(i,t+1) = (1-h/(C_wh(i)*3600)/R_wh(i))*theta(i,t) ...
            + h/(C_wh(i)*3600)/R_wh(i)*theta_a(t)...
            + h/(C_wh(i)*3600)*m(i,t)*P_wh(i) ...
            + h*4.2*water_draw(t,i)*((55-32)*5/9 - theta(i,t))/(C_wh(i)*3600);
        
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
P_upper_wh1 = sum(P_wh) - Po_total_sim;
P_lower_wh1 = Po_total_sim;
E_UL_wh1 = sum((C_wh*ones(1, T).*(delta_wh*ones(1, T))/2).*index_available)';

% calculate hourly average data from minute output for power
P_upper_wh1 = reshape(P_upper_wh1, [60,8760]);
P_upper_wh = mean(P_upper_wh1);
P_lower_wh1 = reshape(P_lower_wh1, [60,8760]);
P_lower_wh = mean(P_lower_wh1);
% extract hourly data from minute output for energy
E_UL_wh = E_UL_wh1(60:60:length(E_UL_wh1));

end