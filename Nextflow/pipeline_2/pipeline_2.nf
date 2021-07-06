#!/usr/bin/env nextflow

// Parameters takes file path to files
params.reads = "samples/*_{1,2}.fastq"
// Parameter into usable Channel or each file path pair
reads_ch = Channel.fromFilePairs(params.reads)


//0 (pull in file)
process Pullfile {

}


//1
process FastQC {
//    executor 'slurm'

    container 'allin.sif'    

    publishDir "results/fastqc", mode:'copy'
        
    input:
        tuple val(key), file(reads) from reads_ch

    output:
        file("*.{html,zip}") into fastqc_ch

    script:
        """
        fastqc $reads  
        """
}

//2
process MultiQC {
//    executor 'slurm'

    container 'allin.sif'

    publishDir "results/multiqc", mode:'copy'

    input:
        file(htmls) from fastqc_ch.collect()

    output:
        file("*multiqc_report.html") into multiqc_report_ch

    script:
        """
        multiqc $htmls
        """
}


//Pre-3
//repeat for clash


params.reapeatreads = "samples/*_{1,2}.fastq"
untrimmed_reads_ch = Channel.fromFilePairs(params.reapeatreads)

//3
process BB_Trim {
//    cpus 4
//    executor 'slurm'

    container 'allin.sif'  

    publishDir "results/trimmed_reads", mode:'copy', pattern: "*.fq"
    
    input:
        tuple val(key), file(reads1) from untrimmed_reads_ch
		
    output:
        tuple val(key), file("*.fq") into trimmed_reads_ch
        tuple val(key), file("*.fq") into reapeat_trimmed_reads_ch

    script:
        """
        bbduk.sh \
        in1=${reads1[0]} \
        in2=${reads1[1]} \
        out1=${key}_1.fq \
        out2=${key}_2.fq \
        minlen=30 \
        qtrim=rl \
        trimq=20 \
        """
}


//4
process FastQC_trim {
//        executor 'slurm'


        container 'allin.sif'

	publishDir "results/trimmed_fastqc", mode:'copy'

	input:
		tuple val(key), file(reads2) from trimmed_reads_ch

	output:
		file("*.{html,zip}") into trimmed_fastqc_ch

	script:
	"""
	fastqc $reads2
	"""
}


//5
process MultiQC_trim {
//    executor 'slurm'


    container 'allin.sif'

    publishDir "results/trimmed_multiqc", mode:'copy'

    input:
        file(htmls1) from trimmed_fastqc_ch.collect()
        
    output:
        file("*multiqc_report.html") into trimmed_multiqc_ch

        script:
        """
        multiqc $htmls1
        """
}




//6
process FormContigs {
//    cpus 4
//    executor 'slurm'

    container 'allin.sif'

    publishDir "results/contigs", mode:'copy'

    input:
        tuple val(readname), file(reads2) from reapeat_trimmed_reads_ch
        //file(reads2) from reapeat_trimmed_reads_ch
                
    output:
        file("*/*.fa") into contigs_ch

    script:
    """
    megahit -1 ${reads2[0]} -2 ${reads2[1]} --min-contig-len 1000 --out-prefix $readname
    """
}

//6.5
//Other assemblers? -metaspades

//7 
//Metaquast - check contigs


//8
//Antismash
process antismash {
//    cpus 4
//    executor 'slurm'
//    memory '16 GB'

    //container '../containers/antismash.sif'
    //conda '-c bioconda antismash'

    publishDir "results/antismash", mode:'copy'

    input:
        file(contig) from contigs_ch  
                
    output:
         file("${contig.baseName}/${contig.baseName}.zip") into antismash_ch
        
    script:
    """
    antismash $contig --genefinding-tool prodigal --output-dir $contig.baseName --logfile nextflow.log 
    """
}

