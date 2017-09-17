% programs for adaptive Affinity Propagation clustering; an improvement
% of Affinity Propagation clusteirng (see Frey & Dueck, Science, Feb. 2007)
% Note: Statistics Toolbox of Matlab needs to be installed
% WANG Kaijun: wangkjun@yahoo.com, July, Sept. 2007.

clear;
id = 10;        % selecting a data set, rows - data points, columns - dimensions
algorithm = 1;  % 1 --- adaptive AP, 0 --- original AP
nrun = 10000;   % max iteration times, default 50000
nrun2 = 2000;   % max iteration times for original AP
nconv = 50;     % convergence condition, default 50
pstep = 0.01;   % decreasing step of preferences: pstep*pmedian, default 0.01
lam = 0.5;      % damping factor, default 0.5
cut = 3;        % after clustering, drop an cluster with number of samples < cut
%splot = 'plot'; % observing a clustering process when it is on
splot = 'noplot';

sw='test2.csv'; 


% initialization
type = 1;       % 1: Euclidean distances
if id > 20
   type = 2;    % 2: Pearson correlation coefficients
end
simatrix = 0;   % 0: data as input; 1: similarity matrix as input
if id > 10 && id <15
    simatrix = 1;
end
data_load      % loading a data file or similarity matrix


disp(' '); disp(['==> Clustering is running on ' sw ', please wait ...']);
if algorithm
   tic;
   if simatrix
      [labels,NCs,labelid,iend,Sp,Slam,NCfixs] = adapt_apcluster(M,type,...
        p,pstep,simatrix,'convits',nconv,'maxits',nrun,'dampfact',lam,splot);
   else
      [labels,NCs,labelid,iend,Sp,Slam,NCfixs] = adapt_apcluster(data,type,...
        p,pstep,simatrix,'convits',nconv,'maxits',nrun,'dampfact',lam,splot);
   end
  [NC,Sil,Silmin] = solution_evaluation(data,M,labels,NCs,...
      NCfixs,simatrix,nrow,type,cut);
  trun = toc;
  if id == 12 || id == 13
      NCs = unique(labelid);
  end
  fprintf('\n## Running time = %g seconds \n', trun);
  fprintf('## Running iterations = %g \n', iend);
  
  % finding an optimal clustering solution
  solution_findK
  
else
    tic;
    if ~simatrix
       M = simatrix_make(data,type,nrow);
    end
    if ~length(p)
        dn = find(M(:,3)>-realmax);
        p = median(M(dn,3));         % Set preference to similarity median
    end
    [labels,netsim,iend,unconverged] = apcluster(M,p,'convits',...
        nconv,'maxits',nrun2,'dampfact',lam,splot);
    trun = toc;
    fprintf('\n## Running time = %g seconds \n', trun);
    fprintf('## Running iterations = %g \n', iend);
    
    % finding an clustering solution
    solution_findK
end


truek = unique(truelabels);
truek = length(truek);
if truek > 1
    C = valid_external(labels(:,Sid), truelabels);
    fprintf('Fowlkes-Mallows validity index: %f\n', C(4));
end
if NCopt == truek
   fprintf('\n## Error rate of clustering solution might be inaccurate if large');
   fprintf('\n     (then use FM index instead) and it is for reference only:');
   valid_errorate(labels(:,Sid), truelabels);
end

a=NCopt;
b=find(NCs==a);
c=labels(:,b);
e=data(:,1);
f=data(:,2);
h1=gscatter(e,f,c);
legend(h1);
xlabel('Latitude');
ylabel('Longitude');

if id == 12 || id == 13
    for j = 1:length(NCs)
       disp(name{NCs(j)});
    end
    
end



%clf; plotdata_bylabels(data,truelabels,2,0,'co');
%clf; plotdata_bylabels(data,labels(:,M),2,0,'nb');