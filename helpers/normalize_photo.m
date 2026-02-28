function [dff,zdff] = normalize_photo(config,gcamp,iso)

% Subtract and normalize with isosbestic signal 
dff = (gcamp-iso)./iso;

% z-score across whole signal (not preferred)
% zdff = zscore(dff); 

% Get baseline duration (in samples)
BL = config.blDuration*config.eegFs;

% z-score relative to baseline activity
zdff = (dff - mean(dff(1:BL)))/std(dff(1:BL)); 

disp('------------- Calculated DF/F and z-DF/F --------------')

end