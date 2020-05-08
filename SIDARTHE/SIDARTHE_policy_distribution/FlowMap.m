function [dX] = FlowMap(X)

global getS getI getD getA getR getT getH getE geta getb getc getd packX epsilon theta eta zita mu ni tau lambda rho kappa sigma csi N

 
 % get state values
 S=getS(X);
 I=getI(X); 
 D=getD(X);
 A=getA(X);
 R=getR(X);
 T=getT(X);
 H=getH(X);
 E=getE(X);
 alpha=geta(X);
 beta=getb(X);
 gamma=getc(X);
 delta=getd(X);
 
 % define the SIDARTHE dynamic equations
 dt=1;
 dS=-S*(alpha*I+beta*D+gamma*A+delta*R)/N;
 dI=S*(alpha*I+beta*D+gamma*A+delta*R)/N - (epsilon+zita+lambda)*I;
 dD=epsilon*I-(eta+rho)*D;
 dA=zita*I-(theta+mu+kappa)*A;
 dR=eta*D+theta*A-(ni+csi)*R;
 dT=mu*A+ni*R-(sigma+tau)*T;
 dH=lambda*I+rho*D+kappa*A+csi*R+sigma*T;
 dE=tau*T;
 da=0;
 db=0;
 dc=0;
 dd=0;
 dPeriod=0;
 dTrig1=0;
 dTrig2=0;

 % return the derivative
 dX = packX(dt,dS,dI,dD,dA,dR,dT,dH,dE,da,db,dc,dd,dPeriod,dTrig1,dTrig2);

end

