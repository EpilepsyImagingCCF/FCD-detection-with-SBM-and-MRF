clear all; close all;
subjects_dir = 'path\to\subjects';
subj_dir = dir(subjects_dir);
for order = 1:length(subj_dir)
   subj_list{order, 1} = subj_dir(order).name; 
end

folder = 'path\to\FreeSurfer_folder';

%% binarization
for order = 1:length(subj_list)
    display(subj_list{order})
    lesion_nii = load_untouch_nii(fullfile(folder, subj_list{order}, 'mri', 'FS_FCD_ROI.nii'));
    lesion_sm_nii = load_untouch_nii(fullfile(folder, subj_list{order}, 'mri', 'FS_FCD_ROI_sm.nii'));

    lesion_img = lesion_nii.img;
    lesion_sm_img = lesion_sm_nii.img;

    lesion_nii.img = double(lesion_img > max(lesion_img(:))*0.3);
    save_untouch_nii(lesion_nii, fullfile(folder, subj_list{order}, 'mri', 'FS_FCD_ROI_bin.nii'))
    lesion_sm_nii.img = double(lesion_sm_img > max(lesion_sm_img(:))*0.3);
    save_untouch_nii(lesion_sm_nii, fullfile(folder, subj_list{order}, 'mri', 'FS_FCD_ROI_sm_bin.nii'))

    clear lesion_nii lesion_sm_nii  lesion_img lesion_sm_img   
end




