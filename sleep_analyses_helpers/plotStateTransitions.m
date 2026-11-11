function results = plotStateTransitions(photoSignal, sleepStruct, cutTime, Fs)

% plot all relevant transitions as well as heatmaps and bar graphs for mean
% DFF per state, then save everything to a structure for later use

results = struct;
% NREM to REM
if ~isempty(sleepStruct.rem_loc)
    nremToRem = cutAroundEvent(sleepStruct.nrem_to_rem, cutTime, smooth(photoSignal, 200));
    
    figure
    set(gcf, 'Units', 'normalized', 'OuterPosition', [0 0 .2 .5])
    subplot(2, 1, 1)
    imagesc(normalization(nremToRem, 250))
    colormap("hot")
    caxis([.3 1])
    xt = get(gca, 'xtick');
    set(gca, 'XTick', xt, 'xticklabel', (xt - cutTime) / Fs)
    xlim([0 length(nremToRem)])
    xlabel('Time (s)')
    title('NREM to REM transition')
    
    if size(sleepStruct.nrem_to_rem, 1) == 1
        err = zeros(1, length(nremToRem));
        subplot(2, 1, 2)
        shadedErrorBar(1:length(nremToRem), nremToRem, err);
    else
        err = std(nremToRem, 0, 1) ./ sqrt(size(nremToRem, 1));
        subplot(2, 1, 2)
        shadedErrorBar([], mean(nremToRem), err)
    end

    hold on
    xline(cutTime, 'Color','red','LineStyle','--','LineWidth',2);
%     ylim([0 0.15])
    xt = get(gca, 'xtick');
    set(gca, 'XTick', xt, 'xticklabel', (xt - cutTime) / Fs)
    xlim([0 length(nremToRem)])
    xlabel('Time (s)')
    ylabel('\Delta F/F')
    title('NREM to REM transition')
%     print('NtoR', '-dpng')
    
    clear err
    
    % REM to wake
    remToWake = cutAroundEvent(sleepStruct.rem_to_wake, cutTime, smooth(photoSignal, 200));
    
    figure
    set(gcf, 'Units', 'normalized', 'OuterPosition', [0 0 .2 .5])
    subplot(2, 1, 1)
    imagesc(normalization(remToWake, 250))
    colormap("hot")
    caxis([.3 1]) 
    xt = get(gca, 'xtick');
    set(gca, 'XTick', xt, 'xticklabel', (xt - cutTime) / Fs)
    xlim([0 length(remToWake)])
    xlabel('Time (s)')
    title('REM to wake transition')

    if size(sleepStruct.rem_to_wake, 1) == 1
        err = zeros(1, length(remToWake));
        subplot(2, 1, 2)
        shadedErrorBar(1:length(remToWake), remToWake, err);
    else
        err = std(remToWake, 0, 1) ./ sqrt(size(remToWake, 1));
        subplot(2, 1, 2)
        shadedErrorBar([], mean(remToWake), err)
    end

    hold on
    xline(cutTime, 'Color','red','LineStyle','--','LineWidth',2);
    xt = get(gca, 'xtick');
    set(gca, 'XTick', xt, 'xticklabel', (xt - cutTime) / Fs)
    xlim([0 length(remToWake)])
%     ylim([0 0.15])
    xlabel('Time (s)')
    ylabel('\Delta F/F')
    title('REM to wake transition')
%     print('RtoW', '-dpng')
    
    clear err
end

% Wake to NREM
wakeToNrem = cutAroundEvent(sleepStruct.wake_to_nrem, cutTime, smooth(photoSignal, 200));

figure
set(gcf, 'Units', 'normalized', 'OuterPosition', [0 0 .2 .5])
subplot(2, 1, 1)
imagesc(normalization(wakeToNrem, 250))
colormap("hot")
caxis([.3 1])
xt = get(gca, 'xtick');
set(gca, 'XTick', xt, 'xticklabel', (xt - cutTime) / Fs)
xlim([0 length(wakeToNrem)])
xlabel('Time (s)')
title('Wake to NREM transition')

