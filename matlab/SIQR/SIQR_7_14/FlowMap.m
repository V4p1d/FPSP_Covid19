function [dX] = FlowMap(X)

global getS getQ getI getb packX alpha eta delta N

 
 
 S=getS(X);
 I=getI(X);
 Q=getQ(X);
 b=getb(X);
 
 
 
 dtau=1;
 
 dS=-(b/N)*S*I;
 dI=(b/N)*S*I-(alpha+eta)*I;
 dQ = -delta*Q + eta*I; 
 dR=alpha*I+delta*Q;
 db=0;
 dT=0;
 dTrig1=0;
 dTrig2=0;

dX = packX(dtau,dS,dI,dQ,dR,db,dT,dTrig1,dTrig2);

end

