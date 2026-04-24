SUBJECT_DIR="/path/to/FreeSurfer_output_folder"  # freesurfer output directory
INPUT_DIR="/path/to/input_folder"

SetName=$1

# Change to the folder that having the best performance
if [[ "$SetName" == 'SBM' ]]; then
    CLUSTERING_method='FreeVis_mD2_mA100_SBM_LOO_v8_pyDBCE_lr3_SMOTE_rL23_thr_nonAdpTh0.5_clxTh2_0.5'
elif [[ "$SetName" == 'SBM_nMRF' ]]; then
    CLUSTERING_method='FreeVis_mD2_mA100_SBM_nMRF_LOO_v8_pyBFL_lr3_SMOTE_rL23_thr_nonAdpTh0.5_clxTh2_0.5'
elif [[ "$SetName" == 'SBM_FLAIR' ]]; then
    CLUSTERING_method='FreeVis_mD2_mA100_SBM_FLAIR_LOO_v8_pyBCE_lr3_SMOTE_rL22_thr_nonAdpTh0.5_clxTh2_0.5'
elif [[ "$SetName" == 'SBM_FLAIR_nMRF' ]]; then
    CLUSTERING_method='FreeVis_mD2_mA100_SBM_FLAIR_nMRF_LOO_v8_pyBFL_lr3_SMOTE_rL23_thr_nonAdpTh0.5_clxTh2_0.5'
else
    echo "SetName does not match any known configuration."
    exit 1
fi

echo "Selected CLUSTERING_method: $CLUSTERING_method"

export SUBJECTS_DIR="$SUBJECT_DIR"
export INPUT_DIR="$INPUT_DIR"

sub=$2

# Moves left hemi from fsaverage to native space - pred_post
mris_apply_reg --src "$INPUT_DIR"/"$CLUSTERING_method"/"$sub"/lh_"$sub"_pred_post.mgh --trg "$INPUT_DIR"/"$CLUSTERING_method"/"$sub"/lh_"$sub"_pred_post_RLcorr.mgh \
--streg $SUBJECTS_DIR/fsaverage_sym/surf/lh.sphere.reg $SUBJECTS_DIR/"$sub"/surf/lh.sphere.reg

mris_apply_reg --src "$INPUT_DIR"/"$CLUSTERING_method"/"$sub"/rh_"$sub"_pred_post.mgh --trg "$INPUT_DIR"/"$CLUSTERING_method"/"$sub"/rh_"$sub"_pred_post_on_rh.mgh  \
--streg $SUBJECTS_DIR/fsaverage_sym/surf/lh.sphere.reg $SUBJECTS_DIR/fsaverage_sym/surf/rh.sphere.left_right

mris_apply_reg --src "$INPUT_DIR"/"$CLUSTERING_method"/"$sub"/rh_"$sub"_pred_post_on_rh.mgh --trg "$INPUT_DIR"/"$CLUSTERING_method"/"$sub"/rh_"$sub"_pred_post_RLcorr.mgh \
--streg $SUBJECTS_DIR/fsaverage_sym/surf/rh.sphere.reg $SUBJECTS_DIR/"$sub"/surf/rh.sphere.reg

# Moves left hemi from fsaverage to native space - pred_pre
mris_apply_reg --src "$INPUT_DIR"/"$CLUSTERING_method"/"$sub"/lh_"$sub"_pred_pre.mgh --trg "$INPUT_DIR"/"$CLUSTERING_method"/"$sub"/lh_"$sub"_pred_pre_RLcorr.mgh \
--streg $SUBJECTS_DIR/fsaverage_sym/surf/lh.sphere.reg $SUBJECTS_DIR/"$sub"/surf/lh.sphere.reg

mris_apply_reg --src "$INPUT_DIR"/"$CLUSTERING_method"/"$sub"/rh_"$sub"_pred_pre.mgh --trg "$INPUT_DIR"/"$CLUSTERING_method"/"$sub"/rh_"$sub"_pred_pre_on_rh.mgh  \
--streg $SUBJECTS_DIR/fsaverage_sym/surf/lh.sphere.reg $SUBJECTS_DIR/fsaverage_sym/surf/rh.sphere.left_right

