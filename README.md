# Surface-based Detection of Focal Cortical Dysplasia using Magnetic Resonance Fingerprinting and Machine Learning

This repository provides the complete processing pipeline and code accompanying the research paper:

**Su TY**, Hu S, Wang X, Adler S, Wagstyl K, Ding Z, Choi JY, Sakaie K, Blümcke I, Murakami H, Alexopoulos AV, Jones SE, Najm I, Ma D, Wang ZI.  
Surfaced-based detection of focal cortical dysplasia using magnetic resonance fingerprinting and machine learning.  
*Epilepsia*. 2026 Jan;67(1):257-271. doi: 10.1111/epi.18667. Epub 2025 Oct 9. PMID: 41066149; PMCID: PMC12893262.

The pipeline enables surface-based analysis of Magnetic Resonance Fingerprinting (MRF) data combined with machine learning for improved detection of Focal Cortical Dysplasia (FCD) lesions in patients with drug-resistant epilepsy.
```
## Repository Structure
Data_dir/
├── P01/                  # Patient folders
│   ├── T1w.nii
│   ├── MRF_M0.nii
│   ├── MRF_T1w.nii
│   ├── MRF_T1.nii
│   ├── MRF_T2.nii
│   └── FLAIR.nii
├── P02/
├── ...
├── V01/                  # Healthy control (volunteer) folders
├── V02/
└── ...
```

Each subject directory contains the raw T1-weighted anatomical image, MRF-derived quantitative maps (M0, T1w, T1, T2), and FLAIR image.

## Pipeline Overview

The workflow consists of the following major stages:

1. **FreeSurfer Reconstruction**  
   Run `Recon_all_process.sh` to perform cortical surface reconstruction on the T1w image for all subjects.

2. **Skull Stripping and Preprocessing of MRF Maps**  
   - (Optional but recommended) Use `mri_synthstrip`(FreeSurfer function) on `MRF_M0.nii` to generate a brain mask.  
   - Apply the mask to MRF_T1w, MRF_T1, and MRF_T2 maps.  
   - Truncate extreme values in the T2 map using `MRF_T2_revision.m`.

3. **Registration and Surface Projection**  
   - Register MRF quantitative maps to the FreeSurfer space (`Reg_MRF_2_FS_batch.sh`).  
   - Project volume data onto the cortical surface and apply smoothing (`Vol2Surf_process.sh`).

4. **Intrinsic Curvature Computation**  
   - Generate intrinsic curvature maps (`Intrinsic_curv_gen.m`).  
   - Smooth the curvature maps (`Intrinsic_curv_sm.sh`).

5. **Normalization**  
   - Perform intra-subject z-score normalization (`IntraSubject_norm.m`).  
   - Perform surface-based registration to `fsaverage_sym` and generate asymmetric (left-right) maps (`Surf2Surf_reg.sh` + `Asym_process.sh`).  
   - Perform inter-subject z-score normalization using healthy controls (`InterSubject_norm.m`).

6. **Machine Learning Data Preparation**  
   - Generate FLAIR lists for patients and controls.  
   - Create training and testing datasets using leave-one-out (LOO) cross-validation (`ML_data_gen.m`).  
     Lesional vertices are taken from known FCD regions; normal vertices are sampled from healthy controls and the contralateral hemisphere (with downsampling to balance classes).

7. **Model Training and Prediction**  
   - Train a binary classifier with leave-one-out cross-validation (`Train_SBM_LOO_BCE.py`).  
   - Convert model outputs to surface-compatible format (`python_ML_2_mgz.m`).

8. **Performance Evaluation**  
   - Vertex-wise evaluation and parameter selection using AUC (`Vertex_perf_eva.m`).  
   - Cluster-wise analysis, thresholding, feature extraction, secondary classification, and final evaluation (`Cluster_characterization_in_batch.m`).

9. **Surface-to-Volume Conversion**  
   - Transform final surface-based predictions back to volumetric space (`Surf2Vol_in_batch.sh`).

## Lesion Mask Processing (Optional but Recommended)

If you have manually drawn lesion ROIs:

- Draw and smooth lesion masks on MRF maps.  
- Register lesion masks to FreeSurfer space.  
- Binarize, convert formats, rename according to hemisphere, project to surface, and register to `fsaverage_sym` template using the dedicated scripts (`Volumetric_lesion_prop.m`, `Convert_lesion_format.sh`, `Vol2surf_in_batch.sh`, `Regis_lesion_2_fsa.sh`, etc.).

Detailed step-by-step instructions for lesion mask handling are provided in the individual script headers and comments.

## Requirements

- FreeSurfer (tested with ver 7.4.1)  
- FSL  
- MATLAB (with Image Processing Toolbox and Statistics Toolbox)  
- Python 3 (with tensorflow.keras and scikit-learn depending on the classifier implementation)  
- mri_synthstrip (part of FreeSurfer)

**Important**: Some scripts may require minor path adjustments. Please review the header comments of each script before running.

## Usage Notes

- The pipeline combines shell scripts (`.sh`) for batch processing and MATLAB scripts (`.m`) for specialized computations. These can be executed interchangeably depending on the processing stage.  
- A large number of normal vertices are downsampled during ML data generation to maintain class balance.  
- For any questions or issues, please contact the corresponding author:  
  **Ting-Yu Su** – sut3@ccf.org

## Citation

If you use this code or data processing pipeline in your research, please cite the original paper:

Su TY, Hu S, Wang X, et al. Surfaced-based detection of focal cortical dysplasia using magnetic resonance fingerprinting and machine learning. *Epilepsia*. 2026;67(1):257-271. doi:10.1111/epi.18667
