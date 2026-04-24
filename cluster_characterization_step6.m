function cluster_characterization_step6(minDistance, min_vtx_area, max_vtx_area, SetName, TrainFcn, Th1Crit, threshold2, out_dir)

if ~exist(['mD' num2str(minDistance) '_mA' num2str(min_vtx_area) '_' SetName '_' TrainFcn '_DataSet_set_thr_' Th1Crit '_clu_ft_clxTh2' num2str(threshold2) '_lr2_result_eva.mat']) 
    global subjects_dir 
    Measure = '.Z_by_controls.thickness_z_on_lh.sm10.mgh';

    load(['mD' num2str(minDistance) '_mA' num2str(min_vtx_area) '_' SetName '_' TrainFcn '_DataSet_set_thr_' Th1Crit '_clu_ft_clxTh2' num2str(threshold2) '_lr2.mat'])
    Dt_set_thr_clu_ft_clx_summary = [Dt_set_thr_clu_ft_clx{:}];
    target_list = {Dt_set_thr_clu_ft_clx_summary.targetSub};

    vis_dir = ['FreeVis' '_mD' num2str(minDistance) '_mA' num2str(min_vtx_area) '_' SetName '_' TrainFcn '_thr_' Th1Crit '_clu_ft_clxTh2_' num2str(threshold2) '_lr2'];

    for target_idx = 1:length(target_list)
        targetSub = target_list{target_idx};
        M = MRIread(fullfile(subjects_dir, targetSub, 'xhemi', 'surf', ['lh' Measure]));
        lesion_side = Dt_set_thr_clu_ft_clx_summary(target_idx).lesion_side;
    
        if ~exist(fullfile(out_dir, vis_dir, targetSub))
            mkdir(fullfile(out_dir, vis_dir, targetSub))
        end
    
        Test_target_cluster_lbl = Dt_set_thr_clu_ft_clx_summary(target_idx).Test_target_cluster_lbl';
        Test_target_cluster_ID = Dt_set_thr_clu_ft_clx_summary(target_idx).Test_target_cluster_ID';
        Pred_target_cluster_lbl = Dt_set_thr_clu_ft_clx_summary(target_idx).Pred_target_cluster_lbl;
        Prob_target_cluster_lbl = Dt_set_thr_clu_ft_clx_summary(target_idx).Prob_target_cluster_lbl;
    
        target_pred_surf = Dt_set_thr_clu_ft_clx_summary(target_idx).target_pred_surf;
        target_pred_surf_H1 = target_pred_surf(1:length(target_pred_surf)/2);%
        target_pred_surf_H2 = target_pred_surf(1 + length(target_pred_surf)/2:end);%
    
        target_true_surf = Dt_set_thr_clu_ft_clx_summary(target_idx).target_true_surf;
        target_true_surf_H1 = target_true_surf(1:length(target_true_surf)/2);%
        target_true_surf_H2 = target_true_surf(1 + length(target_true_surf)/2:end);%
    
        target_pred_cluster_lbl = Dt_set_thr_clu_ft_clx_summary(target_idx).target_pred_cluster_lbl;
        target_pred_H1_cluster_lbl = target_pred_cluster_lbl(1:length(target_pred_cluster_lbl)/2);%
        target_pred_H2_cluster_lbl = target_pred_cluster_lbl(1 + length(target_pred_cluster_lbl)/2:end);%
    
        pred_lbl_post = Test_target_cluster_ID(find(Pred_target_cluster_lbl));
        prob_lbl_post = Prob_target_cluster_lbl(find(Pred_target_cluster_lbl));
    
        target_pred_H1_cluster_lbl_post = zeros(size(target_pred_H1_cluster_lbl));
        target_pred_H2_cluster_lbl_post = zeros(size(target_pred_H2_cluster_lbl));
    
        target_prob_H1_cluster_lbl_post = zeros(size(target_pred_H1_cluster_lbl));
        target_prob_H2_cluster_lbl_post = zeros(size(target_pred_H2_cluster_lbl)); 
    
        for lbl_idx = 1:length(pred_lbl_post)
            if ~isempty(find(target_pred_H1_cluster_lbl == pred_lbl_post(lbl_idx)))
                target_pred_H1_cluster_lbl_post(find(target_pred_H1_cluster_lbl == pred_lbl_post(lbl_idx))) =  pred_lbl_post(lbl_idx);
                target_prob_H1_cluster_lbl_post(find(target_pred_H1_cluster_lbl == pred_lbl_post(lbl_idx))) =  prob_lbl_post(lbl_idx); 
            elseif ~isempty(find(target_pred_H2_cluster_lbl == pred_lbl_post(lbl_idx)))
                target_pred_H2_cluster_lbl_post(find(target_pred_H2_cluster_lbl == pred_lbl_post(lbl_idx))) =  pred_lbl_post(lbl_idx);
                target_prob_H2_cluster_lbl_post(find(target_pred_H2_cluster_lbl == pred_lbl_post(lbl_idx))) =  prob_lbl_post(lbl_idx); 
            end
        end
    
        if sum(strcmp(lesion_side, {'lh', 'both'})) > 0 %%%%%% 04/02/2024 rev
            h1 = 'lh';
            h2 = 'rh';
            MRIwrite_cmd(M, target_pred_H1_cluster_lbl, target_pred_H2_cluster_lbl, fullfile(out_dir, vis_dir, targetSub), [targetSub '_pred_pre']);
            MRIwrite_cmd(M, target_true_surf_H1, target_true_surf_H2, fullfile(out_dir, vis_dir, targetSub), [targetSub '_true']);
            MRIwrite_cmd(M, target_pred_surf_H1, target_pred_surf_H2, fullfile(out_dir, vis_dir, targetSub), [targetSub '_prob_pre']); 
            
            MRIwrite_cmd(M, target_pred_H1_cluster_lbl_post, target_pred_H2_cluster_lbl_post, fullfile(out_dir, vis_dir, targetSub), [targetSub '_pred_post']);  
            MRIwrite_cmd(M, target_prob_H1_cluster_lbl_post, target_prob_H2_cluster_lbl_post, fullfile(out_dir, vis_dir, targetSub), [targetSub '_prob_post']); 
        else
            h1 = 'rh';
            h2 = 'lh';
            MRIwrite_cmd(M, target_pred_H2_cluster_lbl, target_pred_H1_cluster_lbl, fullfile(out_dir, vis_dir, targetSub), [targetSub '_pred_pre']);
            MRIwrite_cmd(M, target_true_surf_H2, target_true_surf_H1, fullfile(out_dir, vis_dir, targetSub), [targetSub '_true']); 
            MRIwrite_cmd(M, target_pred_surf_H2, target_pred_surf_H1, fullfile(out_dir, vis_dir, targetSub), [targetSub '_prob_pre']); 
    
            MRIwrite_cmd(M, target_pred_H2_cluster_lbl_post, target_pred_H1_cluster_lbl_post, fullfile(out_dir, vis_dir, targetSub), [targetSub '_pred_post']);  
            MRIwrite_cmd(M, target_prob_H2_cluster_lbl_post, target_prob_H1_cluster_lbl_post, fullfile(out_dir, vis_dir, targetSub), [targetSub '_prob_post']);  
        end
    
        Dt_result_eva{target_idx}.TargetSub = targetSub; 
        Dt_result_eva{target_idx}.lesion_side = lesion_side; 
    
        cluste_lbl_H1_post = unique(target_pred_H1_cluster_lbl_post);
        cluste_lbl_H1_post(find(ismember(cluste_lbl_H1_post, 0))) = [];
        meanProb_H1_post = zeros([length(cluste_lbl_H1_post), 1]);
        medianProb_H1_post = zeros([length(cluste_lbl_H1_post), 1]);
        clusterSZ_H1_post = zeros([length(cluste_lbl_H1_post), 1]);
        TP_w_sm_H1_post = zeros([length(cluste_lbl_H1_post), 1]);

        for cluster_lbl_order = 1:length(cluste_lbl_H1_post)
            meanProb_H1_post(cluster_lbl_order, 1) = mean(target_prob_H1_cluster_lbl_post(find(target_pred_H1_cluster_lbl_post == cluste_lbl_H1_post(cluster_lbl_order))));
            medianProb_H1_post(cluster_lbl_order, 1) = median(target_prob_H1_cluster_lbl_post(find(target_pred_H1_cluster_lbl_post == cluste_lbl_H1_post(cluster_lbl_order))));
            clusterSZ_H1_post(cluster_lbl_order, 1) = length(find(target_pred_H1_cluster_lbl_post == cluste_lbl_H1_post(cluster_lbl_order)));
            if sum(target_true_surf_H1(find(target_pred_H1_cluster_lbl_post == cluste_lbl_H1_post(cluster_lbl_order)))) ~= 0
                TP_w_sm_H1_post(cluster_lbl_order, 1) = 1;
            else
                TP_w_sm_H1_post(cluster_lbl_order, 1) = 0;
            end
        end
        cluste_lbl_H2_post = unique(target_pred_H2_cluster_lbl_post);
        cluste_lbl_H2_post(find(ismember(cluste_lbl_H2_post, 0))) = [];
        meanProb_H2_post = zeros([length(cluste_lbl_H2_post), 1]);
        medianProb_H2_post = zeros([length(cluste_lbl_H2_post), 1]);
        clusterSZ_H2_post = zeros([length(cluste_lbl_H2_post), 1]);
        TP_w_sm_H2_post = zeros([length(cluste_lbl_H2_post), 1]);

        for cluster_lbl_order = 1:length(cluste_lbl_H2_post)
            meanProb_H2_post(cluster_lbl_order, 1) = mean(target_prob_H2_cluster_lbl_post(find(target_pred_H2_cluster_lbl_post == cluste_lbl_H2_post(cluster_lbl_order))));
            medianProb_H2_post(cluster_lbl_order, 1) = median(target_prob_H2_cluster_lbl_post(find(target_pred_H2_cluster_lbl_post == cluste_lbl_H2_post(cluster_lbl_order))));
            clusterSZ_H2_post(cluster_lbl_order, 1) = length(find(target_pred_H2_cluster_lbl_post == cluste_lbl_H2_post(cluster_lbl_order)));
            if sum(target_true_surf_H2(find(target_pred_H2_cluster_lbl_post == cluste_lbl_H2_post(cluster_lbl_order)))) ~= 0
                TP_w_sm_H2_post(cluster_lbl_order, 1) = 1;
            else
                TP_w_sm_H2_post(cluster_lbl_order, 1) = 0;
            end
        end
        Dt_result_eva{target_idx}.post_cluster_ID_Bi = [cluste_lbl_H1_post, cluste_lbl_H2_post]; 
        Dt_result_eva{target_idx}.post_cluster_ID_H1 = [cluste_lbl_H1_post];
        Dt_result_eva{target_idx}.post_cluster_ID_H2 = [cluste_lbl_H2_post];
        Dt_result_eva{target_idx}.post_meanProb_Bi = [meanProb_H1_post', meanProb_H2_post']; 
        Dt_result_eva{target_idx}.post_meanProb_H1 = [meanProb_H1_post'];
        Dt_result_eva{target_idx}.post_meanProb_H2 = [meanProb_H2_post'];
        Dt_result_eva{target_idx}.post_medianProb_Bi = [medianProb_H1_post', medianProb_H2_post'];
        Dt_result_eva{target_idx}.post_medianProb_H1 = [medianProb_H1_post'];
        Dt_result_eva{target_idx}.post_medianProb_H2 = [medianProb_H2_post'];
        Dt_result_eva{target_idx}.post_clusterSZ_Bi = [clusterSZ_H1_post', clusterSZ_H2_post']; 
        Dt_result_eva{target_idx}.post_clusterSZ_H1 = [clusterSZ_H1_post'];
        Dt_result_eva{target_idx}.post_clusterSZ_H2 = [clusterSZ_H2_post'];
        Dt_result_eva{target_idx}.post_TP_w_sm_Bi = [TP_w_sm_H1_post', TP_w_sm_H2_post']; 
        Dt_result_eva{target_idx}.post_TP_w_sm_H1 = [TP_w_sm_H1_post'];
        Dt_result_eva{target_idx}.post_TP_w_sm_H2 = [TP_w_sm_H2_post'];
    
        cluste_lbl_H1_pre = unique(target_pred_H1_cluster_lbl);
        cluste_lbl_H1_pre(find(ismember(cluste_lbl_H1_pre, 0))) = [];
        meanProb_H1_pre = zeros([length(cluste_lbl_H1_pre), 1]);
        medianProb_H1_pre = zeros([length(cluste_lbl_H1_pre), 1]);
        clusterSZ_H1_pre = zeros([length(cluste_lbl_H1_pre), 1]);
        TP_w_sm_H1_pre = zeros([length(cluste_lbl_H1_pre), 1]);

        for cluster_lbl_order = 1:length(cluste_lbl_H1_pre)
            meanProb_H1_pre(cluster_lbl_order, 1) = mean(target_pred_surf_H1(find(target_pred_H1_cluster_lbl == cluste_lbl_H1_pre(cluster_lbl_order))));
            medianProb_H1_pre(cluster_lbl_order, 1) = median(target_pred_surf_H1(find(target_pred_H1_cluster_lbl == cluste_lbl_H1_pre(cluster_lbl_order))));
            clusterSZ_H1_pre(cluster_lbl_order, 1) = length(find(target_pred_H1_cluster_lbl == cluste_lbl_H1_pre(cluster_lbl_order)));
            if sum(target_true_surf_H1(find(target_pred_H1_cluster_lbl == cluste_lbl_H1_pre(cluster_lbl_order)))) ~= 0
                TP_w_sm_H1_pre(cluster_lbl_order, 1) = 1;
            else
                TP_w_sm_H1_pre(cluster_lbl_order, 1) = 0;
            end
        end
        cluste_lbl_H2_pre = unique(target_pred_H2_cluster_lbl);
        cluste_lbl_H2_pre(find(ismember(cluste_lbl_H2_pre, 0))) = [];
        meanProb_H2_pre = zeros([length(cluste_lbl_H2_pre), 1]);
        medianProb_H2_pre = zeros([length(cluste_lbl_H2_pre), 1]);
        clusterSZ_H2_pre = zeros([length(cluste_lbl_H2_pre), 1]);
        TP_w_sm_H2_pre = zeros([length(cluste_lbl_H2_pre), 1]);

        for cluster_lbl_order = 1:length(cluste_lbl_H2_pre)
            meanProb_H2_pre(cluster_lbl_order, 1) = mean(target_pred_surf_H2(find(target_pred_H2_cluster_lbl == cluste_lbl_H2_pre(cluster_lbl_order))));
            medianProb_H2_pre(cluster_lbl_order, 1) = median(target_pred_surf_H2(find(target_pred_H2_cluster_lbl == cluste_lbl_H2_pre(cluster_lbl_order))));
            clusterSZ_H2_pre(cluster_lbl_order, 1) = length(find(target_pred_H2_cluster_lbl == cluste_lbl_H2_pre(cluster_lbl_order)));
            if sum(target_true_surf_H2(find(target_pred_H2_cluster_lbl == cluste_lbl_H2_pre(cluster_lbl_order)))) ~= 0
                TP_w_sm_H2_pre(cluster_lbl_order, 1) = 1;
            else
                TP_w_sm_H2_pre(cluster_lbl_order, 1) = 0;
            end
        end
        
        Dt_result_eva{target_idx}.pre_cluster_ID_Bi = [cluste_lbl_H1_pre, cluste_lbl_H2_pre]; 
        Dt_result_eva{target_idx}.pre_cluster_ID_H1 = [cluste_lbl_H1_pre];
        Dt_result_eva{target_idx}.pre_cluster_ID_H2 = [cluste_lbl_H2_pre];
        Dt_result_eva{target_idx}.pre_meanProb_Bi = [meanProb_H1_pre', meanProb_H2_pre']; 
        Dt_result_eva{target_idx}.pre_meanProb_H1 = [meanProb_H1_pre'];
        Dt_result_eva{target_idx}.pre_meanProb_H2 = [meanProb_H2_pre'];
        Dt_result_eva{target_idx}.pre_medianProb_Bi = [medianProb_H1_pre', medianProb_H2_pre']; 
        Dt_result_eva{target_idx}.pre_medianProb_H1 = [medianProb_H1_pre'];
        Dt_result_eva{target_idx}.pre_medianProb_H2 = [medianProb_H2_pre'];
        Dt_result_eva{target_idx}.pre_clusterSZ_Bi = [clusterSZ_H1_pre', clusterSZ_H2_pre']; 
        Dt_result_eva{target_idx}.pre_clusterSZ_H1 = [clusterSZ_H1_pre'];
        Dt_result_eva{target_idx}.pre_clusterSZ_H2 = [clusterSZ_H2_pre'];
        Dt_result_eva{target_idx}.pre_TP_w_sm_Bi = [TP_w_sm_H1_pre', TP_w_sm_H2_pre']; 
        Dt_result_eva{target_idx}.pre_TP_w_sm_H1 = [TP_w_sm_H1_pre'];
        Dt_result_eva{target_idx}.pre_TP_w_sm_H2 = [TP_w_sm_H2_pre'];
    
        clear cluste_lbl_H1_post cluste_lbl_H2_post cluste_lbl_H1_pre cluste_lbl_H2_pre meanProb_H1_pre meanProb_H2_pre
        clear medianProb_H1_pre medianProb_H2_pre clusterSZ_H1_pre clusterSZ_H2_pre TP_w_sm_H1_pre TP_w_sm_H2_pre
        clear meanProb_H1_post meanProb_H2_post medianProb_H1_post medianProb_H2_post 
        clear clusterSZ_H1_post clusterSZ_H2_post TP_w_sm_H1_post TP_w_sm_H2_post 
    
        fileID = fopen(fullfile(out_dir, vis_dir, targetSub, ['script_' targetSub '.txt']), 'w');
    
        if sum(strcmp(targetSub, {'P83_14516', 'P110_16132'})) == 0
            fprintf(fileID, ['freeview -f ../freesurfer_MELD/fsaverage_sym/surf/' 'lh' '.pial' ...
                ':overlay=python_ML_dataset_full/' vis_dir '/' targetSub '/' h1 '_' targetSub '_true.mgh' ...
                ':overlay=python_ML_dataset_full/' vis_dir '/' targetSub '/' h1 '_' targetSub '_pred_pre.mgh' ...
                ':overlay=python_ML_dataset_full/' vis_dir '/' targetSub '/' h1 '_' targetSub '_pred_post.mgh' ...
                '\n\n'...
                'freeview -f ../freesurfer_MELD/fsaverage_sym/surf/' 'lh' '.pial' ...
                ':overlay=python_ML_dataset_full/' vis_dir '/' targetSub '/' h2 '_' targetSub '_true.mgh' ...
                ':overlay=python_ML_dataset_full/' vis_dir '/' targetSub '/' h2 '_' targetSub '_pred_pre.mgh' ...
                ':overlay=python_ML_dataset_full/' vis_dir '/' targetSub '/' h2 '_' targetSub '_pred_post.mgh' ...
                ]);
        else
            fprintf(fileID, ['freeview -f ../freesurfer_MELD/fsaverage_sym/surf/' 'lh' '.pial' ...
                ':overlay=python_ML_dataset_full/' vis_dir '/' targetSub '/' h1 '_' targetSub '_true.mgh' ...
                ':overlay=python_ML_dataset_full/' vis_dir '/' targetSub '/' h1 '_' targetSub '_pred_pre.mgh' ...
                ':overlay=python_ML_dataset_full/' vis_dir '/' targetSub '/' h1 '_' targetSub '_pred_post.mgh' ...
                '\n\n'...
                'freeview -f ../freesurfer_MELD/fsaverage_sym/surf/' 'lh' '.pial' ...
                ':overlay=python_ML_dataset_full/' vis_dir '/' targetSub '/' h2 '_' targetSub '_true.mgh' ...
                ':overlay=python_ML_dataset_full/' vis_dir '/' targetSub '/' h2 '_' targetSub '_pred_pre.mgh' ...
                ':overlay=python_ML_dataset_full/' vis_dir '/' targetSub '/' h2 '_' targetSub '_pred_post.mgh' ...
                ]);
        end
        fclose(fileID);
        %setenv('PATH', ['/usr/bin:/bin:/usr/sbin:/sbin:', '/Users/irene/opt/anaconda3/bin:/Users/irene/opt/anaconda3/condabin:/opt/ANTs/bin:/Applications/freesurfer/7.2.0/bin:/Applications/freesurfer/7.2.0/fsfast/bin:/Users/irene/fsl/bin:/Users/irene/fsl/share/fsl/bin:/Applications/freesurfer/7.2.0/mni/bin:/Users/irene/fsl/share/fsl/bin:/Users/irene/fsl/share/fsl/bin:/Library/Frameworks/Python.framework/Versions/2.7/bin:/Library/Frameworks/Python.framework/Versions/3.10/bin:/usr/local/bin:/System/Cryptexes/App/usr/bin:/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/MacGPG2/bin:/opt/X11/bin:/Volumes/eegrvw/Imaging/Multimodal/UCSD:/Volumes/eegrvw/Imaging/Multimodal/UCSD/functions:/opt/ANTs/bin:/Library/Frameworks/R.framework/Resources:/usr/local/gfortran/bin:/usr/local/opt/python/libexec/bin:/Users/irene/abin'])
        %setenv('FREESURFER_HOME', '/Applications/freesurfer/7.2.0')
        %system(['sh surf2vol_sub.sh ' vis_dir ' ' targetSub])
        clear pred_lbl_post h1 h2 fileID prob_lbl_post target_prob_H1_cluster_lbl_post target_prob_H2_cluster_lbl_post
    
        % for HCs 
        % H1 for lh; H2 for rh
        hcs_target_list = Dt_set_thr_clu_ft_clx_summary(target_idx).hcs_target_list;
    
        Test_hcs_cluster_ID = Dt_set_thr_clu_ft_clx_summary(target_idx).Test_hcs_cluster_ID';
        Test_hcs_cluster_subID = Dt_set_thr_clu_ft_clx_summary(target_idx).Test_hcs_cluster_subID';
        Test_hcs_cluster_lbl = Dt_set_thr_clu_ft_clx_summary(target_idx).Test_hcs_cluster_lbl';
        Pred_hcs_cluster_lbl = Dt_set_thr_clu_ft_clx_summary(target_idx).Pred_hcs_cluster_lbl;
        Prob_hcs_cluster_lbl = Dt_set_thr_clu_ft_clx_summary(target_idx).Prob_hcs_cluster_lbl; %%%%% 04/02/2024 rev
    
        hcs_pred_surf = Dt_set_thr_clu_ft_clx_summary(target_idx).hcs_pred_surf;
        hcs_pred_cluster_lbl = Dt_set_thr_clu_ft_clx_summary(target_idx).hcs_pred_cluster_lbl;
        hcs_true_surf = Dt_set_thr_clu_ft_clx_summary(target_idx).hcs_true_surf;
    
        for hcs_idx = 1:length(hcs_target_list)
            HC_TestSub = hcs_target_list{hcs_idx};
            hcs_pred_surf_H1 = hcs_pred_surf(hcs_idx, 1:length(hcs_pred_surf)/2);%
            hcs_pred_surf_H2 = hcs_pred_surf(hcs_idx, 1 + length(hcs_pred_surf)/2:end);%
            hcs_pred_cluster_lbl_H1 = hcs_pred_cluster_lbl(hcs_idx, 1:length(hcs_pred_cluster_lbl)/2);%
            hcs_pred_cluster_lbl_H2 = hcs_pred_cluster_lbl(hcs_idx, 1 + length(hcs_pred_cluster_lbl)/2:end);%
            hcs_true_surf_H1 = hcs_true_surf(hcs_idx, 1:length(hcs_true_surf)/2);%
            hcs_true_surf_H2 = hcs_true_surf(hcs_idx, 1 + length(hcs_pred_surf)/2:end);%
    
            MRIwrite_cmd(M, hcs_pred_cluster_lbl_H1, hcs_pred_cluster_lbl_H2, fullfile(out_dir, vis_dir, targetSub), [HC_TestSub '_pred_pre']);
            MRIwrite_cmd(M, hcs_pred_surf_H1, hcs_pred_surf_H1, fullfile(out_dir, vis_dir, targetSub), [HC_TestSub '_prob_pre']); 
    
            Pred_hcs_cluster_lbl_perHC = Pred_hcs_cluster_lbl(find(strcmp(Test_hcs_cluster_subID, [targetSub '_' HC_TestSub])));
            Prob_hcs_cluster_lbl_perHC = Prob_hcs_cluster_lbl(find(strcmp(Test_hcs_cluster_subID, [targetSub '_' HC_TestSub])));
            Test_hcs_cluster_ID_perHC = Test_hcs_cluster_ID(find(strcmp(Test_hcs_cluster_subID, [targetSub '_' HC_TestSub])));
            Test_hcs_cluster_lbl_perHC = Test_hcs_cluster_lbl(find(strcmp(Test_hcs_cluster_subID, [targetSub '_' HC_TestSub])));
    
            pred_lbl_post = Test_hcs_cluster_ID_perHC(find(Pred_hcs_cluster_lbl_perHC));
            prob_lbl_post = Prob_hcs_cluster_lbl_perHC(find(Pred_hcs_cluster_lbl_perHC)); 
    
            hcs_pred_H1_cluster_lbl_post = zeros(size(hcs_pred_cluster_lbl_H1));
            hcs_pred_H2_cluster_lbl_post = zeros(size(hcs_pred_cluster_lbl_H2));
    
            hcs_prob_H1_cluster_lbl_post = zeros(size(hcs_pred_cluster_lbl_H1)); 
            hcs_prob_H2_cluster_lbl_post = zeros(size(hcs_pred_cluster_lbl_H2)); 
    
            for lbl_idx = 1:length(pred_lbl_post)
                if ~isempty(find(unique(hcs_pred_cluster_lbl_H1) == pred_lbl_post(lbl_idx))) % if pred_ldl is in lh
                    hcs_pred_H1_cluster_lbl_post(find(hcs_pred_cluster_lbl_H1 == pred_lbl_post(lbl_idx))) = pred_lbl_post(lbl_idx);
                    hcs_prob_H1_cluster_lbl_post(find(hcs_pred_cluster_lbl_H1 == pred_lbl_post(lbl_idx))) = prob_lbl_post(lbl_idx); 
                elseif ~isempty(find(unique(hcs_pred_cluster_lbl_H2) == pred_lbl_post(lbl_idx))) % if pred_ldl is in rh
                    hcs_pred_H2_cluster_lbl_post(find(hcs_pred_cluster_lbl_H2 == pred_lbl_post(lbl_idx))) = pred_lbl_post(lbl_idx);
                    hcs_prob_H2_cluster_lbl_post(find(hcs_pred_cluster_lbl_H2 == pred_lbl_post(lbl_idx))) = prob_lbl_post(lbl_idx);
                end
            end
    
            MRIwrite_cmd(M, hcs_pred_H1_cluster_lbl_post, hcs_pred_H2_cluster_lbl_post, fullfile(out_dir, vis_dir, targetSub), [HC_TestSub '_pred_post']);
            MRIwrite_cmd(M, hcs_prob_H1_cluster_lbl_post, hcs_prob_H2_cluster_lbl_post, fullfile(out_dir, vis_dir, targetSub), [HC_TestSub '_prob_post']); 

            cluste_lbl_H1_post = unique(hcs_pred_H1_cluster_lbl_post);
            cluste_lbl_H1_post(find(ismember(cluste_lbl_H1_post, 0))) = [];
            meanProb_H1_post_hcs = zeros([length(cluste_lbl_H1_post), 1]);
            medianProb_H1_post_hcs = zeros([length(cluste_lbl_H1_post), 1]);
            clusterSZ_H1_post_hcs = zeros([length(cluste_lbl_H1_post), 1]);
            for cluster_lbl_order = 1:length(cluste_lbl_H1_post)
                meanProb_H1_post_hcs(cluster_lbl_order, 1) = mean(hcs_prob_H1_cluster_lbl_post(find(hcs_pred_H1_cluster_lbl_post == cluste_lbl_H1_post(cluster_lbl_order))));
                medianProb_H1_post_hcs(cluster_lbl_order, 1) = median(hcs_prob_H1_cluster_lbl_post(find(hcs_pred_H1_cluster_lbl_post == cluste_lbl_H1_post(cluster_lbl_order))));
                clusterSZ_H1_post_hcs(cluster_lbl_order, 1) = length(find(hcs_pred_H1_cluster_lbl_post == cluste_lbl_H1_post(cluster_lbl_order)));
            end
            cluste_lbl_H2_post = unique(hcs_pred_H2_cluster_lbl_post);
            cluste_lbl_H2_post(find(ismember(cluste_lbl_H2_post, 0))) = [];
            meanProb_H2_post_hcs = zeros([length(cluste_lbl_H2_post), 1]);
            medianProb_H2_post_hcs = zeros([length(cluste_lbl_H2_post), 1]);
            clusterSZ_H2_post_hcs = zeros([length(cluste_lbl_H2_post), 1]);
            for cluster_lbl_order = 1:length(cluste_lbl_H2_post)
                meanProb_H2_post_hcs(cluster_lbl_order, 1) = mean(hcs_prob_H2_cluster_lbl_post(find(hcs_pred_H2_cluster_lbl_post == cluste_lbl_H2_post(cluster_lbl_order))));
                medianProb_H2_post_hcs(cluster_lbl_order, 1) = median(hcs_prob_H2_cluster_lbl_post(find(hcs_pred_H2_cluster_lbl_post == cluste_lbl_H2_post(cluster_lbl_order))));
                clusterSZ_H2_post_hcs(cluster_lbl_order, 1) = length(find(hcs_pred_H2_cluster_lbl_post == cluste_lbl_H2_post(cluster_lbl_order)));
            end
            Dt_result_eva{target_idx}.hcs_post_cluster_ID_Bi{hcs_idx} = [cluste_lbl_H1_post, cluste_lbl_H2_post]; 
            Dt_result_eva{target_idx}.hcs_post_meanProb_Bi{hcs_idx} = [meanProb_H1_post_hcs', meanProb_H2_post_hcs']; 
            Dt_result_eva{target_idx}.hcs_post_medianProb_Bi{hcs_idx} = [medianProb_H1_post_hcs', medianProb_H2_post_hcs']; 
            Dt_result_eva{target_idx}.hcs_post_clusterSZ_Bi{hcs_idx} = [clusterSZ_H1_post_hcs', clusterSZ_H2_post_hcs']; 
            Dt_result_eva{target_idx}.hcs_post_FP_cluster_num{hcs_idx} = length([cluste_lbl_H1_post, cluste_lbl_H2_post]);

            clear cluste_lbl_H1_post cluste_lbl_H2_post meanProb_H1_post_hcs meanProb_H2_post_hcs medianProb_H1_post_hcs medianProb_H2_post_hcs clusterSZ_H1_post_hcs clusterSZ_H2_post_hcs

            cluste_lbl_H1_pre = unique(hcs_pred_cluster_lbl_H1);
            cluste_lbl_H1_pre(find(ismember(cluste_lbl_H1_pre, 0))) = [];
            meanProb_H1_pre_hcs = zeros([length(cluste_lbl_H1_pre), 1]);
            medianProb_H1_pre_hcs = zeros([length(cluste_lbl_H1_pre), 1]);
            clusterSZ_H1_pre_hcs = zeros([length(cluste_lbl_H1_pre), 1]);
            for cluster_lbl_order = 1:length(cluste_lbl_H1_pre)
                meanProb_H1_pre_hcs(cluster_lbl_order, 1) = mean(hcs_pred_surf_H1(find(hcs_pred_cluster_lbl_H1 == cluste_lbl_H1_pre(cluster_lbl_order))));
                medianProb_H1_pre_hcs(cluster_lbl_order, 1) = median(hcs_pred_surf_H1(find(hcs_pred_cluster_lbl_H1 == cluste_lbl_H1_pre(cluster_lbl_order))));
                clusterSZ_H1_pre_hcs(cluster_lbl_order, 1) = length(find(hcs_pred_cluster_lbl_H1 == cluste_lbl_H1_pre(cluster_lbl_order)));
            end
            cluste_lbl_H2_pre = unique(hcs_pred_cluster_lbl_H2);
            cluste_lbl_H2_pre(find(ismember(cluste_lbl_H2_pre, 0))) = [];
            meanProb_H2_pre_hcs = zeros([length(cluste_lbl_H2_pre), 1]);
            medianProb_H2_pre_hcs = zeros([length(cluste_lbl_H2_pre), 1]);
            clusterSZ_H2_pre_hcs = zeros([length(cluste_lbl_H2_pre), 1]);
            for cluster_lbl_order = 1:length(cluste_lbl_H2_pre)
                meanProb_H2_pre_hcs(cluster_lbl_order, 1) = mean(hcs_pred_surf_H2(find(hcs_pred_cluster_lbl_H2 == cluste_lbl_H2_pre(cluster_lbl_order))));
                medianProb_H2_pre_hcs(cluster_lbl_order, 1) = median(hcs_pred_surf_H2(find(hcs_pred_cluster_lbl_H2 == cluste_lbl_H2_pre(cluster_lbl_order))));
                clusterSZ_H2_pre_hcs(cluster_lbl_order, 1) = length(find(hcs_pred_cluster_lbl_H2 == cluste_lbl_H2_pre(cluster_lbl_order)));
            end
            Dt_result_eva{target_idx}.hcs_pre_cluster_ID_Bi{hcs_idx} = [cluste_lbl_H1_pre, cluste_lbl_H2_pre]; 
            Dt_result_eva{target_idx}.hcs_pre_meanProb_Bi{hcs_idx} = [meanProb_H1_pre_hcs', meanProb_H2_pre_hcs']; 
            Dt_result_eva{target_idx}.hcs_pre_medianProb_Bi{hcs_idx} = [medianProb_H1_pre_hcs', medianProb_H2_pre_hcs'];
            Dt_result_eva{target_idx}.hcs_pre_clusterSZ_Bi{hcs_idx} = [clusterSZ_H1_pre_hcs', clusterSZ_H2_pre_hcs']; 
            Dt_result_eva{target_idx}.hcs_pre_FP_cluster_num{hcs_idx} = length([cluste_lbl_H1_pre, cluste_lbl_H2_pre]);
            clear cluste_lbl_H1_pre cluste_lbl_H2_pre meanProb_H1_pre_hcs meanProb_H2_pre_hcs medianProb_H1_pre_hcs medianProb_H2_pre_hcs clusterSZ_H1_pre_hcs clusterSZ_H2_pre_hcs
    
            fileID = fopen(fullfile(out_dir, vis_dir, targetSub, ['script_' HC_TestSub '.txt']), 'w'); 
            fprintf(fileID, ['freeview -f ../freesurfer_MELD/fsaverage_sym/surf/' 'lh' '.pial' ...
                ':overlay=python_ML_dataset_full/' vis_dir '/' targetSub '/' 'lh' '_' HC_TestSub '_pred_pre.mgh' ...
                ':overlay=python_ML0_dataset_full/' vis_dir '/' targetSub '/' 'lh' '_' HC_TestSub '_pred_post.mgh' ...
                '\n\n'...
                'freeview -f ../freesurfer_MELD/fsaverage_sym/surf/' 'lh' '.pial' ...
                ':overlay=python_ML_dataset_full/' vis_dir '/' targetSub '/' 'rh' '_' HC_TestSub '_pred_pre.mgh' ...
                ':overlay=python_ML_dataset_full/' vis_dir '/' targetSub '/' 'rh' '_' HC_TestSub '_pred_post.mgh' ...
                ]);
            fclose(fileID);
    
            clear HC_TestSub hcs_pred_surf_H1 hcs_pred_surf_H2 hcs_pred_cluster_lbl_H1 hcs_pred_cluster_lbl_H2 hcs_true_surf_H1 hcs_true_surf_H2  fileID prob_lbl_post
            clear Pred_hcs_cluster_lbl_perHC Test_hcs_cluster_ID_perHC Test_hcs_cluster_lbl_perHC pred_lbl_post hcs_pred_H1_cluster_lbl_post hcs_pred_H2_cluster_lbl_post
            clear hcs_prob_H1_cluster_lbl_post hcs_prob_H2_cluster_lbl_post
        end
        clear target_pred_H1_cluster_lbl_post target_pred_H2_cluster_lbl_post Prob_hcs_cluster_lbl
        clear hcs_target_list Test_hcs_cluster_ID Test_hcs_cluster_subID Test_hcs_cluster_lbl Pred_hcs_cluster_lbl hcs_pred_surf hcs_pred_cluster_lbl hcs_true_surf
        clear targetSub M lesion_side Test_target_cluster_lbl Test_target_cluster_ID Pred_target_cluster_lbl target_pred_surf target_pred_surf_H1 target_pred_surf_H2
        clear target_true_surf target_true_surf_H1 target_true_surf_H2 target_pred_cluster_lbl target_pred_H1_cluster_lbl target_pred_H2_cluster_lbl   
    end
    clear Dt_set_thr_clu_ft_clx Dt_set_thr_clu_ft_clx_summary target_list vis_dir

    save(['mD' num2str(minDistance) '_mA' num2str(min_vtx_area) '_' SetName '_' TrainFcn '_DataSet_set_thr_' Th1Crit '_clu_ft_clxTh2' num2str(threshold2) '_lr2_result_eva.mat'], 'Dt_result_eva', '-v7.3')  %%%%% 04/02/2024 rev%%%%%%%%%%%%%%%2025/4/15
end 