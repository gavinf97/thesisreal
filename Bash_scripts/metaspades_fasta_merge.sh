#!/bin/bash
#Gavin Farrell – 15/8/21 

#Use: 
#File management 

#Description: 
#Collects fastas together into one file, breaks by common parsable marker and includes fasta origin filename

counter=0
#assign common path where fasta files stored
for file in /media/gavin/external_drive/thesis_samples/biosynthmeta_processed_1-100/crc_1-50/results*T1/contigs/ER*/contigs.fasta; do
	#!!!assign output filename prefix here!!!
	out_filename=meta_gcluster44_normal
	x=$(readlink -f "$file")
	filename=$(awk -F/ '{print $(NF-1)}' <<< "$x")
	counter=$(( counter + 1 ))
	cp $file ./"$counter"_"$filename".fasta
	echo "$x"_new_fasta_break >> "$out_filename"_compiled_fasta.fa
	cat "$file" >> "$out_filename"_compiled_fasta.fa
done

grep -c ">N" *T1.fasta > "$out_filename"_fasta_reads.txt
rm *T1.fasta

