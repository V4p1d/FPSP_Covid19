function [Xp] = JumpMap(X)

global  getS getI getD getA getR getT getH getE geta getb getc getd getTrig1 getTrig2 packX alpha_up alpha_dwn alpha_avg beta_up beta_dwn beta_avg gamma_up gamma_dwn delta_up delta_dwn t T1 T2 getTPeriod

 
 % get state values
 S=getS(X);
 I=getI(X); 
 D=getD(X);
 A=getA(X);
 R=getR(X);
 T=getT(X);
 H=getH(X);
 E=getE(X);
 TPeriod=getTPeriod(X);
 a=geta(X);
 b=getb(X);
 c=getc(X);
 d=getd(X); 
 Trig1=getTrig1(X);
 Trig2=getTrig2(X);
 
 tp=0;  %reset timer
 Sp=S;
 Ip=I;
 Dp=D;
 Ap=A;
 Rp=R;
 Tp=T;
 Hp=H;
 Ep=E;
 
 
 % if the tick of the timer was caused by Trigger1, activate Trigger2
 if Trig1>0  
     Tperiodp=T1;
     ap=alpha_dwn;
     bp=beta_dwn;
     cp=gamma_dwn;
     dp=delta_dwn;
     Trigp1= 0;
     Trigp2 = Trig2;

 % if the tick of the timer was caused by Trigger2, activate the policy
 % clock
 elseif Trig2>0 && Trig1 == 0
     Tperiodp=T1;
     ap=alpha_up;
     bp=beta_up;
     cp=gamma_up;
     dp=delta_up;
     Trigp1= 0;
     Trigp2 = 0;     

 % if the tick of the timer was caused by the policy  clock update the next
 % tick time according to the duty cycle
 else 
     ap=alpha_dwn+alpha_up-a;
     bp=beta_dwn+beta_up-b;
     cp=gamma_dwn+gamma_up-c;
     dp=delta_dwn+delta_up-d;     
     Tperiodp= T1+T2-TPeriod;
     Trigp1= 0;
     Trigp2 = 0;  


 end
 
 
 Xp = packX(tp,Sp,Ip,Dp,Ap,Rp,Tp,Hp,Ep,ap,bp,cp,dp,Tperiodp,Trigp1,Trigp2);

end