mris_apply_reg --src "$INPUT_DIR"/"$CLUSTERING_method"/"$sub"/rh_"$sub"_pred_pre_on_rh.mgh --trg "$INPUT_DIR"/"$CLUSTERING_method"/"$sub"/rh_"$sub"_pred_pre_RLcorr.mgh \
--streg $SUBJECTS_DIR/fsaverage_sym/surf/rh.sphere.reg $SUBJECTS_DIR/"$sub"/surf/rh.sphere.reg

# Moves left hemi from fsaverage to native space - prob_post
mris_apply_reg --src "$INPUT_DIR"/"$CLUSTERING_method"/"$sub"/lh_"$sub"_prob_post.mgh --trg "$INPUT_DIR"/"$CLUSTERING_method"/"$sub"/lh_"$sub"_prob_post_RLcorr.mgh \
--streg $SUBJECTS_DIR/fsaverage_sym/surf/lh.sphere.reg $SUBJECTS_DIR/"$sub"/surf/lh.sphere.reg

mris_apply_reg --src "$INPUT_DIR"/"$CLUSTERING_method"/"$sub"/rh_"$sub"_prob_post.mgh --trg "$INPUT_DIR"/"$CLUSTERING_method"/"$sub"/rh_"$sub"_prob_post_on_rh.mgh  \
--streg $SUBJECTS_DIR/fsaverage_sym/surf/lh.sphere.reg $SUBJECTS_DIR/fsaverage_sym/surf/rh.sphere.left_right

mris_apply_reg --src "$INPUT_DIR"/"$CLUSTERING_method"/"$sub"/rh_"$sub"_prob_post_on_rh.mgh --trg "$INPUT_DIR"/"$CLUSTERING_method"/"$sub"/rh_"$sub"_prob_post_RLcorr.mgh \
--streg $SUBJECTS_DIR/fsaverage_sym/surf/rh.sphere.reg $SUBJECTS_DIR/"$sub"/surf/rh.sphere.reg

# Moves left hemi from fsaverage to native space - prob_pre
mris_apply_reg --src "$INPUT_DIR"/"$CLUSTERING_method"/"$sub"/lh_"$sub"_prob_pre.mgh --trg "$INPUT_DIR"/"$CLUSTERING_method"/"$sub"/lh_"$sub"_prob_pre_RLcorr.mgh \
--streg $SUBJECTS_DIR/fsaverage_sym/surf/lh.sphere.reg $SUBJECTS_DIR/"$sub"/surf/lh.sphere.reg

mris_apply_reg --src "$INPUT_DIR"/"$CLUSTERING_method"/"$sub"/rh_"$sub"_prob_pre.mgh --trg "$INPUT_DIR"/"$CLUSTERING_method"/"$sub"/rh_"$sub"_prob_pre_on_rh.mgh  \
--streg $SUBJECTS_DIR/fsaverage_sym/surf/lh.sphere.reg $SUBJECTS_DIR/fsaverage_sym/surf/rh.sphere.left_right

mris_apply_reg --src "$INPUT_DIR"/"$CLUSTERING_method"/"$sub"/rh_"$sub"_prob_pre_on_rh.mgh --trg "$INPUT_DIR"/"$CLUSTERING_method"/"$sub"/rh_"$sub"_prob_pre_RLcorr.mgh \
--streg $SUBJECTS_DIR/fsaverage_sym/surf/rh.sphere.reg $SUBJECTS_DIR/"$sub"/surf/rh.sphere.reg

