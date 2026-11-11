function [peak_array, width_array, prom_array, signal_hp] = gcamp_transients(signal, fs)

%% smooth
signal_sm = smoothdata(signal, 'gaussian', fs);

%% estimate and subtract baseline
baseline = movmedian(signal_sm, fs * 300); % 5 min smooth

signal_hp = signal_sm - baseline;

figure;hold on;plot(signal_sm,'k');plot(baseline,'b')

%% Estimate noise
noise_std = mad(signal_hp, 1) / 0.6745;

threshold = 2 * noise_std;

%% detect peaks
[peak_amp, peak_locs, peak_widths, peak_prom] = findpeaks( ...
    signal_hp, ...
    'MinPeakProminence', threshold, ...
    'MinPeakDistance', fs);

figure; findpeaks(signal_hp,...
    'MinPeakProminence', threshold, ...
    'MinPeakDistance', fs, ... 
    "Annotate", "extents");

%% create arrays
peak_array = nan(size(signal_hp));
peak_array(peak_locs) = peak_amp;

width_array = nan(size(signal_hp));
width_array(peak_locs) = peak_widths;

prom_array = nan(size(signal_hp));
prom_array(peak_locs) = peak_prom;

end