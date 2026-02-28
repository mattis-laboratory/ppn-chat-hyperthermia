function [dff_hpf, zdff_hpf] = hpf_photo(config,dff)

% Setup filter
cutoff  = config.hpfCutoff;
Fs      = config.eegFs;
order   = 2;
[b, a]  = butter(order, cutoff / (Fs/2), 'high');

% Apply high-pass filter
dff_hpf = filtfilt(b, a, dff);

% Z-score high-pass filtered signal
zdff_hpf = zscore(dff_hpf);

disp('------------- High-pass Filtered DF/F --------------')

end