# Moves left hemi from fsaverage to native space - true
mris_apply_reg --src "$INPUT_DIR"/"$CLUSTERING_method"/"$sub"/lh_"$sub"_true.mgh --trg "$INPUT_DIR"/"$CLUSTERING_method"/"$sub"/lh_"$sub"_true_RLcorr.mgh \
--streg $SUBJECTS_DIR/fsaverage_sym/surf/lh.sphere.reg $SUBJECTS_DIR/"$sub"/surf/lh.sphere.reg

mris_apply_reg --src "$INPUT_DIR"/"$CLUSTERING_method"/"$sub"/rh_"$sub"_true.mgh --trg "$INPUT_DIR"/"$CLUSTERING_method"/"$sub"/rh_"$sub"_true_on_rh.mgh  \
--streg $SUBJECTS_DIR/fsaverage_sym/surf/lh.sphere.reg $SUBJECTS_DIR/fsaverage_sym/surf/rh.sphere.left_right

mris_apply_reg --src "$INPUT_DIR"/"$CLUSTERING_method"/"$sub"/rh_"$sub"_true_on_rh.mgh --trg "$INPUT_DIR"/"$CLUSTERING_method"/"$sub"/rh_"$sub"_true_RLcorr.mgh \  
--streg $SUBJECTS_DIR/fsaverage_sym/surf/rh.sphere.reg $SUBJECTS_DIR/"$sub"/surf/rh.sphere.reg

##  11. Convert from .mgh to .nii

# Map from surface back to vol - pred_post
mri_surf2vol --identity "$sub" --template $SUBJECTS_DIR/"$sub"/mri/T1.mgz --o "$INPUT_DIR"/"$CLUSTERING_method"/"$sub"/lh_"$sub"_pred_post_RLcorr_vol.mgh \
--hemi lh --surfval "$INPUT_DIR"/"$CLUSTERING_method"/"$sub"/lh_"$sub"_pred_post_RLcorr.mgh --fillribbon

mri_surf2vol --identity "$sub" --template $SUBJECTS_DIR/"$sub"/mri/T1.mgz --o "$INPUT_DIR"/"$CLUSTERING_method"/"$sub"/rh_"$sub"_pred_post_RLcorr_vol.mgh \
--hemi rh --surfval "$INPUT_DIR"/"$CLUSTERING_method"/"$sub"/rh_"$sub"_pred_post_RLcorr.mgh --fillribbon

# Map from surface back to vol - pred_pre
mri_surf2vol --identity "$sub" --template $SUBJECTS_DIR/"$sub"/mri/T1.mgz --o "$INPUT_DIR"/"$CLUSTERING_method"/"$sub"/lh_"$sub"_pred_pre_RLcorr_vol.mgh \
--hemi lh --surfval "$INPUT_DIR"/"$CLUSTERING_method"/"$sub"/lh_"$sub"_pred_pre_RLcorr.mgh --fillribbon

mri_surf2vol --identity "$sub" --template $SUBJECTS_DIR/"$sub"/mri/T1.mgz --o "$INPUT_DIR"/"$CLUSTERING_method"/"$sub"/rh_"$sub"_pred_pre_RLcorr_vol.mgh \
--hemi rh --surfval "$INPUT_DIR"/"$CLUSTERING_method"/"$sub"/rh_"$sub"_pred_pre_RLcorr.mgh --fillribbon

# Map from surface back to vol - prob_post
mri_surf2vol --identity "$sub" --template $SUBJECTS_DIR/"$sub"/mri/T1.mgz --o "$INPUT_DIR"/"$CLUSTERING_method"/"$sub"/lh_"$sub"_prob_post_RLcorr_vol.mgh \
--hemi lh --surfval "$INPUT_DIR"/"$CLUSTERING_method"/"$sub"/lh_"$sub"_prob_post_RLcorr.mgh --fillribbon

mri_surf2vol --identity "$sub" --template $SUBJECTS_DIR/"$sub"/mri/T1.mgz --o "$INPUT_DIR"/"$CLUSTERING_method"/"$sub"/rh_"$sub"_prob_post_RLcorr_vol.mgh \
--hemi rh --surfval "$INPUT_DIR"/"$CLUSTERING_method"/"$sub"/rh_"$sub"_prob_post_RLcorr.mgh --fillribbon

