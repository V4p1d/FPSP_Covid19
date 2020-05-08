function [dX] = FlowMap(X)

global  Delay t Obs Obsdelayed z gett2 getS getI getD getA getR getT getH getE getC geta getb getc getd packX epsilon theta eta zita mu ni tau lambda rho kappa sigma csi N

 
 
 S=getS(X);
 I=getI(X); 
 D=getD(X);
 A=getA(X);
 R=getR(X);
 T=getT(X);
 H=getH(X);
 E=getE(X);
 C=getC(X);
 alpha=geta(X);
 beta=getb(X);
 gamma=getc(X);
 delta=getd(X);
 
 dt=1;
 dS=-S*(alpha*I+beta*D+gamma*A+delta*R)/N;
 dI=S*(alpha*I+beta*D+gamma*A+delta*R)/N - (epsilon+zita+lambda)*I;
 dD=epsilon*I-(eta+rho)*D;
 dA=zita*I-(theta+mu+kappa)*A;
 dR=eta*D+theta*A-(ni+csi)*R;
 dT=mu*A+ni*R-(sigma+tau)*T;
 dH=lambda*I+rho*D+kappa*A+csi*R+sigma*T;
 dE=tau*T;
 dC = (A + R + D);
 Obs(z) = C;
 t(z) = gett2(X);
 for i = size(t,2):-1:1
     if t(i)<=t(end)-Delay
         CDelay = i;
         break
     end
 end
 if t(z) >= Delay
     Obsdelayed(z) = Obs(CDelay);
 end
 z = z+1;
 da=0;
 db=0;
 dc=0;
 dd=0;
 dPeriod=0;
 dTrig1=0;
 dTrig2=0;
 dT1 =0;
 dT2 =0;
 dtime = 1;

 
dX = packX(dt,dS,dI,dD,dA,dR,dT,dH,dE,dC,da,db,dc,dd,dPeriod,dTrig1,dTrig2,dT1,dT2, dtime);

end

