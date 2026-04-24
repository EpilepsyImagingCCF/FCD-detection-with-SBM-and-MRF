## 1. run the freesurfer recon_all with T1w and FLAIR images

subjects_dir="path/to/subjects_dir"
cd ${subjects_dir}
export SUBJECTS_DIR=${subjects_dir}

image_dir = "path/to/image_dir"

## Change to list your subject
subjects="sub1 sub2 sub3..."

# for each subject do the following
for sub in $subjects
do
    echo ${sub}

    recon-all -s ${sub} -i ${image_dir}/${sub}/T1w.nii -FLAIR ${image_dir}/${sub}/FLAIR.nii -FLAIRpial -all
    
done
