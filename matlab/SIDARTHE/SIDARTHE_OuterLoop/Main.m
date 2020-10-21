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

%% Parameters of the model on two different scenarios. 
% Scenario with no social distancing. R_0 = 2.41


alpha_up = 0.570;
gamma_up = 0.456;
beta_up = 0.011;
delta_up = beta_up;


% Scenario with social Distancing. R_0 = 1.6


% alpha_up = 0.422;
% gamma_up = 0.285;
% beta_up = 0.0057;
% delta_up = beta_up;


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
gamma_dwn = QuarantineCoeff*gamma_up;
delta_dwn = QuarantineCoeff*delta_up;

%% Parameters of the controller

% Deadband for the histeresys

global COld LowDb HighDb MaxPeriod Trigger1 Trigger2 Delay Obsdelayed

COld = 0.0;
LowDb = 0.4;
HighDb = 0.0;

%At time t = Trigger1 a strict lock-down is enforced.At
%time t = Trigger1 + Trigger2 the fast switching policy is enforced



MaxPeriod = 7;
Trigger1 = 20;
Trigger2 = 30;

% Delay and Obsdelayed can be used to introduce further delay into the observed
% valiables for the controller

Obsdelayed = 0;
Delay = 0;

%% Functions needed for solving the hybrid equations

global  z gett gett2 getS getI getD getA getR getT getH getE getC geta getb getc getd getTPeriod getTrig1 getTrig2 getT1 getT2 packX
z = 1; 
gett	=   @(X) X(1,:);
getS	=   @(X) X(2,:); 
getI	=   @(X) X(3,:);
getD    =   @(X) X(4,:);
getA    =   @(X) X(5,:); 
getR    =   @(X) X(6,:); 
getT    =   @(X) X(7,:); 
getH    =   @(X) X(8,:); 
getE    =   @(X) X(9,:);
getC    =   @(X) X(10,:);
geta    =   @(X) X(11,:);
getb 	=   @(X) X(12,:);
getc    =   @(X) X(13,:);
getd    =   @(X) X(14,:);
getTPeriod    =   @(X) X(15,:);
getTrig1      =   @(X) X(16,:);
getTrig2      =   @(X) X(17,:); 
getT1         =   @(X) X(18,:); 
getT2         =   @(X) X(19,:); 
gett2         =   @(X) X(20,:); 
packX  =   @(t,S,I,D,A,R,T,H,E,C,a,b,c,d,TPeriod,Trig1,Trig2,Time1,Time2, time) [t;S;I;D;A;R;T;H;E;C;a;b;c;d;TPeriod;Trig1;Trig2;Time1;Time2; time];

%% Time length of the simulation and initial conditions
% I0 represents the initial number of infected in the population. Delay and


End_Simulation = 1500;
I0 = 500/6;
D0 = 20/6;
A0 = 1/6;
R0 = 2/6;
T0 = 0;
H0 = 0;
E0 = 0;
C0 = 0;
S0 = N-I0-D0-A0-R0-T0-H0-E0;
tspan = 0:0.25:End_Simulation;

%% Simulation

NOfIterations = 6;

for j = 1 : NOfIterations
    MaxPeriod = (j+1)*7;
    T1 = (j+1)*0;
    T2 = (j+1)*7;
    COld = 0.0;
    HighDb = 0.0;
    alpha_up = 0.570;
    gamma_up = 0.456;
    beta_up = 0.011;
    delta_up = beta_up;
    QuarantineCoeff = 0.175;

    alpha_dwn = QuarantineCoeff*alpha_up;
    beta_dwn = QuarantineCoeff*beta_up;
    gamma_dwn = QuarantineCoeff*gamma_up;
    delta_dwn = QuarantineCoeff*delta_up;
    X0 = packX(0,S0,I0,D0,A0,R0,T0,H0,E0,C0,alpha_up,beta_up,gamma_up,delta_up,T1,Trigger1,Trigger2,T1,T2, 0);
    TSPAN=tspan;
    JSPAN=100*tspan;
    rule=1;

    options = odeset('RelTol',1e-6,'MaxStep',.5);
    [Time{j},~,Sol{j}] =HyEQsolver( @FlowMap,@JumpMap,@Cset,@Dset,X0,TSPAN,JSPAN,rule,options);
end

%Plot Results
r1 = epsilon + zita + lambda;
r2 = mu + rho;
r3 = theta + mu + kappa;
r4 = ni + csi;
r5 = sigma + tau;
R0 = alpha_up/r1 + beta_up*epsilon/(r1*r2) + gamma_up*zita/(r1*r3) + delta_up*mu*epsilon/(r1*r2*r4) + delta_up*zita*theta/(r1*r3*r4);

