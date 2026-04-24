function cluster_characterization_step7(minDistance, min_vtx_area, max_vtx_area, SetName, TrainFcn, Th1Crit, threshold2, out_dir)
load(['mD' num2str(minDistance) '_mA' num2str(min_vtx_area) '_' SetName '_' TrainFcn '_DataSet_set_thr_' Th1Crit '_clu_ft_clxTh2' num2str(threshold2) '_lr2_result_eva.mat']);
 
Dt_result_eva_summary = [Dt_result_eva{:}];
target_list = {Dt_result_eva_summary.TargetSub};

% % HCs FP cluster number need to turn on
% for target_idx = 1:length(target_list)
%     targetSub = target_list{target_idx};
%     hcs_post_FP_cluster_num(target_idx) = mean(cell2mat(Dt_result_eva_summary(target_idx).hcs_post_FP_cluster_num));
%     hcs_pre_FP_cluster_num(target_idx) = mean(cell2mat(Dt_result_eva_summary(target_idx).hcs_pre_FP_cluster_num));
% end
% [mean(hcs_pre_FP_cluster_num), mean(hcs_post_FP_cluster_num)]

for target_idx = 1:length(target_list)
    targetSub = target_list{target_idx};
    lesion_side = Dt_result_eva_summary(target_idx).lesion_side;
    pre_TP_w_sm_Bi = Dt_result_eva_summary(target_idx).pre_TP_w_sm_Bi;
    pre_TP_w_sm_H1 = Dt_result_eva_summary(target_idx).pre_TP_w_sm_H1;
    pre_TP_w_sm_H2 = Dt_result_eva_summary(target_idx).pre_TP_w_sm_H2;

    post_TP_w_sm_Bi = Dt_result_eva_summary(target_idx).post_TP_w_sm_Bi;
    post_TP_w_sm_H1 = Dt_result_eva_summary(target_idx).post_TP_w_sm_H1;
    post_TP_w_sm_H2 = Dt_result_eva_summary(target_idx).post_TP_w_sm_H2;
  
    Data_pre_TP_w_sm_Bi(target_idx, 1) = double(sum(pre_TP_w_sm_Bi) > 0);
    Data_pre_FP_num_w_sm_Bi(target_idx, 1) = length(find(pre_TP_w_sm_Bi == 0));

    Data_post_TP_w_sm_Bi(target_idx, 1) = double(sum(post_TP_w_sm_Bi) > 0);
    Data_post_FP_num_w_sm_Bi(target_idx, 1) = length(find(post_TP_w_sm_Bi == 0));

    if strcmp(lesion_side, 'both')
        Data_pre_TP_w_sm_lesionside(target_idx, 1) = double(sum(pre_TP_w_sm_Bi) > 0);
        Data_pre_FP_num_w_sm_lesionside(target_idx, 1) = length(find(pre_TP_w_sm_Bi == 0));
    
        Data_post_TP_w_sm_lesionside(target_idx, 1) = double(sum(post_TP_w_sm_Bi) > 0);
        Data_post_FP_num_w_sm_lesionside(target_idx, 1) = length(find(post_TP_w_sm_Bi == 0));
    else
        Data_pre_TP_w_sm_lesionside(target_idx, 1) = double(sum(pre_TP_w_sm_H1) > 0);
        Data_pre_FP_num_w_sm_lesionside(target_idx, 1) = length(find(pre_TP_w_sm_H1 == 0));
    
        Data_post_TP_w_sm_lesionside(target_idx, 1) = double(sum(post_TP_w_sm_H1) > 0);
        Data_post_FP_num_w_sm_lesionside(target_idx, 1) = length(find(post_TP_w_sm_H1 == 0));
    end

    clear targetSub lesion_side 
    clear pre_TP_w_sm_Bi pre_TP_w_sm_H1 pre_TP_w_sm_H2  
    clear  post_TP_w_sm_Bi post_TP_w_sm_H1 post_TP_w_sm_H2
end
Data_sum_cell = mat2cell([Data_pre_TP_w_sm_Bi, Data_pre_FP_num_w_sm_Bi, ...
    Data_post_TP_w_sm_Bi, Data_post_FP_num_w_sm_Bi, ...
    Data_pre_TP_w_sm_lesionside, Data_pre_FP_num_w_sm_lesionside, ...
    Data_post_TP_w_sm_lesionside, Data_post_FP_num_w_sm_lesionside], ones([length(Data_pre_TP_w_sm_Bi), 1]), ones([8, 1]));

Data_sum_cell{size(Data_sum_cell, 1) + 2, 1} = ['mD' num2str(minDistance) '_mA' num2str(min_vtx_area) '_' SetName '_' TrainFcn '_DataSet_set_thr_' Th1Crit '_clu_ft_clxTh2' num2str(threshold2) '_lr2.mat'];

if strcmp(SetName, 'SBM_LOO_v1')
    out_txt = 'S';
elseif strcmp(SetName, 'SBM_nMRF_LOO_v1')
    out_txt = 'SM';
elseif strcmp(SetName, 'SBM_FLAIR_LOO_v1')
    out_txt = 'SF';
elseif strcmp(SetName, 'SBM_FLAIR_nMRF_LOO_v1')
    out_txt = 'SFM';
end

RowNames = {target_list{:}, 'tmp', 'filename'};
VariableNames = {'Bi_pre_sm_TP_Hiton', 'Bi_pre_sm_FP_num', ...
    'Bi_post_sm_TP_Hiton', 'Bi_post_sm_FP_num', ...
    'LesionSide_pre_sm_TP_Hiton', 'LesionSide_pre_sm_FP_num', ...
    'LesionSide_post_sm_TP_Hiton', 'LesionSide_post_sm_FP_num'};
Data_sum_table = cell2table(Data_sum_cell, "VariableNames", VariableNames, "RowNames", RowNames);
writetable(Data_sum_table, fullfile(out_dir, 'Clusterwise_results.xlsx'),  "WriteRowNames", true, "WriteVariableNames", true, "Sheet", ...
    ['clu_' out_txt '_' Th1Crit num2str(threshold2)])
