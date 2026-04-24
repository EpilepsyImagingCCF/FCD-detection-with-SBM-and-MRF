##This script moves the lesion label to fsaverage_sym
SUBJECT_DIR="/path/to/FreeSurfer_output_folder"

cd "$SUBJECT_DIR"
export SUBJECTS_DIR="$SUBJECT_DIR"

## Import list of subjects
subjects="P01 P02 ..."

for s in $subjects
do

# Move lesion Label to left hemisphere of the template
if [ -e "$s"/surf_meld/lh_lesion_linked.mgh ]
then

mris_apply_reg --src  "$s"/surf_meld/lh_lesion_linked.mgh --trg "$s"/xhemi/surf_meld/lh.on_lh.lesion.mgh  --streg $SUBJECTS_DIR/"$s"/surf/lh.sphere.reg     $SUBJECTS_DIR/fsaverage_sym/surf/lh.sphere.reg
mris_apply_reg --src  "$s"/surf_meld/lh_lesion_sm_linked.mgh --trg "$s"/xhemi/surf_meld/lh.on_lh.lesion_sm.mgh  --streg $SUBJECTS_DIR/"$s"/surf/lh.sphere.reg     $SUBJECTS_DIR/fsaverage_sym/surf/lh.sphere.reg

elif [ -e "$s"/surf_meld/rh_lesion_linked.mgh ]
then

mris_apply_reg --src "$s"/surf_meld/rh_lesion_linked.mgh --trg "$s"/xhemi/surf_meld/rh.on_lh.lesion.mgh   --streg $SUBJECTS_DIR/"$s"/xhemi/surf/lh.fsaverage_sym.sphere.reg     $SUBJECTS_DIR/fsaverage_sym/surf/lh.sphere.reg
mris_apply_reg --src "$s"/surf_meld/rh_lesion_sm_linked.mgh --trg "$s"/xhemi/surf_meld/rh.on_lh.lesion_sm.mgh   --streg $SUBJECTS_DIR/"$s"/xhemi/surf/lh.fsaverage_sym.sphere.reg     $SUBJECTS_DIR/fsaverage_sym/surf/lh.sphere.reg

fi
done


