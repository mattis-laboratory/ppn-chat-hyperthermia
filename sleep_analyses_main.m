% mattis lab PPN photoEEG analysis stuff

%% make the file structure from the recording data from Mattis rig
mousenum = '5634';
date = 'baseline';
makeFiles4AccuSleep(EEG, EMG, gcamp, iso, Fs, mousenum, date)


%% constants and load in variables
Fs = 1000;
eegFs              = 1000;            % EEG sampling rate
photoFs            = 100;              % FP sampling rate
epochLength        = 5;               % EEG epoch length in seconds
identifier         = '5760';          %mouse number 

% load files in dir
files = dir('*.mat');
for i = 1:length(files)
    load(files(i).name)
end

%% bandpass filter to remove high frequency noise

EEGFilt = designfilt('bandpassfir','FilterOrder',10, ...
'CutoffFrequency1',0.3,'CutoffFrequency2',50, ...
'SampleRate',1000);

EEG = filtfilt(EEGFilt,EEG); %filter EEG signal

save filt_EEG EEG

%% bandpass emg
EMGFilt = designfilt('bandpassfir','FilterOrder',10, ...
'CutoffFrequency1',30,'CutoffFrequency2',100, ...
'SampleRate',1000);

EMG = filtfilt(EMGFilt,EMG); %filter EEG signal

save filt_EMG EMG

%% filter out the strange noise - for scoring
EEG = EEG - mean(EEG); % correct DC shifts

% remove 2.5hz noise
nq = 1000 / 2;
wo = 2.5 / nq;
bw = wo   / 8 ; % might need to adjust the bw...
[b, a] = iirnotch(wo,bw);

EEG = filtfilt(b, a, EEG);

% % remove 60hz line noise
% nq = 1000 / 2;
% wo = 60   / nq;
% bw = wo   / 8;
% [b, a] = iirnotch(wo,bw);
% 
% EEG = filtfilt(b, a, EEG);
% 
% EEG = smooth(EEG, 10); % light smoothing

save filt_EEG EEG

%% Load photometry data
% PyPhotometry file - double check which is right/left
pyPhotometryLoc = ['C:\Users\mccartj\University of Michigan Dropbox\MED-burgesslab\BurgessLab_data_transfer\Jordan'];
[photoName, photofolder] = uigetfile({[pyPhotometryLoc '\*.*']}, 'Select PPD'); % select ppd of interest
photoPath = fullfile(photofolder, photoName);                                   % generate file path

photoFile = import_ppd(photoPath); % load data

% assign data to respective variables
photoLeft  = photoFile.analog_1; 
photoRight = photoFile.analog_2;
digSync1   = photoFile.digital_1;
digSync2   = photoFile.digital_2;

% sanity check
figure;  plot(smooth(photoLeft, 100), 'k');
hold on; plot(smooth(photoRight, 100), 'r'); plot(digSync1)
xlim([0 length(photoLeft)])

%% for syncing the recordings on the burgess rig
photoLeftElongated  = resample(photoLeft,  eegFs, photoFs);
photoRightElongated = resample(photoRight, eegFs, photoFs);
digSyncElongated    = resample(+digSync1,  eegFs, photoFs);

long_sig_r = photoRightElongated;
long_sig_l = photoLeftElongated;
dig_sync = digSyncElongated;
daq_sync = Photored;

% sync photometry to nidaq
py_onset  = find(diff(dig_sync) > 0.03)';

daq_onset = find(diff(daq_sync) > 0.5);
offset    = daq_onset(1) - py_onset(1); 

% redefine FP array to account for recording offset
sync_array_r(1:offset) = long_sig_r(100);
sync_array_r(offset + 1:length(daq_sync)) = long_sig_r(1:length(daq_sync) - offset);

sync_array_l(1:offset) = long_sig_l(100);
sync_array_l(offset + 1:length(daq_sync)) = long_sig_l(1:length(daq_sync) - offset);


%% process synced data
baseline = 0.1;

long_sig = sync_array_l;
long_isos = sync_array_r;

%IRLS method of isos correction
[dff, ~] = IRLS_dFF(long_sig, long_isos, 1.4);
zPhotoSignal = zscore(dff);

%make sure it looks normal
figure; tiledlayout(2, 1)
ax(1) = nexttile;
title('original')
plot(long_sig, 'g'); hold on; plot(long_isos, 'k');
ax(2) = nexttile;
title('dff and corrected')
plot(zPhotoSignal);
linkaxes(ax, 'x')

save(horzcat('zPhotoSignal_', identifier), "zPhotoSignal");
save(horzcat('PhotoSignal_', identifier), "dff");

%% nice hypnoplot
eegFs = 1000;
photoFs = 100;
epochLength = 5;
signal= smooth(dff, 100);
start = 0; stop = 6; dur = stop-start; 

