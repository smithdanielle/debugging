function invX=voltage(luminance,a,b,k,g)
%implements the Pelli and Zhang equ to convert
%luminances to required voltages

%16/2/00
%HA based on MVG programs

%global a b k g invG
%a = fitted_parameters(1);
%b = fitted_parameters(2);
%k = fitted_parameters(3);
%g = fitted_parameters(4);
invG=1/g;

if luminance>=a;
invX=luminance-a;
invX=invX.^(1/g);
invX=invX-b;
invX=invX./k;
%invX=( ((real ((luminance-a).^invG))-b)./k);
else
	invX=(-b)./k;
	end

