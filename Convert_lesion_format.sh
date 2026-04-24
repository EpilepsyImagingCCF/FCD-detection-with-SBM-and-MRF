out_dir="/path/to/FreeSurfer_folder"
subjects="P01 P02 ..."

for sub in ${subjects}
do

echo ${sub}
mri_convert -it nii -ot mgz ${out_dir}/${sub}/mri/FS_FCD_ROI_bin.nii ${out_dir}/${sub}/mri/FS_FCD_ROI_bin.mgh
mri_convert -it nii -ot mgz ${out_dir}/${sub}/mri/FS_FCD_ROI_sm_bin.nii ${out_dir}/${sub}/mri/FS_FCD_ROI_sm_bin.mgh

done
