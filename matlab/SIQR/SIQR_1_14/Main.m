% SIR Model Hybrid Solver
% The libraries needed to simulate this code can be found at 
% https://it.mathworks.com/matlabcentral/fileexchange/41372-hybrid-equations-toolbox-v2-04.
% For a tutorial on the hybrid solver for switched systems you can refer to
% https://www.mathworks.com/videos/hyeq-a-toolbox-for-simulation-of-hybrid-dynamical-systems-81992.html
% The model used in this code refers to the spread of the Covid19 and was 
% validated using the data from the Italian outbreak by Morten Gram
% Pedersen and Matteo Meneghini. All the parameters used in this model are
% taken from their paper (source: "Quantifying undetected COVID-19 cases
% and effects of containment measures in Italy"). 


clear all

global beta_up beta_dwn alpha delta eta T1 T2 N

%% Parameters of the model 
 
alpha = 0.067;
eta = alpha;
delta = 0.036;
 
beta_up = 0.373; 
N = 1e7;
QuarantineCoeff = 0.15;
beta_dwn = QuarantineCoeff*beta_up;


%% Control Parameters 
%At time t = Trigger1 a strict lock-down is enforced for time Trig2-Trig1.
%At time Trigger2 the fast switching policy is enforced. The variable Control if
%set on "off" switches off every containment policy and shows the behavour
%of the disease if left unchecked   
 
Trigger1 = 20;
Trigger2 = 30;
Control = 'on';
 
%% State access functions
global gettau getS getI getQ getR getb getT getTrig1 getTrig2 packX
 
gettau	=   @(X) X(1,:);
getS	=   @(X) X(2,:); 
getI	=   @(X) X(3,:);
getQ    =   @(X) X(4,:);
getR	=   @(X) X(5,:); 
getb 	=   @(X) X(6,:);
getT    =   @(X) X(7,:);
getTrig1 =   @(X) X(8,:);
getTrig2 =   @(X) X(9,:); 
packX  =   @(tau,S,I,Q,R,b,T,Trig1,Trig2) [tau;S;I;Q;R;b;T;Trig1;Trig2];


%% Time length of the simulation and initial conditions

End_Simulation = 1500;
epsilon = 500/6;
I0 = epsilon;       %initial number of infected in the population
S0 = N - I0;
Q0 = 0;
R0 = 0;

tspan = [0, End_Simulation];


%% Simulation
% The variables MaxDaysOfWork and MaxDaysOfQuarantine represent the number
% of iteration per each control variable.

% simulating from (1,1) to (14,14) with resolution of 1 day
DayStep =  1;
Nstep= 14;
MaxDaysOfWork = DayStep*Nstep;
MaxDaysOfQuarantine = DayStep*Nstep; 

Interval_i1 = 1:1:Nstep+1;
Interval_i2 = 1:1:Nstep+1;

% variables contining the simulated timeseries
Sol = cell(length(Interval_i1),length(Interval_i2));
Time = cell(length(Interval_i1),length(Interval_i2));

% T1 = DaysOn -> beta_up
% T2 = DaysOff -> beta_down

Interval_T1 = (Interval_i1-1).*DayStep;
Interval_T2 = (Interval_i2-1).*DayStep;


lineLength=0;

for i1 = Interval_i1 
    for i2 = Interval_i2   
        
        T1 =Interval_T1(i1);
        T2 =Interval_T2(i2);
        
        if T1 == 0 && T2 == 0
            continue
        end
        
        %setting initial condition
        X0 = packX(0,S0,I0,Q0,R0,beta_up,T1,Trigger1,Trigger2);
        
        TSPAN=tspan;
        JSPAN=1000*tspan;
        rule=1;
        options = odeset('RelTol',1e-6,'MaxStep',.01);
        
        [Time{i1,i2},~,Sol{i1,i2}] =HyEQsolver( @FlowMap,@JumpMap,@Cset,@Dset,X0,TSPAN,JSPAN,rule,options);
         
        fprintf(repmat('\b',1,lineLength))
        lineLength = fprintf('\n(%d,%d) - (%d,%d)\n',T1,T2,MaxDaysOfWork,MaxDaysOfQuarantine );
   
    end
     
   
 end

%% Result Processing

% This piece of code is needed to find the peak value ad times 
% after the  FPSP policy is enforced.
 
peak = zeros(length(Interval_i1),length(Interval_i2));
peakTime = zeros(length(Interval_i1),length(Interval_i2)); 
for i = Interval_i1
    for j = Interval_i2
        if i ==1 && j ==1
            continue
        end 
        k = min(find(Time{i,j}>Trigger1+Trigger2)); 
        [p,idp] = max(getI(Sol{i,j}(k:end,:)'+getQ(Sol{i,j}(k:end,:)')));
        peak(i,j) = p;
        peakTime(i,j) =Time{i,j}(k+min(idp));
 
    end
end

peak(1,1)=NaN;
peakTime(1,1)=NaN; 

 % save the workspace
 save('workspace_1_14','-v7.3')

 % for image generation see ./ImageGeneration_SIQR_1_14.m and
 % /SQIR/SIQR_mixed/ImageGenerationMixed.m

 