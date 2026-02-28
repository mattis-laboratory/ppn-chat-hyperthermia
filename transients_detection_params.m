
function params = transients_detection_params()

% Transients detection parameters
params              = struct();

params.Fs           = 1000;               % Sampling frequency 
params.minProm      = 1;                  % Minimum peak prominence
params.maxWidth     = 8*params.Fs;        % Maximum peak width
params.promFraction = 0.5;                % Percentage of prominence at which to calculate width
params.p2tWin       = 2.5*params.Fs;      % Time window to look for trough when calculating peak-to-trough amplitude

end

