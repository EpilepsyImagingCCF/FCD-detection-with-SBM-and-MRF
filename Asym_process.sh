## 7. Move features to xhemi

subjects_dir="path/to/subjects_dir"
cd ${subjects_dir}
export SUBJECTS_DIR=${subjects_dir}

## Change to list your subjects
subjects="sub1 sub2 sub3..."

H="lh rh"

Measures="thickness w-g.pct \
        gm_FLAIR_0 gm_FLAIR_0.25 gm_FLAIR_0.5 gm_FLAIR_0.75 wm_FLAIR_0.5 wm_FLAIR_1 \
	gm_MRF_T1_0 gm_MRF_T1_0.25 gm_MRF_T1_0.5 gm_MRF_T1_0.75 wm_MRF_T1_0.5 wm_MRF_T1_1 \
	gm_MRF_T2_tr_0 gm_MRF_T2_tr_0.25 gm_MRF_T2_tr_0.5 gm_MRF_T2_tr_0.75 wm_MRF_T2_tr_0.5 wm_MRF_T2_tr_1"

Measures2="pial.K_filtered_2_z"

Measures3="curv sulc"

# for each subject do the following
for sub in $subjects
do
    for m in $Measures
    do
        # Move onto left hemisphere
        mris_apply_reg --src  "$sub"/surf/lh."$m"_z.sm10.mgh --trg "$sub"/xhemi/surf/lh."$m"_z_on_lh.sm10.mgh  --streg "$sub"/surf/lh.sphere.reg fsaverage_sym/surf/lh.sphere.reg
        mris_apply_reg --src "$sub"/surf/rh."$m"_z.sm10.mgh --trg "$sub"/xhemi/surf/rh."$m"_z_on_lh.sm10.mgh    --streg "$sub"/xhemi/surf/lh.fsaverage_sym.sphere.reg     fsaverage_sym/surf/lh.sphere.reg

        mris_apply_reg --src  "$sub"/surf/lh."$m"_z.mgh --trg "$sub"/xhemi/surf/lh."$m"_z_on_lh.mgh  --streg "$sub"/surf/lh.sphere.reg fsaverage_sym/surf/lh.sphere.reg
        mris_apply_reg --src "$sub"/surf/rh."$m"_z.mgh --trg "$sub"/xhemi/surf/rh."$m"_z_on_lh.mgh    --streg "$sub"/xhemi/surf/lh.fsaverage_sym.sphere.reg     fsaverage_sym/surf/lh.sphere.reg

        mris_apply_reg --src  "$sub"/surf/lh."$m".sm10.mgh --trg "$sub"/xhemi/surf/lh."$m"_on_lh.sm10.mgh  --streg "$sub"/surf/lh.sphere.reg fsaverage_sym/surf/lh.sphere.reg
        mris_apply_reg --src "$sub"/surf/rh."$m".sm10.mgh --trg "$sub"/xhemi/surf/rh."$m"_on_lh.sm10.mgh    --streg "$sub"/xhemi/surf/lh.fsaverage_sym.sphere.reg     fsaverage_sym/surf/lh.sphere.reg
        
        mris_apply_reg --src  "$sub"/surf/lh."$m".mgh --trg "$sub"/xhemi/surf/lh."$m"_on_lh.mgh  --streg "$sub"/surf/lh.sphere.reg fsaverage_sym/surf/lh.sphere.reg
        mris_apply_reg --src "$sub"/surf/rh."$m".mgh --trg "$sub"/xhemi/surf/rh."$m"_on_lh.mgh    --streg "$sub"/xhemi/surf/lh.fsaverage_sym.sphere.reg     fsaverage_sym/surf/lh.sphere.reg

        # Calculate interhemispheric asymmetry
        mris_calc --output "$sub"/xhemi/surf/lh.lh-rh."$m"_z.sm10.mgh "$sub"/xhemi/surf/lh."$m"_z_on_lh.sm10.mgh sub "$sub"/xhemi/surf/rh."$m"_z_on_lh.sm10.mgh
        mris_calc --output "$sub"/xhemi/surf/lh.lh-rh."$m".sm10.mgh "$sub"/xhemi/surf/lh."$m"_on_lh.sm10.mgh sub "$sub"/xhemi/surf/rh."$m"_on_lh.sm10.mgh

        mris_calc --output "$sub"/xhemi/surf/lh.lh-rh."$m"_z.mgh "$sub"/xhemi/surf/lh."$m"_z_on_lh.mgh sub "$sub"/xhemi/surf/rh."$m"_z_on_lh.mgh
        mris_calc --output "$sub"/xhemi/surf/lh.lh-rh."$m".mgh "$sub"/xhemi/surf/lh."$m"_on_lh.mgh sub "$sub"/xhemi/surf/rh."$m"_on_lh.mgh
    done
    
    for m2 in $Measures2
    do
        # Move onto left hemisphere
        mris_apply_reg --src  "$sub"/surf/lh."$m2".sm20.mgh --trg "$sub"/xhemi/surf/lh."$m2"_on_lh.sm20.mgh  --streg "$sub"/surf/lh.sphere.reg  fsaverage_sym/surf/lh.sphere.reg
        mris_apply_reg --src "$sub"/surf/rh."$m2".sm20.mgh --trg "$sub"/xhemi/surf/rh."$m2"_on_lh.sm20.mgh    --streg "$sub"/xhemi/surf/lh.fsaverage_sym.sphere.reg $SUBJECTS_DIR/fsaverage_sym/surf/lh.sphere.reg
        
        mris_apply_reg --src  "$sub"/surf/lh."$m2".mgh --trg "$sub"/xhemi/surf/lh."$m2"_on_lh.mgh  --streg "$sub"/surf/lh.sphere.reg     fsaverage_sym/surf/lh.sphere.reg
        mris_apply_reg --src "$sub"/surf/rh."$m2".mgh --trg "$sub"/xhemi/surf/rh."$m2"_on_lh.mgh    --streg "$sub"/xhemi/surf/lh.fsaverage_sym.sphere.reg     $SUBJECTS_DIR/fsaverage_sym/surf/lh.sphere.reg

        # Asymmetry
        mris_calc --output "$sub"/xhemi/surf/lh.lh-rh."$m2".sm20.mgh "$sub"/xhemi/surf/lh."$m2"_on_lh.sm20.mgh sub "$sub"/xhemi/surf/rh."$m2"_on_lh.sm20.mgh

        mris_calc --output "$sub"/xhemi/surf/lh.lh-rh."$m2".mgh "$sub"/xhemi/surf/lh."$m2"_on_lh.mgh sub "$sub"/xhemi/surf/rh."$m2"_on_lh.mgh
    done

    for m3 in $Measures3
    do
        # Move onto left hemisphere
        mris_apply_reg --src  "$sub"/surf/lh."$m3".mgh --trg "$sub"/xhemi/surf/lh."$m3"_on_lh.mgh  --streg "$sub"/surf/lh.sphere.reg     fsaverage_sym/surf/lh.sphere.reg
        mris_apply_reg --src "$sub"/surf/rh."$m3".mgh --trg "$sub"/xhemi/surf/rh."$m3"_on_lh.mgh    --streg "$sub"/xhemi/surf/lh.fsaverage_sym.sphere.reg     fsaverage_sym/surf/lh.sphere.reg
        
        mris_apply_reg --src  "$sub"/surf/lh."$m3".mgh --trg "$sub"/xhemi/surf/lh."$m3"_on_lh.mgh  --streg "$sub"/surf/lh.sphere.reg     fsaverage_sym/surf/lh.sphere.reg
        mris_apply_reg --src "$sub"/surf/rh."$m3".mgh --trg "$sub"/xhemi/surf/rh."$m3"_on_lh.mgh    --streg "$sub"/xhemi/surf/lh.fsaverage_sym.sphere.reg     fsaverage_sym/surf/lh.sphere.reg

        # Asymmetry
        mris_calc --output "$sub"/xhemi/surf/lh.lh-rh."$m3".mgh "$sub"/xhemi/surf/lh."$m3"_on_lh.mgh sub "$sub"/xhemi/surf/rh."$m3"_on_lh.mgh

    done

    cp "$sub"/xhemi/surf/lh.lh-rh.pial.K_filtered_2_z.sm20.mgh "$sub"/xhemi/surf/rh.lh-rh.pial.K_filtered_2_z.sm20.mgh
    cp "$sub"/xhemi/surf/lh.lh-rh.thickness_z.sm10.mgh "$sub"/xhemi/surf/rh.lh-rh.thickness_z.sm10.mgh
    cp "$sub"/xhemi/surf/lh.lh-rh.w-g.pct_z.sm10.mgh "$sub"/xhemi/surf/rh.lh-rh.w-g.pct_z.sm10.mgh

    cp "$sub"/xhemi/surf/lh.lh-rh.pial.K_filtered_2_z.mgh "$sub"/xhemi/surf/rh.lh-rh.pial.K_filtered_2_z.mgh
    cp "$sub"/xhemi/surf/lh.lh-rh.thickness_z.mgh "$sub"/xhemi/surf/rh.lh-rh.thickness_z.mgh
    cp "$sub"/xhemi/surf/lh.lh-rh.w-g.pct_z.mgh "$sub"/xhemi/surf/rh.lh-rh.w-g.pct_z.mgh

    cp "$sub"/xhemi/surf/lh.lh-rh.gm_FLAIR_0_z.sm10.mgh "$sub"/xhemi/surf/rh.lh-rh.gm_FLAIR_0_z.sm10.mgh
    cp "$sub"/xhemi/surf/lh.lh-rh.gm_FLAIR_0.25_z.sm10.mgh "$sub"/xhemi/surf/rh.lh-rh.gm_FLAIR_0.25_z.sm10.mgh
    cp "$sub"/xhemi/surf/lh.lh-rh.gm_FLAIR_0.5_z.sm10.mgh "$sub"/xhemi/surf/rh.lh-rh.gm_FLAIR_0.5_z.sm10.mgh
    cp "$sub"/xhemi/surf/lh.lh-rh.gm_FLAIR_0.75_z.sm10.mgh "$sub"/xhemi/surf/rh.lh-rh.gm_FLAIR_0.75_z.sm10.mgh
    cp "$sub"/xhemi/surf/lh.lh-rh.wm_FLAIR_0.5_z.sm10.mgh "$sub"/xhemi/surf/rh.lh-rh.wm_FLAIR_0.5_z.sm10.mgh
    cp "$sub"/xhemi/surf/lh.lh-rh.wm_FLAIR_1_z.sm10.mgh "$sub"/xhemi/surf/rh.lh-rh.wm_FLAIR_1_z.sm10.mgh

    cp "$sub"/xhemi/surf/lh.lh-rh.gm_FLAIR_0_z.mgh "$sub"/xhemi/surf/rh.lh-rh.gm_FLAIR_0_z.mgh
    cp "$sub"/xhemi/surf/lh.lh-rh.gm_FLAIR_0.25_z.mgh "$sub"/xhemi/surf/rh.lh-rh.gm_FLAIR_0.25_z.mgh
    cp "$sub"/xhemi/surf/lh.lh-rh.gm_FLAIR_0.5_z.mgh "$sub"/xhemi/surf/rh.lh-rh.gm_FLAIR_0.5_z.mgh
    cp "$sub"/xhemi/surf/lh.lh-rh.gm_FLAIR_0.75_z.mgh "$sub"/xhemi/surf/rh.lh-rh.gm_FLAIR_0.75_z.mgh
    cp "$sub"/xhemi/surf/lh.lh-rh.wm_FLAIR_0.5_z.mgh "$sub"/xhemi/surf/rh.lh-rh.wm_FLAIR_0.5_z.mgh
    cp "$sub"/xhemi/surf/lh.lh-rh.wm_FLAIR_1_z.mgh "$sub"/xhemi/surf/rh.lh-rh.wm_FLAIR_1_z.mgh

    cp "$sub"/xhemi/surf/lh.lh-rh.gm_FLAIR_0.sm10.mgh "$sub"/xhemi/surf/rh.lh-rh.gm_FLAIR_0.sm10.mgh
    cp "$sub"/xhemi/surf/lh.lh-rh.gm_FLAIR_0.25.sm10.mgh "$sub"/xhemi/surf/rh.lh-rh.gm_FLAIR_0.25.sm10.mgh
    cp "$sub"/xhemi/surf/lh.lh-rh.gm_FLAIR_0.5.sm10.mgh "$sub"/xhemi/surf/rh.lh-rh.gm_FLAIR_0.5.sm10.mgh  
    cp "$sub"/xhemi/surf/lh.lh-rh.gm_FLAIR_0.75.sm10.mgh "$sub"/xhemi/surf/rh.lh-rh.gm_FLAIR_0.75.sm10.mgh
    cp "$sub"/xhemi/surf/lh.lh-rh.wm_FLAIR_0.5.sm10.mgh "$sub"/xhemi/surf/rh.lh-rh.wm_FLAIR_0.5.sm10.mgh
    cp "$sub"/xhemi/surf/lh.lh-rh.wm_FLAIR_1.sm10.mgh "$sub"/xhemi/surf/rh.lh-rh.wm_FLAIR_1.sm10.mgh

    cp "$sub"/xhemi/surf/lh.lh-rh.gm_FLAIR_0.mgh "$sub"/xhemi/surf/rh.lh-rh.gm_FLAIR_0.mgh
    cp "$sub"/xhemi/surf/lh.lh-rh.gm_FLAIR_0.25.mgh "$sub"/xhemi/surf/rh.lh-rh.gm_FLAIR_0.25.mgh
    cp "$sub"/xhemi/surf/lh.lh-rh.gm_FLAIR_0.5.mgh "$sub"/xhemi/surf/rh.lh-rh.gm_FLAIR_0.5.mgh  
    cp "$sub"/xhemi/surf/lh.lh-rh.gm_FLAIR_0.75.mgh "$sub"/xhemi/surf/rh.lh-rh.gm_FLAIR_0.75.mgh
    cp "$sub"/xhemi/surf/lh.lh-rh.wm_FLAIR_0.5.mgh "$sub"/xhemi/surf/rh.lh-rh.wm_FLAIR_0.5.mgh
    cp "$sub"/xhemi/surf/lh.lh-rh.wm_FLAIR_1.mgh "$sub"/xhemi/surf/rh.lh-rh.wm_FLAIR_1.mgh

    cp "$sub"/xhemi/surf/lh.lh-rh.gm_MRF_T1_0.sm10.mgh "$sub"/xhemi/surf/rh.lh-rh.gm_MRF_T1_0.sm10.mgh
    cp "$sub"/xhemi/surf/lh.lh-rh.gm_MRF_T1_0.25.sm10.mgh "$sub"/xhemi/surf/rh.lh-rh.gm_MRF_T1_0.25.sm10.mgh
    cp "$sub"/xhemi/surf/lh.lh-rh.gm_MRF_T1_0.5.sm10.mgh "$sub"/xhemi/surf/rh.lh-rh.gm_MRF_T1_0.5.sm10.mgh
    cp "$sub"/xhemi/surf/lh.lh-rh.gm_MRF_T1_0.75.sm10.mgh "$sub"/xhemi/surf/rh.lh-rh.gm_MRF_T1_0.75.sm10.mgh
    cp "$sub"/xhemi/surf/lh.lh-rh.wm_MRF_T1_0.5.sm10.mgh "$sub"/xhemi/surf/rh.lh-rh.wm_MRF_T1_0.5.sm10.mgh
    cp "$sub"/xhemi/surf/lh.lh-rh.wm_MRF_T1_1.sm10.mgh "$sub"/xhemi/surf/rh.lh-rh.wm_MRF_T1_1.sm10.mgh

    cp "$sub"/xhemi/surf/lh.lh-rh.gm_MRF_T1_0.mgh "$sub"/xhemi/surf/rh.lh-rh.gm_MRF_T1_0.mgh
    cp "$sub"/xhemi/surf/lh.lh-rh.gm_MRF_T1_0.25.mgh "$sub"/xhemi/surf/rh.lh-rh.gm_MRF_T1_0.25.mgh
    cp "$sub"/xhemi/surf/lh.lh-rh.gm_MRF_T1_0.5.mgh "$sub"/xhemi/surf/rh.lh-rh.gm_MRF_T1_0.5.mgh
    cp "$sub"/xhemi/surf/lh.lh-rh.gm_MRF_T1_0.75.mgh "$sub"/xhemi/surf/rh.lh-rh.gm_MRF_T1_0.75.mgh  
    cp "$sub"/xhemi/surf/lh.lh-rh.wm_MRF_T1_0.5.mgh "$sub"/xhemi/surf/rh.lh-rh.wm_MRF_T1_0.5.mgh    
    cp "$sub"/xhemi/surf/lh.lh-rh.wm_MRF_T1_1.mgh "$sub"/xhemi/surf/rh.lh-rh.wm_MRF_T1_1.mgh

    cp "$sub"/xhemi/surf/lh.lh-rh.gm_MRF_T1_0_z.sm10.mgh "$sub"/xhemi/surf/rh.lh-rh.gm_MRF_T1_0_z.sm10.mgh
    cp "$sub"/xhemi/surf/lh.lh-rh.gm_MRF_T1_0.25_z.sm10.mgh "$sub"/xhemi/surf/rh.lh-rh.gm_MRF_T1_0.25_z.sm10.mgh
    cp "$sub"/xhemi/surf/lh.lh-rh.gm_MRF_T1_0.5_z.sm10.mgh "$sub"/xhemi/surf/rh.lh-rh.gm_MRF_T1_0.5_z.sm10.mgh
    cp "$sub"/xhemi/surf/lh.lh-rh.gm_MRF_T1_0.75_z.sm10.mgh "$sub"/xhemi/surf/rh.lh-rh.gm_MRF_T1_0.75_z.sm10.mgh
    cp "$sub"/xhemi/surf/lh.lh-rh.wm_MRF_T1_0.5_z.sm10.mgh "$sub"/xhemi/surf/rh.lh-rh.wm_MRF_T1_0.5_z.sm10.mgh
    cp "$sub"/xhemi/surf/lh.lh-rh.wm_MRF_T1_1_z.sm10.mgh "$sub"/xhemi/surf/rh.lh-rh.wm_MRF_T1_1_z.sm10.mgh

    cp "$sub"/xhemi/surf/lh.lh-rh.gm_MRF_T1_0_z.mgh "$sub"/xhemi/surf/rh.lh-rh.gm_MRF_T1_0_z.mgh
    cp "$sub"/xhemi/surf/lh.lh-rh.gm_MRF_T1_0.25_z.mgh "$sub"/xhemi/surf/rh.lh-rh.gm_MRF_T1_0.25_z.mgh
    cp "$sub"/xhemi/surf/lh.lh-rh.gm_MRF_T1_0.5_z.mgh "$sub"/xhemi/surf/rh.lh-rh.gm_MRF_T1_0.5_z.mgh
    cp "$sub"/xhemi/surf/lh.lh-rh.gm_MRF_T1_0.75_z.mgh "$sub"/xhemi/surf/rh.lh-rh.gm_MRF_T1_0.75_z.mgh
    cp "$sub"/xhemi/surf/lh.lh-rh.wm_MRF_T1_0.5_z.mgh "$sub"/xhemi/surf/rh.lh-rh.wm_MRF_T1_0.5_z.mgh
    cp "$sub"/xhemi/surf/lh.lh-rh.wm_MRF_T1_1_z.mgh "$sub"/xhemi/surf/rh.lh-rh.wm_MRF_T1_1_z.mgh
    
    cp "$sub"/xhemi/surf/lh.lh-rh.gm_MRF_T2_tr_0.sm10.mgh "$sub"/xhemi/surf/rh.lh-rh.gm_MRF_T2_tr_0.sm10.mgh
    cp "$sub"/xhemi/surf/lh.lh-rh.gm_MRF_T2_tr_0.25.sm10.mgh "$sub"/xhemi/surf/rh.lh-rh.gm_MRF_T2_tr_0.25.sm10.mgh
    cp "$sub"/xhemi/surf/lh.lh-rh.gm_MRF_T2_tr_0.5.sm10.mgh "$sub"/xhemi/surf/rh.lh-rh.gm_MRF_T2_tr_0.5.sm10.mgh
    cp "$sub"/xhemi/surf/lh.lh-rh.gm_MRF_T2_tr_0.75.sm10.mgh "$sub"/xhemi/surf/rh.lh-rh.gm_MRF_T2_tr_0.75.sm10.mgh
    cp "$sub"/xhemi/surf/lh.lh-rh.wm_MRF_T2_tr_0.5.sm10.mgh "$sub"/xhemi/surf/rh.lh-rh.wm_MRF_T2_tr_0.5.sm10.mgh
    cp "$sub"/xhemi/surf/lh.lh-rh.wm_MRF_T2_tr_1.sm10.mgh "$sub"/xhemi/surf/rh.lh-rh.wm_MRF_T2_tr_1.sm10.mgh

    cp "$sub"/xhemi/surf/lh.lh-rh.gm_MRF_T2_tr_0.mgh "$sub"/xhemi/surf/rh.lh-rh.gm_MRF_T2_tr_0.mgh
    cp "$sub"/xhemi/surf/lh.lh-rh.gm_MRF_T2_tr_0.25.mgh "$sub"/xhemi/surf/rh.lh-rh.gm_MRF_T2_tr_0.25.mgh
    cp "$sub"/xhemi/surf/lh.lh-rh.gm_MRF_T2_tr_0.5.mgh "$sub"/xhemi/surf/rh.lh-rh.gm_MRF_T2_tr_0.5.mgh
    cp "$sub"/xhemi/surf/lh.lh-rh.gm_MRF_T2_tr_0.75.mgh "$sub"/xhemi/surf/rh.lh-rh.gm_MRF_T2_tr_0.75.mgh
    cp "$sub"/xhemi/surf/lh.lh-rh.wm_MRF_T2_tr_0.5.mgh "$sub"/xhemi/surf/rh.lh-rh.wm_MRF_T2_tr_0.5.mgh
    cp "$sub"/xhemi/surf/lh.lh-rh.wm_MRF_T2_tr_1.mgh "$sub"/xhemi/surf/rh.lh-rh.wm_MRF_T2_tr_1.mgh

    cp "$sub"/xhemi/surf/lh.lh-rh.gm_MRF_T2_tr_0_z.sm10.mgh "$sub"/xhemi/surf/rh.lh-rh.gm_MRF_T2_tr_0_z.sm10.mgh
    cp "$sub"/xhemi/surf/lh.lh-rh.gm_MRF_T2_tr_0.25_z.sm10.mgh "$sub"/xhemi/surf/rh.lh-rh.gm_MRF_T2_tr_0.25_z.sm10.mgh
    cp "$sub"/xhemi/surf/lh.lh-rh.gm_MRF_T2_tr_0.5_z.sm10.mgh "$sub"/xhemi/surf/rh.lh-rh.gm_MRF_T2_tr_0.5_z.sm10.mgh
    cp "$sub"/xhemi/surf/lh.lh-rh.gm_MRF_T2_tr_0.75_z.sm10.mgh "$sub"/xhemi/surf/rh.lh-rh.gm_MRF_T2_tr_0.75_z.sm10.mgh
    cp "$sub"/xhemi/surf/lh.lh-rh.wm_MRF_T2_tr_0.5_z.sm10.mgh "$sub"/xhemi/surf/rh.lh-rh.wm_MRF_T2_tr_0.5_z.sm10.mgh
    cp "$sub"/xhemi/surf/lh.lh-rh.wm_MRF_T2_tr_1_z.sm10.mgh "$sub"/xhemi/surf/rh.lh-rh.wm_MRF_T2_tr_1_z.sm10.mgh

    cp "$sub"/xhemi/surf/lh.lh-rh.gm_MRF_T2_tr_0_z.mgh "$sub"/xhemi/surf/rh.lh-rh.gm_MRF_T2_tr_0_z.mgh
    cp "$sub"/xhemi/surf/lh.lh-rh.gm_MRF_T2_tr_0.25_z.mgh "$sub"/xhemi/surf/rh.lh-rh.gm_MRF_T2_tr_0.25_z.mgh
    cp "$sub"/xhemi/surf/lh.lh-rh.gm_MRF_T2_tr_0.5_z.mgh "$sub"/xhemi/surf/rh.lh-rh.gm_MRF_T2_tr_0.5_z.mgh
    cp "$sub"/xhemi/surf/lh.lh-rh.gm_MRF_T2_tr_0.75_z.mgh "$sub"/xhemi/surf/rh.lh-rh.gm_MRF_T2_tr_0.75_z.mgh
    cp "$sub"/xhemi/surf/lh.lh-rh.wm_MRF_T2_tr_0.5_z.mgh "$sub"/xhemi/surf/rh.lh-rh.wm_MRF_T2_tr_0.5_z.mgh
    cp "$sub"/xhemi/surf/lh.lh-rh.wm_MRF_T2_tr_1_z.mgh "$sub"/xhemi/surf/rh.lh-rh.wm_MRF_T2_tr_1_z.mgh
done

