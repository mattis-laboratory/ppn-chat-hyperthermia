function results = boutTransientQuant(labels, widthArray, promArray, Fs, recLength)
%%to do time-based analysis of sleep photometry per bout. recLength should be in
%%hours. the hours that show up on the graphs reflect the last bout of that
%%state ending within the hour
%%JMc 10032025


for i = 1:recLength
    hours(i) = i*3600*Fs;
end

sl_str = parse_states(labels, 5, 1000);
results = struct;


%% nrem stuff

nrem_loc = sl_str.nrem_loc * Fs;

%calculate avg amplitude, transient rate, width, and length of each bout
nrem_rates = NaN(size(nrem_loc, 1), 1);
nrem_amps = NaN(size(nrem_loc, 1), 1);
nrem_lengths = NaN(size(nrem_loc, 1), 1);
nrem_widths = NaN(size(nrem_loc, 1), 1);

for i = 1:size(nrem_loc, 1)
    nrem_bout_peaks = promArray(nrem_loc(i, 1):nrem_loc(i,2));
    avg_nrem_amp = sum(nrem_bout_peaks, 'omitnan')/length(rmmissing(nrem_bout_peaks));
    nrem_amps(i) = avg_nrem_amp;

    nrem_bout_rate = sum(~isnan(nrem_bout_peaks))*Fs / (nrem_loc(i, 2) - nrem_loc(i,1)); %will give bout rate as transients per second
    nrem_rates(i) = nrem_bout_rate;

    nrem_bout_width = widthArray(nrem_loc(i, 1):nrem_loc(i, 2));
    avg_nrem_width = sum(nrem_bout_width, 'omitnan')/length(rmmissing(nrem_bout_width));
    nrem_widths(i) = avg_nrem_width / Fs;

    nrem_bout_length = (nrem_loc(i, 2) - nrem_loc(i,1));
    nrem_lengths(i) = nrem_bout_length / Fs;
end



%find which bouts occurred in which hour
nrem_sections_orig = NaN(length(hours), 1);
for i = 1:length(hours)
    nrem_in_hour = find(nrem_loc(:,2)<=hours(i)); %a bout falls into a section if it ends before the hour is up    
    if ~isempty(nrem_in_hour)
        nrem_sections_orig(i) = nrem_in_hour(end);
    else 
        nrem_sections_orig(i) = 0;
    end
end

nrem_sections = nrem_sections_orig;


%save stuff
results.nrem_bout_lengths = nrem_lengths;
results.nrem_bout_rates = nrem_rates;
results.nrem_bout_amps = nrem_amps;
results.nrem_bout_widths = nrem_widths;
results.nrem_hour_cutoffs = nrem_sections;


figure;
t = tiledlayout(1,3);
t.TileSpacing = 'compact';
t.Padding = 'compact';
title(t, 'NREM bouts')

nexttile;
hold on;
plot(nrem_rates, 'o');
for i = 1:length(nrem_sections)
    linelabel = horzcat('Hour ', num2str(i));
    xline(nrem_sections(i), '--k', linelabel)
end
xlabel('Bout of NREM');
ylabel('Avg Bout Transient Rate (transients/s)');

nexttile;
hold on;
plot(nrem_amps, 'o');
for i = 1:length(nrem_sections)
    linelabel = horzcat('Hour ', num2str(i));
    xline(nrem_sections(i), '--k', linelabel)
end
xlabel('Bout of NREM');
ylabel('Avg Transient Amplitude (zdF/F)');

nexttile;
hold on;
plot(nrem_widths, 'o');
for i = 1:length(nrem_sections)
    linelabel = horzcat('Hour ', num2str(i));
    xline(nrem_sections(i), '--k', linelabel)
end
xlabel('Bout of NREM');
ylabel('Avg Transient Width (s)');

%% rem stuff
rem_loc = sl_str.rem_loc * Fs;

%calculate avg amplitude, transient rate, width, and length of each bout
rem_rates = NaN(size(rem_loc, 1), 1);
rem_amps = NaN(size(rem_loc, 1), 1);
rem_lengths = NaN(size(rem_loc, 1), 1);
rem_widths = NaN(size(rem_loc, 1), 1);

for i = 1:size(rem_loc, 1)
    rem_bout_peaks = promArray(rem_loc(i, 1):rem_loc(i,2));
    avg_rem_amp = sum(rem_bout_peaks, 'omitnan')/length(rmmissing(rem_bout_peaks));
    rem_amps(i) = avg_rem_amp;

    rem_bout_rate = sum(~isnan(rem_bout_peaks))*Fs / (rem_loc(i, 2) - rem_loc(i,1)); %will give bout rate as transients per second
    rem_rates(i) = rem_bout_rate;

    rem_bout_width = widthArray(rem_loc(i, 1):rem_loc(i, 2));
    avg_rem_width = sum(rem_bout_width, 'omitnan')/length(rmmissing(rem_bout_width));
    rem_widths(i) = avg_rem_width / Fs;

    rem_bout_length = (rem_loc(i, 2) - rem_loc(i,1));
    rem_lengths(i) = rem_bout_length / Fs;
