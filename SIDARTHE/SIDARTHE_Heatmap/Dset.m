function [inside] = Dset(X)

global  getTrig1 getTrig2 gett getTPeriod;

Trig1=getTrig1(X);
Trig2=getTrig2(X);
t=gett(X);

if Trig1>0
    bound=Trig1;
elseif Trig2 >0
     bound=Trig2;
else
    bound=getTPeriod(X);
end 

inside = (t>= bound);

end