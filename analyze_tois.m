%% Characterize calcium activity at TOIs
clc; clear; close all;

% Data
root               = '/nfs/turbo/umms-mattislab/Chandni/Data/';
project            = 'PPN_ChAT_Hyperthermia';

load([root,project,'/subs_info.mat']);
load([root,project,'/het_data.mat']);

% Choose dataset
group    = het_zdff_hpf;

filename = ['metrics_',fileRoot,'.xlsx'];
savepath = [folderName,filename];

%% Detect Peaks
for subject = 1: length(group)

    thisZdff = group{subject};

    %% Define Time Periods From TOIs
    % Baseline (0 TO HEAT START) - whole
    BL = 1:all_toi(subject).HEAT;

    % HEATING (HEAT START to UEO)
    HEAT = all_toi{subject}(1)+1:all_toi{subject}(3);
    HEAT_length = length(HEAT);

    % Seizure (UEO to OFF)
    SZ = all_toi{subject}(3):all_toi{subject}(4);

    %% Means
    %Baseline
    BL_mean         = nanmean(thisZdff(BL));
    %Heating
    HEAT1_mean      = nanmean(thisZdff(HEAT(1):HEAT(floor(end/2))));
    HEAT2_mean      = nanmean(thisZdff(HEAT(floor(end/2)):HEAT(end)));
    %Seizure
    SZ_mean         = nanmean(thisZdff(SZ));

    all_means(subject,:) = {het_sess{subject},BL_mean, HEAT1_mean, HEAT2_mean,SZ_mean, PSZ_mean};

    %% Total Peaks
    % Baseline: Get indices of peaks
    BL_pks           = find(locs<length(BL)+1);
    BL_total         = length(BL_pks);
    % HEATING: Get indices of peaks within each half
    HEAT1_pks        = find(locs>HEAT(1) & locs < HEAT(floor(end/2)));
    HEAT2_pks        = find(locs>HEAT(floor(end/2))& locs < HEAT(end));
    HEAT1_total      = length(HEAT1_pks);
    HEAT2_total      = length(HEAT2_pks);
    % Seizure: Get indices of peaks
    SZ_pks           = find(locs>SZ(1) & locs<SZ(end));
    SZ_total         = length(SZ_pks);
    % Post-seizure: Get indices of peaks within each subperiod
    PSZ_pks          = find(locs>PSZ(1));
    PSZ_total        = length(PSZ_pks);

    all_totals(subject,:) = {het_sess{subject},BL_total, HEAT1_total, HEAT2_total,SZ_total, PSZ_total};


    %% Frequency
    % Baseline
    BL_rate             = length(BL_pks)/(length(BL)/Fs);
    % HEATING
    HEAT1_rate          = length(HEAT1_pks)/(HEAT_length/Fs);
    HEAT2_rate          = length(HEAT2_pks)/(HEAT_length/Fs);
    % Seizure
    SZ_rate             = length(SZ_pks)/(length(SZ)/Fs);
    %Post-Seizure
    PSZ_rate            = length(PSZ_pks)/(length(PSZ)/Fs);

    all_freq(subject,:) = {het_sess{subject},BL_rate, HEAT1_rate, HEAT2_rate,SZ_rate, PSZ_rate};


    %% P2T Amplitude
    % Baseline
    BL_P2Tamp           = nanmean(P2Tamp(BL_pks));
    % Heating
    HEAT1_P2Tamp        = nanmean(P2Tamp(HEAT1_pks));
    HEAT2_P2Tamp        = nanmean(P2Tamp(HEAT2_pks));
    % Seizure
    SZ_P2Tamp           = nanmean(P2Tamp(SZ_pks));
    % Post-seizure
    PSZ_P2Tamp          = nanmean(P2Tamp(PSZ_pks));

    all_P2Tamp(subject,:) = {het_sess{subject},BL_P2Tamp, HEAT1_P2Tamp, HEAT2_P2Tamp,SZ_P2Tamp, PSZ_P2Tamp};

    %% P2T Amplitude (DF/F)
    % Baseline
    BL_P2Tamp_dff       = nanmean(P2Tamp_dff(BL_pks));
    % Heating
    HEAT1_P2Tamp_dff    = nanmean(P2Tamp_dff(HEAT1_pks));
    HEAT2_P2Tamp_dff    = nanmean(P2Tamp_dff(HEAT2_pks));
    % Seizure
    SZ_P2Tamp_dff       = nanmean(P2Tamp_dff(SZ_pks));
    % Post-seizure
    PSZ_P2Tamp_dff      = nanmean(P2Tamp_dff(PSZ_pks));

    all_P2Tamp_dff(subject,:) = {het_sess{subject},BL_P2Tamp_dff, HEAT1_P2Tamp_dff, HEAT2_P2Tamp_dff,SZ_P2Tamp_dff, PSZ_P2Tamp_dff};

    %% Peak Width
    %Baseline
    BL_width            = nanmean(prom_widths(BL_pks)/Fs);
    %Heating
    HEAT1_width         = nanmean(prom_widths(HEAT1_pks)/Fs);
    HEAT2_width         = nanmean(prom_widths(HEAT2_pks)/Fs);
    %Seizure
    SZ_width            = nanmean(prom_widths(SZ_pks)/Fs);
    %Post-seizure
    PSZ_width           = nanmean(prom_widths(PSZ_pks)/Fs);

    all_width(subject,:) = {het_sess{subject},BL_width, HEAT1_width, HEAT2_width,SZ_width, PSZ_width};

    %% ISI
    % Baseline
    BL_ISI              = nanmean(diff(locs(BL_pks)))/Fs;
    %Heating
    HEAT1_ISI           = nanmean(diff(locs(HEAT1_pks)))/Fs;
    HEAT2_ISI           = nanmean(diff(locs(HEAT2_pks)))/Fs;
    %Seizure
    SZ_ISI              = nanmean(diff(locs(SZ_pks)))/Fs;
    %Post-seizure
    PSZ_ISI             = nanmean(diff(locs(PSZ_pks)))/Fs;

    all_ISI(subject,:) = {het_sess{subject},BL_ISI, HEAT1_ISI, HEAT2_ISI,SZ_ISI, PSZ_ISI};

    clearvars -except het* project PV_subs root ylimits Fs group det_prom det_width fileRoot ...
        all_means all_totals all_ISI all_freq all_width all_P2Tamp all_P2Tamp_dff folderName savepath
end

%% Save to Excel File

% Append header to each cell
header = {'Mouse_Session','Baseline','Early Heating','Late Heating','Seizure','Post-Ictal'};

all_means = [header; all_means];
all_totals = [header; all_totals];
all_freq = [header; all_freq];
all_P2Tamp = [header; all_P2Tamp];
all_P2Tamp_dff = [header; all_P2Tamp_dff];
all_width = [header; all_width];
all_ISI = [header; all_ISI];


writecell(all_means, savepath, 'Sheet', 'Mean');
writecell(all_totals, savepath, 'Sheet', 'Total');
writecell(all_freq, savepath, 'Sheet', 'Frequency');
writecell(all_P2Tamp, savepath, 'Sheet', 'P2T_amp');
writecell(all_P2Tamp_dff, savepath, 'Sheet', 'P2T_amp_dff');
writecell(all_width, savepath, 'Sheet', 'Width');
writecell(all_ISI, savepath, 'Sheet', 'ISI');


