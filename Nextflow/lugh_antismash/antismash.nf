//Incomplete, needs clean up and debugging (skeleton stage)

//pipeline will run base antismash jobs on contigs from megahit or metspades, run on highmem + MSC + local
//runs very basic antismash to debug the run
//set up for input param contig

// Parameters takes file path to files (fasta for metaspades + fa for megahit)
params.contig = "./x.fa"
// Parameter into usable Channel or each file path pair
contig_ch = Channel.fromPath(params.contig)


//1
process antismash {
    publishDir "antismash_results/", mode:'copy'

    input:
        file(contig) from contig_ch

    output:
        file("${contig.baseName}/${contig.baseName}.zip") into antismash_ch

    script:
        """
        antismash $contig -c 6 --genefinding-tool prodigal --output-dir $contig.baseName --logfile nextflow.log
        """
}
