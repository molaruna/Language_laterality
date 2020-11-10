% Compute laterality index

usr_spm = input('Choose which version of spm8 you want to use (ex: spm8-2):\n', 's');

spm_path = ['/data/sugrue2/Maria/', usr_spm, '/'];
addpath(spm_path)

study_dir = '/data/sugrue2/Lang';
sub_dir = [study_dir, '/Volumes_raw'];
lang_ROI_dir = [study_dir, '/Processing/lang_rois'];
usr_mask = input('Please enter in the mask(s) you would like to use\n');
%list_ROI_maps = [study_dir, '/Processing/lang_rois/', usr_mask]; 
list_ROI_maps = usr_mask

usr_in = input('Choose from the following options:\n [1] Process all subjects\n [2] Choose which subjects to process\n');
   
    
if usr_in == 1
   sub_proc_out = sub_list;
elseif usr_in == 2
   usr_subs = inputdlg('Please enter the ID of all the subjects you would like to process\n');
   sub_proc_out = usr_subs;
end

usr_thresh = input('Please enter in the preferred method of thresholding\n', 's');

if strcmp(usr_thresh, 'rel_thresh_mask')
    curr_thresh_abb = 'rm';
elseif strcmp(usr_thresh, 'rel_thresh_norob_mask')
    curr_thresh_abb = 'rnrm';
end  

      
tic
parfor mapCount = 1:length(list_ROI_maps)
    sub_proc = sub_proc_out;
    lang_ROI_map = list_ROI_maps(mapCount);
    match_HO = strfind(lang_ROI_map, 'HO');
    match_NS = strfind(lang_ROI_map, 'NS');
    match_MNI = strfind(lang_ROI_map, 'MNI');
    if any(horzcat(match_NS{:})) == 1
        lang_ROI_map_type = 'NS';
    elseif any(horzcat(match_HO{:})) == 1
         lang_ROI_map_type = 'HO';
    elseif any(horzcat(match_MNI{:})) == 1
        lang_ROI_map_type = 'MNI';
    else
         fprintf('Neither NS, HO nor MNI in name, aborting...')
         exit
    end

    gunzip(lang_ROI_map, lang_ROI_dir);
    lang_ROI_map = char(lang_ROI_map);
    lang_ROI_map = lang_ROI_map(1:end-3);
    if strcmp(lang_ROI_map_type, 'NS') == 1
        spec_ROI = lang_ROI_map(44:end-4); 
    else
        spec_ROI = lang_ROI_map(45:end-4);
    end
    sub_list = importdata([study_dir, '/Meta_data/listSubs_test.txt']);
    rel_thresh_list = importdata([study_dir, '/Meta_data/list_rel_thresh.txt']);
    
          
    for x = 1:(length(sub_proc))
        sub_proc = str2num(sub_proc{1});
        curr_sub = sub_proc(x);
        curr_sub = int2str(curr_sub);
        
      if length(curr_sub) < 4
            curr_sub = ['0' curr_sub];
      end
      
        curr_sub_dir = [sub_dir '/' curr_sub];
        
        
        curr_scan_dir = [curr_sub_dir, '/LI_proc_scans/', usr_thresh];
        scan_types = ['AT'; 'VG'; 'PL'; 'MR'];
        
        LI_output_dir = [curr_sub_dir, '/LI_outputs'];
        if exist(LI_output_dir, 'dir') == 0
            mkdir(LI_output_dir)
        end
    
        for scan_count = 1:(length(scan_types))
            curr_scan_type = scan_types(scan_count,:); 
        
            for rel_thresh_count = 1:length(rel_thresh_list)
                curr_rel_thresh = rel_thresh_list(rel_thresh_count,:);
                curr_rel_thresh = num2str(curr_rel_thresh);
            

               
                scan_input = [curr_scan_dir, '/Feat_', curr_sub, '_', curr_scan_type, '_mask_reg_', curr_thresh_abb, curr_rel_thresh, '_noclust.nii.gz'];
                %fprintf(['scan input is: ', scan_input, '\n'])
            
                if exist(scan_input, 'file') == 2
                    %fprintf('working\n')
                    gunzip(scan_input, curr_scan_dir);
                    scan_input = scan_input(1:end-3);
            
                if length(curr_rel_thresh) < 2
                    curr_rel_thresh = ['00', curr_rel_thresh];
                
                elseif length(curr_rel_thresh) < 3
                    curr_rel_thresh = ['0', curr_rel_thresh];
                end
                    
                    output_name = [LI_output_dir '/' curr_sub, '_' curr_scan_type, '_', usr_thresh, '_' curr_rel_thresh, '_LI_' lang_ROI_map_type, spec_ROI, '_noclust.txt'];
                    %fprintf(['output name is: ', output_name, '\n'])
                     out = struct('A', scan_input, 'B1', lang_ROI_map, 'C1', 3, 'thr1', -4, 'outfile', output_name, 'vc', 1);
                    fprintf(['output formatting is: LI(struct(''A'', ''', scan_input, ''', ''B1'', ''', lang_ROI_map, ''', ''C1'' , 3, ''thr1'', -4, ''outfile'', ''', output_name, ''', ''vc'', 1))\n']);
                    
                    LI_path = [spm_path, 'toolbox/LI'];
                    
                    cd(LI_path)
                    
                    LI(out)
                end
            end
        end
    end
end
toc