# QIIME PIPELINE - Deep-Sea Microbiology Lab
## Rutgers University
### Donato Giovannelli - donato.giovannelli [at] gmail dot com
### 2012 - update 2017
==============

The basic Qiime pipeline script and this readme file were written by Donato Giovannelli at the Deep Sea Microbiology Lab, IMCS, Rutgers University, NJ, USA.

#### CONTENT
- ASSUMPTIONS
- FOR THE IMPATIENT: RUNNING THE SCRIPT
- INPUT FILE REQUIREMENT
- OUTPUT FILES AND RESULTS

#### ASSUMPTIONS
The script we use at the DSML (@ Rutgers University) makes the following assumption:
- Your sequences have already been separated between samples (demultiplexed), trimmed
of the primer and quality checked. Usually the sequencing facility does this operations
with no additional costs. See INPUT FILE REQUIREMENT section for details.
- Your sequence file is in fasta format and you have a mapping file
- You have a basic understanding of the terminal and of the principles behind Qiime analysis

**NB** This version of the Qiime pipeline has been designed to be used on our bioinformatic server. Changes to the parameters may be needed for it to work on your local machine.


#### THE ANALYSIS IN BRIEF
- Create a working folder containing your sequence and mapping file. Be sure to name the sequence file seqs.fna and the mapping file map.txt
- Copy the qiime_basic_analysis.sh file to the folder
- Start the analysis by typing ./qiime_basic_analysis.sh
- The file will produce a zip file containing the most important output files
- HAPPY QIIMING!!!! ;)


#### INPUT FILE REQUIREMENT
The input file required for the analysis are:
- seqs.fna --> fasta file containing the demultiplexed sequences formatted as described below
- map.txt --> tab separated txt file containing the barcode map (required by QIIME)

QIIME is expecting to have a fasta file containing your sequences which comprises multiple samples separated by a barcode (tag) sequence and a primerLinker. The normal QIIME workflow uses the barcode and primerLinker given in the map.txt file to assign to each group of sequences a sample specific name and the downstream analyses all use the map.txt file to perform comparative analyses among samples.
Many sequencing facilities multiplex your samples with other clients, and provide already demultiplexed files as output. Please verify that your files are already demultiplexed, quality checked and possibly mate-paired. If these operation have not be performed, you'll need to do some pre-processing before proceeding with the analysis. Refer to the [qiime.org website](www.qiime.org) and the web for some excellent tutorials on these arguments.
Even when the sequences have been preprocessed by the sequencing facility, we need to be sure that the header of each file is compatible with Qiime requirement. Specifically, the name of the sample and the name of the sequences need to be separated by a underscore.

The average fasta file containing the sequence need to look like this:
```
>SampleName1_1	F7KXSUD02G4WM7	source=Biofilm	length=241
CTGGCGACCGGCGAACGGGTGAGTAACACGTAGCACTTGCCCTCCAGAGGGGGATAACCGGGGAAACCCGGGCTAATACCCCATACACCCGAGAGGGGAAAGGTTCAGCCGATAGGCTGTTCCGCTGCGGGATGGGGCTGCGGCCTATCAGCTAGTTGGTGGGGTAACGGCCTACCAAGGCGATGACGGGTAGCTGGCCTGAGAGGATGATCAGCCACACTGGGACTGAGACACGGCCCAG			
>SampleName2_2	F7KXSUD02I9V8Z	source=Biofilm	length=121
AGCACTATGGGATGGGGCTGCGGCGTATCAGCTAGTTGGTGGGGTAAAGGCCTACCAAGGCTATGACGCGTAGCTGGTCTGAGAGGATGATCAGCCACACTGGAACTGAGACACGGTCCAG			
>SampleName2_3	F7KXSUD02H72AH	source=Biofilm	length=219
CGCACGGGTGAGTAACACGTAGCTACCTGCCCCATAGACCGGGATAACAGCTGGAAACGGCTGCTAATACTGGATACTCCCTACGGGGGAAATGCTTTTGCGCTATGGGATGGGGCTGCGGCGTATCAGCTAGTTGGTAAGGTAACGGCTTATCAAGGCTATGACGCGTAGCTGGTCTGAGAGGATGATCAGCCACACTGGAACTGAGACACGGTCCAG			
>SampleName1_4	F7KXSUD02IRJ57	source=Biofilm	length=243
...
```

Where the F7KXSUD02G... is the sequence name. The formatting is a standard FASTA file, with the start of every sequence marked with > and the sequence starting after a new line (using enter/return key) was given. You can have as many space separated field in the first line of the header of each sequence as we want. Usually the more informations the better. In this example the fields 'source' and 'length' are present. In case it looks different you will need to parse the file.


#### OUTPUT FILES AND RESULTS
QIIME will create in your is analysis folder several new files and folder. Generally you'll be interested only in some of them. The Qiime pipeline script will package the most important output file in a single .zip file ready to be transferred to your local machine for further investigation. Some of the files have two version, one of which will have a \_cc part on its name. In our internal lab nomenclature \_cc stands for chimera checked and should be the one you use for future analyses. Please see the [Qiime Report](https://github.com/dgiovannelli/QiimeReport) for a convenient way to access our script results.
