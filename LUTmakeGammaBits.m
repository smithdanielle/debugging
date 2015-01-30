function LUT=LUTmakeGammaBits

%%% Updated: 28 January 2014 -- parameters from gamma fit
a=0.269071;
b=0.226514;
g=2.868828;
k=5.183661;

Cont=0.98;

MaxLum=128;
MeanLum=MaxLum/2;

Upper = (1+Cont)/2; 	%Set the upper and lower luminance
Lower =(1-Cont)/2	;	%this will make a LUT symmetric about mean

%LumMax=Upper*MeanLum
%LumMin=Lower*MeanLum

LumMax=MeanLum+MeanLum.*Cont;
LumMin=MeanLum-MeanLum.*Cont;

Nmax=voltage(LumMax,a,b,k,g);	%find the nominal voltages assoc with the
Nmin=voltage(LumMin,a,b,k,g);	%max and min

Luminances=linspace(LumMin,LumMax,256)';

for i=1:256						%find required nominal voltages
	RequiredN(i,1)=voltage(Luminances(i),a,b,k,g);
end
%RequiredN=round(RequiredN);
LUT=[RequiredN,RequiredN,RequiredN];