# Thesis Github: Gavin Farrell
## Updated: 3/9/21 
## Status; being updated and cleaned -> Github Pages will be set up for ease of access + Github Wiki
-> Contact g.farrell13@nuigalway.ie for any specific files or details before then


## Title: Is the a Loss of BGC Diveristy in Colorectal Microbiome
### Description
Given the known dysbiosis of the colorectal gut microbiome in colorectal cancer patients when compared to normal controls, this thesis aimed to determine if there was a further correlation to the number and types of biosynthetic gene clusters (BGC) present in the microbes of the gut microbiome between colorectal cancer patients and normal controls. Data used was short read 100 bp paired end reads. Data was assembled into contigs with Megahit and MetaSpades, and searched for BGC using AntiSMASH and Biosynthetic MetaSpades. Further analsysis and data interpreatation was done using Bash, Python and R scripts.


## 0. Additional files
### 0.1. Sample Accessions and Status
Avaiable on ENA at: https://www.ebi.ac.uk/ena/browser/view/PRJEB12449?show=reads <br />
****Accession****: PRJEB12449
<br />

### 0.2. Dockerhub container used at: https://hub.docker.com/repository/docker/gfarrell/allin
Requires updating as mix of Conda environment and Singularity (docker base) container used for pipelines
<br />

### 0.3. List of tools used (unavailable)
<br />

## 1. Primary Processing Pipelines:
### Snakemake: Test Pipeline (available)
Test pipeline for initial decision of which pipeline development tool to use. Discontinued early into the project as Nextflow had more suited functionality and suitability to the project demands over Snakemake.
<br />

### Nextflow: Megahit Pipeline (available)
Pipeline assembled contigs using Megahit and direct ENA accession downloads for input samples.
### Nextflow: MetaSpades Pipeline (available)
Later stage pipelines. Switched from direct ENA downloads to using nf-core pipeline 'Fetch NGS' to download data first. Then used Biosynthetic MetaSpades to form contigs and extend contigs into larger scaffolds, better for large BGC retrieval.

NF-core Fetch NGS;<br />
https://nf-co.re/fetchngs
<br />

(.jpg files display the tools used in the pipelines and methods undertaken to process the data)
## 2. Bash - File Management (available)
Bash scripts were used to take output BGC data from Nextflow Megahit and MetaSpades pipelines and perform QC and merging steps.
<br />

## 3. Python - File Parsing (available)
Merged BGC data was parsed using Python into basic tsv/csv files for use in R.
<br />

## 4. R - Graphing Data (available)
R scripts took basic Python parsed data files and cleaned up csv/tsv files. File data was then normalised and graphed for interpretation and determination of gut microbiome BGC correlation to colorectal cancer.






