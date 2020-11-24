#!/bin/bash

# This script processes the postoperative resection mask and activation map
# to find the volumetric intersection between the two

inputDir=$1
scanType=$2
studyDir=$3

subArray=( $(cat ${studyDir}/Meta_data/postop_IDs.txt) )

for sub in ${subArray[@]}; do
	echo $sub
	subDir="${studyDir}/Volumes/${sub}/postop_scans"
	resect_reg="${subDir}/${sub}_resection_reg_v2.nii.gz"

	#register ROI masks to T1 pre-op space
	if [[ ! -f $resect_reg ]]; then
		flirt -in ${subDir}/${sub}_resection_ROI*LS.nii.gz -ref ${studyDir}/Volumes/${sub}/${sub}_T1_brain.nii -out ${resect_reg} -init ${subDir}/${sub}_*toT1_CR*.mat -applyxfm
	fi

	#threshold the masks: values < 0.5 = 0
	resect_reg_thr="${subDir}/${sub}_resection_reg_thr_v2.nii.gz"
	fslmaths ${resect_reg} -thr 0.5 ${resect_reg_thr}
	
	#binarize registered mask
	fslmaths $resect_reg_thr -div $resect_reg_thr ${subDir}/${sub}_resection_mask_v2.nii.gz	

	#register MR using FSL funcToT1 matrix
	flirt -in ${studyDir}/Volumes/${sub}/LI_proc_scans/rel_thresh_mask_exp_5/Feat_${sub}_MR_thr_rnrme552_NS_full_noclust.nii.gz -ref ${studyDir}/Volumes/${sub}/${sub}_T1_brain.nii -out ${subDir}/${sub}_optLI_MRtoT1_thr.nii.gz -init ${studyDir}/Volumes/${sub}/Fsl_Proc/${sub}_MR_2.3263_0ds.feat/reg/example_func2highres.mat -applyxfm

	#now register VG...
	flirt -in ${studyDir}/Volumes/${sub}/LI_proc_scans/rel_thresh_mask_exp_5/Feat_${sub}_VG_thr_rnrme552_NS_full_noclust.nii.gz -ref ${studyDir}/Volumes/${sub}/${sub}_T1_brain.nii -out ${subDir}/${sub}_optLI_VGtoT1_thr.nii.gz -init ${studyDir}/Volumes/${sub}/Fsl_Proc/${sub}_VG_2.3263_0ds.feat/reg/example_func2highres.mat -applyxfm

	#add VG + MR lang masks
	fslmaths ${subDir}/${sub}_optLI_MRtoT1_thr.nii.gz -add ${subDir}/${sub}_optLI_VGtoT1_thr.nii.gz ${subDir}/${sub}_optLI_reg.nii.gz

	#threshold bottom 10 percentage & mask
	fslmaths ${subDir}/${sub}_optLI_reg.nii.gz -thrP 10 -bin ${subDir}/${sub}_optLI_reg_mask.nii.gz

	#create binarized intersection mask
	fslmaths ${subDir}/${sub}_optLI_reg_mask.nii.gz -mas ${subDir}/${sub}_resection_mask_v2.nii.gz -bin ${subDir}/${sub}_mask_overlap.nii.gz

	#count volume of overlap
	fslstats ${subDir}/${sub}_mask_overlap.nii.gz -V 
done
