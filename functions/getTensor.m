function  getTensor(EEG, basePath)
OngoingEEG_Tensor = [];
data = EEG.data;
fs = EEG.srate;
window = 3*fs;
noverlap = window*(2/3);
nfft = fs;
fprintf('Creating ongoing EEG tensor ... \n');
for d = 1:size(data,1)
   fprintf('Channel %d/%d to be computed spectral information \n',d,size(data,1));
   [s, f, t] = spectrogram(data(d,:),window,noverlap,nfft,fs); 
   OngoingEEG_Tensor(d,:,:) = abs(s).^2;
end
% delete data whose frequency is over 30 Hz
fprintf('Truncating data with a range of 0-30 Hz in frequency.');
pnt_30Hz = ceil(30/(fs/2)*(nfft/2+1));
OngoingEEG_Tensor = OngoingEEG_Tensor(:,1:pnt_30Hz,:);

fprintf('Saving data ... \n');
savFileName = 'OngoingEEG_Tensor.mat';
savPath = [basePath filesep 'Results' filesep 'OngoingEEG_tensor'];
savFullPath = [savPath filesep savFileName];
if ~exist(savPath, 'dir') mkdir(savPath); end
save(savFullPath, 'OngoingEEG_Tensor');
fprintf('Creating ongoing EEG tensor is done! \n');
end