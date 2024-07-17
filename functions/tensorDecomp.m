function [R, Runs, Method_Flag]=tensorDecomp(basePath)
fprintf('Performing tensor decomposition ... \n');
%% Load Tensor Data
X_tmp = load([basePath filesep 'Results' filesep 'OngoingEEG_tensor' filesep 'OngoingEEG_Tensor.mat']);
fields = fieldnames(X_tmp);
if size(fields,1)>1 
    errodlg('Variables loaded are too much','File Error');
    return
else
    varname = fields{1};
    X = getfield(X_tmp,varname);
end
%% Preparation of tensor decomposition
TensorTrue = tensor(X); 
N = ndims(TensorTrue);
% Tensor Decomposition Parameters
answer = inputdlg({'Enter the number of components','Runs','TD Algorithms (1.iAPG & 2.NTF & 3.NCP):'},'Input',[1 35],{'30','50','1'});
R = str2num(answer{1});
Runs = str2num(answer{2});
Method_Flag = str2num(answer{3});
% R = 30; % The pre-defined number of components

%
ModeSizes = size(TensorTrue);
FR = zeros(N,1); % FR is the ratio of the number of data entries to the degrees of freedom
inv_FR = zeros(N,1);
for ii = 1:N
    FR(ii,1) = prod(ModeSizes) / (R * (ModeSizes(ii) + prod(ModeSizes([1:ii-1 ii+1:end])) - R));
    inv_FR(ii,1) = 1/FR(ii,1);
end
IndicatorDL = nthroot(prod(inv_FR),N); % DL: difficulty level
sIndicatorDL = sprintf('%.3f',IndicatorDL);
fprintf(['ModeSize:\t' mat2str(ModeSizes) '\n' 'RankSize: \t' mat2str(R) '\n']);
fprintf(['DL:\t\t\t' sIndicatorDL '\n']);

% Empirical rule for selecting the number of inner iterations
if IndicatorDL < 0.1
    J = 10;
elseif IndicatorDL >= 0.1
    J = 20;
end
fprintf(['The number of inner iterations is ' mat2str(J) '.\n']);
InnerIter_v = J*ones(N,1);

%% Start of the NCP tensor decomposition using iAPG algorithm
rng('shuffle','twister');
savePath = [basePath filesep 'Results' filesep 'Decomposed_Tensors'];
if ~exist(savePath,'dir') mkdir(savePath);end
cd(savePath);
subfiles = dir(savePath);
subfiles = subfiles(3:end);
if ~isempty(subfiles) delete *.mat; end
poolobj = gcp('nocreate');
if isempty(poolobj), parpool(3); end
options = struct('tol',1e-8,'maxiters',1000,'init','random',...
    'orthoforce',0,'fitmax',.99999,'verbose',0);
parfor ite = 1:Runs
    switch Method_Flag
        case 1
            [A,Out] = ncp_iapg(TensorTrue,R,'maxiters',99999,'tol',1e-6,...
                'init','random','printitn',1,'inner_iter',InnerIter_v,...
                'maxtime',1200,'stop',2,'printitn',1);
        case 2
            [A,Ah,fitarr] = ntf_fastHALS(TensorTrue,R,options);
        case 3
            ProxParam=1e-4;
            RegParams=repmat(ProxParam,N,1);
            [A,Out] = ncp_proximal(TensorTrue,R,'maxiters',99999,'tol',1e-8,...
                'init','random','regparams',RegParams,'printitn',1,...
                'maxtime',600,'stop',2);
    end
parsave(['A_R' num2str(R) '#' num2str(ite) '.mat'],A);
end
delete(gcp('nocreate'));
cd(basePath);
% clearvars 
%%
% fprintf('Elapsed time is %4.6f seconds.\n',Out.time(end));
% fprintf('Solution relative error = %4.4f\n\n',Out.relerr(2,end));
fprintf('Tensor decomposition is done. \n');
end