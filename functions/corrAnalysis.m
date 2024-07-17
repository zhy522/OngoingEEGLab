function corrAnalysis(basePath, chanlocs, R)
%% Image folder
CompImgPath=fullfile(basePath, 'Results', 'ResultImage');
if ~exist(CompImgPath,'dir'), mkdir(CompImgPath); end

%%
% [file, path,indx] = uigetfile({'*.mat'},'Select a tensor');
% load([path filesep file]);
filename_tensor = ['A_R' num2str(R) '#1.mat'];
load([basePath filesep 'Results' filesep 'Decomposed_Tensors' filesep filename_tensor]);
load([basePath filesep 'Results' filesep 'long_term_feature' filesep 'mirLongTermFeatures.mat']);
%load([basePath filesep 'data' filesep 'chanlocs64.mat']);
% [file, path, indx] = uigetfile({'*.mat'},'Select a chanlocs file');
% load([path filesep file]);

SpatialFactor = A.U{3}; %A=x
SpectralFactor = A.U{1};
TemporalFactor = A.U{2};
FreqLow = 1;
FreqHigh = 30;
FreqIndex = linspace(FreqLow,FreqHigh,size(SpectralFactor,1));

%% Correlation Analysis
fprintf('Correlation analysis between temporal and music features ... \n');
Time_zscore=zscore(TemporalFactor);
Features_zscore=zscore(long_term_features);
[p05, p01, p001]=f_p_threshold_oneDim(Time_zscore,Features_zscore);
CORR1=corr(Time_zscore,Features_zscore);

CORR1_P=(CORR1>repmat(p05,size(CORR1,1),1));
if sum(CORR1_P,'all')==0
    fprintf('There is no significant component. \n');
    fprintf('Correlation analysis is done. \n');
    return;
end
%% Plot figures
CompIndex = 0;
for jj=1:size(CORR1_P,2)
    for ii=1:size(CORR1_P,1)
        if CORR1_P(ii,jj)==1
            CompIndex = CompIndex + 1;
            
            figure;
            % Figure
            set(gcf,'outerposition',get(0,'screensize'))
            % Topograph
            subplot(3,4,[1 2 5 6])
%             topoplot(zscore(abs(SpatialFactor(:,ii))),chanlocs64);
            topoplot(abs(SpatialFactor(:,ii)),chanlocs);
            colorbar
            caxis([0 max(abs(SpatialFactor(:,ii)),[],'all')]);
            title(['Topograph#' int2str(ii)],'fontsize',22);
            % Waveform
            subplot(3,4,[9 10 11 12]);
            plot(zscore(abs(TemporalFactor(:,ii))),'linewidth',2);
            hold on
            plot(zscore(long_term_features(:,jj)),'linewidth',2);
            hold off
            grid on
            xlim([0 length(TemporalFactor(:,ii))]);
            xlabel('Time Points/n','fontsize',18);
            ylabel('Amplitude','fontsize',18);
            title(['Waveform, ' 'Threshold=' num2str(p05(jj))  ', CC=' num2str(CORR1(ii,jj))],'fontsize',16);
            sLegend1=sprintf('Temporal Component #%d',ii);
            legend(sLegend1,music_feature_names{jj},'Location','best');
            % Spectrum
            subplot(3,4,[3 4 7 8])
            plot(FreqIndex,SpectralFactor(:,ii),'linewidth',2);grid on;
            xlim([FreqLow FreqHigh]);
            xlabel('Frequency/Hz','fontsize',18);
            ylabel('Amplitude','fontsize',22);
            title('Spectrum','fontsize',22);
            colormap(jet);
            
            % Save Image
            sCompIndex=sprintf('%02d',CompIndex);
            saveas(gca,[CompImgPath filesep sCompIndex '.png'],'png');
        end        
    end
end
fprintf('Correlation analysis is done. \n');
end

