# Date: Jan 3, 2017
# Author: He Hao
# This script is to characterize the flexibility of SEB AHU1
# Dependent file: theta_o.csv

#####################################   Load necessary package   ############################################
Pkg.update()
Pkg.add("JuMP")
Pkg.add("Ipopt")
Pkg.add("Gadfly")
Pkg.add("DataFrames")

using JuMP
using Ipopt
using Gadfly
using DataFrames



##################################### Define necessary variables ############################################
# time is the simulation time in seconds
time = 24*3600
# h is the discretization step in seconds
h = 60*10
# T is the number of time steps
T = convert(Int64,time/h)
# N is the number of thermal zones
n = 17

zonemodel = [
        0.9797792 0.013999440 10^3*4.466370e-05 0.232542;       #142
        0.9640044 0.022239270 10^3*0.0003781706 0.489366;       #143
        0.9470164 0.004853795 10^3*0.0001243516 1.188656;       #118
        0.9603026 0.010378890 10^3*5.627057e-05 0.761795;       #102
        0.9527855 0.003161370 10^3*0.0006250651 1.106867;       #120
        0.9583467 0.005257968 10^3*3.922137e-05 0.897079;       #Corridor
        0.9676096 0.017419190 10^3*0.0003497087 0.476984;       #136
        0.9438126 0.004554815 10^3*0.0002480898 1.313832;       #129
        0.9511861 0.002974475 10^3*0.0006297499 1.142928;       #119
        0.9494451 0.005638420 10^3*0.0001519681 1.180800;       #123a
        0.9330470 0.015840730 10^3*5.036615e-05 1.383911;       #127b
        0.9583600 0.005370380 10^3*0.0004942134 0.926649;       #131
        0.9516168 0.006563101 10^3*0.0002368315 1.061292;       #133
        0.9388286 0.010060080 10^3*6.109575e-05 1.310651;       #127a
        0.9461335 0.005543954 10^3*0.0001521993 1.264443;       #123b
        0.9633996 0.010733080 10^3*0.0001851619 0.706070;       #150
        0.9630977 0.010407890 10^3*0.0004921950 0.880819;       #Restroom
        ]

# a_i's are the thermal model parameters, theta_t+1 = a1 theta_t +a2 theta_o + a3 q_t + a4
a1 = zonemodel[:,1]
a2 = zonemodel[:,2]
a3 = zonemodel[:,3]
a4 = zonemodel[:,4]
# Cp is the specific heat of air
Cp = 1.006
# c_i are the fan model parameters
c1 = 2.569e-12
c2 = -4.451e-9
c3 = 1.459e-4
c4 = 4.711e-3


# mdot_max and mdot_min are the maximum and minimum air flow rates for the 17 zones
m3s2cfm = 2118.880003

mdot_max= m3s2cfm*[
    0.7557;     #142
    0.14364;    #143
    0.35705;    #118
    0.55766;    #102
    8.34E-02;   #120
    1.04288;    #Corridor
    0.13642;    #136
    0.25032;    #129
    8.29E-02;   #119
    0.42064;    #123a
    1.27711;    #127b
    9.98E-02;   #131
    0.23389;    #133
    1.04356;    #127a
    0.43324;    #123b
    0.21182;    #150
    8.75E-02;   #Restroom
    ]

mdot_min = 0.4*mdot_max

# eta is the efficiency factor of the cooling coil, and COP is the coefficient of performance of the chiller
eta = 0.8879
COP = 5.9153
# delta is half of the deadband

delta = 2*ones(n,1)
# theta_r is the room setpoint temperature
theta_r = 21*ones(n,1)
# theta_lower is the temperature lower bound
theta_lower = theta_r - delta
# theta_upper is the temperature upper bound
theta_upper = theta_r + delta;