Food = nan(3600*eegFs*dur, 1); Lick = nan(3600*eegFs*dur, 1); RW = nan(3600*eegFs*dur, 1);
goodHypnoPlot('', EEG(3600*eegFs*start+1:3600*eegFs*stop), EMG(3600*eegFs*start+1:3600*eegFs*stop), ...
signal(3600*eegFs*start+1:3600*eegFs*stop), eegFs, photoFs, epochLength, labels(720*start+1:720*stop), Food, Lick, RW, [])


%% plot state transitions

% get sleep states and save to struct
sl_str = parse_states(labels, 5, 1000);

% plot relevant transitions and heatmaps 
transitions.dff = plotStateTransitions(dff, sl_str, 40000, 1000);

%% get other sleep structure data

sl_str.tot_recording_time = sl_str.tot_wake_time + sl_str.tot_nrem_time + sl_str.tot_rem_time + sl_str.tot_cat_time;

sl_str.nrem_pct = sl_str.tot_nrem_time / sl_str.tot_recording_time;
sl_str.rem_pct = sl_str.tot_rem_time / sl_str.tot_recording_time;
sl_str.wake_pct = sl_str.tot_wake_time / sl_str.tot_recording_time;
sl_str.cat_pct = sl_str.tot_cat_time / sl_str.tot_recording_time;

IRIs = sl_str.rem_loc(2:end, 1) - sl_str.rem_loc(1:end-1, 2);
sl_str.mean_IRI = mean(IRIs);

hr_nrem = sl_str.tot_nrem_time / 3600;
sl_str.rem_per_nrem = sl_str.num_rem_bouts / hr_nrem;

save sleep_data sl_str

%% initial transient rate analysis

%sig_smooth = smooth(zPhotoSignal, 100);

%[peakArray, widthArray, promArray, signal_hp] = gcamp_transients(zPhotoSignal, eegFs);

[peakArray, widthArray, promArray, signal_hp] = gcamp_transients(dff, eegFs);

transients = quantify_transients(labels, peakArray, eegFs); %gives rates for the whole recording (ignore the dffs here)

%% plotting transients backwards from state transitions - didn't use / doesn't work
% THRESHOLD = 30; %amount of time the state must be in seconds
% 
% %update this code from paired peak stuff to process mattis lab data
% transitions = getStateTransitions(labels, THRESHOLD, epochLength, eegFs);
% 
% locs = find(~isnan(peak_array));
% [transitions_quant] = ratesAroundTransitions(transitions, locs, eegFs);
% rasterStateTransitions(transitions_quant.n2r_all_dist, transitions_quant.n2w_all_dist, transitions_quant.r2w_all_dist, transitions_quant.w2n_all_dist, eegFs);

%%
[peakArray, widthArray, promArray, ~] = gcamp_transients(zPhotoSignal, eegFs);


bout_transients = boutTransientQuant(labels, widthArray, promArray, eegFs, recLength);


hour_transients = hourlyTransientQuant(labels, peakArray, widthArray, promArray, eegFs, recLength, epochLength); %gives rates, width, and proms hourly

%% batch stuff

%for batch transitions processing - be in mattislabcollab folder
mouse = '5635';
valid = {'baseline', 'post'};