subplot(2, 1, 2)
if size(sleepStruct.wake_to_nrem, 1) == 1
    err = zeros(1, length(wakeToNrem));
    subplot(2, 1, 2)
    shadedErrorBar(1:length(wakeToNrem), wakeToNrem, err);
else
    err = std(wakeToNrem, 0, 1) ./ sqrt(size(wakeToNrem, 1));
    subplot(2, 1, 2)
    shadedErrorBar([], mean(wakeToNrem), err)
end
hold on
xline(cutTime, 'Color','red','LineStyle','--','LineWidth',2);
% ylim([0 0.15])
xt = get(gca, 'xtick');
set(gca, 'XTick', xt, 'xticklabel', (xt - cutTime) / Fs)
xlim([0 length(wakeToNrem)])
xlabel('Time (s)')
ylabel('\Delta F/F')
title('Wake to NREM transition')
% print('WtoN', '-dpng')

clear err

% NREM to wake
excludeBouts = find(sleepStruct.nrem_to_wake(:, 1) > cutTime);

if length(excludeBouts) < length(sleepStruct.nrem_to_wake)
    sleepStruct.nrem_to_wake(1:excludeBouts(1) - 1, :) = [];
end

nremToWake = cutAroundEvent(sleepStruct.nrem_to_wake, cutTime, smooth(photoSignal, 200));

figure
set(gcf, 'Units', 'normalized', 'OuterPosition', [0 0 .2 .5])
subplot(2, 1, 1)
imagesc(normalization(nremToWake, 250))
colormap("hot")
caxis([.3 1])
xt = get(gca, 'xtick');
set(gca, 'XTick', xt, 'xticklabel', (xt - cutTime) / Fs)
xlim([0 length(nremToWake)])
xlabel('Time (s)')
title('NREM to wake transition')

subplot(2, 1, 2)
if size(sleepStruct.nrem_to_wake, 1) == 1
    err = zeros(1, length(nremToWake));
    subplot(2, 1, 2)
    shadedErrorBar(1:length(nremToWake), nremToWake, err);
else
    err = std(nremToWake, 0, 1) ./ sqrt(size(nremToWake, 1));
    subplot(2, 1, 2)
    shadedErrorBar([], mean(nremToWake), err)
end
hold on
xline(cutTime, 'Color','red','LineStyle','--','LineWidth',2);% ylim([-2 2])
xt = get(gca, 'xtick');
set(gca, 'XTick', xt, 'xticklabel', (xt - cutTime) / Fs)
xlim([0 length(nremToWake)])
% ylim([0 0.15])
xlabel('Time (s)')
ylabel('\Delta F/F')
title('NREM to wake transition')
% print('NtoW', '-dpng')

clear err

% if we have cataplexy, make some extra figs
if ~isempty(sleepStruct.cat_loc)
    % Wake to CAT
    wakeToCat = cutAroundEvent(sleepStruct.wake_to_cat, cutTime, smooth(photoSignal, 200));
    
    figure
    set(gcf, 'Units', 'normalized', 'OuterPosition', [0 0 .2 .5])
    subplot(2, 1, 1)
    imagesc(normalization(wakeToCat, 250))
    colormap("hot")
    caxis([.3 1])
    xt = get(gca, 'xtick');
    set(gca, 'XTick', xt, 'xticklabel', (xt - cutTime) / Fs)
    xlim([0 length(wakeToCat)])
    xlabel('Time (s)')
    title('Wake to CAT transition')

    if size(sleepStruct.wake_to_cat, 1) == 1
        err = zeros(1, length(wakeToCat));
        subplot(2, 1, 2)
        shadedErrorBar(1:length(wakeToCat), wakeToCat, err);
    else
        err = std(wakeToCat, 0, 1) ./ sqrt(size(wakeToCat, 1));
        subplot(2, 1, 2)
        shadedErrorBar([], mean(wakeToCat), err)
    end
    
    hold on
    xline(cutTime, 'Color','red','LineStyle','--','LineWidth',2);