figure1 = figure('OuterPosition',[86 296 1321 748]);
cmap = colormap(lines(7));

tiledlayout(3,2)
nexttile([1,2])
grid
hold on



for j = 1 : NOfIterations
    for k = 1 : size(Time{j},1)
        if Time{j}(k) > Trigger1
            Index1 = k;
            break
        end
    end
    for k = 1 : size(Time{j},1)
        if Time{j}(k) >Trigger2
            Index2 = k;
            break
        end
    end
end

for j = 1 : NOfIterations
   Sol{j}(1:Index1,18) = (j+1)*7;
   Sol{j}(Index1:Index2,18) = (j+1)*0;
   Sol{j}(1:Index1,19) = (j+1)*0;
   Sol{j}(Index1:Index2,19) = (j+1)*7;   
end
        
for j = 1 : NOfIterations 
    
    plot(Time{j}/7,100/N*(Sol{j}(:,3)+ Sol{j}(:,4)+Sol{j}(:,5)+Sol{j}(:,6)),'LineWidth',3)

end
% y1=get(gca,'ylim');
% plot([Trigger1 Trigger1]./7,y1, 'b', 'linewidth', 2)
% plot([ Trigger1+Trigger2  Trigger1+Trigger2]./7,y1, 'b', 'linewidth', 2)
xlabel('Time [Week]')
ylabel('Total Infected [% of 10 Million]')

xlim([50/7 800/7])
 legend( 'c = 14', 'c = 21', 'c = 28', 'c = 35', 'c = 42', 'c = 49')
%legend('P = 7', 'P = 14', 'P = 21')

nexttile
grid
hold on
for j = 1 : NOfIterations/2
    plot(Time{j}/7,(Sol{j}(:,18) + Sol{j}(:,19)*(QuarantineCoeff))./((Sol{j}(:,18)+Sol{j}(:,19)))*R0,'LineWidth',3, 'Color', cmap(j,:))
end
xlabel('Time [Week]')
ylabel('Avg Reproduction Number')
% xlim([0 40])
xlim([50/7 800/7])
ylim([0 1.1])
y1=get(gca,'ylim');
% plot([Trigger1 Trigger1]./7,y1, 'b', 'linewidth', 2)
% plot([ Trigger1+Trigger2  Trigger1+Trigger2]./7,y1, 'b', 'linewidth', 2)
%legend('P = 7', 'P = 14', 'P = 21')
 legend( 'c = 14', 'c = 21', 'c = 28')
nexttile
grid
hold on
for j = NOfIterations/2+1 : NOfIterations 
    plot(Time{j}/7,(Sol{j}(:,18) + Sol{j}(:,19)*(QuarantineCoeff))./((Sol{j}(:,18)+Sol{j}(:,19)))*R0,'LineWidth',3, 'Color', cmap(j,:))
end
xlabel('Time [Week]')
ylabel('Avg Reproduction Number')
xlim([50/7 800/7])
ylim([0 1.1])
legend(  'c = 35', 'c = 42', 'c = 49', 'Location', 'southeast')
nexttile
% nexttile([1,2])
hold on
grid
for j = 1 : NOfIterations/2
    plot(Time{j}/7,100*(Sol{j}(:,18))./((Sol{j}(:,18))+(Sol{j}(:,19))),'LineWidth',3, 'Color', cmap(j,:))
    
end
% xlim([0 40])
xlim([50/7 800/7])
ylim([0 60])
y1=get(gca,'ylim');
xlabel('Time [Week]')
ylabel('Duty Cycle [%]')
y1=get(gca,'ylim');
% plot([Trigger1 Trigger1]./7,y1, 'b', 'linewidth', 2)
% plot([Trigger1+Trigger2  Trigger1+Trigger2]./7,y1, 'b', 'linewidth', 2)
legend( 'c = 14', 'c = 21', 'c = 28')
% legend('P = 7', 'P = 14', 'P = 21')
nexttile
hold on
grid
for j = NOfIterations/2 + 1 : NOfIterations
    plot(Time{j}/7,100*(Sol{j}(:,18))./((Sol{j}(:,18))+(Sol{j}(:,19))),'LineWidth',3, 'Color', cmap(j,:))
    
end
xlim([50/7 800/7])
ylim([0 60])
y1=get(gca,'ylim');
xlabel('Time [Week]')
ylabel('Duty Cycle [%]')
legend(  'c = 35', 'c = 42', 'c = 49', 'Location', 'southeast')