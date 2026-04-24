function cluster_characterization_step3(minDistance, min_vtx_area, max_vtx_area, SetName, TrainFcn, Th1Crit)

if ~exist(['mD' num2str(minDistance) '_mA' num2str(min_vtx_area) '_' SetName '_' TrainFcn '_DataSet_set_thr_' Th1Crit '_clu.mat'])
    load([SetName '_' TrainFcn '_DataSet_set_thr_' Th1Crit '.mat'])
    Dt_set_thr_summary = [Dt_set_thr{:}];
    Dt_set_thr_clu = Dt_set_thr;
    target_list = {Dt_set_thr_summary.targetSub};
    
    for target_idx = 1:length(target_list)
        targetSub = target_list{target_idx};
        TrainSet_opt_threshold = Dt_set_thr_summary(target_idx).TrainSet_opt_threshold;
        lesion_side = Dt_set_thr_summary(target_idx).lesion_side;

        target_pred_surf_H1_pre_thr = Dt_set_thr_summary(target_idx).target_pred_surf_H1_pre_thr;
        target_pred_surf_H2_pre_thr = Dt_set_thr_summary(target_idx).target_pred_surf_H2_pre_thr;
        target_true_surf_H1 = Dt_set_thr_summary(target_idx).target_true_surf_H1;
        target_true_surf_H2 = Dt_set_thr_summary(target_idx).target_true_surf_H2;

        hcs_target_list = Dt_set_thr_summary(target_idx).hcs_target_list;
        hcs_target_pred_surf_H1_pre_set_thr = Dt_set_thr_summary(target_idx).hcs_target_pred_surf_H1_pre_set_thr;
        hcs_target_pred_surf_H2_pre_set_thr = Dt_set_thr_summary(target_idx).hcs_target_pred_surf_H2_pre_set_thr;
        hcs_target_true_surf_H1_set = Dt_set_thr_summary(target_idx).hcs_target_true_surf_H1_set;
        hcs_target_true_surf_H2_set = Dt_set_thr_summary(target_idx).hcs_target_true_surf_H2_set;

        % 3.1 surfaced-based clustering for target sub
        [target_pred_surf_H1, target_pred_H1_cluster_lbl] = pred_surf_cluster(target_pred_surf_H1_pre_thr, TrainSet_opt_threshold, minDistance, min_vtx_area, max_vtx_area);
        [target_pred_surf_H2, target_pred_H2_cluster_lbl] = pred_surf_cluster(target_pred_surf_H2_pre_thr, TrainSet_opt_threshold, minDistance, min_vtx_area, max_vtx_area);

        % arrange the index
        bin = unique(target_pred_H1_cluster_lbl);
        count = 1;
        for order = 2:length(bin)
           target_pred_H1_cluster_lbl(find(target_pred_H1_cluster_lbl == bin(order))) = count;
           count = count + 1;
        end
        clear bin count

        bin = unique(target_pred_H2_cluster_lbl);
        count = 1;
        for order = 2:length(bin)
           target_pred_H2_cluster_lbl(find(target_pred_H2_cluster_lbl == bin(order))) = count;
           count = count + 1;
        end
        clear bin count

        target_pred_H2_cluster_lbl(find(target_pred_H2_cluster_lbl > 0)) =  target_pred_H2_cluster_lbl(find(target_pred_H2_cluster_lbl > 0)) + max(target_pred_H1_cluster_lbl);
        target_pred_cluster_lbl = [target_pred_H1_cluster_lbl, target_pred_H2_cluster_lbl]; 
        target_pred_surf = [target_pred_surf_H1, target_pred_surf_H2]; 

        target_true_surf = [target_true_surf_H1, target_true_surf_H2]; 

        Dt_set_thr_clu{target_idx}.target_pred_cluster_lbl = target_pred_cluster_lbl;
        Dt_set_thr_clu{target_idx}.target_pred_surf = target_pred_surf;
        Dt_set_thr_clu{target_idx}.target_true_surf = target_true_surf;

        % 3.2 surfaced-based clustering for hcs
        for hcs_idx = 1:size(hcs_target_pred_surf_H1_pre_set_thr, 1)
            [hcs_pred_surf_H1_tmp, hcs_pred_H1_cluster_lbl_tmp] = pred_surf_cluster(hcs_target_pred_surf_H1_pre_set_thr(hcs_idx, :), TrainSet_opt_threshold, minDistance, min_vtx_area, max_vtx_area);
            [hcs_pred_surf_H2_tmp, hcs_pred_H2_cluster_lbl_tmp] = pred_surf_cluster(hcs_target_pred_surf_H2_pre_set_thr(hcs_idx, :), TrainSet_opt_threshold, minDistance, min_vtx_area, max_vtx_area);

            % arrange the index
            bin = unique(hcs_pred_H1_cluster_lbl_tmp);
            count = 1;
            for order = 2:length(bin)
               hcs_pred_H1_cluster_lbl_tmp(find(hcs_pred_H1_cluster_lbl_tmp == bin(order))) = count;
               count = count + 1;
            end
            clear bin count

            bin = unique(hcs_pred_H2_cluster_lbl_tmp);
            count = 1;
            for order = 2:length(bin)
               hcs_pred_H2_cluster_lbl_tmp(find(hcs_pred_H2_cluster_lbl_tmp == bin(order))) = count;
               count = count + 1;
            end
            clear bin count

            hcs_pred_H2_cluster_lbl_tmp(find(hcs_pred_H2_cluster_lbl_tmp > 0)) =  hcs_pred_H2_cluster_lbl_tmp(find(hcs_pred_H2_cluster_lbl_tmp > 0)) + max(hcs_pred_H1_cluster_lbl_tmp);
            hcs_pred_cluster_lbl(hcs_idx, :) = [hcs_pred_H1_cluster_lbl_tmp, hcs_pred_H2_cluster_lbl_tmp]; 
            hcs_pred_surf(hcs_idx, :) = [hcs_pred_surf_H1_tmp, hcs_pred_surf_H2_tmp]; 

            hcs_true_surf(hcs_idx, :) = zeros(size(hcs_pred_surf(hcs_idx, :))); 

            clear hcs_pred_surf_H1_tmp hcs_pred_surf_H2_tmp hcs_pred_H1_cluster_lbl_tmp hcs_pred_H2_cluster_lbl_tmp
        end     
        Dt_set_thr_clu{target_idx}.hcs_pred_cluster_lbl = hcs_pred_cluster_lbl;
        Dt_set_thr_clu{target_idx}.hcs_pred_surf = hcs_pred_surf;
        Dt_set_thr_clu{target_idx}.hcs_true_surf = hcs_true_surf;
        
        clear target_pred_surf_H1 target_pred_H1_cluster_lbl target_pred_surf_H2 target_pred_H2_cluster_lbl  
        clear hcs_target_list hcs_target_pred_surf_H1_pre_set_thr hcs_target_pred_surf_H2_pre_set_thr hcs_target_true_surf_H1_set hcs_target_true_surf_H2_set
        clear targetSub TrainSet_opt_threshold lesion_side target_pred_surf_H1_pre_thr target_pred_surf_H2_pre_thr target_true_surf_H1 target_true_surf_H2
        clear hcs_pred_cluster_lbl hcs_pred_surf hcs_true_surf target_pred_cluster_lbl target_pred_surf target_true_surf  
    end
    save(['mD' num2str(minDistance) '_mA' num2str(min_vtx_area) '_' SetName '_' TrainFcn '_DataSet_set_thr_' Th1Crit '_clu.mat'], 'Dt_set_thr_clu', '-v7.3')

    clear Dt_set_thr_clu Dt_set_thr_summary target_list Dt_set_thr
end