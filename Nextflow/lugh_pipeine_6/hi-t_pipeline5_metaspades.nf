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

// Parameters takes file path to files 
//ideally just tweak config on each run with directed to sample like Barry showed
//params.input = "outdirname/fastq/ERX_{1,2}.fastqstq.gz"
//params.type = "crc/normal"

params.sample_basename = "ERX1365077_T1_1"
params.input = "batch61_100/fastq/${params.sample_basename}/*_{1,2}.fastq.gz"
params.type = "normal"

Channel.fromFilePairs(params.input).into { reads1_ch; reads2_ch }
//reads2_ch.view()

process FastQC {
    container 'allin.sif'

    publishDir "results_${params.type}_${params.sample_basename}/qc/fastqc/untrimmed", mode:'copy'

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

    publishDir "results_${params.type}_${params.sample_basename}/qc/multiqc/untrimmed", mode:'copy'

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

    //publishDir "results_${params.type}_${sample_basename}/trimmed_reads", mode:'copy', pattern: "*.fastq.gz"

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
        out1=${key}_1_trim.fastq.gz \
        out2=${key}_2_trim.fastq.gz \
        minlen=30 \
        qtrim=rl \
        trimq=20 \
        """
}

//4
process FastQC_trim {
        container 'allin.sif'

        publishDir "results_${params.type}_${params.sample_basename}/qc/fastqc/trimmed", mode:'copy'

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
    
    publishDir "results_${params.type}_${params.sample_basename}/qc/multiqc/trimmed", mode:'copy'

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
    cpus 10 
    //conda '-c bioconda spades'
    //container 'allin.sif'
    publishDir "results_${params.type}_${params.sample_basename}/contigs", mode:'copy'

    input:
        tuple val(readname), file(reads2) from reapeat_trimmed_reads_ch

    output:
        file("${readname}/*.{fasta,txt,info}") into contigs_ch
        //file("${readname}") into saved_folder_ch

    script:
    """
    metaspades.py --bio -1 ${reads2[0]} -2 ${reads2[1]} -o $readname -t 16 
    """
}

/*
//Step 7
//MetaQuast QC on assembled contigs
process MetaQuast {
    container 'allin.sif'

    publishDir "results_${params.type}_${params.sample_basename}/qc/metaquast/", mode:'copy'

    input:
        file(contig) from contigs_ch

    output:
         file("quast_results") into metaquast_ch

    script:
    """
    metaquast.py $contig
    """
}
*/
