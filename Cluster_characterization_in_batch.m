clear all; close all;

subjects_dir = 'path\to\subjects';
folder = 'path\to\output_folder';
setenv('SUBJECTS_DIR', subjects_dir)
addpath('path\to\FreeSurfer matlab dir')
cd(folder)

% Change to appropriate prefix for all subjects
Subset_feature_type = 'SBM'; %select one of {SBM, SBM_FLAIR}

% Screening criteria
Thres_Set = 0.5:0.05:0.8;

min_vtx_area = 100; %
minDistance = 2; % mininal distance between pts in different clusters

if strcmp(Subset_feature_type, 'SBM')
    Subs=dir(fullfile(subjects_dir, 'P*'));
    subs_all=cell(length(Subs),1);
    for s = 1:length(Subs)
        subs_all{s}=Subs(s).name;
    end
elseif strcmp(Subset_feature_type, 'SBM_FLAIR')
    load FLAIR_list_Patients.mat
    subs_all = Subs;
end

global Cortex
global Cortex_Normal
Cortex = read_label(['fsaverage_sym'],['lh.cortex']);
Cortex_Normal = Cortex(:,1) + 1; % full data 

global surf
surf = fs_read_surf(fullfile(subjects_dir, 'fsaverage_sym', 'surf', 'lh.pial'));
surf = fs_find_neighbors(surf);

max_vtx_area = floor(length(Cortex_Normal)/5);

