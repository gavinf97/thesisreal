#!/bin/bash
#Gavin Farrell – 15/8/21 

#Use: 
#File merging 
 
#Description: 
#Collects gbk count data outputs from Antismash into one file, breaks by common parsable marker and includes sample origin

#change file path to where gbk files are stored in AntiSmash folder
for file in /media/gavin/external_drive/thesis_samples/mega_processed_samples_srapull/crc/gbks_of_mega_contigs/single_crc_gbk/*.gbk; do
	#!!!assign output filename prefix here!!!
	out_filename=mega8_crc
	x=$(readlink -f "$file")
	cp $file .
done

grep -c "cand_cluster" *.gbk > "$out_filename"_gbk_bgcs_count.txt
rm *.gbk


