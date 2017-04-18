# Qiime_pipeline
==============
## Version v0.4-20170415-dev
### Donato Giovannelli

An easy to use script for basic microbial diversity analysis based on 16S rRNA sequences (development version). An html report system is also included. The script has been tested with Qiime 1.9 on Ubuntu and it has been optimized to work over ssh on our bioinformatic server at the Deep-Sea Microbiology Lab - Rutgers University.

Our current workflow consist of running this script to automatically obtain a basic diversity analysis of our sequences and then progress to a more refined manual analysis of the results. Check out the script directly and read the qiime_analysis.txt file for details.

Several of the parameters in the script may need to be changed in order for this script to work on your local computer.

#### v0.4-dev changelog
- added an automatic step to retrieve the value for diversity rarefaction analysis from the library_summary_cc file
