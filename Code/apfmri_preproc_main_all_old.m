%% 1. BASIC SETTING

basedir = '/Users/cnir/Documents/cocoanlab/animal_fMRI';
pathdef = fullfile(basedir, 'experiment_path_def.m');
run(pathdef);

subject_code = 'mango_170405';
subject_dir = apfmri_structural_0_make_directories(subject_code);

%% PREPROC: RUN THESE ON STRUCTURAL SCANS DURING RUN 1 (AFTER STRUCTURAL SCAN)

%% 2. DICOM TO NIFTI: STRUCTURAL ==========================================

apfmri_structural_1_dicom2nifti(subject_dir);

%% 3. DICOM TO NIFTI: FUNCTIONAL -- to get reference ======================

session_num = 1;
disdaq = 5;
apfmri_functional_1_dicom2nifti(subject_dir, session_num, disdaq);

%% 4. save implicit mask and mean functional image ========================

apfmri_functional_2_implicitmask_savemean(subject_dir, session_num);


%% 5. COREGISTRATION TO FUNCTIONAL

apfmri_structural_2_coregistration(subject_dir);

%% 4. REORIENTATION =======================================================

apfmri_structural_3_reorientation(subject_dir)


%% 5. SAVE REORIENTATION MATRIX
apfmri_structural_4_save_reorientation_mat(subject_dir);


%% 6. SEGMENTATION AND SAVING WARPING MATRIX FOR LATER ====================

apfmri_structural_5_segment(subject_dir);


%% 7. DICOM TO NIFTI: FUNCTIONAL (RUN2) ===================================
session_num = 2;
disdaq = 5;

apfmri_functional_1_dicom2nifti(subject_dir, session_num, disdaq);


%% 8. Reorientation =======================================================

apfmri_functional_3_reorient(subject_dir, session_num);


%% 9. Detect spikes, outliers =============================================
 
apfmri_functional_4_spike_id(subject_dir, session_num);
 

%% 10. SLICE TIME CORRECTION ===============================================

apfmri_functional_5_slice_timing(subject_dir, session_num, 'TR', 1.2, 'MBF', 2, 'acq', 'interleaved_TD');

%% optional
dicom_img = filenames(fullfile(subject_dir, 'Functional', 'dicom', 'r02', '*IMA'));
hdr = dicominfo(dicom_img{1});
slice_time = hdr.Private_0019_1029;

apfmri_functional_5_slice_timing(subject_dir, session_num, 'TR', 1.2, 'MBF', 2, 'acq', 'interleaved_TD', 'slice_time', slice_time);

%% 11. MOTION CORRECTION ===================================================

apfmri_functional_6_motion_correction(subject_dir, session_num);


%% 12. Normalization =======================================================

apfmri_functional_7_normalization(subject_dir, session_num);


%% 12. Smoothing 

PREPROC = apfmri_functional_8_smooth(subject_dir, session_num);


%% 13. Regression

dat = fmri_data_rhesus(PREPROC.swrao_func_files{session_num});
dat.X = out.event_regressor(:,1);

%% Regression
stats = regress(dat, .05, 'unc');

stats.b.dat = stats.b.dat(:,1);
stats.b.sig = stats.b.sig(:,1);
stats.b.p = stats.b.p(:,1);
stats.b.ste = stats.b.ste(:,1);

%% visualization without thresholding
b_dat = fmri_data(stats.b);
orthviews_rhesus(b_dat)

%% visualization with thresholding

b_dat.dat = b_dat.dat .* stats.b.sig;
orthviews_rhesus(t_dat)


