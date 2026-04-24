## 4. smooth the intrinsic curvature

subjects_dir="path/to/subjects_dir"
cd ${subjects_dir}
export SUBJECTS_DIR=${subjects_dir}

## Change to list your subject
subjects="sub1 sub2 sub3..."

H="lh rh"

# for each subject do the following
for sub in $subjects
do
    echo ${sub}

    #for each hemisphere
    for h in $H
    do

        mris_fwhm --s "$sub" --hemi "$h" --cortex --smooth-only --fwhm 20 --i "$sub"/surf/"$h".pial.K_filtered_2.mgh --o "$sub"/surf/"$h".pial.K_filtered_2.sm20.mgh

    done
done
