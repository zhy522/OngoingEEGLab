function getLongTermFeature(MUSIC,basePath)
fprintf('Extracting long-term feature ... \n');
%% Read audio file
% An audio file of 8.5 minutes. A compute with large memory is required.
% mirfile=miraudio('Piazzolla.mp3'); 
%
fileFullPath = [MUSIC.filepath filesep MUSIC.filename];
mirfile = miraudio(fileFullPath);
%%
% Frame
mirfileframe=mirframe(mirfile,'Length',3,'s','Hop',1/3,'/1');
mirframedata=mirgetdata(mirfileframe);
framenumber=size(mirframedata,2);
%%
FluctuationCentroid=zeros(framenumber,1);
FluctuationEntropy=zeros(framenumber,1);
PulseClarity=zeros(framenumber,1);
%%
for ii=0:framenumber-1 % number of frames
    excerpt0=miraudio(mirfile,'Extract',ii,ii+3);
    excerpt=mirframe(excerpt0,'Length',3,'s','Hop',1/3,'/1');
    fluc=(mirfluctuation(excerpt,'summary'));
    flucdata=mirgetdata(fluc);
    FluctuationCentroid(ii+1)=WDQFlucCentroid(flucdata);
    FluctuationEntropy(ii+1)=WDQFlucEntropy(flucdata);
    PulseClarity(ii+1)=mirgetdata(mirpulseclarity(excerpt));
end     

%%
% Tonal Features
mirchr=mirchromagram(mirfile,'Frame',3, 1/3,'Wrap',0,'Pitch',0);
[~, mirtonalkeyclarity] = mirkey(mirchr,'Total',1);
mirtonalmode = mirmode(mirchr);
mirkeyclaritydata=mirgetdata(mirtonalkeyclarity)';
mirmodedata=mirgetdata(mirtonalmode)';

%%
figure;plot(1:framenumber,mirkeyclaritydata);xlabel('Frame Number');ylabel('Value');title('Tonal Key Clarity');
figure;plot(1:framenumber,mirmodedata);xlabel('Frame Number');ylabel('Value');title('Tonal Mode');
figure;plot(1:framenumber,FluctuationCentroid);xlabel('Frame Number');ylabel('Value');title('Fluctuation Centroid');
figure;plot(1:framenumber,FluctuationEntropy);xlabel('Frame Number');ylabel('Value');title('Fluctuation Entropy');
figure;plot(1:framenumber,PulseClarity);xlabel('Frame Number');ylabel('Value');title('Pulse Clarity');

%%
long_term_features = [PulseClarity FluctuationEntropy FluctuationCentroid mirmodedata mirkeyclaritydata];
music_feature_names={'Pulse Clarity','Fluctuation Entropy','Fluctuation Centroid','Mode','Key'};

fprintf('Saving long term features .... \n');
savFileName = 'mirLongTermFeatures.mat';
savPath = [basePath filesep 'Results' filesep 'long_term_feature'];
savFullPath = [savPath filesep savFileName];
if ~exist(savPath, 'dir') mkdir(savPath); end
save(savFullPath, 'long_term_features', 'music_feature_names');
fprintf('Extracting long-term feature is done. \n');
end