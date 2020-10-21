function [inside] = Dset(X)

global  getTrig1 getTrig2 gett getTPeriod;

% get values of Trig1, Trig2 and current time t
Trig1=getTrig1(X);
Trig2=getTrig2(X);
t=gett(X);

% if Trig1 is not zero, the clock ticks after Trig1 seconds
% if Trig1=0 and Trig2>0, the clock ticks after Trig1 seconds
% otherwise the clock ticks according to the policy dity cycle
if Trig1>0
    bound=Trig1;
elseif Trig2 >0
     bound=Trig2;
else
    bound=getTPeriod(X);
end 

% returns false if t>tick bound.
inside = (t>= bound);

end