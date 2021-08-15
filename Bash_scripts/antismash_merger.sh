#!/bin/bash
#Gavin Farrell – 15/8/21 

#Use: 
#File merging 

#Description: 
#File description: merges single Antismash gbk file outputs into one whole one for subsequent use with Python parsing script 

for file in /media/gavin/external_drive/thesis_samples/mega_processed_samples_srapull/crc/*results; do 
	cat "$file"/antismash/ER*/ER*/*.gbk > "$file"_merged.gbk
done
