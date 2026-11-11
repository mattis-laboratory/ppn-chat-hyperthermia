function final = collapse(varargin)
%% figure out inputs
p = inputParser;
p.addParameter('is_struct', 1); % assume struct by default
p.addParameter('is_avg',    1); % assume avg by default
p.addParameter('dimension', 1); % dimension to average over
p.addParameter('is_equal',  1); % assume array dimensions should be checked
p.addParameter('to_save',   0); % don't save by default
p.parse(varargin{:});

is_struct = p.Results.is_struct;
is_avg    = p.Results.is_avg;
dimension = p.Results.dimension;
is_equal  = p.Results.is_equal;
to_save   = p.Results.to_save;

%% navigate to dir w data
selpath = uigetdir();
filedir = selpath;
cd(filedir);

file_pat = fullfile(filedir, '*.mat');
my_files = dir(file_pat);

%% loop through files
if is_struct == 1
    %% concatenate nested fields across structures

    store = cell(1, length(my_files));

    for i = 1:length(my_files)
        cur_file  = load(my_files(i).name);
        cur_strct = get_var_name(cur_file);

        error_check_struct(cur_strct);

        % Optional averaging of all numeric leaf arrays
        if is_avg == 1
            cur_strct = avg_struct_arrays_recursive(cur_strct, dimension);
        end

        store{i} = cur_strct;
    end

    % Recursively concatenate fields while preserving nested structure
    final = cat_structs_recursive(store, '');

else
    %% concatenate arrays
    final = []; 

    for i = 1:length(my_files) 
        cur_file = load(my_files(i).name);
        cur_file = get_var_name(cur_file);
        error_check_array(cur_file);

        if is_equal == 1
            cur_file = equal_array_dimensions(cur_file);
        end
        
        if ~isempty(cur_file)
            if is_avg == 1
                store = mean(cur_file, 'omitnan');
            else
                store = cur_file;
            end
        end
    
        final = [final; store]; 
    end
end

%% save collapsed data
if to_save == 1
    save_loc  = uigetdir('', 'Choose save location');
    session   = char(inputdlg('Session type:', 'Input', [1 50]));
    save([save_loc '\' session] , 'final')
end

end

%% nested functions
    function name = get_var_name(file)
        fields = fieldnames(file); % get fields of loaded variable
        name   = char(fields);     % convert cell to char array
         
        if size(name, 1) > 1
            error('Multiple files are saved to this variable')
        end

        name   = file.(name);      % return true loaded var
    end

    function [up_cur, up_next] = check_fields(cur, next)
        all_field = string(union(fieldnames(cur), fieldnames(next)));
        
        for i = 1:length(all_field)
            get_field = all_field(i);
            if ~isfield(cur, (get_field))
                cur(1).(get_field) = [];
            end
        
            if ~isfield(next, (get_field))
                next.(get_field) = [];
            end
        end
        
        up_cur  = cur;
        up_next = next;
    end

    function error_check_struct(input)
        if isstruct(input) == 0; error('Input is not a structure'); end
    end

    function error_check_array(input)
        if isstruct(input) == 1; error('Input is a structure'); end
    end

    function input = equal_struct_dimensions(input)
        fields = string(fieldnames(input));
    
        for i = 1:length(fields)
            if size(input.(fields(i)), 1) > size(input.(fields(i)), 2)
                input.(fields(i)) = input.(fields(i))';
            end
        end
    end

    function input = equal_array_dimensions(input)
        if size(input, 1) > size(input, 2)
            input = input';
        end
    end

    function input = avg_struct_arrays_recursive(input, dimension)
        if numel(input) ~= 1
            error('Only scalar structs are supported for recursive averaging.');
        end
    
        fields = fieldnames(input);
    
        for i = 1:length(fields)
            get_field = fields{i};
            val = input.(get_field);
    
            if isstruct(val)
                % Recurse into nested struct
                input.(get_field) = avg_struct_arrays_recursive(val, dimension);
    
            elseif isnumeric(val) || islogical(val)
                % Average numeric/logical leaf data
                if ~isempty(val)
                    if dimension == 1
                        input.(get_field) = mean(val, 'omitnan');
                    elseif dimension == 2
                        input.(get_field) = mean(val, 2, 'omitnan');
                    else
                        input.(get_field) = mean(val, dimension, 'omitnan');
                    end
                end
    
            else
                % Leave nonnumeric fields unchanged
                input.(get_field) = val;
            end
        end
    end

    function out = cat_structs_recursive(structs, path)
        % Remove empty entries
        structs = structs(~cellfun(@isempty, structs));
    
        if isempty(structs)
            out = struct();
            return
        end
    
        % Make sure all inputs are scalar structs
        for k = 1:numel(structs)
            if ~isstruct(structs{k})
                error('Expected struct at path "%s".', path);
            end
    
            if numel(structs{k}) ~= 1
                error('Only scalar structs are supported at path "%s".', path);
            end
        end
    
        % Get union of all fields across all structs
        all_fields = {};
    
        for k = 1:numel(structs)
            cur_fields = fieldnames(structs{k});
    
            for f = 1:numel(cur_fields)
                if ~ismember(cur_fields{f}, all_fields)
                    all_fields{end + 1} = cur_fields{f}; %#ok<AGROW>
                end
            end
        end
    
        out = struct();
    
        % Loop through every field
        for f = 1:numel(all_fields)
            field_name = all_fields{f};
    
            if isempty(path)
                cur_path = field_name;
            else
                cur_path = [path '.' field_name];
            end
    
            vals = {};
    
            % Collect this field from each struct that has it
            for k = 1:numel(structs)
                if isfield(structs{k}, field_name)
                    vals{end + 1} = structs{k}.(field_name); %#ok<AGROW>
                end
            end
    
            % Remove empty values so missing fields do not contribute
            vals = vals(~cellfun(@isempty, vals));
    
            if isempty(vals)
                out.(field_name) = [];
                continue
            end
    
            is_struct_val = cellfun(@isstruct, vals);
    
            if any(is_struct_val)
                % If this field is a struct in any file, it should be a struct
                % in all non-empty files.
                if any(~is_struct_val)
                    error('Field "%s" is a struct in some files but not others.', cur_path);
                end
    
                % Recurse deeper
                out.(field_name) = cat_structs_recursive(vals, cur_path);
    
            else
                % Leaf data: concatenate across files
                out.(field_name) = cat_leaf_values(vals, cur_path);
            end
        end
    end

    function out = cat_leaf_values(vals, path)
        vals = vals(~cellfun(@isempty, vals));
    
        if isempty(vals)
            out = [];
            return
        end
    
        % Try vertical concatenation first
        try
            out = vertcat(vals{:});
        catch
            % If vertical concatenation fails, try horizontal concatenation
            try
                out = horzcat(vals{:});
            catch
                error('Could not concatenate values at field "%s". Check array dimensions.', path);
            end
        end
    end