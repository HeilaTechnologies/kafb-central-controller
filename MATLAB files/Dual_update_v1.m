function [lambdak, muk, gammaUk, gammaLk] = Dual_update(V_meas, P_subk, set_sub_up, set_sub_low, alpha, Service, lambdakm1, mukm1, gammaUkm1, gammaLkm1)

% Node numbering 

% Node 0: substation
% Node 1: intermediate node
% Node 2: location of C3+C4
% Node 3: intermediate node
% Node 4: location of C1
% Node 5: location of C2

% Lines
% Impedance z1 between node 3 and node 4
% Impedance z2 between node 3 and node 5
% Impedance z3 between node 1 and node 3
% Impedance z4 between node 1 and node 2
% Impedance z5 between node 0 and node 1


%------------------
% Voltage p.u. 
%------------------
V0_LL_sub = 480; % Line-to-line 
Zbase = 1; % leave this one to 1

VbaseD = V0_LL_sub; % line-to-line voltage
Vbase = V0_LL_sub/sqrt(3); % line-to-ground voltage
SbaseD = (VbaseD^2)/Zbase;
Sbase = (Vbase^2)/Zbase;

%------------------
% parameters
%------------------
epsilon = 0.001;

%------------------
% dual step
%------------------

% V_meas is a 15x1 vector collecting the measured voltages; 
% Voltages are listed from node 1 to node 5; three phase to ground
% measurements per node. Measurements are in V

% P_subk is a 3x1 vector collecting the powers measured at the three phases
% of the PCC; a positive sign means that the power are flowing from the PCC
% to the rest of the grid; a negative sign means that the powers are
% entering the microgrid. Measurements are in kW

% lambdak and lambdak and 15x1 vectors
% gammaUk and gammaLk are 3x1 vectors

% Vmin is the minimum limit for the voltage magnitude (e.g., 0.95)
% Vmax is the maximum limit for the voltage magnitude (e.g., 1.05)

% alpha: stepsize

% Service: indicates wheather the powers at the PCC must follow a setpoint
% set_sub_up, set_sub_low: defines the interval for the power at the PCC
% when Service = 1; Example: set_sub_low = 795; set_sub_up =
% 805 when the setpoint for the PCC os 800kW. 


%-------------------------------------------
% Dual update

% Nornalization in pu
V_meas = V_meas/Vbase;
P_subk = P_subk*1000/Sbase;
set_sub_low = set_sub_low*1000/Sbase;
set_sub_up = set_sub_up*1000/Sbase;
uni = ones(1,15);
Vmin = 0.9;
Vmax = 1.1;

% Voltages
    lk = lambdakm1 + alpha*(uni*Vmin - V_meas - epsilon*lambdakm1); 
    lambdak = max(0,lk);
    mk = mukm1 + alpha*(V_meas - uni*Vmax - epsilon*mukm1);
    muk = max(0,mk);      

% Power at PCC         
    if Service == 1
        lk = gammaUkm1 + alpha*(P_subk - set_sub_up - epsilon*gammaUkm1);
        gammaUk = max(0,lk);
        lk = gammaLkm1 + alpha*(set_sub_low - P_subk - epsilon*gammaLkm1);
        gammaLk = max(0,lk);
    else
        gammaUk = gammaUkm1;
        gammaLk = gammaLkm1;
    end
    
    
end