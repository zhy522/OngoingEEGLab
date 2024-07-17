function [EEG] = loadEEG()
[file, path, ~] = uigetfile({'*.set'},'Import EEG Data');
EEG = pop_loadset([path filesep file]);
end