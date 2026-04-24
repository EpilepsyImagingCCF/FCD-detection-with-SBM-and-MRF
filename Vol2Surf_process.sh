## 2. sample MRF and FLAIR and smooth features

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

    # Create identity matrix
    bbregister --s "$sub" --mov "$sub" --mov "$sub"/mri/brainmask.mgz --reg "$sub"/mri/transforms/Identity.dat --init-fsl --t1

    #for each hemisphere
    for h in $H
    do

        # Sample FLAIR at 25%, 50%, 75% of the cortical thickness & at the grey-white matter boundary & smooth using 10mm Gaussian kernel
        D="0.5 0.25 0.75 0"

        for d in $D
        do
            echo ${s}

            #sampling volume to surface
            mri_vol2surf --src "$sub"/mri/FLAIR.mgz --out "$sub"/surf/"$h".gm_FLAIR_"$d".mgh --hemi "$h" --projfrac "$d" --srcreg "$sub"/mri/transforms/Identity.dat --trgsubject "$sub" --surf white
            mri_vol2surf --src "$sub"/mri/MRF_T1.mgz --out "$sub"/surf/"$h".gm_MRF_T1_"$d".mgh --hemi "$h" --projfrac "$d" --srcreg "$sub"/mri/transforms/Identity.dat --trgsubject "$sub" --surf white
            mri_vol2surf --src "$sub"/mri/MRF_T2_tr.mgz --out "$sub"/surf/"$h".gm_MRF_T2_tr_"$d".mgh --hemi "$h" --projfrac "$d" --srcreg "$sub"/mri/transforms/Identity.dat --trgsubject "$sub" --surf white
           
            #smoothing
            mris_fwhm --s "$sub" --hemi "$h" --cortex --smooth-only --fwhm 10 --i "$sub"/surf/"$h".gm_FLAIR_"$d".mgh --o "$sub"/surf/"$h".gm_FLAIR_"$d".sm10.mgh
            mris_fwhm --s "$sub" --hemi "$h" --cortex --smooth-only --fwhm 10 --i "$sub"/surf/"$h".gm_MRF_T1_"$d".mgh --o "$sub"/surf/"$h".gm_MRF_T1_"$d".sm10.mgh
            mris_fwhm --s "$sub" --hemi "$h" --cortex --smooth-only --fwhm 10 --i "$sub"/surf/"$h".gm_MRF_T2_tr_"$d".mgh --o "$sub"/surf/"$h".gm_MRF_T2_tr_"$d".sm10.mgh
	done

        # Sample FLAIR 0.5mm and 1mm subcortically & smooth using 10mm Gaussian kernel
        D_wm="0.5 1"

        for d_wm in $D_wm
        do

            mri_vol2surf --src "$sub"/mri/FLAIR.mgz --out "$sub"/surf/"$h".wm_FLAIR_"$d_wm".mgh --hemi "$h" --projdist -"$d_wm" --srcreg "$sub"/mri/transforms/Identity.dat --trgsubject "$sub" --surf white
            mri_vol2surf --src "$sub"/mri/MRF_T1.mgz --out "$sub"/surf/"$h".wm_MRF_T1_"$d_wm".mgh --hemi "$h" --projdist -"$d_wm" --srcreg "$sub"/mri/transforms/Identity.dat --trgsubject "$sub" --surf white
            mri_vol2surf --src "$sub"/mri/MRF_T2_tr.mgz --out "$sub"/surf/"$h".wm_MRF_T2_tr_"$d_wm".mgh --hemi "$h" --projdist -"$d_wm" --srcreg "$sub"/mri/transforms/Identity.dat --trgsubject "$sub" --surf white

            mris_fwhm --s "$sub" --hemi "$h" --cortex --smooth-only --fwhm 10 --i "$sub"/surf/"$h".wm_FLAIR_"$d_wm".mgh --o "$sub"/surf/"$h".wm_FLAIR_"$d_wm".sm10.mgh
            mris_fwhm --s "$sub" --hemi "$h" --cortex --smooth-only --fwhm 10 --i "$sub"/surf/"$h".wm_MRF_T1_"$d_wm".mgh --o "$sub"/surf/"$h".wm_MRF_T1_"$d_wm".sm10.mgh
            mris_fwhm --s "$sub" --hemi "$h" --cortex --smooth-only --fwhm 10 --i "$sub"/surf/"$h".wm_MRF_T2_tr_"$d_wm".mgh --o "$sub"/surf/"$h".wm_MRF_T2_tr_"$d_wm".sm10.mgh
        done

        # Smooth cortical thickness and grey white matter intensity contrast

        mris_fwhm --s "$sub" --hemi "$h" --cortex --smooth-only --fwhm 10 --i "$sub"/surf/"$h".thickness --o "$sub"/surf/"$h".thickness.sm10.mgh
        mris_fwhm --s "$sub" --hemi "$h" --cortex --smooth-only --fwhm 10 --i "$sub"/surf/"$h".w-g.pct.mgh --o "$sub"/surf/"$h".w-g.pct.sm10.mgh
        mris_fwhm --s "$sub" --hemi "$h" --cortex --smooth-only --fwhm 5 --i "$sub"/surf/"$h".w-g.pct.mgh --o "$sub"/surf/"$h".w-g.pct.sm5.mgh

        # Calculate curvature

        mris_curvature_stats -f white -g --writeCurvatureFiles "$sub" "$h" curv
        mris_curvature_stats -f pial -g --writeCurvatureFiles "$sub" "$h" curv

        # Convert mean curvature and sulcal depth to .mgh file type
        mris_convert -c "$sub"/surf/"$h".thickness "$sub"/surf/"$h".white "$sub"/surf/"$h".thickness.mgh
        mris_convert -c "$sub"/surf/"$h".curv "$sub"/surf/"$h".white "$sub"/surf/"$h".curv.mgh
        mris_convert -c "$sub"/surf/"$h".sulc "$sub"/surf/"$h".white "$sub"/surf/"$h".sulc.mgh
        mris_convert -c "$sub"/surf/"$h".pial.K.crv "$sub"/surf/"$h".white "$sub"/surf/"$h".pial.K.mgh

    done
done
