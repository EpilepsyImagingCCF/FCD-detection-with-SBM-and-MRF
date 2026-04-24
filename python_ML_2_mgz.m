clear all; close all;

subjects_dir = 'path\to\subjects';
cd(subjects_dir)
setenv('SUBJECTS_DIR', subjects_dir)
addpath('path\to\FreeSurfer matlab dir')

folder = 'path\to\data_folder';

TrainFcn_Set = {'pyBCE_lr3_SMOTE'}; % can be added or revised based on the fine-tuning parameters
ds_rate = '1';
Measure = '.Z_by_controls.thickness_z_on_lh.sm10.mgh';

Cortex = read_label(['fsaverage_sym'],['lh.cortex']);
Cortex_lesion = Cortex(:,1) + 1; % full sample for the lesion area

version = '_v1'; % can be revised
classifier_tag = ['classifier_LOO' version];
Feature_Sets = {['SBM_LOO' version], ['SBM_MRF_LOO' version], ['SBM_nMRF_LOO' version], ['SBM_FLAIR_LOO' version], ['SBM_FLAIR_MRF_LOO' version], ['SBM_FLAIR_nMRF_LOO' version]};

for Set_order = 1:length(Feature_Sets)
    SetName = Feature_Sets{Set_order};
    
    for Fcn_order = 1:length(TrainFcn_Set)
        TrainFcn = TrainFcn_Set{Fcn_order};
        disp([SetName ' ' TrainFcn]);
        Subject_list = dir(fullfile(folder, SetName, '*_sm_data.mat'));

        for Subject_list_idx = 1:length(Subject_list)
            str_cmpt = strsplit(Subject_list(Subject_list_idx).name, '.');
            Subject_list_filename{Subject_list_idx} = strjoin(str_cmpt(1), '_');
            clear str_cmpt
        end

        for Subject_list_idx = 1:length(Subject_list)
            disp(['                       ' Subject_list_filename{Subject_list_idx}])

            str_cmpt = strsplit(Subject_list_filename{Subject_list_idx}, '_');
            Target_Subject_Name = strjoin(str_cmpt(1:2), '_');
            lesion_type = str_cmpt{3};

            disp(['Target subject name: ' Target_Subject_Name '; TrainFcn: ' TrainFcn '; FTs: ' SetName]);

            FileList = [dir(fullfile(Subject_list(Subject_list_idx).folder, [Subject_list_filename{Subject_list_idx} '_TestSub_*_' TrainFcn '.mat'])); ...
                dir(fullfile(Subject_list(Subject_list_idx).folder, [Subject_list_filename{Subject_list_idx} '_HCSub_*_' TrainFcn '.mat']))];

            if ~exist(fullfile(Target_Subject_Name, 'xhemi', classifier_tag))
                mkdir(fullfile(Target_Subject_Name, 'xhemi', classifier_tag))
            end
            
            M_lh = MRIread(fullfile(Target_Subject_Name, 'xhemi', 'surf', ['lh' Measure]));
            M_rh = MRIread(fullfile(Target_Subject_Name, 'xhemi', 'surf', ['rh' Measure]));

            for order = 1:length(FileList)
                load(fullfile(FileList(order).folder, FileList(order).name));
                
                M_lh.vol = M_lh.vol*0;
                M_lh.vol(Cortex_lesion) = Y_predict_lh;
                MRIwrite(M_lh, fullfile(Target_Subject_Name, 'xhemi', classifier_tag, ['lh.' FileList(order).name '.FTs_' SetName '_ds' ds_rate '.mgh']));

                M_rh.vol = M_rh.vol*0;
                M_rh.vol(Cortex_lesion) = Y_predict_rh;
                MRIwrite(M_rh, fullfile(Target_Subject_Name, 'xhemi', classifier_tag, ['rh.' FileList(order).name '.FTs_' SetName '_ds' ds_rate '.mgh']));
                
                clear Y_test_lh Y_test_rh X_test_lh X_test_rh Y_predict_lh Y_predict_rh
            end
            
            clear M_lh M_rh FileList lesion_type Target_Subject_Name str_cmpt 
        end
        clear Subject_list TrainFcn Subject_list_filename
    end
    clear SetName
end