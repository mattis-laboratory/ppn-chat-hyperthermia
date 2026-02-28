
function cfg = setup_preproc_config()

% User-defined parameters for running preprocessing script
% Always double-check before running 
cfg = struct();

%% --- Subjects ---
cfg.subject            = '';         % ID of which mouse to run

%% --- Paths ---
cfg.root               = '';         % root data directory
cfg.project            = '';         % project specific subfolder
cfg.datapath           = [cfg.root,cfg.project,'/',num2str(cfg.subject),'/']; 

%% --- Channels / signals ---
cfg.eegChannel         = 3;          % which EEG channel to load/process
cfg.tempChannel        = [];         % temp sensor channel (if applicable)
cfg.optoADC            = [];         % ADC 7 = 23 in OEP
cfg.numOEPRecording    = 1;          % which eeg recording (usually first one)

%% --- Processing options ---
cfg.rejectArtifact     = false;      % choose whether to interpolate eeg artifacts (optional)
cfg.gaussSigma         = 75;         % stdev of gaussian kernel for photometry denoising (in samples)
cfg.hpfCutoff          = 0.01;       % cutoff freq. for high-pass filtering (in Hz)
cfg.blDuration         = 60;         % duration of baseline/ when heating started (in seconds)

%% --- Plotting options ---

% Colors/styles for event lines
cfg.evtStyle           = struct( ...
    'HEAT', struct('Color','b','LineStyle','--','LineWidth',2), ...
    'EEC',  struct('Color','r','LineStyle','--','LineWidth',2), ...
    'UEO',  struct('Color','g','LineStyle','--','LineWidth',2), ...
    'OFF',  struct('Color','k','LineStyle','--','LineWidth',2) );

cfg.showPlot           = 'on';       % Show final plots

%% --- Overwrite ---
cfg.overwrite          = false;      % Overwrite existing save 

end

