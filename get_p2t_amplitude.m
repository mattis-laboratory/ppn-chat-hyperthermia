function [P2Tamp] = get_p2t_amplitude(params,signal,pks,locs)

% Initialize an array to store the peak-to-trough amplitudes
P2Tamp = zeros(1, length(locs));
% Loop through each detected peak to find the nearest trough
for i = 1:length(locs)
    % Set the window range to look for a trough around the peak
    window_start = max(1, locs(i) - params.p2tWin);  % Avoid out-of-bounds
    window_end   = min(length(signal), locs(i) + params.p2tWin);

    % Find the minimum (trough) value within the window
    [trough_value, ~] = min(signal(window_start:window_end));

    % Calculate peak-to-trough amplitude
    P2Tamp(i) = pks(i) - trough_value;
end

end
