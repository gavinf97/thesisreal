#!/usr/bin/env nextflow 
//Base Pipeline (version 3) for Antismash Colorectal Examination - 3/7/21
//Pipeline will intake an SRA/ENA accession code for PE fastq files 

/* Files will be processed with:
   -Pull in PE fastq files (Step 0)   - Tools: Nextflow SRA Channel grabber
   -Pre-QC (Step 1+2)                 - Tools: FastQC + MultiQC 
   -Processed for use (Step 3)        - Tools: BBduk
   -Post-processing-QC (Step 4 + 5)   - Tools: FastQC + MultiQC
   -Contig Assembly (Step 6)          - Tools: Megahit
   -Contig QC (Step 7)                -	Tools: MetaQuast
   -BGC detection (Step 8)            - Tools: Antismash 
*/

/* !!!NOTE!!!
   IF ENA HAS 2 VS 3 GZIP FILES -> CHANGE 0 AND 1 IN BBDUK (Step 3)
*/
//add a change param for user here? eg:2/3 gzip?

//Step 0
//ENA,SRA accession *input below* 
//PE read files are pulled in in the format of: Accession_(1/2).fastq.gz
params.accession = 'SRR026680' 
Channel.fromSRA(params.accession).into { reads1_ch; reads2_ch }


//Step 1
//FastQC on untrimmed PE reads
process FastQC {
    container "allin.sif"

    publishDir "results/qc/fastqc/untrimmed/", mode:'copy'

    input:
        tuple val(key), file(reads) from reads1_ch

    output:
        file("*.zip") into fastqc_ch

    script:
        """
        fastqc $reads
        """ 
}


//Step 2
//MultiQC on untrimmed PE reads FastQC files
process MultiQC {
    container "allin.sif"

    publishDir "results/qc/multiqc/untrimmed/", mode:'copy'

    input:
        file(zips) from fastqc_ch.collect()
    
    output: 
        file("*multiqc_report.html") into multiqc_report_ch
    
    script:
        """
        multiqc $zips
        """
}


//Step 3
//BBduk trim processing on untrimmed PE reads
process BB_Trim {
    container 'allin.sif'

    publishDir "results/trimmed_reads", mode:'copy', pattern: "*.fq.gz"

    input:
        tuple val(key), file(reads1) from reads2_ch

    output:
        tuple val(key), file("*.fq.gz") into trimmed_reads_ch
        tuple val(key), file("*.fq.gz") into repeat_trimmed_reads_ch

    script:
        """
        bbduk.sh \
        in1=${reads1[1]} \
        in2=${reads1[2]} \
        out1=${key}_1.fq.gz \
        out2=${key}_2.fq.gz \
        minlen=30 \
        qtrim=rl \
        trimq=20 \
        """
}


//Step 4
//FastQC on trimmed PE reads
process FastQC_trim {
        container 'allin.sif'

        publishDir "results/qc/fastqc/trimmed/", mode:'copy'

        input:
                tuple val(key), file(reads2) from trimmed_reads_ch

        output:
                file("*.zip") into trimmed_fastqc_ch

        script:
        """
        fastqc $reads2
        """
}


//Step 5
//MultiQC on trimmed PE reads FastQC files
process MultiQC_trim {
    container 'allin.sif'

    publishDir "results/qc/multiqc/trimmed/", mode:'copy'

    input:
        file(zip1) from trimmed_fastqc_ch.collect()

    output:
        file("*multiqc_report.html") into trimmed_multiqc_ch

        script:
        """
        multiqc $zip1
        """
}


//Step 6
//Megahit contig assembly; intakes trimmed PE fastq reads and outputs single fasta file with contigs
process FormContigs {
    container 'allin.sif'

    publishDir "results/contigs/", mode:'copy'

    input:
        tuple val(readname), file(reads2) from repeat_trimmed_reads_ch
        
    output:
        file("*/*.fa") into (contigs1_ch, contigs2_ch)

    script:
    """
    megahit -1 ${reads2[0]} -2 ${reads2[1]} --min-contig-len 1000 --out-prefix $readname
    """
}


//6.5 Other assemblers? -metaspades


//Step 7
//MetaQuast QC on assembled contigs
process MetaQuast {
    container 'allin.sif'

    publishDir "results/metaquast/", mode:'copy'

    input:
        file(contig2) from contigs2_ch

    output:
         file("quast_results") into metaquast_ch

    script:
    """
    metaquast.py $contig2
    """
}


//Step 8
//Antismash BGC detection in fasta contigs formed
process Antismash {
    publishDir "results/antismash", mode:'copy'

    input:
        file(contig) from contigs1_ch

    output:
         file("${contig.baseName}/${contig.baseName}.zip") into antismash_ch

    script:
    """
    antismash $contig --genefinding-tool prodigal --output-dir $contig.baseName --logfile nextflow.log
    """
}
