function rasterStateTransitions(n2r_all_dist, n2w_all_dist, r2w_all_dist, w2n_all_dist, Fs);
%nice rasterplot of the different peak types at nrem-rem and nrem-wake
%transitions 
%INPUTS: transitions structure from getStateTransitions, locs structure
%from findclosestpeak, Fs of photometry signal


% plot the peak types going back in time from transitions
figure; tiledlayout(4, 1, 'TileSpacing','compact')

ax(1) = nexttile;
hold on;
xline(0, '--k')

%for nrem to rem transitions
for i = 1:size(n2r_all_dist, 1)
    dist = n2r_all_dist{i} ;
    scatter(dist./Fs, repelem(i, length(dist)), 'o', 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'blue')
end
ylabel('Bout')

ax(2) = nexttile;
hold on;

all = horzcat(n2r_all_dist{:});
histogram(all./Fs, 100, 'normalization', 'probability', "EdgeColor",'none', 'FaceColor','blue', 'FaceAlpha', 0.4);

ylabel('Probability')
xlabel('Seconds from NREM to REM transition')


ax(3) = nexttile;
hold on;
xline(0, 'k')

%for nrem to wake transitions
for i = 1:size(n2w_all_dist, 1)
    dist = n2w_all_dist{i}; 
    scatter(dist./Fs, repelem(i, length(dist)), 'o', 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'green')
end

ylabel('Bout')

ax(4) = nexttile;
hold on;

all = horzcat(n2w_all_dist{:});
histogram(all./Fs, 100, 'normalization', 'probability', "EdgeColor",'none', 'FaceColor','green', 'FaceAlpha', 0.4);

ylabel('Probability')
xlabel('Seconds from NREM to Wake transition')

linkaxes(ax, 'x')



figure; tiledlayout(2, 1, 'TileSpacing','compact');
ax_2(1) = nexttile;
hold on;
xline(0, '--k');

%for rem to wake transitions
for i = 1:size(r2w_all_dist, 1)
    dist = r2w_all_dist{i} ;
    scatter(dist./Fs, repelem(i, length(dist)), 'o', 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'red')
end
ylabel('Bout')

ax_2(2) = nexttile;
hold on;

all = horzcat(r2w_all_dist{:});
histogram(all./Fs, 100, 'normalization', 'probability', "EdgeColor",'none', 'FaceColor','red', 'FaceAlpha', 0.4);

ylabel('Probability')
xlabel('Seconds from REM to Wake transition')

linkaxes(ax_2, 'x')



figure; tiledlayout(2, 1, 'TileSpacing','compact');
ax_3(1) = nexttile;
hold on;
xline(0, '--k');

%for wake to nrem transitions
for i = 1:size(w2n_all_dist, 1)
    dist = w2n_all_dist{i} ;
    scatter(dist./Fs, repelem(i, length(dist)), 'o', 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'white')
end
ylabel('Bout')

ax_3(2) = nexttile;
hold on;

all = horzcat(w2n_all_dist{:});
histogram(all./Fs, 100, 'normalization', 'probability', "EdgeColor",'none', 'FaceColor','k', 'FaceAlpha', 0.4);

ylabel('Probability')
xlabel('Seconds from Wake to NREM transition')

linkaxes(ax_3, 'x')