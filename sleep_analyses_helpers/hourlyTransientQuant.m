function results = hourlyTransientQuant(labels, peakArray, widthArray, promArray, Fs, recLength, epochLength);
%%function to analyze data by hour
%%INPUTS: Fs of the peakArrays, recLength in hours, epochLength in s
%%OUTPUTS: bout length and total state time in seconds, transient rate in
%%transients/second, prominence in z-dF/F, widths in seconds
%%JMc 10/8/25

extended = repelem(labels, epochLength * Fs); 

% labels for Accusleep purposes
NREM_LABEL = 3; 
REM_LABEL  = 1;
WAKE_LABEL = 2;

%break files into individual hours
hour_idxs = 0:recLength;
hourlyLabels = NaN(3600/epochLength, recLength);
extHourlyLabels = NaN(recLength, 3600*Fs);
hourlyPeaks = NaN(recLength, 3600*Fs);
hourlyWidths = NaN(recLength, 3600*Fs);
hourlyProms = NaN(recLength, 3600*Fs);

for i = 1:length(hour_idxs)-1
    start_idx = hour_idxs(i)*3600*Fs + 1;
    end_idx = hour_idxs(i+1)*3600*Fs;

    extHourlyLabels(i, :) = extended(start_idx:end_idx);
    hourlyPeaks(i, :) = peakArray(start_idx:end_idx);
    hourlyWidths(i, :) = widthArray(start_idx:end_idx);
    hourlyProms(i, :) = promArray(start_idx:end_idx);

    lbl_s = hour_idxs(i)*(3600/epochLength) + 1;
    lbl_e = hour_idxs(i+1)*(3600/epochLength);
    hourlyLabels(:, i) = labels(lbl_s:lbl_e); %this one for parse_states

end

%initialize arrays to save stuff
hr_nrem_bouts = NaN(1, recLength);
hr_nrem_time = NaN(1, recLength);
hr_nrem_avg_blen = NaN(1, recLength);
hr_rem_bouts = NaN(1, recLength);
hr_rem_time = NaN(1, recLength);
hr_rem_avg_blen = NaN(1, recLength);
hr_wake_bouts = NaN(1, recLength);
hr_wake_time = NaN(1, recLength);
hr_wake_avg_blen = NaN(1, recLength);

hr_nrem_avg_rate = NaN(1, recLength);
hr_nrem_avg_width = NaN(1, recLength);
hr_nrem_avg_prom = NaN(1, recLength);
hr_rem_avg_rate = NaN(1, recLength);
hr_rem_avg_width = NaN(1, recLength);
hr_rem_avg_prom = NaN(1, recLength);
hr_wake_avg_rate = NaN(1, recLength);
hr_wake_avg_width = NaN(1, recLength);
hr_wake_avg_prom = NaN(1, recLength);

