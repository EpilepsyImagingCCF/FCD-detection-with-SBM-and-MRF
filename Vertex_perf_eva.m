clear all; close all;

folder = 'path\to\data_folder';

subjects_dir = 'path\to\subjects';
cd(subjects_dir)
setenv('SUBJECTS_DIR', subjects_dir)
addpath('path\to\FreeSurfer matlab dir')

%change to appropriate prefix for all subjects
Subset_feature_type = 'SBM'; %select one of {SBM, SBM_FLAIR}

if strcmp(Subset_feature_type, 'SBM')
    Subs = dir(fullfile(subjects_dir, 'P*'));
    subs_all = cell(length(Subs),1);
    for s = 1:length(Subs)
        subs_all{s}=Subs(s).name;
    end
elseif strcmp(Subset_feature_type, 'SBM_FLAIR')
    load FLAIR_list_Patients.mat
    subs_all = Subs;
end

Measure = '.Z_by_controls.thickness_z_on_lh.sm10.mgh';

global Cortex
global Cortex_Normal
Cortex = read_label(['fsaverage_sym'],['lh.cortex']);
Cortex_Normal = Cortex(:,1)+1; % full data 

%% LOO 
version = '_v8';
X_re = 0:1e-2:1; % resample vector
ds_rate = '1';

if strcmp(Subset_feature_type, 'SBM')
    Feature_Sets = {['SBM_LOO' version], ['SBM_nMRF_LOO' version]};
elseif strcmp(Subset_feature_type, 'SBM_FLAIR')
    Feature_Sets = {['SBM_FLAIR_LOO' version], ['SBM_FLAIR_nMRF_LOO' version]};
end

% All the outputs with different fine-tuned parameters could be put together here
TrainFcn_Sets = {'pyBCE_lr3_SMOTE'};

for Set_order = 1:length(Feature_Sets) 
    SetName = Feature_Sets{Set_order};
    for Fcn_order = 1:length(TrainFcn_Sets)
        TrainFcn = TrainFcn_Sets{Fcn_order};
        for order = 1:length(subs_all)
            TestSub = subs_all{order};
            disp(['SetName: ' SetName '; TrainFcn: ' TrainFcn '; TestSub: ' TestSub])

            if exist(fullfile(subjects_dir, TestSub, 'xhemi', 'surf_meld', ['lh' '.on_lh.lesion.mgh']))
                h1 = 'lh';
                h2 = 'rh';
            elseif exist(fullfile(subjects_dir, TestSub, 'xhemi', 'surf_meld', ['rh' '.on_lh.lesion.mgh']))
                h1 = 'rh';
                h2 = 'lh';
            end

            % true lesion vertexs from both left and right hemisphere
            Lesion_H1 = MRIread(fullfile(subjects_dir, TestSub, 'xhemi', 'surf_meld', [h1 '.on_lh.lesion_sm.mgh']));
            true_surf_H1 = Lesion_H1.vol(Cortex_Normal);
            true_surf_H1(find(true_surf_H1 ~= 1)) = 0;
            true_surf_H2 = zeros(size(true_surf_H1));
            true_surf = [true_surf_H1, true_surf_H2];

            % predicted lesion probability of both left and right hemisphere
            file_H1 = dir(fullfile(subjects_dir, TestSub, 'xhemi', ['classifier_LOO' version], [h1 '.TestSub_' TestSub '_sm_' TrainFcn  '.mat.FTs_' SetName '_ds' ds_rate '.mgh']));
            pred_H1 = MRIread(fullfile(subjects_dir, TestSub, 'xhemi', ['classifier_LOO' version], file_H1.name));
            pred_surf_H1 = pred_H1.vol(Cortex_Normal);

            file_H2 = dir(fullfile(subjects_dir, TestSub, 'xhemi', ['classifier_LOO' version], [h2 '.TestSub_' TestSub '_sm_' TrainFcn  '.mat.FTs_' SetName '_ds' ds_rate '.mgh']));
            pred_H2 = MRIread(fullfile(subjects_dir, TestSub, 'xhemi', ['classifier_LOO' version], file_H2.name));
            pred_surf_H2 = pred_H2.vol(Cortex_Normal);

            pred_surf = [pred_surf_H1, pred_surf_H2]; 

            [X, Y, T, AUC] = perfcurve(true_surf, pred_surf, 1);

            vtxperf_AUC(order) = AUC;
            clear TestSub h1 h2 Lesion_H1 true_surf_H1 true_surf_H2 true_surf file_H1 file_H2 pred_H1 pred_H2 pred_surf_H1 pred_surf_H2 pred_surf X Y T AUC Y_re
        end

        vtxperf_AUC_mean(Fcn_order, Set_order)= mean(vtxperf_AUC);

        clear TrainFcn vtxperf_AUC
    end
    clear SetName
end

%%
% The different outputs with fine-tuned parameters can be compared by the
% vertex-wise mean AUC variable "vtxperf_AUC_mean". The parameters with the
% highest AUC could be picked up here.

%% ROC plot generation
version = '_v8';
X_re = 0:1e-2:1; % resample vector
ds_rate = '1';

if strcmp(Subset_feature_type, 'SBM')
    Feature_Sets = {['SBM_LOO' version], ['SBM_nMRF_LOO' version]};

    % The fine-tuned version with the highest AUC
    TrainFcn_Sets = {'pyDBCE_lr3_SMOTE_rL23', 'pyBFL_lr3_SMOTE_rL23'}; 
