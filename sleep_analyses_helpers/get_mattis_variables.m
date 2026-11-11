function [labels, gcamp, iso, dffSignal] = get_mattis_variables(fold);

labels = [];
gcamp = [];
iso = [];
dffSignal = [];

for k = 1:numel(fold)
    name = fold(k).name;

    % skip folders and non-.mat files
    if fold(k).isdir || ~endsWith(name, ".mat")
        continue
    end

    fpath = fullfile(fold(k).folder, name);

    % Load only what you need and assign explicitly
    if  contains(name, "labels")
        S = load(fpath, "labels");
        labels = S.labels; 

    elseif contains(name, "gcamp")
        S = load(fpath, "gcamp");
        gcamp = S.gcamp; 

    elseif contains(name, "iso")
        S = load(fpath, "iso");
        iso = S.iso;

    elseif contains(name, "PhotoSignal");

        fileVars = who('-file', fpath);
        if any(strcmp(fileVars, "dff"))
            S = load(fpath, "dff");
            dffSignal = S.dff;
        end
        
    end
end

end