end



%find which bouts occurred in which hour
rem_sections_orig = NaN(length(hours), 1);
for i = 1:length(hours)
    rem_in_hour = find(rem_loc(:,2)<=hours(i)); %a bout falls into a section if it ends before the hour is up    
    if ~isempty(rem_in_hour)
        rem_sections_orig(i) = rem_in_hour(end);
    else 
        rem_sections_orig(i) = 0;
    end
end
rem_sections = rem_sections_orig;


%save stuff
results.rem_bout_lengths = rem_lengths;
results.rem_bout_rates = rem_rates;
results.rem_bout_amps = rem_amps;
results.rem_bout_widths = rem_widths;
results.rem_hour_cutoffs = rem_sections;


figure;
t = tiledlayout(1,3);
t.TileSpacing = 'compact';
t.Padding = 'compact';
title(t, 'rem bouts')

nexttile;
hold on;
plot(rem_rates, 'o');
for i = 1:length(rem_sections)
    linelabel = horzcat('Hour ', num2str(i));
    xline(rem_sections(i), '--k', linelabel)
end
xlabel('Bout of REM');
ylabel('Avg Bout Transient Rate (transients/s)');

nexttile;
hold on;
plot(rem_amps, 'o');
for i = 1:length(rem_sections)
    linelabel = horzcat('Hour ', num2str(i));
    xline(rem_sections(i), '--k', linelabel)
end
xlabel('Bout of REM');
ylabel('Avg Transient Amplitude (zdF/F)');

nexttile;
hold on;
plot(rem_widths, 'o');
for i = 1:length(rem_sections)
    linelabel = horzcat('Hour ', num2str(i));
    xline(rem_sections(i), '--k', linelabel)
end
xlabel('Bout of REM');
ylabel('Avg Transient Width (s)');

%% wake stuff
wake_loc = sl_str.wake_loc * Fs;

%calculate avg amplitude, transient rate, width, and length of each bout
wake_rates = NaN(size(wake_loc, 1), 1);
wake_amps = NaN(size(wake_loc, 1), 1);
wake_lengths = NaN(size(wake_loc, 1), 1);
wake_widths = NaN(size(wake_loc, 1), 1);

for i = 1:size(wake_loc, 1)
    wake_bout_peaks = promArray(wake_loc(i, 1):wake_loc(i,2));
    avg_wake_amp = sum(wake_bout_peaks, 'omitnan')/length(rmmissing(wake_bout_peaks));
    wake_amps(i) = avg_wake_amp;

    wake_bout_rate = sum(~isnan(wake_bout_peaks))*Fs / (wake_loc(i, 2) - wake_loc(i,1)); %will give bout rate as transients per second
    wake_rates(i) = wake_bout_rate;

    wake_bout_width = widthArray(wake_loc(i, 1):wake_loc(i, 2));
    avg_wake_width = sum(wake_bout_width, 'omitnan')/length(rmmissing(wake_bout_width));
    wake_widths(i) = avg_wake_width / Fs;

    wake_bout_length = (wake_loc(i, 2) - wake_loc(i,1));
    wake_lengths(i) = wake_bout_length / Fs;
end



%find which bouts occurred in which hour
wake_sections_orig = NaN(length(hours), 1);
for i = 1:length(hours)
    wake_in_hour = find(wake_loc(:,2)<=hours(i)); %a bout falls into a section if it ends before the hour is up    
    if ~isempty(wake_in_hour)
        wake_sections_orig(i) = wake_in_hour(end);
    else 
        wake_sections_orig(i) = 0;
    end
end
wake_sections = wake_sections_orig;



%save stuff
results.wake_bout_lengths = wake_lengths;
results.wake_bout_rates = wake_rates;
results.wake_bout_amps = wake_amps;
results.wake_bout_widths = wake_widths;
results.wake_hour_cutoffs = wake_sections;


%sanity check plots
figure;
t = tiledlayout(1,3);
t.TileSpacing = 'compact';
t.Padding = 'compact';
title(t, 'Wake bouts')

nexttile;
hold on;
plot(wake_rates, 'o');
for i = 1:length(wake_sections)
    linelabel = horzcat('Hour ', num2str(i));
    xline(wake_sections(i), '--k', linelabel)
end
xlabel('Bout of Wake');
ylabel('Avg Bout Transient Rate (transients/s)');

nexttile;
hold on;
plot(wake_amps, 'o');
for i = 1:length(wake_sections)
    linelabel = horzcat('Hour ', num2str(i));
    xline(wake_sections(i), '--k', linelabel)
end
xlabel('Bout of Wake');
ylabel('Avg Transient Amplitude (zdF/F)');

nexttile;
hold on;
plot(wake_widths, 'o');
for i = 1:length(wake_sections)
    linelabel = horzcat('Hour ', num2str(i));
    xline(wake_sections(i), '--k', linelabel)
end
xlabel('Bout of Wake');
ylabel('Avg Transient Width (s)');

