function [config, eegClean] = reject_artifact(config, eegFilt)

if config.rejectArtifact == true

    rejEEG = eegFilt;

    rej = figure;
    rej.Position = [53 201 1260 323];

    h = plot(rejEEG);
    title('Brush artifacts, then CLOSE the figure to continue')
    brush(rej, 'on');

    rej_ind = [];

    % When the figure is closed, grab BrushData BEFORE deletion
    rej.CloseRequestFcn = @onClose;

    % Wait until uiresume is called (in onClose)
    uiwait(rej);

    % ---- Continue after figure close ----
    config.rej_indices  = rej_ind;

    rejEEG(rej_ind) = NaN;
    eegClean = fillmissing(rejEEG, "pchip");
    disp('------------ Noise Interpolated ------------')

else
    eegClean = eegFilt;
    disp('------------ No Interpolation Completed ------------')
end

    function onClose(~, ~)
        % Called when user closes the figure.
        % Capture brushed points before the line/figure are deleted.
        try
            bd = h.BrushData;           % numeric array (0 = not brushed)
            rej_ind = find(bd > 0);     % brushed indices
        catch
            rej_ind = [];
        end

        % Resume script and then close figure
        uiresume(rej);
        delete(rej);
    end

end