# we have to make the ambient temperature profile as an external input
# theta_o is the ambient temperature
theta_o = readtable("temperature_San_Diego_10min.csv", header = false)
theta_o = convert(DataArray,theta_o)
# theta_o = [
#   28.8889,   28.9074,   28.9259,   28.9444,   28.9630,   28.9815,   29.0000,   29.0648,   29.1296,   29.1944,
#   29.2593,   29.3241,   29.3889,   29.1574,   28.9259,   28.6944,   28.4630,   28.2315,   28.0000,   27.8704,
#   27.7407,   27.6111,   27.4815,   27.3519,   27.2222,   26.8519,   26.4815,   26.1111,   25.7407,   25.3704,
#   25.0000,   24.8981,   24.7963,   24.6944,   24.5926,   24.4907,   24.3889,   24.2037,   24.0185,   23.8333,
#   23.6481,   23.4630,   23.2778,   23.3796,   23.4815,   23.5833,   23.6852,   23.7870,   23.8889,   24.5741,
#   25.2593,   25.9444,   26.6296,   27.3148,   28.0000,   28.5000,   29.0000,   29.5000,   30.0000,   30.5000,
#   31.0000,   31.6667,   32.3333,   33.0000,   33.6667,   34.3333,   35.0000,   35.5000,   36.0000,   36.5000,
#   37.0000,   37.5000,   38.0000,   38.0463,   38.0926,   38.1389,   38.1852,   38.2315,   38.2778,   38.4630,
#   38.6481,   38.8333,   39.0185,   39.2037,   39.3889,   39.6759,   39.9630,   40.2500,   40.5370,   40.8241,
#   41.1111,   41.2130,   41.3148,   41.4167,   41.5185,   41.6204,   41.7222,   41.7685,   41.8148,   41.8611,
#   41.9074,   41.9537,   42.0000,   41.8519,   41.7037,   41.5556,   41.4074,   41.2593,   41.1111,   40.6389,
#   40.1667,   39.6944,   39.2222,   38.7500,   38.2778,   37.4444,   36.6111,   35.7778,   34.9444,   34.1111,
#   33.2778,   32.8981,   32.5185,   32.1389,   31.7593,   31.3796,   31.0000,   30.8333,   30.6667,   30.5000,
#   30.3333,   30.1667,   30.0000,   30.1019,   30.2037,   30.3056,   30.4074,   30.5093,   30.6111,   30.3241,
#   30.0370,   29.7500,   29.4630,   29.1759]-10


##################################### Using JuMP to model the optimization problem ##################################
theta_o_org = theta_o

######################################################## simulation for each day

for ii = 1:365
println("This is for day ",ii)
startIdx = (ii-1)*144+1
endIdx = ii*144
theta_o = theta_o_org[startIdx:endIdx]

# N is the prediction horizon
N = 144

# Define the control inputs and total power for lower power case
mdot_lower = zeros(n,N)
q_lower = zeros(n,N)
theta_c_lower = zeros(1,N)
damper_lower = zeros(1,N)
P_total_lower = zeros(1,N)
# Define the control inputs and total power for upper power case
mdot_upper = zeros(n,N)
q_upper = zeros(n,N)
theta_c_upper = zeros(1,N)
damper_upper = zeros(1,N)
P_total_upper = zeros(1,N)

############################### Characterizing the lower and upper power limits #############################

############################### Characterizing the lower power limits #############################
for t =1:N

  m = Model(solver=IpoptSolver(print_level=0))

  @defVar(m, mdot[1:n])
  @defVar(m, q[1:n])
  @defVar(m, mdot_total)
  @defVar(m, q_total)
  @defVar(m, Pf)
  @defVar(m, Pc)
  @defVar(m, 0.2 <= damper <= 0.8)
  @defVar(m, 8 <= theta_c <= 15)

  @addConstraint(m, mdot_constraint[k=1:n], mdot_min[k]*0.00055 <= mdot[k] <= mdot_max[k]*0.00055)
  @addConstraint(m, mdot_total == sum(mdot))
  @addConstraint(m,  q_total == sum(q))
  @addNLConstraint(m, Pf == c1*(mdot_total/0.00055)^3+c2*(mdot_total/0.00055)^2+c3*mdot_total/0.00055+c4)
  @addNLConstraint(m, Pc == (1-damper)*(1/COP/eta)*Cp*mdot_total*(theta_o[t]-theta_c) - damper*(1/COP/eta)*q_total)
  @addNLConstraint(m, q_constraint[k=1:n], Cp*mdot[k]*(theta_c-theta_lower[k]) == q[k])


  # compute the lower power limits
  println("This is time step ", t, " lower case")
  @setObjective(m, Min, (Pf+Pc))
  status = solve(m)
  if status == :Optimal
    mdot_lower[:,t] = getValue(mdot)
    q_lower[:,t] = getValue(q)
    theta_c_lower[t] = getValue(theta_c)
    damper_lower[t] = getValue(damper)
    P_total_lower[t] = getValue(Pf+Pc)
  end