# Map from surface back to vol - prob_pre
mri_surf2vol --identity "$sub" --template $SUBJECTS_DIR/"$sub"/mri/T1.mgz --o "$INPUT_DIR"/"$CLUSTERING_method"/"$sub"/lh_"$sub"_prob_pre_RLcorr_vol.mgh \
--hemi lh --surfval "$INPUT_DIR"/"$CLUSTERING_method"/"$sub"/lh_"$sub"_prob_pre_RLcorr.mgh --fillribbon

mri_surf2vol --identity "$sub" --template $SUBJECTS_DIR/"$sub"/mri/T1.mgz --o "$INPUT_DIR"/"$CLUSTERING_method"/"$sub"/rh_"$sub"_prob_pre_RLcorr_vol.mgh \
--hemi rh --surfval "$INPUT_DIR"/"$CLUSTERING_method"/"$sub"/rh_"$sub"_prob_pre_RLcorr.mgh --fillribbon

# Map from surface back to vol - true
mri_surf2vol --identity "$sub" --template $SUBJECTS_DIR/"$sub"/mri/T1.mgz --o "$INPUT_DIR"/"$CLUSTERING_method"/"$sub"/lh_"$sub"_true_RLcorr_vol.mgh \   
--hemi lh --surfval "$INPUT_DIR"/"$CLUSTERING_method"/"$sub"/lh_"$sub"_true_RLcorr.mgh --fillribbon

mri_surf2vol --identity "$sub" --template $SUBJECTS_DIR/"$sub"/mri/T1.mgz --o "$INPUT_DIR"/"$CLUSTERING_method"/"$sub"/rh_"$sub"_true_RLcorr_vol.mgh \
--hemi rh --surfval "$INPUT_DIR"/"$CLUSTERING_method"/"$sub"/rh_"$sub"_true_RLcorr.mgh --fillribbon

# convert to nifti - pred_post
mri_convert "$INPUT_DIR"/"$CLUSTERING_method"/"$sub"/lh_"$sub"_pred_post_RLcorr_vol.mgh "$INPUT_DIR"/"$CLUSTERING_method"/"$sub"/lh_"$sub"_pred_post_RLcorr_vol.nii
mri_convert "$INPUT_DIR"/"$CLUSTERING_method"/"$sub"/rh_"$sub"_pred_post_RLcorr_vol.mgh "$INPUT_DIR"/"$CLUSTERING_method"/"$sub"/rh_"$sub"_pred_post_RLcorr_vol.nii

# convert to nifti - pred_pre
mri_convert "$INPUT_DIR"/"$CLUSTERING_method"/"$sub"/lh_"$sub"_pred_pre_RLcorr_vol.mgh "$INPUT_DIR"/"$CLUSTERING_method"/"$sub"/lh_"$sub"_pred_pre_RLcorr_vol.nii
mri_convert "$INPUT_DIR"/"$CLUSTERING_method"/"$sub"/rh_"$sub"_pred_pre_RLcorr_vol.mgh "$INPUT_DIR"/"$CLUSTERING_method"/"$sub"/rh_"$sub"_pred_pre_RLcorr_vol.nii

# convert to nifti - prob_post
mri_convert "$INPUT_DIR"/"$CLUSTERING_method"/"$sub"/lh_"$sub"_prob_post_RLcorr_vol.mgh "$INPUT_DIR"/"$CLUSTERING_method"/"$sub"/lh_"$sub"_prob_post_RLcorr_vol.nii
mri_convert "$INPUT_DIR"/"$CLUSTERING_method"/"$sub"/rh_"$sub"_prob_post_RLcorr_vol.mgh "$INPUT_DIR"/"$CLUSTERING_method"/"$sub"/rh_"$sub"_prob_post_RLcorr_vol.nii

