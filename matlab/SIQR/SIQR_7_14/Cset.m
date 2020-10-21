function [inside] = Cset(X)

global  gettau getTrig1 getTrig2 getT;


Trig1=getTrig1(X);

Trig2=getTrig2(X);
tau=gettau(X);

if Trig1>0
    bound=Trig1;
elseif Trig2>0
    bound=Trig2;
else
    bound=getT(X);
end
inside = (tau>=0 & tau<=bound);

end