%     ylim([0 0.15])
    xt = get(gca, 'xtick');
    set(gca, 'XTick', xt, 'xticklabel', (xt - cutTime) / Fs)
    xlim([0 length(wakeToCat)])
    xlabel('Time (s)')
    ylabel('\Delta F/F')
    title('Wake to CAT transition')

    clear err
    
    % CAT to wake
    catToWake = cutAroundEvent(sleepStruct.cat_to_wake, cutTime, smooth(photoSignal, 200));
    
    figure
    set(gcf, 'Units', 'normalized', 'OuterPosition', [0 0 .2 .5])
    subplot(2, 1, 1)
    imagesc(normalization(catToWake, 250))
    colormap("hot")
    caxis([.3 1])
    xt = get(gca, 'xtick');
    set(gca, 'XTick', xt, 'xticklabel', (xt - cutTime) / Fs)
    xlim([0 length(catToWake)])
    xlabel('Time (s)')
    title('CAT to wake transition')

    if size(sleepStruct.cat_to_wake, 1) == 1
        err = zeros(1, length(catToWake));
        subplot(2, 1, 2)
        shadedErrorBar(1:length(catToWake), catToWake, err);
    else
        err = std(catToWake, 0, 1) ./ sqrt(size(catToWake, 1));
        subplot(2, 1, 2)
        shadedErrorBar([], mean(catToWake), err)
    end

    hold on
    xline(cutTime, 'Color','red','LineStyle','--','LineWidth',2);
%     ylim([0 0.15])
    xt = get(gca, 'xtick');
    set(gca, 'XTick', xt, 'xticklabel', (xt - cutTime) / Fs)
    xlim([0 length(catToWake)])
    xlabel('Time (s)')
    ylabel('\Delta F/F')
    title('CAT to wake transition')

    clear err
end

brief = cutAroundEvent(sleepStruct.brief_wake_loc(:, 1) * Fs, cutTime, smooth(photoSignal, 200));

figure
set(gcf, 'Units', 'normalized', 'OuterPosition', [0 0 .2 .5])
subplot(2, 1, 1)
imagesc(normalization(brief, 250))
colormap("hot")
caxis([.3 1])
xt = get(gca, 'xtick');
set(gca, 'XTick', xt, 'xticklabel', (xt - cutTime) / Fs)
xlim([0 length(brief)])
xlabel('Time (s)')
title('Brief arousal')

subplot(2, 1, 2)
if size(brief, 1) == 1
    err = zeros(1, length(brief));
    subplot(2, 1, 2)
    shadedErrorBar(1:length(brief), brief, err);
else
    err = std(brief, 0, 1) ./ sqrt(size(brief, 1));
    subplot(2, 1, 2)
    shadedErrorBar([], mean(brief), err)
end
hold on
xline(cutTime, 'Color','red','LineStyle','--','LineWidth',2);% ylim([-2 2])
xt = get(gca, 'xtick');
set(gca, 'XTick', xt, 'xticklabel', (xt - cutTime) / Fs)
xlim([0 length(brief)])
xlabel('Time (s)')
ylabel('\Delta F/F')
% ylim([0 0.15])
% print('brief', '-dpng')

results.briefArousals = brief;

% save all relevant results
if ~isempty(sleepStruct.rem_loc)
    results.nremToRemTransitions = nremToRem;
    results.remToWakeTransitions = remToWake;
end
results.wakeToNremTransitions = wakeToNrem;
results.nremToWakeTransitions = nremToWake;

if ~isempty(sleepStruct.cat_loc)
    results.wakeToCatTransitions = wakeToCat;
    results.catToWakeTransitions = catToWake;
end

end