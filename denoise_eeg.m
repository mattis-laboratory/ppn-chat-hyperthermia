function [eegNotch] = filter_eeg(config, eeg)

Fs = config.eegFs;

%% Bandpass Filter
lowFreq   = 1; 
highFreq  = 70; 
filterOrder = 2; 

nyqFreq = Fs/2;
lowFreq = lowFreq/nyqFreq;
highFreq = highFreq/nyqFreq;

if filterOrder == 2
    [B, A]      = butter(2, [lowFreq highFreq]);
    eegBP       = filtfilt(B, A, double(eeg));
else
    % Calculate zpk values using BUTTER 
    [z,p,k]     = butter(filterOrder/2, [lowFreq highFreq]);
    % To avoid round-off errors, do not use the transfer function
    [sos_var,g] = zp2sos(z, p, k);
    hd          = dfilt.df2sos(sos_var, g);
    eegBP       = filtfilthd(hd, eeg);
end

%% Notch Filter

% Notch Frequency
f0 = 60; 

% Quality factor 
Q = 10;

% Calculate notch filter coefficients
omega = 2 * pi * f0 / Fs;
alpha = sin(omega) / (2 * Q);
b0 = 1;
b1 = -2 * cos(omega);
b2 = 1;
a0 = 1 + alpha;
a1 = -2 * cos(omega);
a2 = 1 - alpha;

% Define the filter coefficients
b = [b0 b1 b2];
a = [a0 a1 a2];

% Filter 
eegNotch = filtfilt(b,a,eegBP);

disp('------------ EEG Filtered ------------')
end