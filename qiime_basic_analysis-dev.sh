#!/bin/bash
## Starting the script
clear
echo "Starting the QIIME 1.9 pipeline optimized for the polyphemus server. Refer to the file readme.md on github for details. Version v0.3-20170415-dev by Donato Giovannelli"

mkdir results	# prepare the result folder
print_qiime_config.py -tb > results/analysis_info.txt	# print the qiime config file, script version, analysis date and other basic info for future reference
echo "Script version v0.4-dev-20170318" >>  results/analysis_info.txt
date >> results/analysis_info.txt
echo "Username running the script" $USER >> results/analysis_info.txt
ls -lah >> results/analysis_info.txt
echo "Check mapping file"	# Validating the mapping file
rm -rf results/check_map/ ; validate_mapping_file.py -m map.txt -o results/check_map/	# The rm ensure that previous check attempt in the same folder do not block the script
echo

read -p "Do you want to proceed with the analysis? [y/n]" answer
if [[ $answer = n ]] ; then
	echo "Check the results/check_map/ folder and correct the map.txt file. Rerun the qiime script"
	[[ "$0" = "$BASH_SOURCE" ]] && exit 1 || return 1 # handle exits from shell or function but doesn't exit interactive shell
else
	echo "No error found in the mapping file. Proceeding with the qiime DSML basic pipeline"
	echo
	echo "Pick open reference OTUs at 97% cut-off using the default GreenGene database"
	#echo “pick_otus:enable_rev_strand_match True” > results/otu_params.txt		# Enable reverse strand match for paired end reads if not mate paired. Enable if most of the reads fail during this step and add -p results/otu_params.txt  to the below command
	pick_open_reference_otus.py -o results/otus/ -i seqs.fna -aO 8 # Open reference OTU picking, currently the preferred methods
	echo
	echo "Check for chimera sequences and write them to chimeric_otu.txt"
	identify_chimeric_seqs.py -i results/otus/pynast_aligned_seqs/rep_set_aligned.fasta  -a /usr/local/lib/python2.7/dist-packages/qiime_default_reference/gg_13_8_otus/rep_set_aligned/85_otus.pynast.fasta -o results/chimeric_otu.txt # Check and remove chimera from OTUs selected sequences
	filter_fasta.py -f results/otus/rep_set.fna -o results/rep_set_cc.fna -s results/chimeric_otu.txt -n	# Remove chimera from OTU table, rep_set fasta and rep_set tree
	filter_fasta.py -f results/otus/pynast_aligned_seqs/rep_set_aligned_pfiltered.fasta -o results/rep_set_aligned_cc.fasta -s results/chimeric_otu.txt -n
	filter_otus_from_otu_table.py -i results/otus/otu_table_mc2_w_tax.biom -e results/chimeric_otu.txt -o results/otus/otu_table_mc2_w_tax_cc.biom
	filter_tree.py -i results/otus/rep_set.tre -f results/rep_set_cc.fna -o results/rep_set_cc.tre
	echo "Chimera sequences removal completed"
	echo
	echo "Assign taxonomy using rdp naive bayesian classifier"
	parallel_assign_taxonomy_rdp.py -i results/rep_set_cc.fna -o results/greengene_assigned_taxonomy/ -c 0.80	# assign taxonomy with rdp against greengenes
	make_otu_table.py -i results/otus/final_otu_map_mc2.txt -o results/otu_cc_greengenes.biom -t results/greengene_assigned_taxonomy/rep_set_cc_tax_assignments.txt
	biom convert -i results/otu_cc_greengenes.biom -o results/otu_cc_greengenes.txt --to-tsv --header-key taxonomy --output-metadata-id "Consensus Lineage"

	biom summarize-table -i results/otus/otu_table_mc2_w_tax.biom -o results/library_summary_before_cc.txt 	# Print library stats on failed OTU call and before and after chimera removal
	biom summarize-table -i results/otus/otu_table_mc2_w_tax_cc.biom -o results/library_summary_after_cc.txt

	compute_core_microbiome.py -i results/otu_cc_greengenes.biom -o results/core_microbiome 	# Computing the core biome, aka the OTUs common to all samples. Change the  --min_fraction_for_core parameters if needed [0,1]"

	echo
	seq_rarefact=$(grep "Min" results/library_summary_after_cc.txt | cut -d":" -f2)
	echo "Computing alpha and beta diversity. Rarefaction is set to ${seq_rarefact%.*} sequences based on the Min number of sequences in your library_summary_after_cc.txt file."
  echo "Diversity rarefaction parameters for alpha and beta diversity set to ${seq_rarefact%.*} sequences" >> results/analysis_info.txt
	summarize_taxa_through_plots.py -o results/taxa_summary -i results/otu_cc_greengenes.biom -m map.txt		# Making basic summary plots
	make_otu_network.py -m map.txt -i results/otu_cc_greengenes.biom -o results/network	# Compute and create OTUs network. It can be visualized with Cytoscape or parsed to be used in Circos or HivePlot
	single_rarefaction.py -i results/otu_cc_greengenes.biom -o results/otu_cc_greengenes_rarefied.biom -d ${seq_rarefact%.*}
	alpha_diversity.py -i results/otu_cc_greengenes_rarefied.biom -o results/alpha_rarefaction --metrics PD_whole_tree,chao1,observed_species,shannon -t results/rep_set_cc.tre 	# Compute alpha diversity as Chao1 and Shannon indexes

	beta_diversity_through_plots.py -i results/otu_cc_greengenes.biom -m map.txt -o results/betadiv -t results/rep_set_cc.tre -e ${seq_rarefact%.*} -a --jobs_to_start 8 --ignore_missing_samples		# Compute beta diversity between the sample
	nmds.py -i results/betadiv/weighted_unifrac_dm.txt -o results/betadiv/nmds.txt -d 2
	nmds.py -i results/betadiv/weighted_unifrac_dm.txt -o results/betadiv/nmds_3D.txt -d 3

	zip -r basic_qiime_results.zip results/analysis_info.txt results/rep_set_cc.fna results/rep_set_aligned_cc.fasta results/rep_set_cc.tre results/otu_cc_greengenes.biom results/otu_cc_greengenes.txt results/library_summary_before_cc.txt results/library_summary_after_cc.txt results/core_microbiome results/taxa_summary results/network results/alpha_rarefaction results/betadiv	# Compress the results folder ready for transfer to the local computer

	echo
	echo "Qiime basic analysis completed. The results are in the basic_qiime_results.zip files ready to be transferred to your local computer for further analysis."
fi