end


############################### Characterizing the upper power limits #############################
for t = 1:N

  m = Model(solver=IpoptSolver(print_level=0))

  @defVar(m, mdot[1:n])
  @defVar(m, q[1:n])
  @defVar(m, mdot_total)
  @defVar(m, q_total)
  @defVar(m, Pf)
  @defVar(m, Pc)
  @defVar(m, 0.2 <= damper <= 0.8)
  @defVar(m, 8 <= theta_c <= 15)

  @addConstraint(m, mdot_constraint[k=1:n], mdot_min[k]*0.00055 <= mdot[k] <= mdot_max[k]*0.00055)
  @addConstraint(m, mdot_total == sum(mdot))
  @addConstraint(m,  q_total == sum(q))
  @addNLConstraint(m, Pf == c1*(mdot_total/0.00055)^3+c2*(mdot_total/0.00055)^2+c3*mdot_total/0.00055+c4)
  @addNLConstraint(m, Pc == (1-damper)*(1/COP/eta)*Cp*mdot_total*(theta_o[t]-theta_c) - damper*(1/COP/eta)*q_total)
  @addNLConstraint(m, q_constraint[k=1:n], Cp*mdot[k]*(theta_c-theta_lower[k]) == q[k])

  # compute the upper power limits
  println("This is time step ", t, " upper case")
  @setObjective(m, Max, (Pf+Pc))
  status = solve(m)
  if status == :Optimal
    mdot_upper[:,t] = getValue(mdot)
    q_upper[:,t] = getValue(q)
    theta_c_upper[t] = getValue(theta_c)
    damper_upper[t] = getValue(damper)
    P_total_upper[t] = getValue(Pf+Pc)
  end

end

# println(P_total_lower)
# println(P_total_upper)



############################### Characterizing the lower and upper energy limits #############################
# P_total_lower_x and P_total_upper_x are the characterized powers with assigned inputs
P_total_lower_x = zeros(1,N)
P_total_upper_x = zeros(1,N)


############################### compute the lower power profile #############################

m = Model(solver=IpoptSolver(print_level=0))

@defVar(m, theta[1:n,1:(N+1)])
@defVar(m, mdot[1:n,1:N])
@defVar(m, q[1:n,1:N])
@defVar(m, slack_upper[1:n,1:N] >=0)
@defVar(m, slack_lower[1:n,1:N] >=0)
@defVar(m, mdot_total[1:N])
@defVar(m, q_total[1:N])
@defVar(m, Pf[1:N])
@defVar(m, Pc[1:N])
@defVar(m, 0.2 <= damper[1:N] <= 0.8)
@defVar(m, 8 <= theta_c[1:N] <= 15)
@defVar(m, theta_s[1:n,1:N] <= 32)
@defVar(m, q_h[1:n,1:N])
@defVar(m, q_c[1:n,1:N])

@addConstraint(m, mdot_constraint[k=1:n, i=1:N], mdot_min[k]*0.00055 <= mdot[k,i] <= mdot_max[k]*0.00055)
@addConstraint(m, mdot_total_constraint[i=1:N], mdot_total[i] == sum(mdot[:,i]))
@addConstraint(m, q_total_constraint[i=1:N], q_total[i] == sum(q[:,i]))
@addNLConstraint(m, Pf_constraint[i=1:N], Pf[i] == c1*(mdot_total[i]/0.00055)^3+c2*(mdot_total[i]/0.00055)^2+c3*mdot_total[i]/0.00055+c4)
@addNLConstraint(m, Pc_constraint[i=1:N], Pc[i] == (1-damper[i])*(1/COP/eta)*Cp*mdot_total[i]*(theta_o[i]-theta_c[i]) - damper[i]*(1/COP/eta)*q_total[i])
@addConstraint(m, X_constraint[k=1:n, i=1:N], theta[k,i+1] == a1[k]*theta[k,i] + a2[k]*theta_o[i] + a3[k]*q[k,i] + a4[k])
@addConstraint(m, theta0_constraint[k=1:n], theta[k,1] == theta_upper[k])
@addConstraint(m, theta_constraint_upper[k=1:n, i=1:N], theta[k,i+1] <= (theta_upper[k] + slack_upper[k,i]))
@addConstraint(m, theta_constraint_lower[k=1:n, i=1:N], theta[k,i+1] >= (theta_lower[k] - slack_lower[k,i]))
@addConstraint(m, theta_s_constraint[k=1:n, i=1:N], theta_c[i] <= theta_s[k,i])
@addNLConstraint(m, q_h_constraint[k=1:n, i=1:N], Cp*mdot[k,i]*(theta_s[k,i]-theta_c[i]) == q_h[k,i])
@addNLConstraint(m, q_c_constraint[k=1:n, i=1:N], Cp*mdot[k,i]*(theta_c[i]-theta[k,i]) == q_c[k,i])
@addConstraint(m, q_constraint[k=1:n, i=1:N], q_h[k,i] + q_c[k,i] == q[k,i])

