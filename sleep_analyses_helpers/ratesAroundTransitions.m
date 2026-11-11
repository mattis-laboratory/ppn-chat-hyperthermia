function [transitions_quant] = ratesAroundTransitions(transitions, locs, Fs);

transitions_quant = struct;

%use the timestamps from transitions and the locs to calculate rates 
%will be saved as paired, oppositely paired, unpaired
n2r_rates = NaN(size(transitions.nrem2rem, 1), 1);
n2w_rates = NaN(size(transitions.nrem2wake, 1), 1);
r2w_rates = NaN(size(transitions.rem2wake, 1), 1);
w2n_rates = NaN(size(transitions.wake2nrem, 1), 1);

n2r_all_dist = cell(size(transitions.nrem2rem, 1), 1);
n2w_all_dist = cell(size(transitions.nrem2wake, 1), 1);
r2w_all_dist = cell(size(transitions.rem2wake, 1), 1);
w2n_all_dist = cell(size(transitions.wake2nrem, 1), 1);


for i = 1:size(transitions.nrem2rem, 1)
    curr_bout_start = transitions.nrem2rem(i, 1);
    curr_bout_end = transitions.nrem2rem(i, 2);
    pks_in_bout = sum(locs > curr_bout_start & locs < curr_bout_end);
    bout_len = (curr_bout_end - curr_bout_start) / Fs;
    n2r_rates(i) = pks_in_bout / bout_len;

    pk_locs = locs(locs > curr_bout_start & locs < curr_bout_end);
    dist = pk_locs - curr_bout_end;
    n2r_all_dist{i} = dist;

end

for i = 1:size(transitions.nrem2wake, 1)
    curr_bout_start = transitions.nrem2wake(i, 1);
    curr_bout_end = transitions.nrem2wake(i, 2);
    pks_in_bout = sum(locs> curr_bout_start & locs < curr_bout_end);
    bout_len = (curr_bout_end - curr_bout_start) / Fs;
    n2w_rates(i) = pks_in_bout / bout_len;

    pk_locs = locs(locs > curr_bout_start & locs < curr_bout_end);
    dist = pk_locs - curr_bout_end;
    n2w_all_dist{i} = dist;
end

for i = 1:size(transitions.rem2wake, 1)
    curr_bout_start = transitions.rem2wake(i, 1);
    curr_bout_end = transitions.rem2wake(i, 2);
    pks_in_bout = sum(locs> curr_bout_start & locs < curr_bout_end);
    bout_len = (curr_bout_end - curr_bout_start) / Fs;
    r2w_rates(i) = pks_in_bout / bout_len;

    pk_locs = locs(locs > curr_bout_start & locs < curr_bout_end);
    dist = pk_locs - curr_bout_end;
    r2w_all_dist{i} = dist;
end

for i = 1:size(transitions.wake2nrem, 1)
    curr_bout_start = transitions.wake2nrem(i, 1);
    curr_bout_end = transitions.wake2nrem(i, 2);
    pks_in_bout = sum(locs> curr_bout_start & locs < curr_bout_end);
    bout_len = (curr_bout_end - curr_bout_start) / Fs;
    w2n_rates(i) = pks_in_bout / bout_len;

    pk_locs = locs(locs > curr_bout_start & locs < curr_bout_end);
    dist = pk_locs - curr_bout_end;
    w2n_all_dist{i} = dist;
end


transitions_quant.n2r_rates = n2r_rates;
transitions_quant.n2r_all_dist = n2r_all_dist;
transitions_quant.n2w_rates = n2w_rates;
transitions_quant.n2w_all_dist = n2w_all_dist;

transitions_quant.r2w_rates = r2w_rates;
transitions_quant.r2w_all_dist = r2w_all_dist;
transitions_quant.w2n_rates = w2n_rates;
transitions_quant.w2n_all_dist = w2n_all_dist;

end