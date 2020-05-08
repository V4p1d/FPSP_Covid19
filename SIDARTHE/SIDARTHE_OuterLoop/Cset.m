function [inside] = Cset(X)

global  gett getTrig1 getTrig2 getTPeriod Trigger1 Trigger2;


Trig1=getTrig1(X);

Trig2=getTrig2(X);
t=gett(X);

if Trig1>0
    bound=Trigger1;
elseif Trig2>0
    bound= Trigger2;
else
    bound=getTPeriod(X);
end
inside = (t>=0 & t<=bound);

end