elseif strcmp(Subset_feature_type, 'SBM_FLAIR')
    Feature_Sets = {['SBM_FLAIR_LOO' version], ['SBM_FLAIR_nMRF_LOO' version]};

    % The fine-tuned version with the highest AUC
    TrainFcn_Sets = {'pyBCE_lr3_SMOTE_rL22', 'pyBFL_lr3_SMOTE_rL23'};
end

for Set_order = 1:length(Feature_Sets) 
    SetName = Feature_Sets{Set_order};
    for Fcn_order = Set_order
        TrainFcn = TrainFcn_Sets{Fcn_order};
        for order = 1:length(subs_all)
            TestSub = subs_all{order};
            disp(['SetName: ' SetName '; TrainFcn: ' TrainFcn '; TestSub: ' TestSub])
            
            if exist(fullfile(subjects_dir, TestSub, 'xhemi', 'surf_meld', ['lh' '.on_lh.lesion.mgh']))
                h1 = 'lh';
                h2 = 'rh';
            elseif exist(fullfile(subjects_dir, TestSub, 'xhemi', 'surf_meld', ['rh' '.on_lh.lesion.mgh']))
                h1 = 'rh';
                h2 = 'lh';
            end
            % true lesion vertexs from both left and right hemisphere
            Lesion_H1 = MRIread(fullfile(subjects_dir, TestSub, 'xhemi', 'surf_meld', [h1 '.on_lh.lesion_sm.mgh']));
            true_surf_H1 = Lesion_H1.vol(Cortex_Normal);
            true_surf_H1(find(true_surf_H1 ~= 1)) = 0;
            true_surf_H2 = zeros(size(true_surf_H1));
            true_surf = [true_surf_H1, true_surf_H2];
            
            % predicted lesion probability of both left and right hemisphere
            file_H1 = dir(fullfile(subjects_dir, TestSub, 'xhemi', ['classifier_LOO' version], [h1 '.TestSub_' TestSub '_sm_' TrainFcn  '.mat.FTs_' SetName '_ds' ds_rate '.mgh']));
            pred_H1 = MRIread(fullfile(subjects_dir, TestSub, 'xhemi', ['classifier_LOO' version], file_H1.name));
            pred_surf_H1 = pred_H1.vol(Cortex_Normal);

            file_H2 = dir(fullfile(subjects_dir, TestSub, 'xhemi', ['classifier_LOO' version], [h2 '.TestSub_' TestSub '_sm_' TrainFcn  '.mat.FTs_' SetName '_ds' ds_rate '.mgh']));
            pred_H2 = MRIread(fullfile(subjects_dir, TestSub, 'xhemi', ['classifier_LOO' version], file_H2.name));
            pred_surf_H2 = pred_H2.vol(Cortex_Normal);
            
            pred_surf = [pred_surf_H1, pred_surf_H2]; 
            
            [X, Y, T, AUC] = perfcurve(true_surf, pred_surf, 1);
            
            X = X' + linspace(0, 1, length(X))*1E-6;
            Y = Y' + linspace(0, 1, length(Y))*1E-6;
            Y_re = interp1(X, Y, X_re);
            
            vtxperf_Y(order, :) = Y_re;
            vtxperf_AUC(order) = AUC;
            
            clear TestSub h1 h2 Lesion_H1 true_surf_H1 true_surf_H2 true_surf file_H1 file_H2 pred_H1 pred_H2 pred_surf_H1 pred_surf_H2 pred_surf X Y T AUC Y_re
        end
        vtxperf_AUC_std(Fcn_order, 1)= std(vtxperf_AUC);
        vtxperf_AUC_mean(Fcn_order, 1)= mean(vtxperf_AUC);
        vtxperf_Y_mean = mean(vtxperf_Y);
        vtxperf_Y_std = std(vtxperf_Y);
        vtxperf_Y_stderr = std(vtxperf_Y)/sqrt(length(vtxperf_Y));
        
        errorbar(X_re, vtxperf_Y_mean, vtxperf_Y_std); %title(['Mean ROC plot among subjects']); xlabel('False positive rate'); ylabel('True positive rate')
        hold on
        clear TrainFcn vtxperf_AUC vtxperf_Y vtxperf_Y_mean vtxperf_Y_stderr
    end
    clear SetName
end

xlim([0 1]); ylim([0 1.1])
% set(gcf, 'Position', get(0, 'Screensize'))
% title(['ROC for vertex-wise performance']); xlabel('False positive rate'); ylabel('True positive rate')
if strcmp(Subset_feature_type, 'SBM')
    legend(sprintf(['[T1w] \n mean AUC = ' num2str(round(vtxperf_AUC_mean(1), 2)) ' ' char(177) ' ' num2str(round(vtxperf_AUC_std(1), 2))]), sprintf(['[T1w + MRF] \n mean AUC = ' num2str(round(vtxperf_AUC_mean(2), 2))  ' ' char(177) ' ' num2str(round(vtxperf_AUC_std(2), 2))]), 'Location', 'southeast', 'Fontsize', 10)
    saveas(gcf, [Subset_feature_type version '_vtxPerf_ROC.png'])
elseif strcmp(Subset_feature_type, 'SBM_FLAIR')
    legend(sprintf(['[T1w + FLAIR] \n mean AUC = ' num2str(round(vtxperf_AUC_mean(1), 2)) ' ' char(177) ' ' num2str(round(vtxperf_AUC_std(1), 2))]), sprintf(['[T1w + FLAIR + nMRF] \n mean AUC = ' num2str(round(vtxperf_AUC_mean(2), 2)) ' ' char(177) ' ' num2str(round(vtxperf_AUC_std(2), 2))]), 'Location', 'southeast', 'Fontsize', 10)
    saveas(gcf, [Subset_feature_type version '_vtxPerf_ROC.png'])
end
