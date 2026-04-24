clear all; close all; 

path = 'path\to\files';
subj_dir = dir(fullfile(path, '*'));
subj_dir([1, 2]) = [];

for order = 1:length(subj_dir)
   subj_list{order, 1} = subj_dir(order).name; 
end

for order = 1:length(subj_list)
    display(subj_list{order})

    T2_nii = load_untouch_nii(fullfile(path, subj_list{order}, 'MRF_T2_brain.nii'));
    T2_img = double(T2_nii.img);

    T2_img(find(T2_img > 800)) = 800;

    T2_nii.img = T2_img;
    save_untouch_nii(T2_nii, fullfile(path, subj_list{order}, 'MRF_T2_brain_tr.nii'))

    clear T2_nii T2_img
end


