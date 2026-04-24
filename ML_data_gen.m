clear all; close all;

% Change to appropriate subject dir
subjects_dir = 'path\to\subjects';
setenv SUBJECTS_DIR .
cd(subjects_dir)
addpath('path\to\FreeSurfer matlab dir')
out_dir = 'path\to\outputs';

Subset_feature_type = 'SBM'; %select one of {SBM, SBM_FLAIR}

profix = 'LOO_v8'; 
lesion_type = '_sm'; % smoothed one

if strcmp(Subset_feature_type, 'SBM')
    Subs = dir(fullfile(subjects_dir, 'P*'));
    subs_all = cell(length(Subs),1);
    for s = 1:length(Subs)
        subs_all{s} = Subs(s).name;
    end
    clear Subs
    
    Subs = dir(fullfile(subjects_dir, 'V*'));
    HCs_all = {Subs.name}';
    clear Subs
elseif strcmp(Subset_feature_type, 'SBM_FLAIR')
    load FLAIR_list_Patients.mat
    subs_all = Subs;
    clear Subs
    
    load FLAIR_list_Normal.mat
    HCs_all = Subs;
    clear Subs
end

% Get the data from the FreeSurfer template
percentage = 0.1;
Cortex = read_label('fsaverage_sym', 'lh.cortex');
Cortex_pc = pointCloud(Cortex(:, 2:4));
Cortex_pcdc = pcdownsample(Cortex_pc, 'random', percentage);
for i = 1:length(Cortex_pcdc.Location)
    idx_c = intersect(intersect(find(Cortex_pcdc.Location(i, 1) == Cortex_pc.Location(:, 1)), ...
        find(Cortex_pcdc.Location(i, 2) == Cortex_pc.Location(:, 2))), ...
        find(Cortex_pcdc.Location(i, 3) == Cortex_pc.Location(:, 3)));

    if length(Cortex(idx_c, 1)) > 1
        Cortex_Normal(i, 1) = max(Cortex(idx_c, 1));
    else
        Cortex_Normal(i, 1) = Cortex(idx_c, 1);
    end

    clear idx_c
end
Cortex_Normal = Cortex_Normal + 1; % downsampled vertex index
Cortex_lesion = Cortex(:,1) + 1; % full vertex index 

% all features
All_features = {...
    '.Z_by_controls.thickness_z_on_lh.sm10.mgh'; '.Z_by_controls.lh-rh.thickness_z.sm10.mgh';...
    '.Z_by_controls.w-g.pct_z_on_lh.sm10.mgh';'.Z_by_controls.lh-rh.w-g.pct_z.sm10.mgh';...
    '.Z_by_controls.curv_on_lh.mgh';'.Z_by_controls.sulc_on_lh.mgh';...
    ...
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
};

% This is the set of measures you want to include in your classifier
SBM = [1:6, 55, 56];
SBM_nMRF = [1:6, 19:30, 43:54, 55, 56];
SBM_FLAIR = [1:6, 7:18, 55, 56];
SBM_FLAIR_nMRF = [1:6, 7:18, 19:30, 43:54, 55, 56];

if strcmp(Subset_feature_type, 'SBM')
    Sets = {'SBM', 'SBM_nMRF'}; 
elseif strcmp(Subset_feature_type, 'SBM_FLAIR')
    Sets = {'SBM_FLAIR', 'SBM_FLAIR_nMRF'};
end

