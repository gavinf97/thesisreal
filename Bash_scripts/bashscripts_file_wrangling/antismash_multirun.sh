#!/bin/bash
#Gavin Farrell – 15/8/21 

#Use: 
#File processing 

#Description: 
#Runs AntiSmash on Bisoynthetic MetaSpades processed fasta files, will run on each 'genecluster' fasta iteratively 

#Change file path
for file in /media/gavin/external_drive/thesis_samples/biosynthmeta_processed_1-100/biosynthmeta_processed_1-10/results_*/contigs/ER*/; do
        x=$(readlink -f "$file") 
	antismash  "$file"/gene_clusters.fasta --genefinding-tool prodigal --output-dir "$x"/anti_gene_cluster --logfile test.log
done