% all features
All_features={'.Z_by_controls.thickness_z_on_lh.sm10.mgh'; '.Z_by_controls.lh-rh.thickness_z.sm10.mgh';...
    '.Z_by_controls.w-g.pct_z_on_lh.sm10.mgh';'.Z_by_controls.lh-rh.w-g.pct_z.sm10.mgh';...
    '.Z_by_controls.curv_on_lh.mgh';'.Z_by_controls.sulc_on_lh.mgh';...
    '.Z_by_controls.gm_FLAIR_0.75_z_on_lh.sm10.mgh';'.Z_by_controls.gm_FLAIR_0.5_z_on_lh.sm10.mgh';...
    '.Z_by_controls.gm_FLAIR_0.25_z_on_lh.sm10.mgh';'.Z_by_controls.gm_FLAIR_0_z_on_lh.sm10.mgh';...
    '.Z_by_controls.wm_FLAIR_0.5_z_on_lh.sm10.mgh';'.Z_by_controls.wm_FLAIR_1_z_on_lh.sm10.mgh';...
    '.Z_by_controls.lh-rh.gm_FLAIR_0.75_z.sm10.mgh';'.Z_by_controls.lh-rh.gm_FLAIR_0.5_z.sm10.mgh';...
    '.Z_by_controls.lh-rh.gm_FLAIR_0.25_z.sm10.mgh';'.Z_by_controls.lh-rh.gm_FLAIR_0_z.sm10.mgh';...
    '.Z_by_controls.lh-rh.wm_FLAIR_0.5_z.sm10.mgh';'.Z_by_controls.lh-rh.wm_FLAIR_1_z.sm10.mgh';...
    ...
    '.Z_by_controls.gm_MRF_T1_0.75_z_on_lh.sm10.mgh';'.Z_by_controls.gm_MRF_T1_0.5_z_on_lh.sm10.mgh';...
    '.Z_by_controls.gm_MRF_T1_0.25_z_on_lh.sm10.mgh';'.Z_by_controls.gm_MRF_T1_0_z_on_lh.sm10.mgh';...
    '.Z_by_controls.wm_MRF_T1_0.5_z_on_lh.sm10.mgh';'.Z_by_controls.wm_MRF_T1_1_z_on_lh.sm10.mgh';...
    '.Z_by_controls.lh-rh.gm_MRF_T1_0.75_z.sm10.mgh';'.Z_by_controls.lh-rh.gm_MRF_T1_0.5_z.sm10.mgh';...
    '.Z_by_controls.lh-rh.gm_MRF_T1_0.25_z.sm10.mgh';'.Z_by_controls.lh-rh.gm_MRF_T1_0_z.sm10.mgh';...
    '.Z_by_controls.lh-rh.wm_MRF_T1_0.5_z.sm10.mgh';'.Z_by_controls.lh-rh.wm_MRF_T1_1_z.sm10.mgh';...
    ...
    '.Z_by_controls.gm_MRF_T2_0.75_z_on_lh.sm10.mgh';'.Z_by_controls.gm_MRF_T2_0.5_z_on_lh.sm10.mgh';...
    '.Z_by_controls.gm_MRF_T2_0.25_z_on_lh.sm10.mgh';'.Z_by_controls.gm_MRF_T2_0_z_on_lh.sm10.mgh';...
    '.Z_by_controls.wm_MRF_T2_0.5_z_on_lh.sm10.mgh';'.Z_by_controls.wm_MRF_T2_1_z_on_lh.sm10.mgh';...
    '.Z_by_controls.lh-rh.gm_MRF_T2_0.75_z.sm10.mgh';'.Z_by_controls.lh-rh.gm_MRF_T2_0.5_z.sm10.mgh';...
    '.Z_by_controls.lh-rh.gm_MRF_T2_0.25_z.sm10.mgh';'.Z_by_controls.lh-rh.gm_MRF_T2_0_z.sm10.mgh';...
    '.Z_by_controls.lh-rh.wm_MRF_T2_0.5_z.sm10.mgh';'.Z_by_controls.lh-rh.wm_MRF_T2_1_z.sm10.mgh';...
    ...
    '.Z_by_controls.gm_MRF_T2_tr_0.75_z_on_lh.sm10.mgh';'.Z_by_controls.gm_MRF_T2_tr_0.5_z_on_lh.sm10.mgh';...
    '.Z_by_controls.gm_MRF_T2_tr_0.25_z_on_lh.sm10.mgh';'.Z_by_controls.gm_MRF_T2_tr_0_z_on_lh.sm10.mgh';...
    '.Z_by_controls.wm_MRF_T2_tr_0.5_z_on_lh.sm10.mgh';'.Z_by_controls.wm_MRF_T2_tr_1_z_on_lh.sm10.mgh';...
    '.Z_by_controls.lh-rh.gm_MRF_T2_tr_0.75_z.sm10.mgh';'.Z_by_controls.lh-rh.gm_MRF_T2_tr_0.5_z.sm10.mgh';...
    '.Z_by_controls.lh-rh.gm_MRF_T2_tr_0.25_z.sm10.mgh';'.Z_by_controls.lh-rh.gm_MRF_T2_tr_0_z.sm10.mgh';...
    '.Z_by_controls.lh-rh.wm_MRF_T2_tr_0.5_z.sm10.mgh';'.Z_by_controls.lh-rh.wm_MRF_T2_tr_1_z.sm10.mgh';...
    ...
    '.Z_by_controls.lh-rh.pial.K_filtered_2_z.sm20.mgh';'.Z_by_controls.pial.K_filtered_2_z_on_lh.sm20.mgh'
    ...
    '.gm_MRF_T1_0.75_on_lh.sm10.mgh';'.gm_MRF_T1_0.5_on_lh.sm10.mgh';...
    '.gm_MRF_T1_0.25_on_lh.sm10.mgh';'.gm_MRF_T1_0_on_lh.sm10.mgh';...
    '.wm_MRF_T1_0.5_on_lh.sm10.mgh';'.wm_MRF_T1_1_on_lh.sm10.mgh';...
    '.lh-rh.gm_MRF_T1_0.75.sm10.mgh';'.lh-rh.gm_MRF_T1_0.5.sm10.mgh';...
    '.lh-rh.gm_MRF_T1_0.25.sm10.mgh';'.lh-rh.gm_MRF_T1_0.sm10.mgh';...
    '.lh-rh.wm_MRF_T1_0.5.sm10.mgh';'.lh-rh.wm_MRF_T1_1.sm10.mgh';...
    ...
    '.gm_MRF_T2_0.75_on_lh.sm10.mgh';'.gm_MRF_T2_0.5_on_lh.sm10.mgh';...
    '.gm_MRF_T2_0.25_on_lh.sm10.mgh';'.gm_MRF_T2_0_on_lh.sm10.mgh';...
    '.wm_MRF_T2_0.5_on_lh.sm10.mgh';'.wm_MRF_T2_1_on_lh.sm10.mgh';...
    '.lh-rh.gm_MRF_T2_0.75.sm10.mgh';'.lh-rh.gm_MRF_T2_0.5.sm10.mgh';...
    '.lh-rh.gm_MRF_T2_0.25.sm10.mgh';'.lh-rh.gm_MRF_T2_0.sm10.mgh';...
    '.lh-rh.wm_MRF_T2_0.5.sm10.mgh';'.lh-rh.wm_MRF_T2_1.sm10.mgh';...
    ...
    '.gm_MRF_T2_tr_0.75_on_lh.sm10.mgh';'.gm_MRF_T2_tr_0.5_on_lh.sm10.mgh';...
    '.gm_MRF_T2_tr_0.25_on_lh.sm10.mgh';'.gm_MRF_T2_tr_0_on_lh.sm10.mgh';...
    '.wm_MRF_T2_tr_0.5_on_lh.sm10.mgh';'.wm_MRF_T2_tr_1_on_lh.sm10.mgh';...
    '.lh-rh.gm_MRF_T2_tr_0.75.sm10.mgh';'.lh-rh.gm_MRF_T2_tr_0.5.sm10.mgh';...
    '.lh-rh.gm_MRF_T2_tr_0.25.sm10.mgh';'.lh-rh.gm_MRF_T2_tr_0.sm10.mgh';...
    '.lh-rh.wm_MRF_T2_tr_0.5.sm10.mgh';'.lh-rh.wm_MRF_T2_tr_1.sm10.mgh';...
    ...
    '.Z_by_controls.gm_T1_over_T2_0.75_z_on_lh.sm10.mgh';'.Z_by_controls.gm_T1_over_T2_0.5_z_on_lh.sm10.mgh';...
    '.Z_by_controls.gm_T1_over_T2_0.25_z_on_lh.sm10.mgh';'.Z_by_controls.gm_T1_over_T2_0_z_on_lh.sm10.mgh';...
    '.Z_by_controls.wm_T1_over_T2_0.5_z_on_lh.sm10.mgh';'.Z_by_controls.wm_T1_over_T2_1_z_on_lh.sm10.mgh';...
    '.Z_by_controls.lh-rh.gm_T1_over_T2_0.75_z.sm10.mgh';'.Z_by_controls.lh-rh.gm_T1_over_T2_0.5_z.sm10.mgh';...
    '.Z_by_controls.lh-rh.gm_T1_over_T2_0.25_z.sm10.mgh';'.Z_by_controls.lh-rh.gm_T1_over_T2_0_z.sm10.mgh';...
    '.Z_by_controls.lh-rh.wm_T1_over_T2_0.5_z.sm10.mgh';'.Z_by_controls.lh-rh.wm_T1_over_T2_1_z.sm10.mgh';...
    };