%% Training Subjects with Leave-One-Out Framework
for SetNumber = 1:length(Sets)
    Set = eval(Sets{SetNumber});
    SetName = Sets{SetNumber};

    % Normal vertex
    Normal_HC_set = [];
    Measures = All_features(Set);
    NumberOfMeasures = length(Measures);

    disp('Creating training data from healthy control');
    for order = 1:length(HCs_all)
        NormalSubject = HCs_all{order};

        if randi(2) == 1
            h1 = 'lh';
        else
            h1 = 'rh';
        end 
        
        for L = 1:NumberOfMeasures
            M = MRIread(fullfile(NormalSubject, 'xhemi', 'surf', [h1 Measures{L}]));
            Normal_HC(:, L) = M.vol(Cortex_lesion)';
            clear M 
        end
        
        Normal_HC_set = [Normal_HC_set; Normal_HC];
        
        clear h1 Normal_HC NormalSubject
    end

    disp('Creating training data from patients');
    for order = 1:length(subs_all)
        TestSubject = subs_all{order};

        % remove patients
        subset = subs_all;
        Remove = {TestSubject};
        ind = find(ismember(subset, Remove));
        subset(ind) = [];
        clear Remove ind

        disp(['Creating training data for Subject ' TestSubject ' in FT_Set [' SetName ']']);

        if ~exist(fullfile(out_dir, [SetName '_' profix]))
           mkdir(fullfile(out_dir, [SetName '_' profix])) 
        end

        Multi = [];
        Score = [];

        % patient vertex
        for s = 1:length(subset)
            sub = subset(s);
            sub = cell2mat(sub);

            %Set h1 to be lesional hemisphere
            if exist(['',sub,'/xhemi/surf_meld/lh.on_lh.lesion.mgh'])
                h1 = 'lh';
                h2 = 'rh';
            elseif exist(['',sub,'/xhemi/surf_meld/rh.on_lh.lesion.mgh'])
                h1 = 'rh';
                h2 = 'lh';
            else
                display(['error with lesion'])
                break
            end
            
            % Get the vertices from the contralateral side of patient
            Normal = zeros(length(Cortex_Normal), NumberOfMeasures);
            for L = 1:NumberOfMeasures
                M = MRIread(['',sub,'/xhemi/surf/',h2,'',Measures{L},'']);
                Normal(:, L) = M.vol(Cortex_Normal)';
                clear M
            end

            % Get the vertices from patient
            Lesion = MRIread(['', sub, '/xhemi/surf_meld/', h1, '.on_lh.lesion' lesion_type '.mgh']);
            [a, Lesion, c] = find(Lesion.vol == 1);
            Lesion = intersect(Lesion, Cortex_lesion);
            
            LesionData = zeros(length(Lesion), NumberOfMeasures);
            for L = 1:NumberOfMeasures
                M = MRIread(['', sub, '/xhemi/surf/', h1, '', Measures{L}, '']);
                LesionData(:, L) = M.vol(Lesion)';
                clear M
            end
            
            % Load all data together as a single matrix
            Combined = cat(1, Normal, LesionData);
            
            % Add Normal and Lesional data to data of all other subjects
            Multi = cat(1, Multi, Combined);

            Binary(1:size(Normal, 1), 1) = 1;
            Binary(size(Normal, 1) + 1:size(Normal, 1) + size(LesionData, 1), 1) = 0;
            Score = cat(1, Score, Binary);
            
            clear Binary Combined Normal Lesion LesionData rand_idx sub
        end

        rand_idx = randi(size(Normal_HC_set, 1), size(Multi, 1), 1);
        
        Multi = cat(1, Multi, Normal_HC_set(rand_idx, :, :));
        Score = cat(1, Score, ones(size(rand_idx, 1), 1));
        Score(:,2) = Score(:,1).*-1+1;

        X_train = Multi;
        Y_train = Score;
    
        if ~exist(fullfile(out_dir, [SetName '_' profix], ['subject_' num2str(order)]))
            mkdir(fullfile(out_dir, [SetName '_' profix], ['subject_' num2str(order)]))
        end

        fid = fopen(fullfile(out_dir, [SetName '_' profix], ['subject_' num2str(order)], [TestSubject lesion_type '.txt']), 'wt');
        fclose(fid);

        clear fid

        save(fullfile(out_dir, [SetName '_' profix], ['subject_' num2str(order)], 'Train_data.mat'), 'X_train', 'Y_train', '-v7.3')
        clear X_train Y_train TestSubject subset
    end
    clear Normal_HC_set Measures NumberOfMeasures SetName Set
end

%% Test Subjects
for SetNumber = 1:length(Sets)
    Set = eval(Sets{SetNumber});
    SetName = Sets{SetNumber};
    
    for order = 1:length(subs_all)
        TestSubject = subs_all{order};
        disp(['Creating testing data for Subject ' TestSubject ' in FT_Set [' SetName ']']);
        
        % Selecting measures
        Measures = All_features(Set);
        NumberOfMeasures = length(Measures);
        
        for hemi = 1:2
            %run on both hemispheres
            if hemi == 1
                h1 = 'lh';
            else
                h1 = 'rh';
            end 

            for L = 1:NumberOfMeasures
                M = MRIread(['', TestSubject, '/xhemi/surf/', h1, '', Measures{L}, '']);
                Normal(:, L) = M.vol(Cortex_lesion)';
                clear M
            end

            eval(['X_test_' h1 ' = Normal;']);    
            
            clear X Normal h1
        end

        if exist(['', TestSubject, '/xhemi/surf_meld/lh.on_lh.lesion.mgh'])
            Lesion_lh = MRIread(['',TestSubject,'/xhemi/surf_meld/','lh','.on_lh.lesion' lesion_type '.mgh']);
            Y_test_lh(:, 2) = Lesion_lh.vol(Cortex_lesion)';
            Y_test_lh(:, 1) = Y_test_lh(:, 2)*-1+1;
            Y_test_rh(:, 1) = ones(size(Y_test_lh(:, 1)));
            Y_test_rh(:, 2) = zeros(size(Y_test_lh(:, 2)));
        else
            Lesion_rh = MRIread(['',TestSubject,'/xhemi/surf_meld/','rh','.on_lh.lesion' lesion_type '.mgh']);
            Y_test_rh(:, 2) = Lesion_rh.vol(Cortex_lesion)';
            Y_test_rh(:, 1) = Y_test_rh(:, 2)*-1+1;
            Y_test_lh(:, 1) = ones(size(Y_test_rh(:, 1)));
            Y_test_lh(:, 2) = zeros(size(Y_test_rh(:, 2)));
        end

        save(fullfile(out_dir, [SetName '_' profix], ['subject_' num2str(order)], 'Test_data.mat'), ...
            'X_test_lh', 'X_test_rh', 'Y_test_lh', 'Y_test_rh', '-v7.3');
        clear Y_test_lh Y_test_rh Lesion_lh Lesion_rh
        clear Measures NumberOfMeasures SetName Set
    end
    clear TestSubject 
end
