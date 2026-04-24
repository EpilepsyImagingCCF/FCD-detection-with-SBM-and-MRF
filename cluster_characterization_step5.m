function cluster_characterization_step5(minDistance, min_vtx_area, max_vtx_area, SetName, TrainFcn, Th1Crit, threshold2)

if ~exist(['mD' num2str(minDistance) '_mA' num2str(min_vtx_area) '_' SetName '_' TrainFcn '_DataSet_set_thr_' Th1Crit '_clu_ft_clxTh2' num2str(threshold2) '_lr2.mat'])
    load(['mD' num2str(minDistance) '_mA' num2str(min_vtx_area) '_' SetName '_' TrainFcn '_DataSet_set_thr_' Th1Crit '_clu_ft.mat'])
   
    Dt_set_thr_clu_ft_summary = [Dt_set_thr_clu_ft{:}];
    Dt_set_thr_clu_ft_clx = Dt_set_thr_clu_ft;
    target_list = {Dt_set_thr_clu_ft_summary.targetSub};

    for target_idx = 1:length(target_list)
        targetSub = target_list{target_idx};
        lesion_side = Dt_set_thr_clu_ft_summary(target_idx).lesion_side;

        hcs_target_list = Dt_set_thr_clu_ft_summary(target_idx).hcs_target_list;

        Train_target_cluster_fts = Dt_set_thr_clu_ft_summary(target_idx).Train_target_cluster_fts';
        Train_target_cluster_lbl = Dt_set_thr_clu_ft_summary(target_idx).Train_target_cluster_lbl';
        Test_target_cluster_fts = Dt_set_thr_clu_ft_summary(target_idx).Test_target_cluster_fts';
        Test_target_cluster_lbl = Dt_set_thr_clu_ft_summary(target_idx).Test_target_cluster_lbl';
        Test_target_cluster_ID = Dt_set_thr_clu_ft_summary(target_idx).Test_target_cluster_ID';

        Test_hcs_cluster_fts = Dt_set_thr_clu_ft_summary(target_idx).Test_hcs_cluster_fts';
        Test_hcs_cluster_ID = Dt_set_thr_clu_ft_summary(target_idx).Test_hcs_cluster_ID';
        Test_hcs_cluster_subID = Dt_set_thr_clu_ft_summary(target_idx).Test_hcs_cluster_subID';
        Test_hcs_cluster_lbl = Dt_set_thr_clu_ft_summary(target_idx).Test_hcs_cluster_lbl';

        rng('default');
        t = templateTree('MaxNumSplits', size(Train_target_cluster_fts, 1));

        % RUSBoost classifier training and target sub predictoin
        if sum(Train_target_cluster_lbl) ~= 0 
            rusTree = fitcensemble(Train_target_cluster_fts, Train_target_cluster_lbl, 'Method', 'RUSBoost', 'NumLearningCycles', 1000, 'Learners', t,'LearnRate', 0.01, 'nprint', 100);
                
            [imp_per, ~] = predictorImportance(rusTree);
            if ~isempty(imp_per)
                imp(target_idx, :) = imp_per;
            else
                imp(target_idx, :) = zeros([1, size(Train_target_cluster_fts, 2)]);
            end

            if ~isempty(Test_target_cluster_fts)
                [~, scores] = predict(rusTree, Test_target_cluster_fts);
                Pred_target_cluster_lbl = double(scores(:, 2)./sum(scores, 2) > threshold2); 
                Prob_target_cluster_lbl = scores(:, 2)./sum(scores, 2); 
                clear scores
            else
                Pred_target_cluster_lbl = []; 
                Prob_target_cluster_lbl = []; 
            end
            RusTree_Training_flag = 1;
        else
            Pred_target_cluster_lbl = zeros(size(Test_target_cluster_lbl)); 
            Prob_target_cluster_lbl = zeros(size(Test_target_cluster_lbl));
            RusTree_Training_flag = 0;
        end
        Dt_set_thr_clu_ft_clx{target_idx}.Pred_target_cluster_lbl = Pred_target_cluster_lbl;
        Dt_set_thr_clu_ft_clx{target_idx}.Prob_target_cluster_lbl = Prob_target_cluster_lbl;

        % Cluster-wise performance evaluation of target sub
        Dt_set_thr_clu_ft_clx{target_idx}.target_FP_cluster_num_post = sum(Pred_target_cluster_lbl(find(~Test_target_cluster_lbl)));
        if ~isempty(find(Test_target_cluster_lbl))
            Dt_set_thr_clu_ft_clx{target_idx}.target_TP_cluster_HitOn_post = max(Pred_target_cluster_lbl(find(Test_target_cluster_lbl)));
        else
            Dt_set_thr_clu_ft_clx{target_idx}.target_TP_cluster_HitOn_post = 0;
        end

        % Hcs prediction
        Pred_hcs_cluster_lbl = zeros(size(Test_hcs_cluster_lbl));
        Prob_hcs_cluster_lbl = zeros(size(Test_hcs_cluster_lbl));
        for hcs_idx = 1:length(hcs_target_list)
            HC_TestSub = [targetSub '_' hcs_target_list{hcs_idx}];
            if RusTree_Training_flag == 1
                if ~isempty(find(strcmp(Test_hcs_cluster_subID, HC_TestSub)))
                    [~, scores] = predict(rusTree, Test_hcs_cluster_fts(find(strcmp(Test_hcs_cluster_subID, HC_TestSub)), :));

                    Pred_hcs_cluster_lbl_perHC{hcs_idx, 1} = double(scores(:, 2)./sum(scores, 2) > threshold2);
                    Pred_hcs_cluster_lbl(find(strcmp(Test_hcs_cluster_subID, HC_TestSub))) = double(scores(:, 2)./sum(scores, 2) > threshold2); 
                    Prob_hcs_cluster_lbl(find(strcmp(Test_hcs_cluster_subID, HC_TestSub))) = scores(:, 2)./sum(scores, 2);
                    clear scores
                else
                    Pred_hcs_cluster_lbl_perHC{hcs_idx, 1} = [];
                end
            else
                if ~isempty(find(strcmp(Test_hcs_cluster_subID, HC_TestSub)))
                    Pred_hcs_cluster_lbl_perHC{hcs_idx, 1} = zeros(size(Test_hcs_cluster_ID(find(strcmp(Test_hcs_cluster_subID, HC_TestSub))))); 
                    Pred_hcs_cluster_lbl(find(strcmp(Test_hcs_cluster_subID, HC_TestSub))) = zeros(size(Test_hcs_cluster_ID(find(strcmp(Test_hcs_cluster_subID, HC_TestSub))))); 
                    Prob_hcs_cluster_lbl(find(strcmp(Test_hcs_cluster_subID, HC_TestSub))) = zeros(size(Test_hcs_cluster_ID(find(strcmp(Test_hcs_cluster_subID, HC_TestSub))))); 
                else
                    Pred_hcs_cluster_lbl_perHC{hcs_idx, 1} = [];
                end
            end
            clear HC_TestSub
        end
        Dt_set_thr_clu_ft_clx{target_idx}.Pred_hcs_cluster_lbl = Pred_hcs_cluster_lbl;
        Dt_set_thr_clu_ft_clx{target_idx}.Prob_hcs_cluster_lbl = Prob_hcs_cluster_lbl;

        % Cluster-wise performance evaluation of hcs sub
        for hcs_idx = 1:length(Pred_hcs_cluster_lbl_perHC)
            if sum(Pred_hcs_cluster_lbl_perHC{hcs_idx}) == 0
                hcs_TN_HitOn_post(1, hcs_idx) = 1;
                hcs_FP_cluster_num(1, hcs_idx) = 0;
            else
                hcs_TN_HitOn_post(1, hcs_idx) = 0;
                hcs_FP_cluster_num(1, hcs_idx) = sum(Pred_hcs_cluster_lbl_perHC{hcs_idx});
            end
        end
        Dt_set_thr_clu_ft_clx{target_idx}.hcs_FP_cluster_AvgNum_post = mean(hcs_FP_cluster_num);
        Dt_set_thr_clu_ft_clx{target_idx}.hcs_TN_HitOn_percentage_post = length(find(hcs_TN_HitOn_post))/length(hcs_TN_HitOn_post);

        clear Pred_hcs_cluster_lbl Prob_hcs_cluster_lbl Pred_hcs_cluster_lbl_perHC hcs_TN_HitOn_post hcs_FP_cluster_num
        clear Test_hcs_cluster_fts Test_hcs_cluster_ID Test_hcs_cluster_subID Test_hcs_cluster_lbl t rusTree Pred_target_cluster_lbl Prob_target_cluster_lbl RusTree_Training_flag
        clear targetSub lesion_side hcs_target_list Train_target_cluster_fts Train_target_cluster_lbl Test_target_cluster_fts Test_target_cluster_lbl Test_target_cluster_ID
    end
    save(['mD' num2str(minDistance) '_mA' num2str(min_vtx_area) '_' SetName '_' TrainFcn '_DataSet_set_thr_' Th1Crit '_clu_ft_clxTh2' num2str(threshold2) '_lr2.mat'], 'Dt_set_thr_clu_ft_clx', '-v7.3')
    clear target_list Dt_set_thr_clu_ft_summary Dt_set_thr_clu_ft Dt_set_thr_clu_ft_clx
end