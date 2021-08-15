#!/bin/bash
#Gavin Farrell – 15/8/21 

#Use:
#File merging 

#Description: 
#Merges fasta file data together into one file, breaks by common parsable marker and includes fasta orgin name

for file in /media/gavin/external_drive/thesis_samples/mega_processed_samples_srapull/crc/*results/contigs/megahit_out/*.fa; do
	#!!!assign output filename prefix here!!!
	out_filename=mega8_crc
	x=$(readlink -f "$file")
	cp $file .
	echo "$x"_new_fasta_break >> "$out_filename"_compiled_fasta.fa
	cat "$file" >> "$out_filename"_compiled_fasta.fa
done

#counts fasta reads and outputs to .txt file
grep -c ">k" *contigs.fa > "$out_filename"_fasta_reads.txt
rm *contigs.fa


