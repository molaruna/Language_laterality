#!/bin/bash

# This script computes the overlap between the two candidate language masks
# And the language/auditory task activation maps used


study_dir=$1

mask_dir="${study_dir}/Processing/lang_rois/overlap"
arr_masks=("NS_fwd" "NS_rev" "HO_lang")
arr_submasks=("full" "ant" "post")
arr_tasks=("AT" "PL" "MR" "VG")
output=$study_dir/Meta_data/table_overlap.csv
#Header row
printf "mask_submask,%s" > $output

for task in ${arr_tasks[@]}; do
	printf "${task}_mask_activ,%s${task}_mask_tot,%s${task}_activ_tot,%s" >> $output
done

printf "\n" >> $output

for mask in ${arr_masks[@]}; do
	#echo "processing mask $mask"

	for submask in ${arr_submasks[@]}; do
		printf "${mask}_${submask},%s" >> $output
		for task in ${arr_tasks[@]}; do
			echo "processing mask $mask $submask $task"
			fslmaths ${mask_dir}/activ_masks/${task}_activ_mask.nii.gz -mas ${mask_dir}/${mask}_${submask}.nii.gz ${mask_dir}/${task}_${mask}_${submask}_intersect.nii.gz

			mask_activ=$(fslstats ${mask_dir}/${task}_${mask}_${submask}_intersect.nii.gz -V)
			mask_activ=${mask_activ%% *}
			mask_tot=$(fslstats ${mask_dir}/${mask}_${submask}.nii.gz -V)
			mask_tot=${mask_tot%% *}
			activ_tot=$(fslstats ${mask_dir}/activ_masks/${task}_activ_mask_${submask}.nii.gz -V)
			activ_tot=${activ_tot%% *}
			printf "${mask_activ},%s${mask_tot},%s${activ_tot},%s" >> $output
		done
	printf "\n" >> $output
	done
done
	 