# compute the baseline power limits
@setObjective(m, Min, sum((theta - theta_upper*ones(1,N+1)).^2) + 1000*sum(slack_lower + slack_upper) + 100*sum(q_h) )
status = solve(m)


P_total_lower_x = getValue(Pf+Pc)


############################### compute the upper power profile #############################

m = Model(solver=IpoptSolver(print_level=0))

@defVar(m, theta[1:n,1:(N+1)])
@defVar(m, mdot[1:n,1:N])
@defVar(m, q[1:n,1:N])
@defVar(m, slack_upper[1:n,1:N] >=0)
@defVar(m, slack_lower[1:n,1:N] >=0)
@defVar(m, mdot_total[1:N])
@defVar(m, q_total[1:N])
@defVar(m, Pf[1:N])
@defVar(m, Pc[1:N])
@defVar(m, 0.2 <= damper[1:N] <= 0.8)
@defVar(m, 8 <= theta_c[1:N] <= 15)
@defVar(m, theta_s[1:n,1:N] <= 32)
@defVar(m, q_h[1:n,1:N])
@defVar(m, q_c[1:n,1:N])

@addConstraint(m, mdot_constraint[k=1:n, i=1:N], mdot_min[k]*0.00055 <= mdot[k,i] <= mdot_max[k]*0.00055)
@addConstraint(m, mdot_total_constraint[i=1:N], mdot_total[i] == sum(mdot[:,i]))
@addConstraint(m, q_total_constraint[i=1:N], q_total[i] == sum(q[:,i]))
@addNLConstraint(m, Pf_constraint[i=1:N], Pf[i] == c1*(mdot_total[i]/0.00055)^3+c2*(mdot_total[i]/0.00055)^2+c3*mdot_total[i]/0.00055+c4)
@addNLConstraint(m, Pc_constraint[i=1:N], Pc[i] == (1-damper[i])*(1/COP/eta)*Cp*mdot_total[i]*(theta_o[i]-theta_c[i]) - damper[i]*(1/COP/eta)*q_total[i])
@addConstraint(m, X_constraint[k=1:n, i=1:N], theta[k,i+1] == a1[k]*theta[k,i] + a2[k]*theta_o[i] + a3[k]*q[k,i] + a4[k])
@addConstraint(m, theta0_constraint[k=1:n], theta[k,1] == theta_lower[k])
@addConstraint(m, theta_constraint_upper[k=1:n, i=1:N], theta[k,i+1] <= (theta_upper[k] + slack_upper[k,i]))
@addConstraint(m, theta_constraint_lower[k=1:n, i=1:N], theta[k,i+1] >= (theta_lower[k] - slack_lower[k,i]))
@addConstraint(m, theta_s_constraint[k=1:n, i=1:N], theta_c[i] <= theta_s[k,i])
@addNLConstraint(m, q_h_constraint[k=1:n, i=1:N], Cp*mdot[k,i]*(theta_s[k,i]-theta_c[i]) == q_h[k,i])
@addNLConstraint(m, q_c_constraint[k=1:n, i=1:N], Cp*mdot[k,i]*(theta_c[i]-theta[k,i]) == q_c[k,i])
@addConstraint(m, q_constraint[k=1:n, i=1:N], q_h[k,i] + q_c[k,i] == q[k,i])

# compute the baseline power limits
@setObjective(m, Min, sum((theta - theta_lower*ones(1,N+1)).^2) + 1000*sum(slack_lower + slack_upper) + 100*sum(q_h) )
status = solve(m)


P_total_upper_x = getValue(Pf+Pc)



############################### Compute the baseline power profile #############################

m = Model(solver=IpoptSolver(print_level=0))

