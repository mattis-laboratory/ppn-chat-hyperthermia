function [config,gcampAligned,isoAligned,eegAligned,tEEG, tPhoto,syncData] = ...
    align_eeg_photo(config,OEP,events,PPD)

%% Extract raw gcamp, isosbestic, and EEG signals and TTLs
gcampRaw           = PPD.analog_1;
isoRaw             = PPD.analog_2;
photoSync          = PPD.digital_1;

eegRaw             = double(OEP.samples(config.eegChannel,:));
eegSync            = get_OEP_TTL(OEP,events);
eegSync            = +eegSync;

%% Upsample Photometry Signal to EEG resolution
fs1 = PPD.sampling_rate;        % Original sampling rate
fs2 = OEP.metadata.sampleRate;  % Target sampling rate

% Generate original time vector
t1 = (0:length(+photoSync)-1) / fs1;

% Generate new (upsampled) time vector
t2 = (0:1/fs2:max(t1));

% Interpolate
photoSyncLong = interp1(t1, +photoSync, t2, 'previous');  % Use 'nearest' if needed
gcampLong     = interp1(t1, gcampRaw, t2, 'pchip');
isoLong       = interp1(t1, isoRaw, t2, 'pchip');

%% Align Signals

[~,~,lag]              = alignsignals(photoSyncLong,eegSync, ...
    Method='risetime',...
    StateLevels=[0 1]);
trim                   = abs(lag);
syncData               = struct();

if lag >0 %photo leading > trim eeg to fit
    eegSyncTrim        = eegSync(trim:end);

    eegAligned         = eegRaw(trim:end);
    gcampAligned       = gcampLong;
    isoAligned         = isoLong;

    syncData.lag       = lag;
    syncData.eegSync   = eegSyncTrim;
    syncData.photoSync = photoSyncLong;
    syncData.note      = 'Photometry leading EEG. Trimmed EEG.';

elseif lag <0 %photo lagging > trim photo to fit
    photoSyncLongTrim  = photoSyncLong(trim:end);

    eegAligned         = eegRaw;
    gcampAligned       = gcampLong(trim:end);
    isoAligned         = isoLong(trim:end);

    syncData.lag       = lag;
    syncData.eegSync   = eegSync;
    syncData.photoSync = photoSyncLongTrim;
    syncData.note      = 'EEG leading photometry. Trimmed photo.';

end

%% Get timestamps
tEEG                   = getTime(eegAligned,config.eegFs);
tPhoto                 = getTime(gcampAligned,config.eegFs);

disp('------------ Signals Aligned ------------')

end
