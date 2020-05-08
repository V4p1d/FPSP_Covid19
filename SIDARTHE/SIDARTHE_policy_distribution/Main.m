% Simulations for the outer loop of the FPSP on the Sidharte Model.
% The libraries needed to simulate this code can be found at 
% https://it.mathworks.com/matlabcentral/fileexchange/41372-hybrid-equations-toolbox-v2-04.
% For a tutorial on the hybrid solver for switched systems you can refer to
% https://www.mathworks.com/videos/hyeq-a-toolbox-for-simulation-of-hybrid-dynamical-systems-81992.html
% The model used in this code refers to the spread of the Covid19 and was 
% validated using the data from the Italian outbreak. The paper, where the Sidarthe is described
% code can be found at https://www.nature.com/articles/s41591-020-0883-7.

clear all
 
global alpha_up alpha_dwn beta_up beta_dwn  gamma_up gamma_dwn delta_up delta_dwn epsilon theta eta zita mu ni tau lambda rho kappa sigma csi T1 T2 N

%% Parameters of the model. 
alpha_up = 0.570;
gamma_up = 0.456;
beta_up = 0.011;
delta_up = beta_up;
epsilon = 0.171;
theta = 0.371;
eta = 0.125;
zita = eta;
mu = 0.012;
ni = 0.027;
tau = 0.003;
lambda = 0.034;
rho = lambda;
kappa = 0.017;
sigma = kappa;
csi = kappa;

% population size
N = 10e6; 

% quarantine coefficient
QuarantineCoeff = 0.175;

alpha_dwn = QuarantineCoeff*alpha_up;
beta_dwn = QuarantineCoeff*beta_up; 
gamma_dwn = QuarantineCoeff*gamma_up;
delta_dwn = QuarantineCoeff*delta_up; 



%% Control Parameters 
%At time t = Trigger1 a strict lock-down is enforced for time Trigger2-Trigger1 days.
%At time Trigger2 the fast switching policy is applied. 
%The variable Control if set on "off" switches off every containment policy and shows the behavour
%of the disease if left unchecked   
 
Trigger1 = 20;
Trigger2 = 30;
Control = 'on';
 
%% auxiliary functions

global gett getS getI getD getA getR getT getH getE geta getb getc getd getTPeriod getTrig1 getTrig2 packX
 
gett	=   @(X) X(1,:);
getS	=   @(X) X(2,:); 
getI	=   @(X) X(3,:);
getD    =   @(X) X(4,:);
getA    =   @(X) X(5,:); 
getR    =   @(X) X(6,:); 
getT    =   @(X) X(7,:); 
getH    =   @(X) X(8,:); 
getE    =   @(X) X(9,:);
geta    =   @(X) X(10,:);
getb 	=   @(X) X(11,:);
getc    =   @(X) X(12,:);
getd    =   @(X) X(13,:);
getTPeriod    =   @(X) X(14,:);
getTrig1 =   @(X) X(15,:);
getTrig2 =   @(X) X(16,:); 
packX  =   @(t,S,I,D,A,R,T,H,E,a,b,c,d,Period,Trig1,Trig2) [t;S;I;D;A;R;T;H;E;a;b;c;d;Period;Trig1;Trig2];


%% Simulation parameters
 
End_Simulation = 1000;

I0 = 500/6; % initial number of infected people in the population
D0 = 20/6;
A0 = 1/6;
R0 = 2/6;
T0 = 0;
H0 = 0;
E0 = 0;
S0 = N-I0-D0-A0-R0-T0-H0-E0;
tspan = [0, End_Simulation];


%% Simulation
% The variables MaxDaysOfWork and MaxDaysOfQuarantine represent the number
% of iteration per each control variable.

DayStep =  1;                           % resolution
Nstep= 7*4*4;                           % number of simulation per semiperiod
MaxDaysOfWork = DayStep*Nstep;          % maximum simulated days of work in a period 
MaxDaysOfQuarantine = DayStep*Nstep;    % maximum simulated days of quarantine in a period 

% grid of the combinations of work and quarantine days to simulate
Interval_i1 = 1:1:Nstep+1;
Interval_i2 = 1:1:Nstep+1;

% variables containing the simulated time series
Sol = cell(length(Interval_i1),length(Interval_i2));
Time = cell(length(Interval_i1),length(Interval_i2));

% variables containing the actual number of days on and days off for each
% simulation
Interval_T1 = (Interval_i1-1).*DayStep; % T1 = DaysOn -> beta_up
Interval_T2 = (Interval_i2-1).*DayStep; % T2 = DaysOff -> beta_down


lineLength=0;

for i1 = Interval_i1 
    for i2 = Interval_i2   
        
        T1 =Interval_T1(i1);    % T1 = DaysOn
        T2 =Interval_T2(i2);    % T2 = DaysOff
        
        % skip if the period is not a multiple of 7
        if (T1+T2==0) || (mod(T1+T2,7)~=0)
            Time{i1,i2}=[];
            Sol{i1,i2}=[];
            continue
        end
        
        % set the initial condition
        X0 = packX(0,S0,I0,D0,A0,R0,T0,H0,E0,alpha_up,beta_up,gamma_up,delta_up,T1,Trigger1,Trigger2);
        
        % simulation
        TSPAN=tspan;
        JSPAN=1000*tspan;
        rule=1;
        options = odeset('RelTol',1e-6,'MaxStep',.01);
        
        [Time{i1,i2},~,Sol{i1,i2}] =HyEQsolver( @FlowMap,@JumpMap,@Cset,@Dset,X0,TSPAN,JSPAN,rule,options);
         
        % print simulation percentage
        fprintf(repmat('\b',1,lineLength))
        lineLength = fprintf('\n(%d,%d) - (%d,%d)\n',T1,T2,MaxDaysOfWork,MaxDaysOfQuarantine );
   
    end
     
   
 end



% save the workspace
save('workspace_colaneri_7','-v7.3')



%% Simulation Result Processing
 
 
peak = zeros(length(Interval_i1),length(Interval_i2));
peakTime = zeros(length(Interval_i1),length(Interval_i2));


for i = Interval_i1
    for j = Interval_i2
        
        T1 =Interval_T1(i);
        T2 =Interval_T2(j);
        
        % skip if the period is not a multiple of 7
        if (T1+T2==0) || (mod(T1+T2,7)~=0)
            peak(i,j) = NaN;
            peakTime(i,j) =NaN;
            continue
        end
        
        % find the infected peak after Trigger1+Trigger2 (i.e. after the policy
        % is enforce)
        k = min(find(Time{i,j}>Trigger1+Trigger2)); 
        [p,idp] = max(getI(Sol{i,j}(k:end,:)')+getD(Sol{i,j}(k:end,:)')+getA(Sol{i,j}(k:end,:)')...
                       +getR(Sol{i,j}(k:end,:)')+getT(Sol{i,j}(k:end,:)') );
        peak(i,j) = p;
        peakTime(i,j) =Time{i,j}(k+min(idp));
        
 
    end
end


peak(1,1)=NaN;
peakTime(1,1)=NaN; 

% save reduced workspace 
save('workspace_reduced.mat','peak','peakTime','MaxDaysOfQuarantine','MaxDaysOfWork',...
    'Interval_i1','Interval_i2','Interval_T1','Interval_T2','DayStep');

 

%% plot of simulations: see ./ImageCreation


