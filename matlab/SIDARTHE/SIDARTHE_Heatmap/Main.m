% Simulations for the outer loop of the FPSP on the Sidharte Model.
% The libraries needed to simulate this code can be found at 
% https://it.mathworks.com/matlabcentral/fileexchange/41372-hybrid-equations-toolbox-v2-04.
% For a tutorial on the hybrid solver for switched systems you can refer to
% https://www.mathworks.com/videos/hyeq-a-toolbox-for-simulation-of-hybrid-dynamical-systems-81992.html
% The model used in this code refers to the spread of the Covid19 and was 
% validated using the data from the Italian outbreak. The paper, where the Sidarthe is described
% code can be found at https://www.nature.com/articles/s41591-020-0883-7.


 

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


N = 10e6; 

QuarantineCoeff = 0.175;

alpha_dwn = QuarantineCoeff*alpha_up;
beta_dwn = QuarantineCoeff*beta_up;
%beta_dwn = beta_up;
gamma_dwn = QuarantineCoeff*gamma_up;
delta_dwn = QuarantineCoeff*delta_up;




%% Control Parameters 
%At time t = Trigger1 a strict lock-down is enforced.At
%time t = Trigger1 + Trigger2 the fast switching policy is enforced
 
 
Trigger1 = 20;
Trigger2 = 30;

 
%% Functions needed for solving the hybrid equations
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


%% Time length of the simulation and initial conditions
% I0 represents the initial number of infected in the population

End_Simulation = 250;

I0 = 500/6;
D0 = 20/6;
A0 = 1/6;
R0 = 2/6;
T0 = 0;
H0 = 0;
E0 = 0;
S0 = N-I0-D0-A0-R0-T0-H0-E0;
tspan = 0:0.25:End_Simulation;



MaxWorkPeriod = 1;
MaxQuarantinePeriod = 6;


Sol = cell(MaxWorkPeriod+1,MaxQuarantinePeriod+1);
Time = cell(MaxWorkPeriod+1,MaxQuarantinePeriod+1);

for T1 = 1: 1: MaxWorkPeriod
    for T2 = 6 : 1: MaxQuarantinePeriod   
        if T1 == 0 && T2 == 0
            continue
        end

        X0 = packX(0,S0,I0,D0,A0,R0,T0,H0,E0,alpha_up,beta_up,gamma_up,delta_up,T1,Trigger1,Trigger2);
        TSPAN=tspan;
        JSPAN=100*tspan;
        rule=1;
        options = odeset('RelTol',1e-6,'MaxStep',.5);
        [Time{T1+1,T2+1},~,Sol{T1+1,T2+1}] =HyEQsolver( @FlowMap,@JumpMap,@Cset,@Dset,X0,TSPAN,JSPAN,rule,options);

    end
 end

% Plot Results
% This piece of code is needed to find the peak value of the infection
% after the  FPSP policy is enforced.

[On, Off] = meshgrid(0:MaxDaysOfWork, 0:MaxDaysOfQuarantine);
peak = zeros(MaxDaysOfWork+1, MaxDaysOfQuarantine+1);
peakTime = zeros(MaxDaysOfWork+1, MaxDaysOfQuarantine+1);
for i = 1 : MaxDaysOfWork+1
    for j = 1 : MaxDaysOfQuarantine+1
        if i ==1 && j ==1
            continue
        end
        for k = 1:length(Time{i,j})
            if Time{i,j}(k)>Trigger1+Trigger2
                index = k;
                break
            end
        end
        [peak(i,j), idp] = max(Sol{i,j}(index:end,6)+Sol{i,j}(index:end,3)+Sol{i,j}(index:end,4)+Sol{i,j}(index:end,5)+Sol{i,j}(index:end,7));
        peakTime(i,j) = Time{i,j}(k+min(idp)-1);
    end
end

% Heatmap of the peak values

figure(2)
h = heatmap(0:MaxDaysOfWork,0:MaxDaysOfQuarantine,peak);
ylabel('Work Days [Day]')
xlabel('Quarantine Days [Day]')
title('Peak Value of the infected population [% of 60 million]')

% Time evolution of the solution of the SIQR model for a specific pair of
% values (X,Y) = (DayWork, DayQuarantine).

DayWork = 1;
DayQuarantine = 6;
figure(3)
grid
hold on
plot(Time{DayWork+1,DayQuarantine+1}/7,100/N*(Sol{DayWork+1,DayQuarantine+1}(:,6)+Sol{DayWork+1,DayQuarantine+1}(:,3)+Sol{DayWork+1,DayQuarantine+1}(:,4)+Sol{DayWork+1,DayQuarantine+1}(:,5)+Sol{DayWork+1,DayQuarantine+1}(:,7)),'LineWidth',3)
xlim([0 250/7])
% plot(Time{1,2},100/N*(Sol{1,2}(:,6)+Sol{1,2}(:,3)+Sol{1,2}(:,4)+Sol{1,2}(:,5)+Sol{1,2}(:,7)),'--','LineWidth',3)
% ylim([0 0.15])
% xlim([0 350])
y1=get(gca,'ylim');
plot([Trigger1 Trigger1]./7,y1, 'b', 'linewidth', 2)
plot([Trigger1 + Trigger2 Trigger1 + Trigger2]./7,y1, 'b', 'linewidth', 2)
% plot([Trig3 Trig3],y1, 'b', 'linewidth', 2)
% legend('FPSP-(' + string(DayWork) + ',' + string(DayQuarantine) + ')'+ ' Policy', 'Lockdown Policy')
xlabel('Time [Week]')
ylabel('Total Infected People [% of 10 million]')
title(string(DayWork) + ' days of work, ' + string(DayQuarantine) + ' days of quarantine (X,Y) = (' + string(DayWork) + ',' + string(DayQuarantine) + ')' )