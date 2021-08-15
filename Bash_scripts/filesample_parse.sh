#!/bin/bash
#Gavin Farrell – 15/8/21 

#Use: 
#File management 

#Description: 
#Compiles filename accessions together into one txt file, shows sample names used

for file in ./*_results; do
	#!!!assign output filename prefix here!!!
	out_filename=mega8_crc
	echo "$file" | cut -d'_' -f2 >> "$out_filename"_samples_used.txt
done

