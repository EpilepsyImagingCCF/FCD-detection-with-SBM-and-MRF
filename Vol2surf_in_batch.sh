script_dir=$(pwd)

SUBJECT_DIR="/path/to/Freesurfer_output_folder"
subject_list="List_subjects.txt"
echo $SUBJECT_DIR
cd "$SUBJECT_DIR"
export SUBJECTS_DIR="$SUBJECT_DIR"

## List of subjects
subjects="P01 P02 ..."

for s in $subjects;
do
echo ${s}
python "$script_dir"create_identity_reg.py "$s"

mkdir "$s"/surf_meld

#detect if lesion and which hemisphere
if [ -e  "$s"/mri/rh_lesion.mgz ];
then

mri_vol2surf --src "$s"/mri/rh_lesion.mgh --out "$s"/surf_meld/rh_lesion.mgh --hemi rh --srcreg "$s"/mri/transforms/Identity.dat
mri_vol2surf --src "$s"/mri/rh_lesion_sm.mgh --out "$s"/surf_meld/rh_lesion_sm.mgh --hemi rh --srcreg "$s"/mri/transforms/Identity.dat

elif [ -e  "$s"/mri/lh_lesion.mgz ];
then

mri_vol2surf --src "$s"/mri/lh_lesion.mgh --out "$s"/surf_meld/lh_lesion.mgh --hemi lh --srcreg "$s"/mri/transforms/Identity.dat
mri_vol2surf --src "$s"/mri/lh_lesion_sm.mgh --out "$s"/surf_meld/lh_lesion_sm.mgh --hemi lh --srcreg "$s"/mri/transforms/Identity.dat

fi

done

python "$script_dir"lesion_blobbing.py "$SUBJECT_DIR" "$subject_list"
python "$script_dir"lesion_blobbing_sm.py "$SUBJECT_DIR" "$subject_list"

