function [Xp] = JumpMap(X)

global  gettau getTrig1 getTrig2 getS getQ getI getR getb packX getT beta_up beta_dwn T1 T2

 

 S=getS(X);
 I=getI(X);
 Q=getQ(X);
 R=getR(X);
 T=getT(X);
 b=getb(X);
 Trig1=getTrig1(X);
 Trig2=getTrig2(X);
 Tau = gettau(X);
 
 taup=0;
 Sp=S;
 Ip=I;
 Rp=R;
 Qp=Q;
 
 
 
 if Trig1>0  
     Tp=T2;
     bp=beta_dwn;
     Trigp1= 0;
     Trigp2 = Trig2;

 elseif Trig2>0 && Trig1 == 0
     Tp=T1;
     bp=beta_up;
     Trigp1= 0;
     Trigp2 = 0;     

 else 
     bp=beta_dwn+beta_up-b;
     Tp= T1+T2-T;
     Trigp1= 0;
     Trigp2 = 0;  


 end
 
 

 

Xp = packX(taup,Sp,Ip,Qp,Rp,bp,Tp,Trigp1,Trigp2);

end

