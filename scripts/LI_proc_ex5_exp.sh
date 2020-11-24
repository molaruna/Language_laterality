#!/bin/bash
# This script thresholds the individual task activation maps using percentile logarithm thresholding 
# from the summed task scan


script_name=$0
thr_opt=$1
list_thresh=$2
mask_type=$3
study_dir=$4

if [[ $1 == "-h" ]] || [[ $1 == "--help" ]]; then
	echo "$script_name -rnrme5 <list_of_thresholds> <mask_type>"
	echo "example: $script_name -rnrme5 ../Meta_data/exp_thresh_0.05.txt NS_full"
	echo "-rnrme5: relative exponential decay global summed thresholds w/ non-robust measures and manual mask (scale of 0.05)"
	exit
fi  

study_dir=$4
array_thresh=( $(cat $list_thresh) )
array_task_type=("AT" "VG" "MR" "PL")
sub_list="$study_dir/Meta_data/listSubsAllScansConserv_final.txt"
sub_arr=( $(cat $sub_list) )

	thr_type="rel_thresh_mask_exp_5"

for sub in ${sub_arr[@]}; do
	
	sub_fp=$study_dir/Volumes_raw/$sub

	scan_dir="$sub_fp/LI_proc_scans/$thr_type"
	nii_dir="$scan_dir/nii_scans"

	if [[ ! -d $scan_dir ]]; then

		mkdir $scan_dir
	fi

	if [[ ! -d $nii_dir ]]; then
		mkdir $nii_dir
	fi

    mv $scan_dir/*.nii $nii_dir
    echo "moving scans for $sub_fp"
	
	thresh_output="$scan_dir/list_thresholds_${thr_type}_${mask_type}_${sub}.txt"

	printf "thresholds,%spercent_thresh,%szstat_thresh,%s\n" > $thresh_output

	lang_mask="$study_dir/test/${mask_type}.nii.gz"
    sum_task_scan="$scan_dir/summed_task_scan_${mask_type}.nii.gz"

	#For thresholds using a summed scan from which to thresholds from
	for scan_type in "VG" "PL" "MR"; do
		scan_zstat2="$sub_fp/Fsl_Proc/${sub}_${scan_type}_2.3263_0ds.feat/stats/zstat2.nii.gz"
		scan_zstat2_mas="$sub_fp/${sub}_${scan_type}_2.3263_zstat2_${mask_type}_mask.nii.gz"
    
		lang_mask_sub="${scan_dir}/${sub}_lang_mask_reg_sub_${scan_type}.nii.gz"
    	lang_reg_mat="${sub_fp}/Fsl_Proc/${sub}_${scan_type}_2.3263_0ds.feat/reg/standard2example_func.mat"

		flirt -in $lang_mask -ref $scan_zstat2 -applyxfm -init $lang_reg_mat -out $lang_mask_sub
    	fslmaths $lang_mask_sub -thr 0.55 $lang_mask_sub
		fslmaths $scan_zstat2 -mas $lang_mask_sub $scan_zstat2_mas  
	done

	fslmerge -t $sum_task_scan $sub_fp/${sub}_VG_2.3263_zstat2_${mask_type}_mask.nii.gz $sub_fp/${sub}_MR_2.3263_zstat2_${mask_type}_mask.nii.gz $sub_fp/${sub}_PL_2.3263_zstat2_${mask_type}_mask.nii.gz

	fslmaths $sum_task_scan -thr 0 $sum_task_scan

	#For thresholds which require knowledge of task with highest z-stat from which to threshold from

	count=0
    for rel_thresh in ${array_thresh[@]}; do
		let "count++"
    	custom_name=${thr_opt:1}${count}

		#For a non-robust thresholding option
        curr_thr=$(fslstats $sum_task_scan -P $rel_thresh)
		

		#For logarithmic thresholding, add in percentile used in text output file
		printf "${count},%s${rel_thresh},%s${curr_thr},%s\n" >> $thresh_output
		

    	for scan_type in "AT" "PL" "VG" "MR"; do
        	scan_zstat2="$sub_fp/Fsl_Proc/${sub}_${scan_type}_2.3263_0ds.feat/stats/zstat2.nii.gz"
        	echo "beginning to process $sub for $custom_name $scan_type"                 

        	scan_thr="${scan_dir}/Feat_${sub}_${scan_type}_thr_${custom_name}_${mask_type}_noclust.nii.gz"
        	scan_mask="${scan_dir}/Feat_${sub}_${scan_type}_mask_${custom_name}_${mask_type}_noclust.nii.gz"

        	fslmaths $scan_zstat2 -thr $curr_thr $scan_thr
        	fslmaths $scan_thr -div $scan_thr $scan_mask

        	scan_reg_mat="${sub_fp}/Fsl_Proc/${sub}_${scan_type}_2.3263_0ds.feat/reg/example_func2standard.mat"
        	scan_standard="/netopt/rhel7/fsl/data/standard/MNI152_T1_2mm_brain.nii.gz"
        	scan_mask_reg="${scan_dir}/Feat_${sub}_${scan_type}_mask_reg_${custom_name}_${mask_type}_noclust.nii.gz"
        	flirt -in $scan_mask -ref $scan_standard -applyxfm -init $scan_reg_mat -out $scan_mask_reg

        	fslmaths $scan_mask_reg -div $scan_mask_reg $scan_mask_reg
		done
	done	
done
