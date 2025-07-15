function [R] = laggedCoherence(X,Y)
%laggedCoherence measures the coherence between two time-series random variables X and Y
%   Steps: Find fourier transform of the signals
%          Compute classical cross-spectra values
%          Use cross-spectra values to compute lagged coherence of the
%          time-series variables


% Classical cross-spectra computation
Sxx = cpsd(X,X);
Sxy = cpsd(X,Y);
Syy = cpsd(Y,Y);
 
num = imag(mean(Sxy));
den = sqrt(mean(Sxx)*mean(Syy)-real(mean(Sxy))^2);

R = num/den;

end