all = dir(mouse);
for i = 1:numel(all)
    if ismember(all(i).name, valid)
        fprintf('Loading data from %s\n', all(i).name);

        day = dir(fullfile(all(i).folder, all(i).name));
        % load in raw signal and labels file
        [labels, ~, ~, dffSignal] = get_mattis_variables(day);

        %get dff and z-scored signal - IRLS method of isos correction
        %[dffSignal, ~] = IRLS_dFF(gcamp, iso, 1.4);
        %zPhotoSignal = zscore(dffSignal);

        sl_str = parse_states(labels, 5, 1000);

        for k = 1 %if doing both, k = 1:2
            if k == 1
                signal = dffSignal;
                savetype = 'dff';
            else
                signal = zPhotoSignal;
                savetype = 'zscored';
            end

            %transitions.(savetype) = plotStateTransitions(signal, sl_str, 40000, 1000);
            stateDFF.(savetype)    = plotStateDFF(signal, labels, sl_str.brief_wake_loc, 1000, 5); 
        end
        
        %save state transitions and dFF into a folder for later plotting
        %save_name1 = horzcat(mouse, all(i).name, 'transitions', '.mat');
        %save(fullfile("C:\Users\mccartj\University of Michigan Dropbox\MED-burgesslab\BurgessLab_data_transfer\Jordan\mattislabcollab\Data\DS_post_transitions\", save_name1), "transitions");
        save_name2 = horzcat(mouse, all(i).name, 'stateDFF', '.mat');
        save(fullfile("C:\Users\mccartj\University of Michigan Dropbox\MED-burgesslab\BurgessLab_data_transfer\Jordan\mattislabcollab\Data", save_name2), "stateDFF");

    end
end

%% get averages per mouse
data = collapse('is_avg', 1, 'is_struct', 1);
post = collapse('is_avg', 1, 'is_struct', 1);

%% get all trials for mouse
data2 = collapse('is_avg', 0, 'is_struct', 1);

%% brandon's function for a nice state transitions graph - have to go in and modify things for it to work for this data btw

plotting_slp_transitions(data.dff, [42, 150, 3]./255,'figure')

%plotting_slp_transitions(post.dff, [26, 162, 196]./255 ,'hold')



%% batch transient analysis

%for batch transients processing - be in mattislabcollab folder
mouse = '5635';
valid = {'baseline', 'post'};

eegFs = 1000;
epochLength = 5;

all = dir(mouse);
for i = 1:numel(all)
    if ismember(all(i).name, valid)
        fprintf('Loading data from %s\n', all(i).name);

        day = dir(fullfile(all(i).folder, all(i).name));

        %load in dff variable
        [labels, ~, ~, dffSignal] = get_mattis_variables(day);

        % % load in raw signal and labels file
        % [labels, gcamp, iso] = get_mattis_variables(day);
        % 
        % %get dff and z-scored signal - IRLS method of isos correction
        % [dffSignal, ~] = IRLS_dFF(gcamp, iso, 1.4);
        % zPhotoSignal = zscore(dffSignal);

        sl_str = parse_states(labels, 5, 1000);

        transients = struct;

        % for k = 1
        %     if k == 1
        %         signal = dffSignal;
        %         savetype = 'dff';
        %     else
        %         signal = zPhotoSignal;
        %         savetype = 'zscored';
        %     end
        % 
        %     [peakArray, widthArray, promArray, ~] = gcamp_transients(signal, eegFs);
        % 
        %     rate = quantify_transients(labels, peakArray, eegFs); 
        %     [widths, proms] = quantify_width_prom(labels, widthArray, promArray, eegFs);
        % 
        %     transients.(savetype).rate = rate;
        %     transients.(savetype).widths = widths;
        %     transients.(savetype).proms = proms;
        % 
        % end
        
        signal = dffSignal;
        savetype = 'dff';
    
        [peakArray, widthArray, promArray, ~] = gcamp_transients(signal, eegFs);
        rate = quantify_transients(labels, peakArray, eegFs); 
        [widths, proms] = quantify_width_prom(labels, widthArray, promArray, eegFs);

        transients.(savetype).rate = rate;
        transients.(savetype).widths = widths;
        transients.(savetype).proms = proms;

        %save into a folder for later plotting
        save_name1 = horzcat(mouse, all(i).name, 'transients', '.mat');
        save(fullfile("C:\Users\mccartj\University of Michigan Dropbox\MED-burgesslab\BurgessLab_data_transfer\Jordan\mattislabcollab\Data", save_name1), "transients");

    end
end


%% combine data

data = collapse('is_struct', 1, 'is_avg', 0);


%% heatmaps for the combined data - use non-averaged structures
Fs = 1000;

figure;
tiledlayout(1, 5);

nexttile;
imagesc(normalization(data2.dff.nremToRemTransitions, 250))
colormap("hot")
caxis([.2 1])
xline(40000, '--w')
xt = get(gca, 'xtick');
set(gca, 'XTick', xt, 'xticklabel', (xt - 40000) / Fs)
xlim([0 length(data2.dff.nremToRemTransitions)])
xlabel('Time (s)')
title('NREM to REM transition')
pbaspect([1 1 1])


nexttile;
imagesc(normalization(data2.dff.remToWakeTransitions, 250))
colormap("hot")
caxis([.2 1])
xline(40000, '--w')
xt = get(gca, 'xtick');
set(gca, 'XTick', xt, 'xticklabel', (xt - 40000) / Fs)
xlim([0 length(data2.dff.remToWakeTransitions)])
xlabel('Time (s)')
title('REM to Wake transition')
pbaspect([1 1 1])

nexttile;
imagesc(normalization(data2.dff.wakeToNremTransitions, 250))
colormap("hot")
caxis([.2 1])
xline(40000, '--w')
xt = get(gca, 'xtick');
set(gca, 'XTick', xt, 'xticklabel', (xt - 40000) / Fs)
xlim([0 length(data2.dff.wakeToNremTransitions)])
xlabel('Time (s)')
title('Wake to NREM transition')
pbaspect([1 1 1])

nexttile;
imagesc(normalization(data2.dff.nremToWakeTransitions, 250))
colormap("hot")
caxis([.2 1])
xline(40000, '--w')
xt = get(gca, 'xtick');
set(gca, 'XTick', xt, 'xticklabel', (xt - 40000) / Fs)
xlim([0 length(data2.dff.nremToWakeTransitions)])
xlabel('Time (s)')
title('NREM to Wake transition')
pbaspect([1 1 1])

nexttile;
imagesc(normalization(data2.dff.briefArousals, 250))
colormap("hot")
caxis([.2 1])
xline(40000, '--w')
xt = get(gca, 'xtick');
set(gca, 'XTick', xt, 'xticklabel', (xt - 40000) / Fs)
xlim([0 length(data2.dff.briefArousals)])
xlabel('Time (s)')
title('Brief Arousals')
pbaspect([1 1 1])

colorbar()
set(gcf, 'renderer', 'painters')