function [] = GoodHypnoPlot(Title, Name, Date, ds_factorEEG, FsEEG, EEG, EMG, Photo_dff, Full_statenum)


hypnodiff = find(abs(diff(Full_statenum)) ~= 0);
hypnodiffupscale = hypnodiff*FsEEG*ds_factorEEG;

figure;
ax1 = subplot(3,1,1);
plot(Photo_dff,'k')
title(Title)
hold on
  if Full_statenum(hypnodiff(1)) == 7;
        color = [0.7 0.7 0.7];
    elseif Full_statenum(hypnodiff(1)) == 2;
        color = [0 0 0.7];
    elseif Full_statenum(hypnodiff(1)) == 14;
        color = [0 0.7 0];
    else
        color = [1 1 1];
    end
patch([1 1, hypnodiffupscale(1) hypnodiffupscale(1)],[min(Photo_dff) max(Photo_dff) max(Photo_dff) min(Photo_dff)],  color,'LineStyle','none')
alpha(0.3) 
clear color
hold on
for i = 2:length(hypnodiffupscale)
    if Full_statenum(hypnodiff(i)) == 7;
        color = [0.7 0.7 0.7];
    elseif Full_statenum(hypnodiff(i)) == 2;
        color = [0 0 0.7];
    elseif Full_statenum(hypnodiff(i)) == 14;
        color = [0 0.7 0];
    else
        color = [1 1 1];
    end
    
patch([hypnodiffupscale(i-1) hypnodiffupscale(i-1), hypnodiffupscale(i) hypnodiffupscale(i)],[min(Photo_dff) max(Photo_dff) max(Photo_dff) min(Photo_dff)],  color,'LineStyle','none')
alpha(0.3)       
end
  if Full_statenum(hypnodiff(end)+1) == 7;
        color = [0.7 0.7 0.7];
    elseif Full_statenum(hypnodiff(end)+1) == 2;
        color = [0 0 0.7];
    elseif Full_statenum(hypnodiff(end)+1) == 14;
        color = [0 0.7 0];
    else
        color = [1 1 1];
    end
    
   
patch( [hypnodiffupscale(end) hypnodiffupscale(end), length(EEG) length(EEG)],[min(Photo_dff) max(Photo_dff) max(Photo_dff) min(Photo_dff)], color,'LineStyle','none')
alpha(0.3)  

ylabel('{\Delta}F/F')
ax2 = subplot(3,1,2);
plot(EEG,'k')
hold on
  if Full_statenum(hypnodiff(1)) == 7;
        color = [0.7 0.7 0.7];
    elseif Full_statenum(hypnodiff(1)) == 2;
        color = [0 0 0.7];
    elseif Full_statenum(hypnodiff(1)) == 14;
        color = [0 0.7 0];
    else
        color = [1 1 1];
    end
patch([1 1, hypnodiffupscale(1) hypnodiffupscale(1)],[min(EEG) max(EEG) max(EEG) min(EEG)],  color,'LineStyle','none')
alpha(0.3) 
clear color
hold on
for i = 2:length(hypnodiffupscale)
    if Full_statenum(hypnodiff(i)) == 7;
        color = [0.7 0.7 0.7];
    elseif Full_statenum(hypnodiff(i)) == 2;
        color = [0 0 0.7];
    elseif Full_statenum(hypnodiff(i)) == 14;
        color = [0 0.7 0];
    else
        color = [1 1 1];
    end
    
patch( [hypnodiffupscale(i-1) hypnodiffupscale(i-1), hypnodiffupscale(i) hypnodiffupscale(i)],[min(EEG) max(EEG) max(EEG) min(EEG)], color,'LineStyle','none')
alpha(0.3)       
end
  if Full_statenum(hypnodiff(end)+1) == 7;
        color = [0.7 0.7 0.7];
    elseif Full_statenum(hypnodiff(end)+1) == 2;
        color = [0 0 0.7];
    elseif Full_statenum(hypnodiff(end)+1) == 14;
        color = [0 0.7 0];
    else
        color = [1 1 1];
    end
    
   
patch( [hypnodiffupscale(end) hypnodiffupscale(end), length(EEG) length(EEG)],[min(EEG) max(EEG) max(EEG) min(EEG)], color,'LineStyle','none')
alpha(0.3)  

ylabel('EEG')
ax3 = subplot(3,1,3);
plot(EMG,'k')
hold on
  if Full_statenum(hypnodiff(1)) == 7;
        color = [0.7 0.7 0.7];
    elseif Full_statenum(hypnodiff(1)) == 2;
        color = [0 0 0.7];
    elseif Full_statenum(hypnodiff(1)) == 14;
        color = [0 0.7 0];
    else
        color = [1 1 1];
    end
patch([1 1, hypnodiffupscale(1) hypnodiffupscale(1)],[min(EMG) max(EMG) max(EMG) min(EMG)],  color,'LineStyle','none')
alpha(0.3) 
clear color
hold on
for i = 2:length(hypnodiffupscale)
    if Full_statenum(hypnodiff(i)) == 7;
        color = [0.7 0.7 0.7];
    elseif Full_statenum(hypnodiff(i)) == 2;
        color = [0 0 0.7];
    elseif Full_statenum(hypnodiff(i)) == 14;
        color = [0 0.7 0];
    else
        color = [1 1 1];
    end
    
patch( [hypnodiffupscale(i-1) hypnodiffupscale(i-1), hypnodiffupscale(i) hypnodiffupscale(i)],[min(EMG) max(EMG) max(EMG) min(EMG)], color,'LineStyle','none')
alpha(0.3)       
end

    if Full_statenum(hypnodiff(end)+1) == 7;
        color = [0.7 0.7 0.7];
    elseif Full_statenum(hypnodiff(end)+1) == 2;
        color = [0 0 0.7];
    elseif Full_statenum(hypnodiff(end)+1) == 14;
        color = [0 0.7 0];
    else
        color = [1 1 1];
    end
    
patch( [hypnodiffupscale(end) hypnodiffupscale(end), length(EEG) length(EEG)],[min(EMG) max(EMG) max(EMG) min(EMG)], color,'LineStyle','none')
alpha(0.3)  
ylabel('EMG')

linkaxes([ax1 ax2 ax3],'x');

% print([Name ' ' Date ' Hypnoplot'],'-djpeg');