%% cluster characterization: find the features which have significant difference between TP and FP clusters
version_name = 'LOO_v1';
ds_rate = '1';

if strcmp(Subset_feature_type, 'SBM')
    Feature_Sets = {['SBM_' version_name], ['SBM_nMRF_' version_name]};
    if strcmp(version_name, 'LOO_v1')
        % fill in the optimized output with the parameters that achieve higheset vertex-wise AUC  
        TrainFcn_Sets = {'pyBCE_lr3_SMOTE_rL22', 'pyBFL_lr3_SMOTE_rL23'};
    end
    Ft_Sets = {[1:6, 55, 56], [1:6, 19:30, 43:54, 55, 56]};
    
elseif strcmp(Subset_feature_type, 'SBM_FLAIR')
    Feature_Sets = {['SBM_FLAIR_' version_name], ['SBM_FLAIR_nMRF_' version_name]};
    if strcmp(version_name, 'LOO_v1')
        % fill in the optimized output with the parameters that achieve higheset vertex-wise AUC  
        TrainFcn_Sets = {'pyDBCE_lr3_SMOTE_rL22', 'pyDBCE_lr3_SMOTE_rL22'};
    end
    Ft_Sets = {[1:6, 7:18, 55, 56], [1:6, 7:18, 19:30, 43:54, 55, 56]};
end

