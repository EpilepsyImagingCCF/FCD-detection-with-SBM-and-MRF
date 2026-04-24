data_dir="path/to/MRF_data"
FreeSurfer_dir="path/to/Freesurfer_subject_directory"

transform_type="s"

subjects="sub1 sub2 sub3..."

for sub in ${subjects}
do

    echo ${sub}

    mri_convert -it mgz \
        -ot nii \
        ${FreeSurfer_dir}/${sub}/mri/brain.mgz \
        ${FreeSurfer_dir}/${sub}/mri/brain.nii

    antsRegistrationSyN.sh -d 3 \
        -m ${data_dir}/${sub}/MRF_T1w_brain.nii \
	-f ${FreeSurfer_dir}/${sub}/mri/brain.nii \
        -t ${transform_type} \
        -n 3 \
	-o ${data_dir}/${sub}/Reg_MRF_2_FS_${transform_type}_

    antsApplyTransforms -d 3 \
        -i ${data_dir}/${sub}/MRF_T1_brain.nii \
        -o ${data_dir}/${sub}/mri/rMRF_T1_brain.nii \
        -r ${FreeSurfer_dir}/${sub}/mri/brain.nii \
        -t ${data_dir}/${sub}/Reg_MRF_2_FS_${transform_type}_1Warp.nii.gz \
        -t ${data_dir}/${sub}/Reg_MRF_2_FS_${transform_type}_0GenericAffine.mat

    antsApplyTransforms -d 3 \
        -i ${data_dir}/${sub}/MRF_T2_brain_tr.nii \
        -o ${data_dir}/${sub}/mri/rMRF_T2_brain_tr.nii \
        -r ${FreeSurfer_dir}/${sub}/mri/brain.nii \
        -t ${data_dir}/${sub}/Reg_MRF_2_FS_${transform_type}_1Warp.nii.gz \
        -t ${data_dir}/${sub}/Reg_MRF_2_FS_${transform_type}_0GenericAffine.mat

    % For the lesion registration
    antsApplyTransforms -d 3 \
        -i ${data_dir}/${sub}/FCD_ROI.nii \
        -o ${data_dir}/${sub}/mri/FS_FCD_ROI.nii \
        -r ${FreeSurfer_dir}/${sub}/mri/brain.nii \
        -t ${data_dir}/${sub}/Reg_MRF_2_FS_${transform_type}_1Warp.nii.gz \
        -t ${data_dir}/${sub}/Reg_MRF_2_FS_${transform_type}_0GenericAffine.mat

    antsApplyTransforms -d 3 \
        -i ${data_dir}/${sub}/FCD_ROI_sm.nii \
        -o ${data_dir}/${sub}/mri/FS_FCD_ROI_sm.nii \
        -r ${FreeSurfer_dir}/${sub}/mri/brain.nii \
        -t ${data_dir}/${sub}/Reg_MRF_2_FS_${transform_type}_1Warp.nii.gz \
        -t ${data_dir}/${sub}/Reg_MRF_2_FS_${transform_type}_0GenericAffine.mat

done
