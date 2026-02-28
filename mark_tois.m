function out = mark_tois(config,zdff, eegClean)
% Mark EEC, UEO, and OFF timepoints
% out.markings = [EEC, UEO, OFF, ...]

% Append start of heating/end of baseline to beginning of markings
HEAT = config.blDuration*config.eegFs;

out = struct('markings', [], 'HEAT', HEAT, 'EEC', [], 'UEO', [], 'OFF', [], 'allTips', []);

fig = figure('NumberTitle','off');
fig.Position = [46,165,1343,332];
tiledlayout(fig, 2, 1);

ax1 = nexttile;
plot(ax1, zdff); box(ax1,'off');
ylabel(ax1, 'z-DF/F');

ax2 = nexttile;
plot(ax2, eegClean); box(ax2,'off');
ax2.YLim = [-10000 10000];
ylabel(ax2, 'EEG (uV)');

linkaxes([ax1 ax2], 'x');

% Enable data cursor mode (data tips)
dcm = datacursormode(fig);
set(dcm, 'Enable', 'on');
title(ax1, "Add data tips at EEC/UEO/OFF (any axis), then CLOSE the figure");

% capture tip indices on close
done = false;
fig.CloseRequestFcn = @onClose;

uiwait(fig);   % wait until user closes figure (via onClose)

if ~done
    % user closed unexpectedly
    return;
end

    function onClose(~,~)
        % Capture cursor info BEFORE figure is deleted
        try
            info = getCursorInfo(dcm);   % struct array
            if isempty(info)
                tips = [];
            else
                tips = sort([info.DataIndex]);  % indices into x-data (sample index)
            end
        catch
            tips = [];
        end

        out.allTips = tips;

        if isempty(tips)
            out.markings = HEAT;
        else
            out.markings = [HEAT, tips];
            if numel(tips) >= 3
                out.EEC = tips(1);
                out.UEO = tips(2);
                out.OFF = tips(3);
            end
        end

        done = true;
        uiresume(fig);
        delete(fig);
    end
end