# convert to nifti - prob_pre
mri_convert "$INPUT_DIR"/"$CLUSTERING_method"/"$sub"/lh_"$sub"_prob_pre_RLcorr_vol.mgh "$INPUT_DIR"/"$CLUSTERING_method"/"$sub"/lh_"$sub"_prob_pre_RLcorr_vol.nii
mri_convert "$INPUT_DIR"/"$CLUSTERING_method"/"$sub"/rh_"$sub"_prob_pre_RLcorr_vol.mgh "$INPUT_DIR"/"$CLUSTERING_method"/"$sub"/rh_"$sub"_prob_pre_RLcorr_vol.nii

# convert to nifti - true
mri_convert "$INPUT_DIR"/"$CLUSTERING_method"/"$sub"/lh_"$sub"_true_RLcorr_vol.mgh "$INPUT_DIR"/"$CLUSTERING_method"/"$sub"/lh_"$sub"_true_RLcorr_vol.nii
mri_convert "$INPUT_DIR"/"$CLUSTERING_method"/"$sub"/rh_"$sub"_true_RLcorr_vol.mgh "$INPUT_DIR"/"$CLUSTERING_method"/"$sub"/rh_"$sub"_true_RLcorr_vol.nii

# combine vols from left and right hemis - pred_post
fslmaths "$INPUT_DIR"/"$CLUSTERING_method"/"$sub"/lh_"$sub"_pred_post_RLcorr_vol.nii \
-add "$INPUT_DIR"/"$CLUSTERING_method"/"$sub"/rh_"$sub"_pred_post_RLcorr_vol.nii \
"$INPUT_DIR"/"$CLUSTERING_method"/"$sub"/"$sub"_pred_post_RLcorr_vol.nii

# combine vols from left and right hemis - pred_pre
fslmaths "$INPUT_DIR"/"$CLUSTERING_method"/"$sub"/lh_"$sub"_pred_pre_RLcorr_vol.nii \
-add "$INPUT_DIR"/"$CLUSTERING_method"/"$sub"/rh_"$sub"_pred_pre_RLcorr_vol.nii \
"$INPUT_DIR"/"$CLUSTERING_method"/"$sub"/"$sub"_pred_pre_RLcorr_vol.nii

# combine vols from left and right hemis - prob_post
fslmaths "$INPUT_DIR"/"$CLUSTERING_method"/"$sub"/lh_"$sub"_prob_post_RLcorr_vol.nii \
-add "$INPUT_DIR"/"$CLUSTERING_method"/"$sub"/rh_"$sub"_prob_post_RLcorr_vol.nii \
"$INPUT_DIR"/"$CLUSTERING_method"/"$sub"/"$sub"_prob_post_RLcorr_vol.nii

# combine vols from left and right hemis - prob_pre
fslmaths "$INPUT_DIR"/"$CLUSTERING_method"/"$sub"/lh_"$sub"_prob_pre_RLcorr_vol.nii \
-add "$INPUT_DIR"/"$CLUSTERING_method"/"$sub"/rh_"$sub"_prob_pre_RLcorr_vol.nii \
"$INPUT_DIR"/"$CLUSTERING_method"/"$sub"/"$sub"_prob_pre_RLcorr_vol.nii

# combine vols from left and right hemis - true
fslmaths "$INPUT_DIR"/"$CLUSTERING_method"/"$sub"/lh_"$sub"_true_RLcorr_vol.nii \
-add "$INPUT_DIR"/"$CLUSTERING_method"/"$sub"/rh_"$sub"_true_RLcorr_vol.nii \
"$INPUT_DIR"/"$CLUSTERING_method"/"$sub"/"$sub"_true_RLcorr_vol.nii

# copy the underlay
cp $SUBJECTS_DIR/"$sub"/mri/FS_FCD_ROI_bin.nii "$INPUT_DIR"/"$CLUSTERING_method"/"$sub"/
cp $SUBJECTS_DIR/"$sub"/mri/T1.nii "$INPUT_DIR"/"$CLUSTERING_method"/"$sub"/