@defVar(m, theta[1:n,1:(N+1)])
@defVar(m, mdot[1:n,1:N])
@defVar(m, q[1:n,1:N])
@defVar(m, slack_upper[1:n,1:N] >=0)
@defVar(m, slack_lower[1:n,1:N] >=0)
@defVar(m, mdot_total[1:N])
@defVar(m, q_total[1:N])
@defVar(m, Pf[1:N])
@defVar(m, Pc[1:N])
@defVar(m, 0.2 <= damper[1:N] <= 0.8)
@defVar(m, 8 <= theta_c[1:N] <= 15)
@defVar(m, theta_s[1:n,1:N] <= 32)
@defVar(m, q_h[1:n,1:N])
@defVar(m, q_c[1:n,1:N])

@addConstraint(m, mdot_constraint[k=1:n, i=1:N], mdot_min[k]*0.00055 <= mdot[k,i] <= mdot_max[k]*0.00055)
@addConstraint(m, mdot_total_constraint[i=1:N], mdot_total[i] == sum(mdot[:,i]))
@addConstraint(m, q_total_constraint[i=1:N], q_total[i] == sum(q[:,i]))
@addNLConstraint(m, Pf_constraint[i=1:N], Pf[i] == c1*(mdot_total[i]/0.00055)^3+c2*(mdot_total[i]/0.00055)^2+c3*mdot_total[i]/0.00055+c4)
@addNLConstraint(m, Pc_constraint[i=1:N], Pc[i] == (1-damper[i])*(1/COP/eta)*Cp*mdot_total[i]*(theta_o[i]-theta_c[i]) - damper[i]*(1/COP/eta)*q_total[i])
@addConstraint(m, X_constraint[k=1:n, i=1:N], theta[k,i+1] == a1[k]*theta[k,i] + a2[k]*theta_o[i] + a3[k]*q[k,i] + a4[k])
@addConstraint(m, theta0_constraint[k=1:n], theta[k,1] == theta_r[k])
@addConstraint(m, theta_constraint_upper[k=1:n, i=1:N], theta[k,i+1] <= (theta_upper[k] + slack_upper[k,i]))
@addConstraint(m, theta_constraint_lower[k=1:n, i=1:N], theta[k,i+1] >= (theta_lower[k] - slack_lower[k,i]))
@addConstraint(m, theta_s_constraint[k=1:n, i=1:N], theta_c[i] <= theta_s[k,i])
@addNLConstraint(m, q_h_constraint[k=1:n, i=1:N], Cp*mdot[k,i]*(theta_s[k,i]-theta_c[i]) == q_h[k,i])
@addNLConstraint(m, q_c_constraint[k=1:n, i=1:N], Cp*mdot[k,i]*(theta_c[i]-theta[k,i]) == q_c[k,i])
@addConstraint(m, q_constraint[k=1:n, i=1:N], q_h[k,i] + q_c[k,i] == q[k,i])

# compute the baseline power limits
@setObjective(m, Min, sum((theta - theta_r*ones(1,N+1)).^2) + 1000*sum(slack_lower + slack_upper)  + 100*sum(q_h))
status = solve(m)


P_baseline = getValue(Pf+Pc)


alpha = mean(zonemodel[:,1])

X_upper = sum(P_total_upper_x - P_baseline)*h/3600/(1-alpha)/N*ones(N,1)
X_lower = sum(P_total_lower_x - P_baseline)*h/3600/(1-alpha)/N*ones(N,1)


plot_P_total_lower = plot(x=1:N,y=P_total_lower'-P_baseline, Geom.line, Guide.xlabel("Time Step"), Guide.ylabel("Power (kW)"))
plot_P_total_upper = plot(x=1:N,y=P_total_upper'-P_baseline, Geom.line, Guide.xlabel("Time Step"), Guide.ylabel("Power (kW)"))
plot_X_upper = plot(x=1:N,y=X_upper, Geom.line, Guide.xlabel("Time Step"), Guide.ylabel("Energy (kWh)"))
plot_X_lower = plot(x=1:N,y=X_lower, Geom.line, Guide.xlabel("Time Step"), Guide.ylabel("Energy (kWh)"))


df = convert(DataFrame,reshape([P_total_lower'-P_baseline; P_total_upper'-P_baseline; X_lower; X_upper; P_baseline; alpha*ones(N,1);theta_o;], N, 7))
outfile = "power_v12_CA_San_Diego_"
outfile = string(outfile,ii,".csv")
writetable(outfile, df)

end
