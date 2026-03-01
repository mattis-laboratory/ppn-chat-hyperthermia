%% Preprocessing EEG and Fluorescence Signals
% Chandni Rana - University of Michigan - Mattis Lab
clear; close all
cfg                           = setup_preproc_config();

%% Step 1: Import Data (select session to run)
[PPD]                         = load_ppd(cfg.datapath);
[OEP,~, events,~]             = load_oep(cfg.datapath,cfg.numOEPRecording);

% Append metadata to config file
cfg.eegFs                     = OEP.metadata.sampleRate;
cfg.photoFs                   = PPD.sampling_rate;
cfg.datestamp                 = PPD.date_time(1:10);
cfg.savepath                  = [cfg.datapath,cfg.datestamp,'/test/'];

if ~isfolder(cfg.savepath)
    mkdir(cfg.savepath)
    disp('----------------Output Directory Created----------------')
end

%% Step 2: Upsample Fluorescence and Align with EEG
[cfg, gcampAln, isoAln, eegAln, tEEG, tPhoto, syncData] ...
                              = align_eeg_photo(cfg,OEP,events,PPD);

%% Step 3: Denoise EEG
[eegFilt]                     = denoise_eeg(cfg, eegAln);

%% Step 4: Reject EEG Artifacts (optional)
[cfg, eegClean]               = reject_artifact(cfg,eegFilt);

%% Step 5: Denoise Fluorescence
[gcampFilt,isoFilt]           = denoise_photo(cfg,gcampAln,isoAln);

%% Step 6: Normalize Fluorescence
[dff,zdff]                    = normalize_photo(cfg,gcampFilt,isoFilt);

%% Step 7: High-pass filter DF/F (remove drift)
[dff_hpf, zdff_hpf]           = hpf_photo(cfg,dff);

%% Step 8: Mark Times of Interest (TOIs)
[toi]                         = mark_tois(cfg,zdff, eegClean);

%% Step 9: Plot preprocessed signals
fig = figure('Visible',cfg.showPlot);
fig.Position = [431 174 1048 605];

tl = tiledlayout(fig, 2, 1);

% --- Panel 1: Photometry ---
ax1 = nexttile(tl);
plotPanel(ax1, tPhoto, zdff, 'z-\DeltaF/F');
title(ax1, sprintf('%s-%s', num2str(cfg.subject), cfg.datestamp));
yl = ylim(ax1);
ax1.YLim = [yl(1)-1, yl(2)+1];
addEventLines(ax1, tPhoto, toi, cfg.evtStyle);

% --- Panel 2: EEG (in mV) ---
ax2 = nexttile(tl);
plotPanel(ax2, tEEG, eegClean/1000, 'EEG (mV)');
ax2.YLim = [-15 15];
addEventLines(ax2, tEEG, toi, cfg.evtStyle);
xlabel('Time (s)')

% --- Adjust axes ---
linkaxes([ax1 ax2], 'x');
%extend x-axis 15 second beyond last data point
xmax = max([tEEG(end), tPhoto(end)]) + 15;
xlim(ax1, [0 xmax]);

%% Step 10: Save preprocessed data (optional)
if cfg.overwrite == true
    % Save preproc figure
    saveas(fig, [cfg.savepath,'preproc_traces.fig']);  % Save as .fig file
    saveas(fig, [cfg.savepath,'preproc_traces.png']);  % Save as .png file
    delete(fig)

    % Save preproc data
    eeg  = eegClean; %rename for convenience

    filename = [cfg.savepath,'preproc_data.mat'];
    save(filename,'cfg','syncData','toi', ...
        'dff','dff_hpf','zdff','zdff_hpf','tPhoto',...
        'eeg','tEEG','-mat')

    disp('----------------------Preprocessed Data Saved!------------------')
else
    disp('----------------------Data was NOT Saved------------------------')
end



%% Helpers
function plotPanel(ax, t, y, ylab)
plot(ax, t, y);
box(ax, 'off');
ylabel(ax, ylab);
ax.FontSize = 14;
ax.FontWeight = "bold";
end

function addEventLines(ax, t, events, style)
% Always draw HEAT if present
if isfield(events, 'HEAT') && ~isempty(events.HEAT)
    addOne(ax, t, events.HEAT, style.HEAT);
end

% Draw others only if present
fn = {'EEC','UEO','OFF'};
for i = 1:numel(fn)
    f = fn{i};
    if isfield(events, f) && ~isempty(events.(f))
        addOne(ax, t, events.(f), style.(f));
    end
end

    function addOne(axh, tt, idx, st)
        % idx is an index into tt
        if idx >= 1 && idx <= numel(tt)
            xline(axh, tt(idx), 'Color', st.Color, 'LineStyle', st.LineStyle, 'LineWidth', st.LineWidth);
        end
    end
end
