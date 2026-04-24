function cluster_characterization_step4(minDistance, min_vtx_area, max_vtx_area, SetName, TrainFcn, Th1Crit, VariableName_ori)

if ~exist(['mD' num2str(minDistance) '_mA' num2str(min_vtx_area) '_' SetName '_' TrainFcn '_DataSet_set_thr_' Th1Crit '_clu_ft.mat'])
    load(['mD' num2str(minDistance) '_mA' num2str(min_vtx_area) '_' SetName '_' TrainFcn '_DataSet_set_thr_' Th1Crit '_clu.mat'])
    Dt_set_thr_clu_summary = [Dt_set_thr_clu{:}];
    target_list = {Dt_set_thr_clu_summary.targetSub};

    % get all the data
    FP_count = 1;
    TP_count = 1;
    for target_idx = 1:length(target_list)
        targetSub = target_list{target_idx};
        lesion_side = Dt_set_thr_clu_summary(target_idx).lesion_side;
        target_pred_cluster_lbl = Dt_set_thr_clu_summary(target_idx).target_pred_cluster_lbl;
        target_pred_surf = Dt_set_thr_clu_summary(target_idx).target_pred_surf;
        target_true_surf = Dt_set_thr_clu_summary(target_idx).target_true_surf;

        load(fullfile('python_ML_dataset_full', SetName, 'Testsubject_PT', [targetSub, '_sm.mat'])); % has X_test_lh X_test_rh Y_test_lh Y_test_rh
        
        if numel(size(X_test_lh)) == 3
            X_test_lh = squeeze(mean(X_test_lh, 2));
            X_test_rh = squeeze(mean(X_test_rh, 2));
        end
        if strcmp(lesion_side, 'lh')
            target_test_ft = [X_test_lh; X_test_rh]';
        elseif strcmp(lesion_side, 'rh')
            target_test_ft = [X_test_rh; X_test_lh]';
        elseif strcmp(lesion_side, 'both')    %%%%% 04/02/2024 rev
            target_test_ft = [X_test_lh; X_test_rh]';  %%%%% 04/02/2024 rev
        end
        clear X_test_lh X_test_rh Y_test_lh Y_test_rh

        target_cluster_ft = target_test_ft(:, find(target_pred_surf));
        target_cluster_lbl = target_pred_cluster_lbl(1, find(target_pred_surf));
        target_cluster_true = target_true_surf(1, find(target_pred_surf));
        target_cluster_pred = target_pred_surf(1, find(target_pred_surf));

        target_cluster_lbl_set = unique(target_cluster_lbl);
        for cluster_order = 1:length(target_cluster_lbl_set)
            target_cluster_ft_per = [length(find(target_cluster_lbl == target_cluster_lbl_set(cluster_order))); ...
                max(target_cluster_ft(:, find(target_cluster_lbl == target_cluster_lbl_set(cluster_order))), [], 2); ...
                std(target_cluster_ft(:, find(target_cluster_lbl == target_cluster_lbl_set(cluster_order))), [], 2); ...
                mean(target_cluster_ft(:, find(target_cluster_lbl == target_cluster_lbl_set(cluster_order))), 2); ...
                prctile(target_cluster_ft(:, find(target_cluster_lbl == target_cluster_lbl_set(cluster_order))), 25, 2); ...
                median(target_cluster_ft(:, find(target_cluster_lbl == target_cluster_lbl_set(cluster_order))), 2); ...
                prctile(target_cluster_ft(:, find(target_cluster_lbl == target_cluster_lbl_set(cluster_order))), 75, 2); ...
                ...
                max(target_cluster_pred(:, find(target_cluster_lbl == target_cluster_lbl_set(cluster_order))), [], 2); ...
                std(target_cluster_pred(:, find(target_cluster_lbl == target_cluster_lbl_set(cluster_order))), [], 2); ...
                mean(target_cluster_pred(:, find(target_cluster_lbl == target_cluster_lbl_set(cluster_order))), 2); ...
                prctile(target_cluster_pred(:, find(target_cluster_lbl == target_cluster_lbl_set(cluster_order))), 25, 2); ...
                median(target_cluster_pred(:, find(target_cluster_lbl == target_cluster_lbl_set(cluster_order))), 2); ...
                prctile(target_cluster_pred(:, find(target_cluster_lbl == target_cluster_lbl_set(cluster_order))), 75, 2); ...
                ];
            if sum(target_cluster_true(find(target_cluster_lbl == target_cluster_lbl_set(cluster_order)))) == 0 % FP cluster
                target_FP_cluster_fts(:, FP_count) = target_cluster_ft_per; %%
                target_FP_cluster_ID(1, FP_count) = target_cluster_lbl_set(cluster_order); %%
                target_FP_cluster_subID{:, FP_count} = targetSub;
                FP_count = FP_count + 1;
            else % TP cluster
                target_TP_cluster_fts(:, TP_count) = target_cluster_ft_per; %%
                target_TP_cluster_ID(1, TP_count) = target_cluster_lbl_set(cluster_order); %%
                target_TP_cluster_subID{:, TP_count} = targetSub;
                TP_count = TP_count + 1;
            end
            clear target_cluster_ft_per
        end

        clear target_test_ft target_cluster_ft target_cluster_lbl target_cluster_true target_cluster_pred target_cluster_lbl_set
        clear targetSub lesion_side target_pred_cluster_lbl target_pred_surf target_true_surf 
    end

    % if no TP cluster for all sub
    if TP_count - 1 == 0
        target_TP_cluster_fts = [];
        target_TP_cluster_ID = [];
        target_TP_cluster_subID = [];
    end

    % if no FP cluster for all sub
    if FP_count - 1 == 0
        target_FP_cluster_fts = [];
        target_FP_cluster_ID = [];
        target_FP_cluster_subID = [];
    end

    % HCs
    Dt_set_thr_clu_ft = Dt_set_thr_clu;
    hcs_FP_cluster_fts = [];
    hcs_FP_cluster_ID = [];
    hcs_FP_cluster_subID = [];
    for target_idx = 1:length(target_list)
        targetSub = target_list{target_idx};
        hcs_target_list = Dt_set_thr_clu_summary(target_idx).hcs_target_list;
        hcs_pred_cluster_lbl = Dt_set_thr_clu_summary(target_idx).hcs_pred_cluster_lbl;
        hcs_pred_surf = Dt_set_thr_clu_summary(target_idx).hcs_pred_surf;
        hcs_true_surf = Dt_set_thr_clu_summary(target_idx).hcs_true_surf;

        hcs_FP_count = 1;
        hcs_FP_cluster_fts_per = [];
        hcs_FP_cluster_ID_per = [];
        hcs_FP_cluster_subID_per = {};
        for hcs_idx = 1:length(hcs_target_list)
            HC_TestSub = hcs_target_list{hcs_idx};
            load(fullfile('python_ML_dataset_full', SetName, 'Testsubject_HC', [HC_TestSub, '_sm_data.mat'])); % has X_test_lh X_test_rh Y_test_lh Y_test_rh
            if numel(size(X_test_lh)) == 3
                X_test_lh = squeeze(mean(X_test_lh, 2));
                X_test_rh = squeeze(mean(X_test_rh, 2));
            end
            
            hcs_test_ft = [X_test_lh; X_test_rh]';

            hcs_cluster_ft = hcs_test_ft(:, find(hcs_pred_surf(hcs_idx, :)));
            hcs_cluster_lbl = hcs_pred_cluster_lbl(hcs_idx, find(hcs_pred_surf(hcs_idx, :)));
            hcs_cluster_true = hcs_true_surf(hcs_idx, find(hcs_pred_surf(hcs_idx, :)));
            hcs_cluster_pred = hcs_pred_surf(hcs_idx, find(hcs_pred_surf(hcs_idx, :)));

            hcs_cluster_lbl_set = unique(hcs_cluster_lbl);
            for cluster_order = 1:length(hcs_cluster_lbl_set)
                hcs_cluster_ft_per = [length(find(hcs_cluster_lbl == hcs_cluster_lbl_set(cluster_order))); ...
                    max(hcs_cluster_ft(:, find(hcs_cluster_lbl == hcs_cluster_lbl_set(cluster_order))), [], 2); ...
                    std(hcs_cluster_ft(:, find(hcs_cluster_lbl == hcs_cluster_lbl_set(cluster_order))), [], 2); ...
                    mean(hcs_cluster_ft(:, find(hcs_cluster_lbl == hcs_cluster_lbl_set(cluster_order))), 2); ...
                    prctile(hcs_cluster_ft(:, find(hcs_cluster_lbl == hcs_cluster_lbl_set(cluster_order))), 25, 2); ...
                    median(hcs_cluster_ft(:, find(hcs_cluster_lbl == hcs_cluster_lbl_set(cluster_order))), 2); ...
                    prctile(hcs_cluster_ft(:, find(hcs_cluster_lbl == hcs_cluster_lbl_set(cluster_order))), 75, 2); ...
                    ...
                    max(hcs_cluster_pred(:, find(hcs_cluster_lbl == hcs_cluster_lbl_set(cluster_order))), [], 2); ...
                    std(hcs_cluster_pred(:, find(hcs_cluster_lbl == hcs_cluster_lbl_set(cluster_order))), [], 2); ...
                    mean(hcs_cluster_pred(:, find(hcs_cluster_lbl == hcs_cluster_lbl_set(cluster_order))), 2); ...
                    prctile(hcs_cluster_pred(:, find(hcs_cluster_lbl == hcs_cluster_lbl_set(cluster_order))), 25, 2); ...
                    median(hcs_cluster_pred(:, find(hcs_cluster_lbl == hcs_cluster_lbl_set(cluster_order))), 2); ...
                    prctile(hcs_cluster_pred(:, find(hcs_cluster_lbl == hcs_cluster_lbl_set(cluster_order))), 75, 2); ...
                    ];

                hcs_FP_cluster_fts_per(:, hcs_FP_count) = hcs_cluster_ft_per; %%
                hcs_FP_cluster_ID_per(1, hcs_FP_count) = hcs_cluster_lbl_set(cluster_order); %%
                hcs_FP_cluster_subID_per{1, hcs_FP_count} = [targetSub '_' HC_TestSub]; %%
                hcs_FP_count = hcs_FP_count + 1;

                clear hcs_cluster_ft_per
            end

            clear HC_TestSub X_test_lh X_test_rh Y_test_lh Y_test_rh hcs_test_ft hcs_cluster_ft hcs_cluster_lbl hcs_cluster_true hcs_cluster_pred hcs_cluster_lbl_set
        end
        if ~isempty(hcs_FP_cluster_fts_per)
            Dt_set_thr_clu_ft{target_idx}.Test_hcs_cluster_fts = hcs_FP_cluster_fts_per;
            Dt_set_thr_clu_ft{target_idx}.Test_hcs_cluster_ID = hcs_FP_cluster_ID_per;
            Dt_set_thr_clu_ft{target_idx}.Test_hcs_cluster_subID = hcs_FP_cluster_subID_per;
            Dt_set_thr_clu_ft{target_idx}.Test_hcs_cluster_lbl = zeros(size(hcs_FP_cluster_subID_per));
        else
            Dt_set_thr_clu_ft{target_idx}.Test_hcs_cluster_fts = [];
            Dt_set_thr_clu_ft{target_idx}.Test_hcs_cluster_ID = [];
            Dt_set_thr_clu_ft{target_idx}.Test_hcs_cluster_subID = [];
            Dt_set_thr_clu_ft{target_idx}.Test_hcs_cluster_lbl = [];
        end

        for hcs_idx = 1:length(hcs_target_list)
            HC_TestSub = hcs_target_list{hcs_idx};
            if ~isempty(find(strcmp(hcs_FP_cluster_subID_per, [targetSub '_' HC_TestSub])))
                hcs_FP_cluster_set(1, hcs_idx) = length(find(strcmp(hcs_FP_cluster_subID_per, [targetSub '_' HC_TestSub])));
            else
                hcs_FP_cluster_set(1, hcs_idx) = 0;
            end
            clear HC_TestSub
        end
        Dt_set_thr_clu_ft{target_idx}.hcs_FP_cluster_AvgNum_pre = mean(hcs_FP_cluster_set);
        Dt_set_thr_clu_ft{target_idx}.hcs_TN_HitOn_percentage_pre = length(find(hcs_FP_cluster_set == 0))/length(hcs_FP_cluster_set);

        clear hcs_FP_cluster_set

        if ~isempty(hcs_FP_cluster_fts_per)
            if length(find(strcmp(target_FP_cluster_subID, targetSub))) ~= 0
                if length(find(strcmp(target_FP_cluster_subID, targetSub))) < size(hcs_FP_cluster_fts_per, 2)
                    rand_4_FP_cluster_idx = randi(size(hcs_FP_cluster_fts_per, 2), length(find(strcmp(target_FP_cluster_subID, targetSub))), 1);

                    hcs_FP_cluster_fts = cat(2, hcs_FP_cluster_fts, hcs_FP_cluster_fts_per(:, rand_4_FP_cluster_idx)); 
                    hcs_FP_cluster_subID = cat(2, hcs_FP_cluster_subID, hcs_FP_cluster_subID_per(rand_4_FP_cluster_idx)); 
                    hcs_FP_cluster_ID = cat(2, hcs_FP_cluster_ID, hcs_FP_cluster_ID_per(rand_4_FP_cluster_idx)); 

                    clear rand_4_FP_cluster_idx
                else
                    hcs_FP_cluster_fts = cat(2, hcs_FP_cluster_fts, hcs_FP_cluster_fts_per);
                    hcs_FP_cluster_subID = cat(2, hcs_FP_cluster_subID, hcs_FP_cluster_subID_per);
                    hcs_FP_cluster_ID = cat(2, hcs_FP_cluster_ID, hcs_FP_cluster_ID_per);
                end
                clear hcs_FP_cluster_fts_per hcs_FP_cluster_ID_per hcs_FP_cluster_subID_per
            end
        end
        clear targetSub hcs_target_list hcs_pred_cluster_lbl hcs_pred_surf hcs_true_surf
    end

    % add HCs into target sub
    if ~isempty(hcs_FP_cluster_fts)
        target_FP_cluster_fts = cat(2, target_FP_cluster_fts, hcs_FP_cluster_fts);
        target_FP_cluster_subID = cat(2, target_FP_cluster_subID, hcs_FP_cluster_subID);
        target_FP_cluster_ID = cat(2, target_FP_cluster_ID, hcs_FP_cluster_ID);
    end
    clear hcs_FP_cluster_fts hcs_FP_cluster_subID hcs_FP_cluster_ID

    % Seperate the train data for each subs 
    for target_idx = 1:length(target_list)
        targetSub = target_list{target_idx};
        
        % FP clusters of target sub
        if ~isempty(find(strcmp(target_FP_cluster_subID, targetSub))) 
            target_FP_cluster_idx = find(strcmp(target_FP_cluster_subID, targetSub));
            Train_target_FP_cluster_fts = target_FP_cluster_fts;
            Train_target_FP_cluster_fts(:, target_FP_cluster_idx) = []; 
            Test_target_FP_cluster_fts = target_FP_cluster_fts(:, target_FP_cluster_idx); 
            Test_target_FP_cluster_ID = target_FP_cluster_ID(:, target_FP_cluster_idx); 
            target_FP_cluster_num_pre = length(target_FP_cluster_idx); 
        else
            target_FP_cluster_num_pre = 0;
            Train_target_FP_cluster_fts = target_FP_cluster_fts;
            Test_target_FP_cluster_fts = [];
            Test_target_FP_cluster_ID = [];
        end

        % TP clusters of target sub
        if ~isempty(find(strcmp(target_TP_cluster_subID, targetSub))) 
            target_TP_cluster_idx = find(strcmp(target_TP_cluster_subID, targetSub));
            Train_target_TP_cluster_fts = target_TP_cluster_fts;
            Train_target_TP_cluster_fts(:, target_TP_cluster_idx) = []; 
            Test_target_TP_cluster_fts = target_TP_cluster_fts(:, target_TP_cluster_idx); 
            Test_target_TP_cluster_ID = target_TP_cluster_ID(:, target_TP_cluster_idx); 
            target_TP_cluster_HitOn_pre = 1; 
        else % if no TP cluster
            target_TP_cluster_HitOn_pre = 0;
            Train_target_TP_cluster_fts = target_TP_cluster_fts;
            Test_target_TP_cluster_fts = [];
            Test_target_TP_cluster_ID = [];
        end

        % combine FP and TP 
        Train_target_cluster_fts = [Train_target_FP_cluster_fts, Train_target_TP_cluster_fts];
        Train_target_cluster_lbl = [zeros([1, size(Train_target_FP_cluster_fts, 2)]), ones([1, size(Train_target_TP_cluster_fts, 2)])];
        Test_target_cluster_fts = [Test_target_FP_cluster_fts, Test_target_TP_cluster_fts];
        Test_target_cluster_lbl = [zeros([1, size(Test_target_FP_cluster_fts, 2)]), ones([1, size(Test_target_TP_cluster_fts, 2)])];
        Test_target_cluster_ID = [Test_target_FP_cluster_ID, Test_target_TP_cluster_ID];

        Dt_set_thr_clu_ft{target_idx}.VariableName = VariableName_ori;
        Dt_set_thr_clu_ft{target_idx}.Train_target_cluster_fts = Train_target_cluster_fts;
        Dt_set_thr_clu_ft{target_idx}.Train_target_cluster_lbl = Train_target_cluster_lbl;
        Dt_set_thr_clu_ft{target_idx}.Test_target_cluster_fts = Test_target_cluster_fts;
        Dt_set_thr_clu_ft{target_idx}.Test_target_cluster_lbl = Test_target_cluster_lbl;
        Dt_set_thr_clu_ft{target_idx}.Test_target_cluster_ID = Test_target_cluster_ID;

        Dt_set_thr_clu_ft{target_idx}.target_FP_cluster_num_pre = target_FP_cluster_num_pre;
        Dt_set_thr_clu_ft{target_idx}.target_TP_cluster_HitOn_pre = target_TP_cluster_HitOn_pre;

        clear Train_target_FP_cluster_fts Train_target_TP_cluster_fts Test_target_FP_cluster_fts Test_target_TP_cluster_fts Test_target_FP_cluster_ID Test_target_TP_cluster_ID
        clear Train_target_cluster_fts Train_target_cluster_lbl Test_target_cluster_fts Test_target_cluster_lbl Test_target_cluster_ID
    end
    
    save(['mD' num2str(minDistance) '_mA' num2str(min_vtx_area) '_' SetName '_' TrainFcn '_DataSet_set_thr_' Th1Crit '_clu_ft.mat'], 'Dt_set_thr_clu_ft', '-v7.3')%%%%%%%%%%%%%%%2025/4/15
    clear target_FP_cluster_fts target_FP_cluster_ID target_FP_cluster_subID target_TP_cluster_fts target_TP_cluster_ID target_TP_cluster_subID
    clear Dt_set_thr_clu Dt_set_thr_clu_summary target_list FP_count TP_count Dt_set_thr_clu_ft
end