%% Transients Detection and Characterization
% Chandni Rana - University of Michigan - Mattis Lab
%
% This script identifies calcium transients in fluorescence time-series signals (using find peaks) 
% Properties of identified transients are then calculated (see OUTPUT)
% Detection parameters are set by the user from "transients_detection_params()"
% Expected input is Nx1 data (N = trials)
%
%
% INPUT 
% params   (struct)       - user-specified detection parameters
% zdff     (Nx1 cell)     - z-DF/F fluorescence signals
% dff      (Nx1 cell)     - DF/F fluorescence signals 
% zdff_hpf (Nx1 cell)     - z-DF/F and high-pass filtered fluorescence signals
% 
%
% OUTPUT (Nx7 cell) containing: 
% 1 - PEAKS               - z-DF/F signal value at detected timestamps ("peak value")
% 2 - LOCS                - indices of detected peaks
% 3 - WIDTHS              - width of detected peaks 
% 4 - P2TAmp              - peak-to-trough amplitude (nearest trough within user-specified window)
% 5 - PROMS               - peak prominences
% 6 - DFF PEAKS           - same as (1) but on DF/F signal
% 7 - P2TAmp(DFF)         - same as (4) but on DF/F peaks

%% Define Detection Parameters
params               = transients_detection_params();

% Which dataset to run
zdff_data            = het_zdff_hpf;  
dff_data             = het_dffs;

% Preallocate output
transients = cell([numel(zdff_data),7]);

%% Detect Peaks
for subject = 1:numel(zdff_data)

    thisZdff = zdff_data{subject};
    thisDff  = dff_data{subject};
    
    %------- FIND PEAKS ACROSS WHOLE SIGNAL ------%
    [pks, locs, ~, proms]     = findpeaks(thisZdff,"MinPeakProminence",params.minProm) ;
    
    %------- GET PEAK WIDTHS ------%
    [widths]                  = get_peak_width(params,thisZdff,pks);
    
    %------- REMOVE PEAKS LONGER THAN X SEC (to avoid detecting seizure peaks) ------%
    above_thresh              = find(widths>params.maxWidth);
    pks(above_thresh)         = [];
    locs(above_thresh)        = [];
    widths(above_thresh)      = [];
    proms(above_thresh)       = [];

    % ------- GET (z-DF/F) PEAK-TO-TROUGH AMPLITUDE  ------%
    [P2Tamp]                  = get_p2t_amplitude(params,thisZdff,pks,locs);

    % ------- GET (DF/F) PEAK-TO-TROUGH AMPLITUDE  ------%
     dff_pks                  = thisDff(locs);
    [P2Tamp_dff]              = get_p2t_amplitude(params,thisDff,dff_pks,locs);
    
    transients{subject,1} = pks;
    transients{subject,2} = locs;
    transients{subject,3} = widths;
    transients{subject,4} = P2Tamp;
    transients{subject,5} = proms;
    transients{subject,6} = dff_pks;
    transients{subject,7} = P2Tamp_dff;

    clearvars -except params subject zdff_data dff_data

end
