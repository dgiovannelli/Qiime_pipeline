#!/bin/bash
# QIIME 1.7 routine for handling single sample file sequence already demultisplexed and splitted
clear
echo "Starting the QIIME 1.7 sample analysis pipeline. Refer to the file readme.txt locate in this folder for details. Version v0.1-20130507"

# Pre-processing
echo "Check mapping file"
rm -rf mapping_output ; check_id_map.py -m map.txt -o check_map/
echo "If no error are found in the map file initiate analysis. Check the check_map folder for errors."
echo

# otus Picking
echo "Pick OTUs through OTU table at 97% cut-off"
rm -rf otus ; pick_de_novo_otus.py -i seq.fna -o otus
notify-send "OTUs have been selected"
echo

#Check and remove chimera from OTUs selected sequences
echo "Check for chimera sequences and write them to chimeric_otu.txt file. This my take a while..."
identify_chimeric_seqs.py -i otus/pynast_aligned_seqs/seq_rep_set_aligned.fasta  -a /home/dg/qiime_software/core_set_aligned.fasta.imputed -o chimeric_otu.txt
echo "Remove the chimera from the OTUs selected sequences and OTU table creating the _cc (chimera checked) files"
filter_fasta.py -f otus/rep_set/seq_rep_set.fasta -o otus/rep_set/seq_rep_set_cc.fasta -s chimeric_otu.txt -n
filter_fasta.py -f otus/pynast_aligned_seqs/seq_rep_set_aligned_pfiltered.fasta -o otus/pynast_aligned_seqs/seq_rep_set_aligned_cc.fasta -s chimeric_otu.txt -n
filter_otus_from_otu_table.py -i otus/otu_table.biom -e chimeric_otu.txt -o otus/otu_table_cc.biom
notify-send "Chimera sequences removal completed"
echo

#Copute core biome
#echo "Coputing the core biome, aka the OTUs common to all samples. Change the  --min_fraction_for_core parameters if needed"
#compute_core_microbiome.py -i otus/otu_table_cc.biom -o otus/otu_table_core --min_fraction_for_core 1
#echo

#Print library stats
echo "Printing library statistics before and after chimera removal in the library_summary file. Following analyses will use only chemra removed files"
per_library_stats.py -i otus/otu_table.biom > library_summary.txt
per_library_stats.py -i otus/otu_table_cc.biom > library_summary_cc.txt
echo

#Making tree
echo "Building a tree from the chimera removed alignment. Tree bulding method default is fasttree and newick format file. The file can be visualized and edited using FigTree"
make_phylogeny.py -i otus/pynast_aligned_seqs/seq_rep_set_aligned_cc.fasta -o otus/rep_set_cc.tre
echo

#Create files to be used with Topiary Explorer
echo "Creating the files set into /tree/ folder to be used with Topiary Explorer for tree visualization"
mkdir tree
convert_biom.py -i otus/otu_table_cc.biom -o otus/otu_table_te.txt -b --header_key taxonomy --output_metadata_id "Consensus Lineage" 
cp otus/rep_set_cc.tre tree/rep_set_cc_te.tre
cp otus/otu_table_te.txt tree/otu_table_te.txt
cp map.txt tree/map_te.txt
cp otus/rdp_assigned_taxonomy/seq_rep_set_tax_assignments.txt tree/tip_data.txt
echo

#Create a Heat map of the samples
echo "Create OTUs Heatmap from the _cc OTUs table"
make_otu_heatmap_html.py -i otus/otu_table_cc.biom -o otus/otu_heatmap/
echo

#Make Taxa Summary Charts
echo "Summarize taxa in pie and bar plots. The plot are interactive HTML and can be downloaded as .pdf to be modified in Illustrator or Inkscape"
summarize_taxa.py -i otus/otu_table_cc.biom -o ./tax
plot_taxa_summary.py -i tax/otu_table_cc_L2.txt,tax/otu_table_cc_L3.txt,tax/otu_table_cc_L4.txt,tax/otu_table_cc_L5.txt,tax/otu_table_cc_L6.txt -c pie,bar -o output_plots/
notify-send "Summary plot completed"
echo

#Make OTU Network
echo "Compute and create OTUs network. It can be visualized with Cytoscape or parsed to be used in Circos or HivePlot."
make_otu_network.py -m map.txt -i otus/otu_table_cc.biom -o otus/OTU_Network
echo

#Compute alpha diversity as Chao1 and Shannon indexes
echo "Alpha rarefaction computed as Observed specien number, Chao1 and Shannon indexes"
echo "alpha_diversity:metrics shannon,chao1,observed_species,PD_whole_tree" > alpha_params.txt
alpha_rarefaction.py -i otus/otu_table_cc.biom -m map.txt -o alpha_rarefaction/ -p alpha_params.txt -t otus/rep_set_cc.tre
echo

#Compute beta diversity
echo "Compute beta diversity between the sample"
beta_diversity_through_plots.py -i otus/otu_table_cc.biom -m map.txt -o betadiv/ -t otus/rep_set_cc.tre -e 1000 
echo
echo

echo "Default QIIME 1.6 pipeline for multiple sample analysis is complete. Pipeline written by Donato Giovannelli - 2012. Please refer to readme.txt file for detail on code, parameters and output results."
notify-send "QIIME analysis pipeline completed"

zenity --title "QIIME PIPELINE" --info --text="QIIME analysis completed!"
