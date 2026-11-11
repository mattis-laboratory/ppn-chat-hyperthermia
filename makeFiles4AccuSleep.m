function makeFiles4AccuSleep(EEG, EMG, gcamp, iso, Fs, mousenum, date);

epochLength = 5;

recLengthSeconds = length(EEG) / Fs;

labels_length = recLengthSeconds / epochLength;

labels = repelem(4, floor(labels_length));

mydir = horzcat('C:\Users\mccartj\University of Michigan Dropbox\MED-burgesslab\BurgessLab_data_transfer\Jordan\mattislabcollab\', mousenum, '\', date, '\');

if ~isfolder(mydir)
    mkdir(mydir);
end

EEG_name = fullfile(mydir, 'EEG.mat');
EMG_name = fullfile(mydir, 'EMG.mat');
labels_name = fullfile(mydir, 'labels.mat');
gcamp_name = fullfile(mydir, 'gcamp.mat');
isos_name = fullfile(mydir, 'iso.mat');

save(EEG_name, "EEG");
save(EMG_name, "EMG");
save(labels_name, "labels");
save(gcamp_name, "gcamp");
save(isos_name, "iso");

end

