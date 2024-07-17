function [MUSIC] = loadMUSIC()
[file, path,~] = uigetfile({'*.wav;*.mp3';},'Import Audio Data');
[MUSIC.data, MUSIC.srate] = audioread([path filesep file]);
MUSIC.filename = file;
MUSIC.filepath = path;
end