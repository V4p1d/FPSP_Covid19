function [Xp] = JumpMap(X)

global t Obsdelayed gett2  MaxPeriod getS getI getD getA getR getT getH getE getC geta getb getc getd getTrig1 getTrig2 packX alpha_up alpha_dwn  beta_up beta_dwn  gamma_up gamma_dwn delta_up delta_dwn t T1 T2 getTPeriod COld1 COld2 flag LowDb HighDb
 
S=getS(X);
 I=getI(X); 
 D=getD(X);
 A=getA(X);
 R=getR(X);
 T=getT(X);
 H=getH(X);
 E=getE(X);
 C=getC(X);
 TPeriod=getTPeriod(X);
 a=geta(X);
 b=getb(X);
 c=getc(X);
 d=getd(X); 
 Trig1=getTrig1(X);
 Trig2=getTrig2(X);
 time = gett2(X);
 tp=0;
 Sp=S;
 Ip=I;
 Dp=D;
 Ap=A;
 Rp=R;
 Tp=T;
 Hp=H;
 Ep=E;
 
 C = Obsdelayed(end);
 if Trig1>0  
     Tperiodp=T2;
     ap=alpha_dwn;
     bp=beta_dwn;
     cp=gamma_dwn;
     dp=delta_dwn;
     Trigp1= 0;
     Trigp2 = Trig2;
     COld2 = COld1;
     COld1=C;
     Cp = 0;
     flag = 1;
 elseif Trig2>0 && Trig1 == 0
     Tperiodp=T1;
%      alpha_up = 0.422;
%      gamma_up = 0.285;
%      beta_up = 0.0057;
%      delta_up = beta_up;
%      QuarantineCoeff = 0.175;
% 
%      alpha_dwn = QuarantineCoeff*alpha_up;
%      beta_dwn = QuarantineCoeff*beta_up;
%      gamma_dwn = QuarantineCoeff*gamma_up;
%      delta_dwn = QuarantineCoeff*delta_up;
     ap=alpha_up;
     bp=beta_up;
     cp=gamma_up;
     dp=delta_up;
     Trigp1= 0;
     Trigp2 = 0; 
     COld2 = COld1;
     COld1=C;
     Cp = 0;
     flag = 1;
 else 
     if TPeriod == T1 && flag == 1
         if C-COld1 < (COld1-COld2)*(1 - LowDb)
             T1 = Mid(T1+1,0,MaxPeriod);
             T2 = Mid(T2-1,0,MaxPeriod);
             %TPeriod = T1;
         elseif  C-COld1 > (COld1-COld2)*(1 + HighDb)
             T1 = Mid(T1-1,0,MaxPeriod);
             T2 = Mid(T2+1,0,MaxPeriod);
         end
         flag = 2;
         COld2 = COld1;
         COld1=C;
         Cp = 0;
         TPeriod = T1;
     else
         Cp=C;
         flag = 1;
         TPeriod = T2;
     end
     ap=alpha_dwn+alpha_up-a;
     bp=beta_dwn+beta_up-b;    
     cp=gamma_dwn+gamma_up-c;
     dp=delta_dwn+delta_up-d;
     
     Tperiodp= T1+T2-TPeriod;

     Trigp1= 0;
     Trigp2 = 0;  
 end
 Tp1 = T1;
 Tp2 = T2;
 C=getC(X);
Xp = packX(tp,Sp,Ip,Dp,Ap,Rp,Tp,Hp,Ep,C,ap,bp,cp,dp,Tperiodp,Trigp1,Trigp2,Tp1,Tp2,time);
end