function [prom_widths] = get_peak_width(params,thisZdff,pks)

     % ------- CALCULATE PEAK WIDTH AT X% PROMINENCE ------%
    for p = 1:length(pks)
        % Find the peak height at X% of prominence
        height_at_X_percent = pks(p) - params.promFraction * proms(p);

        % Find the left and right points where the signal is equal to height_at_X_percent
        left_idx = find(thisZdff(1:locs(p)) <= height_at_X_percent, 1, 'last');
        right_idx = find(thisZdff(locs(p):end) <= height_at_X_percent, 1, 'first') + locs(p) - 1;

        % Calculate the width at X% prominence
        prom_widths(p,:) = right_idx - left_idx;
    end

end