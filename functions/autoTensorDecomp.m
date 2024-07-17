function autoTensorDecomp(basePath)
answer = inputdlg({'Start of range','Iteration step','End of range','Runs','Modes','TD Algorithms (1.iAPG & 2.NTF & 3.NCP):'},'Input the range of components',[1 40],{'10','5','40','50','4','1'});
rang = [];
rang.start = str2num(answer{1});
ite_step = str2num(answer{2});
rang.end = str2num(answer{3});
% Runs = 50; % the number of runs
Runs = str2num(answer{4});
% Modes = 3; % the number of modes of the decomposed tensor
Modes = str2num(answer{5});
Method_Flag = str2num(answer{6});
Resultfile = ['Multi_runs_result']; % The folder that used to store CPD results. The number of files in the folder is exactly same with Runs
SI = {};
meanSI = [];
stdSI = [];
x_range = [];
f=figure();
hold on;
for R = rang.start:ite_step:rang.end
    savePath = [basePath filesep 'Results' filesep Resultfile filesep 'R' num2str(R)];
    if ~exist(savePath,'dir'), mkdir(savePath); end
    tensorDecomp_MultiRuns(basePath,savePath,Runs,R,Method_Flag);
    file = dir([savePath filesep '*.mat']);
    %% Creating data
    for isRun = 1:Runs
        load([savePath filesep file(isRun).name]);
        if isRun==1
            for isMode = 1:Modes
                Modedata{isMode} = [];
            end
        end
        for isMode = 1:Modes
            Modedata{isMode} = [Modedata{isMode}  A.U{isMode}];
        end
    end
    for isMode = 1:Modes
        Sim{isMode} = abs(corr(Modedata{isMode}));
    end
    %% Tensor Spectral Clustering
    try
        [in_avg,partition,P,newspace,CentroidIndex]=f_Tensor_Spectral_Clustering(Sim,R);
    catch ME
        in_avg = 0;
    end
    SI{end+1} = in_avg;
    meanSI(end+1) =  mean(rmmissing(in_avg));
    stdSI(end+1) = std(rmmissing(in_avg),0);
    figure(f);
    x_range(end+1) = R;
    plot(x_range,meanSI+stdSI,'LineStyle','--','Color','#D95319');
    plot(x_range,meanSI,'LineStyle','-','Color','#0072BD','LineWidth',2);
    plot(x_range,meanSI-stdSI,'LineStyle','--','Color','#EDB120');
    plot(x_range,0.9*ones(size(x_range)),'LineStyle','-.','Color','b','LineWidth',2);
    xticks(x_range);
    xlabel('Number of components');
    ylabel('Stability Index');
    title('Result of automatic repeatability analysis');
    legend('Mean+Std','Mean','Mean-Std');
end
savePath = [basePath filesep 'Results' filesep Resultfile];
savFileName = 'SI.mat';
savFullPath = [savePath filesep savFileName];
save(savFullPath, 'SI');
%%
end