% record the lesion side
if ~exist([Feature_Sets{1} '_PTs_lesion_side.mat'])
    for sub_idx = 1:length(subs_all)
        if exist(fullfile(subjects_dir, subs_all{sub_idx}, 'xhemi', 'surf_meld', ['lh' '.on_lh.lesion.mgh']))
            subs_all_h1{sub_idx, 1} = 'lh';
        elseif exist(fullfile(subjects_dir, subs_all{sub_idx}, 'xhemi', 'surf_meld', ['rh' '.on_lh.lesion.mgh']))
            subs_all_h1{sub_idx, 1} = 'rh';
        end
    end
    save([Feature_Sets{1} '_PTs_lesion_side.mat'], 'subs_all_h1', 'subs_all')
end
            
for Set_order = 1:length(Feature_Sets) 
    SetName = Feature_Sets{Set_order};
    
    load([SetName '_PTs_lesion_side.mat'])
    for Fcn_order = Set_order
        TrainFcn = TrainFcn_Sets{Fcn_order};
        Ft_Set = Ft_Sets{Fcn_order};
        VariableName_ori = ['size', strcat(All_features(Ft_Set)', '_Max'), strcat(All_features(Ft_Set)', '_Std'), strcat(All_features(Ft_Set)', '_Mean'), strcat(All_features(Ft_Set)', '_P25'), strcat(All_features(Ft_Set)', '_Median'), strcat(All_features(Ft_Set)', '_P75'), ...
                    'ProbMax', 'ProbStd', 'ProbMean', 'ProbP25', 'ProbMedian', 'ProbP75'];
        
        % (1). Get all the data
        disp('(1). Get all the data')
        if ~exist([SetName '_' TrainFcn '_DataSet_set.mat'])
            for sub_idx = 1:length(subs_all)
                TargetSub = subs_all{sub_idx};
                Dt_set{sub_idx}.TargetSub = TargetSub;
                PTs_file_list = dir(fullfile(subjects_dir, TargetSub, 'xhemi', ['classifier_' version_name], ['lh.TestSub_*_sm_' TrainFcn '.mat.FTs_' SetName '_ds' ds_rate '.mgh']));
                
                for PTs_idx = 1:length(PTs_file_list) 
                    str_cmpt = strsplit(PTs_file_list(PTs_idx).name, {'_sm', 'TestSub_'});
                    TestSub = str_cmpt{2};
                    h1 = subs_all_h1{find(strcmp(TestSub, subs_all)), 1};
                    
                    if strcmp(h1, 'lh')
                        h2 = 'rh';
                    elseif strcmp(h1, 'rh')
                        h2 = 'lh';
                    elseif strcmp(h1, 'both')
                        h1 = 'lh';
                        h2 = 'rh';
                    end

                    TestSub_set{PTs_idx, 1} = TestSub;
                    TestSub_h1{PTs_idx, 1} = h1;

                    % true lesion vertexs from both left and right hemisphere
                    Lesion_H1 = MRIread(fullfile(subjects_dir, TestSub, 'xhemi', 'surf_meld', [h1 '.on_lh.lesion_sm.mgh'])); 
                    true_surf_H1 = Lesion_H1.vol(Cortex_Normal);
                    true_surf_H1(find(true_surf_H1 ~= 1)) = 0;
                    true_surf_H2 = zeros(size(true_surf_H1));

                    % predicted lesion probability of both left and right hemisphere 
                    file_H1 = dir(fullfile(subjects_dir, TargetSub, 'xhemi', ['classifier_' version_name], [h1 '.TestSub_' TestSub '_sm_' TrainFcn  '.mat.FTs_' SetName '_ds' ds_rate '.mgh']));
                    pred_H1 = MRIread(fullfile(subjects_dir, TargetSub, 'xhemi', ['classifier_' version_name], file_H1.name));
                    pred_surf_H1_pre = pred_H1.vol(Cortex_Normal);

                    file_H2 = dir(fullfile(subjects_dir, TargetSub, 'xhemi', ['classifier_' version_name], [h2 '.TestSub_' TestSub '_sm_' TrainFcn  '.mat.FTs_' SetName '_ds' ds_rate '.mgh']));
                    pred_H2 = MRIread(fullfile(subjects_dir, TargetSub, 'xhemi', ['classifier_' version_name], file_H2.name));
                    pred_surf_H2_pre = pred_H2.vol(Cortex_Normal);

                    true_surf_H1_set(PTs_idx, :) = true_surf_H1;
                    true_surf_H2_set(PTs_idx, :) = true_surf_H2;
                    pred_surf_H1_pre_set(PTs_idx, :) = pred_surf_H1_pre;
                    pred_surf_H2_pre_set(PTs_idx, :) = pred_surf_H2_pre;

                    clear true_surf_H1 true_surf_H2 pred_surf_H1_pre pred_surf_H2_pre file_H1 pred_H1 file_H2 pred_H2 Lesion_H1 h1 TestSub str_cmpt   
                end

                HCs_file_list = dir(fullfile(subjects_dir, subs_all{sub_idx}, 'xhemi', ['classifier_' version_name], ['lh.HCSub_*_sm_data_' TrainFcn '.mat.FTs_' SetName '_ds' ds_rate '.mgh']));
                for HCs_idx = 1:length(HCs_file_list) 
                    str_cmpt = strsplit(HCs_file_list(HCs_idx).name, {'_sm_data', 'HCSub_'});
                    TestSub = str_cmpt{2}; c

                    TestSub_set{length(PTs_file_list) + HCs_idx, 1} = TestSub;
                    TestSub_h1{length(PTs_file_list) + HCs_idx, 1} = [];

                    % predicted lesion probability of both left and right hemisphere
                    % H1 for lh; H2 for rh                                 
                    file_H1 = dir(fullfile(subjects_dir, TargetSub, 'xhemi', ['classifier_' version_name], ['lh.HCSub_' TestSub '_sm_data_' TrainFcn  '.mat.FTs_' SetName '_ds' ds_rate '.mgh']));
                    pred_H1 = MRIread(fullfile(subjects_dir, TargetSub, 'xhemi', ['classifier_' version_name], file_H1.name));
                    pred_surf_H1_pre = pred_H1.vol(Cortex_Normal);

                    file_H2 = dir(fullfile(subjects_dir, TargetSub, 'xhemi', ['classifier_' version_name], ['rh.HCSub_' TestSub '_sm_data_' TrainFcn  '.mat.FTs_' SetName '_ds' ds_rate '.mgh']));
                    pred_H2 = MRIread(fullfile(subjects_dir, TargetSub, 'xhemi', ['classifier_' version_name], file_H1.name));
                    pred_surf_H2_pre = pred_H2.vol(Cortex_Normal);

                    true_surf_H1 = zeros(size(pred_surf_H1_pre));
                    true_surf_H2 = zeros(size(pred_surf_H2_pre));

                    true_surf_H1_set(length(PTs_file_list) + HCs_idx, :) = true_surf_H1;
                    true_surf_H2_set(length(PTs_file_list) + HCs_idx, :) = true_surf_H2;
                    pred_surf_H1_pre_set(length(PTs_file_list) + HCs_idx, :) = pred_surf_H1_pre;
                    pred_surf_H2_pre_set(length(PTs_file_list) + HCs_idx, :) = pred_surf_H2_pre;

                    clear true_surf_H1 true_surf_H2 pred_surf_H1_pre pred_surf_H2_pre file_H1 file_H2 pred_H1 pred_H2 TestSub str_cmpt  
                end

                Dt_set{sub_idx}.TestSub_set = TestSub_set;
                Dt_set{sub_idx}.TestSub_h1 = TestSub_h1;
                Dt_set{sub_idx}.true_surf_H1_set = true_surf_H1_set;
                Dt_set{sub_idx}.true_surf_H2_set = true_surf_H2_set;
                Dt_set{sub_idx}.pred_surf_H1_pre_set = pred_surf_H1_pre_set;
                Dt_set{sub_idx}.pred_surf_H2_pre_set = pred_surf_H2_pre_set;
                clear TargetSub PTs_file_list HCs_file_list
            end
            save([SetName '_' TrainFcn '_DataSet_set.mat'], 'Dt_set', '-v7.3')
            
            clear Dt_set
        end
        
        % (2). apply different thresholds
        for thres_idx = 1:length(Thres_Set)
            Th1Crit = ['nonAdpTh' num2str(Thres_Set(thres_idx))]; 
            disp(['(2). decide the threshold by the ' Th1Crit ' score of traning set'])
            TrainSet_opt_threshold = Thres_Set(thres_idx);
            
            if ~exist([SetName '_' TrainFcn '_DataSet_set_thr_' Th1Crit '.mat'])
                load([SetName '_' TrainFcn '_DataSet_set.mat'])
                Dt_set_summary = [Dt_set{:}];
                target_list = {Dt_set_summary.TargetSub};
                for target_idx = 1:length(target_list)
                    targetSub = target_list{target_idx};
                    target_TestSub_set = Dt_set_summary(target_idx).TestSub_set;
                    target_true_surf_H1_set = Dt_set_summary(target_idx).true_surf_H1_set;
                    target_true_surf_H2_set = Dt_set_summary(target_idx).true_surf_H2_set;

                    target_pred_surf_H1_pre_set = Dt_set_summary(target_idx).pred_surf_H1_pre_set;
                    target_pred_surf_H2_pre_set = Dt_set_summary(target_idx).pred_surf_H2_pre_set;
                    
                    % only get the target sub
                    patient_idx = strfind(target_TestSub_set, targetSub);
                    patient_idx(cellfun('isempty', patient_idx)) = {0};
                    patient_idx = cell2mat(patient_idx);
          
                    % Get the pred result of the target sub
                    target_pred_surf_H1_pre = target_pred_surf_H1_pre_set(find(strcmp(target_TestSub_set, targetSub)), :);
                    target_pred_surf_H2_pre = target_pred_surf_H2_pre_set(find(strcmp(target_TestSub_set, targetSub)), :);
                    target_true_surf_H1 = target_true_surf_H1_set(find(strcmp(target_TestSub_set, targetSub)), :);
                    target_true_surf_H2 = target_true_surf_H2_set(find(strcmp(target_TestSub_set, targetSub)), :);
            
                    % Threshold the pred of the target sub
                    target_pred_surf_H1_pre_thr = zeros(size(target_pred_surf_H1_pre));
                    target_pred_surf_H1_pre_thr(find(target_pred_surf_H1_pre > TrainSet_opt_threshold)) = target_pred_surf_H1_pre(find(target_pred_surf_H1_pre > TrainSet_opt_threshold));
                    target_pred_surf_H2_pre_thr = zeros(size(target_pred_surf_H2_pre));
                    target_pred_surf_H2_pre_thr(find(target_pred_surf_H2_pre > TrainSet_opt_threshold)) = target_pred_surf_H2_pre(find(target_pred_surf_H2_pre > TrainSet_opt_threshold));
            
                    % Threshold the HCs
                    hcs_idx = strfind(target_TestSub_set, 'V');
                    hcs_idx(cellfun('isempty', hcs_idx)) = {0};
                    hcs_idx = cell2mat(hcs_idx);

                    hcs_target_pred_surf_H1_pre_set = target_pred_surf_H1_pre_set(find(hcs_idx), :);
                    hcs_target_pred_surf_H2_pre_set = target_pred_surf_H2_pre_set(find(hcs_idx), :);
                    hcs_target_true_surf_H1_set = target_true_surf_H1_set(find(hcs_idx), :);
                    hcs_target_true_surf_H2_set = target_true_surf_H2_set(find(hcs_idx), :);

                    hcs_target_pred_surf_H1_pre_set_thr = zeros(size(hcs_target_pred_surf_H1_pre_set));
                    hcs_target_pred_surf_H1_pre_set_thr(find(hcs_target_pred_surf_H1_pre_set > TrainSet_opt_threshold)) = ...
                        hcs_target_pred_surf_H1_pre_set(find(hcs_target_pred_surf_H1_pre_set > TrainSet_opt_threshold));
                    hcs_target_pred_surf_H2_pre_set_thr = zeros(size(hcs_target_pred_surf_H2_pre_set));
                    hcs_target_pred_surf_H2_pre_set_thr(find(hcs_target_pred_surf_H2_pre_set > TrainSet_opt_threshold)) = ...
                        hcs_target_pred_surf_H2_pre_set(find(hcs_target_pred_surf_H2_pre_set > TrainSet_opt_threshold));

                    % Get the lesion side
                    Dt_set_thr{target_idx}.lesion_side = subs_all_h1{find(strcmp(subs_all, targetSub))};
                    
                    Dt_set_thr{target_idx}.TrainSet_opt_threshold = TrainSet_opt_threshold;
                    Dt_set_thr{target_idx}.TrainSet_threshold_way = "non-adaptive";
                    Dt_set_thr{target_idx}.targetSub = targetSub;
                    
                    Dt_set_thr{target_idx}.target_pred_surf_H1_pre_thr = target_pred_surf_H1_pre_thr;
                    Dt_set_thr{target_idx}.target_pred_surf_H2_pre_thr = target_pred_surf_H2_pre_thr;
                    Dt_set_thr{target_idx}.target_true_surf_H1 = target_true_surf_H1;
                    Dt_set_thr{target_idx}.target_true_surf_H2 = target_true_surf_H2;

                    Dt_set_thr{target_idx}.hcs_target_list = target_TestSub_set(find(hcs_idx));
                    Dt_set_thr{target_idx}.hcs_target_pred_surf_H1_pre_set_thr = hcs_target_pred_surf_H1_pre_set_thr;
                    Dt_set_thr{target_idx}.hcs_target_pred_surf_H2_pre_set_thr = hcs_target_pred_surf_H2_pre_set_thr;
                    Dt_set_thr{target_idx}.hcs_target_true_surf_H1_set = hcs_target_true_surf_H1_set;
                    Dt_set_thr{target_idx}.hcs_target_true_surf_H2_set = hcs_target_true_surf_H2_set;
                    
                    clear patient_idx target_pred_surf_H2_pre_set target_pred_surf_H1_pre_set target_true_surf_H2_set target_true_surf_H1_set target_TestSub_set targetSub
                    clear hcs_idx target_pred_surf_H2_pre_thr target_pred_surf_H1_pre_thr target_true_surf_H2 target_true_surf_H1 target_pred_surf_H2_pre target_pred_surf_H1_pre                        
                    clear hcs_target_pred_surf_H2_pre_set_thr hcs_target_pred_surf_H1_pre_set_thr hcs_target_true_surf_H2_set hcs_target_true_surf_H1_set hcs_target_pred_surf_H2_pre_set hcs_target_pred_surf_H1_pre_set
                end
                save([SetName '_' TrainFcn '_DataSet_set_thr_' Th1Crit '.mat'], 'Dt_set_thr', '-v7.3')
                
                clear target_list Dt_set_summary Dt_set Dt_set_thr
            end
            clear TrainSet_opt_threshold
        end
        
        
        for thres_idx = 1:length(Thres_Set)
            % (3). surface-based clustering
            disp('(3). surface-based clustering')
            
            Th1Crit = ['nonAdpTh' num2str(Thres_Set(thres_idx))]; 
            cluster_characterization_step3(minDistance, min_vtx_area, max_vtx_area, SetName, TrainFcn, Th1Crit);
            
            % (4). cluster-wise feature creation
            disp('(4). cluster-wise feature calculation')
            cluster_characterization_step4(minDistance, min_vtx_area, max_vtx_area, SetName, TrainFcn, Th1Crit, VariableName_ori);
            
            % (5) 2nd stage cluster-wise classification
            disp('(5). 2nd stage cluster-wise classification')

            threshold2 = 0.5;
            cluster_characterization_step5(minDistance, min_vtx_area, max_vtx_area, SetName, TrainFcn, Th1Crit, threshold2);

            % (6) Visualization in freesurfer, optional
            % disp('(6) Visualization in freesurfer')
            % cluster_characterization_step6(minDistance, min_vtx_area, max_vtx_area, SetName, TrainFcn, Th1Crit, threshold2);
        end
    
        clear TrainFcn Ft_Set VariableName_ori  
    end
    clear SetName
end

%% Result evaluation
for Set_order = 1:length(Feature_Sets) 
    SetName = Feature_Sets{Set_order};
    
    for Fcn_order = Set_order
        TrainFcn = TrainFcn_Sets{Fcn_order};
        Ft_Set = Ft_Sets{Fcn_order};
        
        for thres_idx = 1:length(Thres_Set)
            Th1Crit = ['nonAdpTh' num2str(Thres_Set(thres_idx))]; 
            threshold2 = 0.5;
            disp('(7). Result evaluation')
            cluster_characterization_step7(minDistance, min_vtx_area, max_vtx_area, SetName, TrainFcn, Th1Crit, threshold2);
        end
        
        clear TrainFcn Ft_Set VariableName_ori  
    end
    clear SetName
end