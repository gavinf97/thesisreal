#!/usr/bin/env nextflow
//Base Pipeline (version 5-metaspades) for Antismash Colorectal Examination - 8/7/21
//Pipeline will use organised PE fastq files in folders pulled to cluster through ngs-fetch nf-core pipeline

/*
   -Set up file path channel (Step 0) - Tools: Nextflow Channels
   -Pre-QC (Step 1+2)                 - Tools: FastQC + MultiQC
   -Processed for assembly (Step 3)   - Tools: BBduk
   -Post-processing-QC (Step 4 + 5)   - Tools: FastQC + MultiQC
   -Contig Assembly (Step 6)          - Tools: Metaspades
   -Contig QC (Step 7)                - Tools: MetaQuast
*/

//Pre-download: use ENA accession in list and ngs-fetch nf-core pipeline, 
//PE fastqs stored under run accession ERX, in 'outdirname/fastqc/ERX_{1,2}'

//Step 0.
//Set up channel inputs

// Parameters takes file path to files 
//ideally just tweak config on each run with directed to sample like Barry showed
//params.input = "outdirname/fastq/ERX_{1,2}.fastqstq.gz"
//params.type = "crc/normal"

params.input = "batch2/fastq/ERXsample/*_{1,2}.fastq.gz"
params.type = "crc"

// Parameter into usable Channel or each file path pair
Channel.fromFilePairs(params.input).into { reads1_ch; reads2_ch }

//1
process FastQC {
    container 'allin.sif'    

    publishDir "results_"$params.type"_"$params.input"/qc/fastqc/untrimmed", mode:'copy'
        
    input:
        tuple val(key), file(reads) from reads1_ch

    output:
        file("*.zip") into fastqc_ch

    script:
        """
        fastqc $reads  
        """
}

//2
process MultiQC {
    container 'allin.sif'

    publishDir "results_"$params.type"_"$params.input"/qc/multiqc/untrimmed", mode:'copy'

    input:
        file(zips) from fastqc_ch.collect()

    output:
        file("*multiqc_report.html") into multiqc_report_ch

    script:
        """
        multiqc $zips
        """
}


//3
process BB_Trim {
    container 'allin.sif'  

    publishDir "results_"$params.type"_"$params.input"/trimmed_reads", mode:'copy', pattern: "*.fastq.gz"
    
    input:
        tuple val(key), file(reads1) from reads2_ch
		
    output:
        tuple val(key), file("*.fastq.gz") into trimmed_reads_ch
        tuple val(key), file("*.fastq.gz") into reapeat_trimmed_reads_ch

    script:
        """
        bbduk.sh \
        in1=${reads1[0]} \
        in2=${reads1[1]} \
        out1=${key}_1.fastq.gz \
        out2=${key}_2.fastq.gz \
        minlen=30 \
        qtrim=rl \
        trimq=20 \
        """
}


//4
process FastQC_trim {
        container 'allin.sif'

	publishDir "results_"$params.type"_"$params.input"/qc/fastqc/trimmed", mode:'copy'

	input:
		tuple val(key), file(reads2) from trimmed_reads_ch

	output:
		file("*.zip") into trimmed_fastqc_ch

	script:
	"""
	fastqc $reads2
	"""
}


//5
process MultiQC_trim {
    container 'allin.sif'

    publishDir "results_"$params.type"_"$params.input"/qc/multiqc/trimmed", mode:'copy'

    input:
        file(zips1) from trimmed_fastqc_ch.collect()
        
    output:
        file("*multiqc_report.html") into trimmed_multiqc_ch

        script:
        """
        multiqc $zips1
        """
}


//6
process FormContigs {
    container 'allin.sif'

    publishDir "results_"$params.type"_"$params.input"/contigs", mode:'copy'

    input:
        tuple val(readname), file(reads2) from reapeat_trimmed_reads_ch
                        
    output:
        file("*/*.fa") into contigs_ch

    script:
    """
    megahit -1 ${reads2[0]} -2 ${reads2[1]} --min-contig-len 1000 --out-prefix $readname
    """
}

//Step 7
//MetaQuast QC on assembled contigs
process MetaQuast {
    container 'allin.sif'

    publishDir "results_"$params.type"_"$params.input"/qc/metaquast/", mode:'copy'

    input:
        file(contig) from contigs_ch

    output:
         file("quast_results") into metaquast_ch

    script:
    """
    metaquast.py $contig
    """
}
