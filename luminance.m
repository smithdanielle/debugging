function Y=luminance(voltage,a,b,k,g)

% finds the luminance values for voltage, using the
%fitted parameters a b k g and the gamma function (Pelli and Zhang)

%15/2/00 Harriet Allen


if (b+(k*voltage))>=0
	Y=b+(k*voltage);
	Y=a+Y.^g;
	%Y=a+(b+(k*voltage).^g);
else
	Y=a;
end

