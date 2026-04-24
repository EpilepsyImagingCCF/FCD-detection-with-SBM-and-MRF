## 5. Surf-2-surf registration

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

    for h in $H
    do
        if [ ! -e "$sub"/xhemi ]; then
            surfreg --s "$sub" --t fsaverage_sym --lh
            surfreg --s "$sub" --t fsaverage_sym --lh --xhemi

            if [ ! -e "$sub"/xhemi/surf_meld ]; then
                mkdir "$sub"/xhemi/surf_meld
            fi
        fi
    done
done