%analyze by individual hours
for h = 1:recLength

    %sleep data
    sl = parse_states(hourlyLabels(:,h), epochLength, Fs);
    
    hr_nrem_bouts(h) = sl.num_nrem_bouts;
    hr_nrem_time(h) = sl.tot_nrem_time;
    hr_nrem_avg_blen(h) = sl.avg_nrem_len;

    hr_rem_bouts(h) = sl.num_rem_bouts;
    hr_rem_time(h) = sl.tot_rem_time;
    hr_rem_avg_blen(h) = sl.avg_rem_len;

    hr_wake_bouts(h) = sl.num_wake_bouts;
    hr_wake_time(h) = sl.tot_wake_time;
    hr_wake_avg_blen(h) = sl.avg_wake_len;
    
    
    %transient data
    curr_pks = hourlyPeaks(h, :);
    curr_widths = hourlyWidths(h, :);
    curr_proms = hourlyProms(h, :);

    nrem_peaks = curr_pks(extHourlyLabels(h, :) == NREM_LABEL);
    rem_peaks = curr_pks(extHourlyLabels(h, :) == REM_LABEL);
    wake_peaks = curr_pks(extHourlyLabels(h, :) == WAKE_LABEL);

    nrem_widths = curr_widths(extHourlyLabels(h, :) == NREM_LABEL);
    rem_widths = curr_widths(extHourlyLabels(h, :) == REM_LABEL);
    wake_widths = curr_widths(extHourlyLabels(h, :) == WAKE_LABEL);

    nrem_proms = curr_proms(extHourlyLabels(h, :) == NREM_LABEL);
    rem_proms = curr_proms(extHourlyLabels(h, :) == REM_LABEL);
    wake_proms = curr_proms(extHourlyLabels(h, :) == WAKE_LABEL);

    hr_nrem_avg_rate(h) = sum(~isnan(nrem_peaks))*Fs / length(nrem_peaks);
    hr_nrem_avg_width(h) = mean(nrem_widths, 'omitmissing') / Fs;
    hr_nrem_avg_prom(h) = mean(nrem_proms, 'omitmissing');

    hr_rem_avg_rate(h) = sum(~isnan(rem_peaks))*Fs / length(rem_peaks);
    hr_rem_avg_width(h) = mean(rem_widths, 'omitmissing') / Fs;
    hr_rem_avg_prom(h) = mean(rem_proms, 'omitmissing');

    hr_wake_avg_rate(h) = sum(~isnan(wake_peaks))*Fs / length(wake_peaks);
    hr_wake_avg_width(h) = mean(wake_widths, 'omitmissing') / Fs;
    hr_wake_avg_prom(h) = mean(wake_proms, 'omitmissing');

end

%save results
results.hr_nrem_bouts = hr_nrem_bouts;
results.hr_nrem_time = hr_nrem_time;
results.hr_nrem_avg_bout_len = hr_nrem_avg_blen;
results.hr_rem_bouts = hr_rem_bouts;
results.hr_rem_time = hr_rem_time;
results.hr_rem_avg_bout_len = hr_rem_avg_blen;
results.hr_wake_bouts = hr_wake_bouts;
results.hr_wake_time = hr_wake_time;
results.hr_wake_avg_bout_len = hr_wake_avg_blen;

results.hr_nrem_avg_rate = hr_nrem_avg_rate;
results.hr_nrem_avg_width = hr_nrem_avg_width;
results.hr_nrem_avg_prom = hr_nrem_avg_prom;
results.hr_rem_avg_rate = hr_rem_avg_rate;
results.hr_rem_avg_width = hr_rem_avg_width;
results.hr_rem_avg_prom = hr_rem_avg_prom;
results.hr_wake_avg_rate = hr_wake_avg_rate;
results.hr_wake_avg_width = hr_wake_avg_width;
results.hr_wake_avg_prom = hr_wake_avg_prom ;

%sanity check outputs

%change NaN rates to 0 for plotting
hr_nrem_avg_rate_plot = hr_nrem_avg_rate;
hr_rem_avg_rate_plot = hr_rem_avg_rate;
hr_wake_avg_rate_plot = hr_wake_avg_rate;

hr_nrem_avg_rate_plot(~isfinite(hr_nrem_avg_rate)) = 0;
hr_rem_avg_rate_plot(~isfinite(hr_rem_avg_rate)) = 0;
hr_wake_avg_rate_plot(~isfinite(hr_wake_avg_rate)) = 0;

%sample of the data
figure;
hold on;
plot(hr_nrem_avg_rate_plot,'-o', 'Color',[3 87 150]./255, 'MarkerFaceColor',[3 87 150]./255);
plot(hr_rem_avg_rate_plot, '--s', 'Color',[207, 2, 121]./255, 'MarkerFaceColor',[207, 2, 121]./255);
plot(hr_wake_avg_rate_plot, ':^', 'Color',[102 105 115]./255, 'MarkerFaceColor',[102 105 115]./255);
legend({'NREM', 'REM', 'Wake'})
xlabel('Hour')
ylabel('transients/second')

disp(horzcat('NREM bouts per hour: ', num2str(hr_nrem_bouts)));
disp(horzcat('REM bouts per hour: ', num2str(hr_rem_bouts)));
disp(horzcat('Wake bouts per hour: ', num2str(hr_wake_bouts)));

end