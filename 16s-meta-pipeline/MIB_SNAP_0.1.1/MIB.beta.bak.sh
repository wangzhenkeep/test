#!/bin/bash
#
#	This is the main driver script for the metagenomic identification of bacteria (MIB).
#
#	Quick guide:
#	Create default config file.
#		$0 -z -i <NGSfile> -p <454/iontor/illumina> -f <fastq/fasta/bam/sam> -r <reference_path>
#
#	Run MIB with the config file:
#		$0 -c <configfile> -i <NGSfile>
#
#	Run MIB with verification mode
#		$0 -i <NGSfile> -v
### Authors : Yang Li <liyang@ivdc.chinacdc.cn>
### Update  : 2015-10-15
#

MIB_version="0.1.0"

if [ $# -lt 1 ]
then
	echo "Please type $0 -h for helps"
	exit 65
fi

while getopts ":i:c:r:zhv" opt
do
	case "${opt}" in
		i) NGS=${OPTARG}
		   HELP=0		
		;;
		c) config_file=${OPTARG}
		;; 
		h) HELP=1
		#echo "HELP IS $HELP"
		;;
		z) CONFIG=1 # create config_file
		;;
		v) VERIFICATION=1 # check the dependancies
		;;
		r) REF_PATH=${OPTARG} #reference DB path
		;;
		?) echo "Option -${opt} requires an argument. Please type $0 -h for helps" >&2
		exit 1
		;;
	esac
done

if [ $HELP -eq 1 ]
then
	cat <<USAGE

Metagenomic Identification of Bacteria (MIB) version ${version}

This program will run the 16s pipeline with the parameters supplied by the config file.

Command Line Switches:

	-h	Show this help & ignore all other switches

	-i	Specify NGS file for processing, MIB is optimised for illumina platforms
		
	-r	Specify the PATH for database (DB)

		MIB will search the reference DB under the Path provided.
		
			• host_DB
			• 16s_refseq_DB
			• tax_DB

	-v	Verification mode

		When using verification mode, MIB will check necessary dependencies.
		This same verification is also done before each MIB run.

			• software dependencies
				MIB will check for the presence of all software dependencies. (software lists are available online)
			• taxonomy lookup functionality
				MIB verifies the functionality of the taxonomy lookup. 

	-z	This switch will create a standard config file.

Usage:

	Create default config file.
		$0 -z -i <NGSfile> -r <reference_path>

	Run MIB with the config file:
		$0 -c <configfile> -i <NGSfile>

	Run MIB with verification mode
		$0 -i <NGSfile> -v

USAGE
	exit
fi

if [ ! -f $NGS ]
then
	echo "$NGS file doesnot exist. Please check it"
	exit 65
fi

if [ ! $CONFIG ]
then
	CONFIG=0
fi

if [ $CONFIG -eq "1" ] && [ -f $NGS ]
then
	quality_threshold=20

#------------------------------------------------------------------------------------------------
(
	cat <<EOF
# This is the config file used by Metagenomic Identification of Bacteria (MIB). 
# It contains parameters critical for MIB. Please 
# Do not change the MIB_version - it is auto-generated.
# and used to ensure that the config file used matches the version of the MIB pipeline run.
MIB_config_version="$MIB_version"

##########################
#  PATH for MIB
##########################
#The variable REF_PATH is the top branch of MIB scripts and its dependancies.
#All software dependencies were installed in REF_PATH/bin

PATH=$PATH:$REF_PATH
MIB_DIR=$REF_PATH/bin

##########################
#  Input file
##########################

#MIB can take NGS file generated from different sequencing platform, such as 454/iontor/illumina.
inputfile="$NGS"

##########################
# Preprocessing
##########################

#preprocess parameter to skip preprocessing or not
#skipping preprocess is useful for large data sets that have already undergone preprocessing step such as data from SRA.
#default yes
#preprocess=Y/N
preprocess="Y"

#Specific parameters for preprocess
#average quality cutoff (17 for PGM, 15 for 454, 18 for illumina)
quality_cutoff="$quality_threshold"
#length_cutoff: after quality and adaptor trimming, any sequence with length smaller than length_cutoff will be discarded
length_cutoff="20"

#Cropping reads prior to further process
#left_cutoff = start crop from left
#crop_length = start crop from right
left_cutoff=0
right_cutoff=0

#Removing Background-related reads
#default yes
#background=Y/N
background=Y


##########################
# Reference Data
##########################
#	• host_DB
#	• 16S_refseq_DB
#	• tax_DB
#	
# bowtie-indexed database of host genome for subtraction phase

host_DB="$REF_PATH/DATABASE/HOST/host"

# directory for 16s_database 
# directory must ONLY contain blast+ indexed databases (16s bioproject/Gold RDP)
BAC_16S_REF="$REF_PATH/DATABASE/BLASTDB/16s_refseq"
BAC_16S_FULL="$REF_PATH/DATABASE/BLASTDB/16s_full_name"

#Taxonomy Reference data directory
#This folder should contain the 3 SQLite files created by the script "create_taxonomy_db.sh" 
#gi_taxid_nucl.db - nucleotide db of gi/taxid
#gi_taxid_prot.db - protein db of gi/taxid
#names_nodes_scientific.db - db of taxonid/taxonomy
tax_DB="$REF_PATH/DATABASE/TAX/"


EOF
) > $NGS.conf
#chmod 777 $NGS.conf
echo "Config file for $NGS generated! Please type $0 -c $NGS.conf -i $NGS to run MIB"
exit
fi
# 
if [ -r $config_file ] &&  [ -f "$NGS" ]
then
	source $config_file
	#verify that config file version matches SURPI version
	if [ "$MIB_config_version" != "$MIB_version" ]
	then
		echo "ERROR!!!ERROR!!!"
		echo "The config file $NGS.conf was created by MIB version $MIB_config_version not the current MIB version $MIB_version"
		echo "Please re-generate the config file with current MIB version $MIB_version."
		exit 65
	fi
	
else
	echo "Please check the config file $config_file and the ngs file $NGS."
	exit 65
fi
####system info
total_cores=$(grep processor /proc/cpuinfo | wc -l)
####
echo -e "############################################################################"
echo -e "##### ####### ## ##   ######################################################"
echo -e "##### # ###   ## ## ## #####################################################"
echo -e "##### ## # ## ## ##    #####################################################"
echo -e "##### ### ### ## ## ## #####################################################"
echo -e "##### ### ### ## ##   ######################################################"
echo -e "############################################################################"
echo -e "####\tParameters:"
echo -e "####\tThe NGS file:	"$inputfile""
echo -e "####\tPreprocess?:	"$preprocess""
echo -e "####\tquality_cutoff:	"$quality_cutoff""
echo -e "####\tThe min length of reads to keep:	"$length_cutoff""
echo -e "####\tLetters were discarded from 5 end:	"$left_cutoff""
echo -e "####\tLetters were discarded from 3 end:	"$right_cutoff""
echo -e "####\tbackground?:	$background"
echo -e "####\thost_DB:	"$host_DB""
echo -e "####\t16S_DB:	"$BAC_16S_REF""
echo -e "####\t16S_FULL:	"$BAC_16S_FULL""
echo -e "####\ttax_DB:	"$tax_DB""
echo -e "####\ttotal_cores:	"$total_cores""
echo -e "$(date)\t$0\tVerification Begins..."
PATH=$PATH:/usr/MIB/:/usr/MIB/bin/:/usr/MIB/bin/edirect/:$MIB_DIR/bin
#verify software dependencies
declare -a software_list=("seqtk" "prinseq-lite.pl" "bowtie2" "distributionCalc.pl" "distributionPlot.py" "efetch" "esearch" )
echo "#####################################################################################"
echo "#####################SOFTWARE DEPENDENCY VERIFICATION"
echo "#####################################################################################"
for command in "${software_list[@]}"
do
        if hash $command 2>/dev/null; then
                echo -e "$command: passed"
        else
                echo
                echo -e "$command: failed"
                echo -e "$command does not appear to be installed properly."
                echo -e "Please check MIB installation and \$PATH, then restart the pipeline"
                echo -e "SOFTWARE DEPENDENCY VERIFICATION failed"
	exit 65
        fi
done
echo "#####################################################################################"
echo "#####################SOFTWARE DEPENDENCY VERIFICATION PASSED"
echo "#####################################################################################"
#########
echo -e "$(date)\t$0\tMetagenomic Identification of Bacteria (MIB) begins"
BEGIN_MIB=$(date +%s)
mkdir $inputfile.report
curdir=`pwd`

if [ "$preprocess" = "Y" ]
then
	echo -e "$(date)\t$0\tBegin to preprocess"
	if [ -f $inputfile.preprocessed ]
	then	
		echo -e "$inputfile.preprocessed has been existing. The preprocess has to be skip"
	else
		START_PREPROCESS=$(date +%s)
		MIB_preProcess.sh "$inputfile" "$length_cutoff" "$left_cutoff" "$right_cutoff" "$quality_cutoff"
		mv $inputfile.preprocessed.* $inputfile.preprocessed
		END_PREPROCESS=$(date +%s)
		DIFF_PREPROCESS=$(( $END_PREPROCESS - $START_PREPROCESS ))
		echo -e "$(date)\t$0\tPreprocess took $DIFF_PREPROCESS seconds"		
	fi
else
	echo -e "The preprocess has been skip."
	num_total_reads=`prinseq-lite.pl -stats_info -fasta $inputfile | grep "reads" | awk '{print$3}'`
	echo -e "Total_sequences\t$num_total_reads" > $inputfile.reads_distribution
	mv $inputfile $inputfile.preprocessed
	sleep 5
fi

#####HUMAN MAPPING########
if [ -f "$inputfile.nohost.fastq" ]
then
	echo -e "$(date)\t$0\t$inputfile.nohost.fastq has been existing. The process for removing human-related reads has been skip."
	sleep 5
else
	if [ "$background" = "Y" ]
	then
		echo -e "$(date)\t$0\tBegin to filter reads related to human"
		echo -e "$(date)\t$0\tThe directory of the human database is "$host_DB""
		echo -e "$(date)\t$0\tBegin to alignmet against the human database"
		START_HUMAN=$(date +%s)
		bowtie2 -x "$host_DB" -r $inputfile.preprocessed -S $inputfile.preprocessed.human.sam -q -p $total_cores
		egrep -v "^@" $inputfile.preprocessed.human.sam | awk '{if($3 == "*") print "@"$1"\n"$10"\n""+"$1"\n"$11}' > $inputfile.nohost.fastq
		Host_related_reads=`egrep -v "^@" $inputfile.preprocessed.human.sam | awk '{if($3 != "*") print$1}' | uniq | wc -l | awk '{print$1}'` 
		END_HUMAN=$(date +%s)
		DIFF_HUMAN=$(( $END_HUMAN - $START_HUMAN ))
		echo -e "Host_reads\t$Host_related_reads" >> $inputfile.reads_distribution	
		echo -e "$(date)\t$0\tHuman-related reads has been removed. This process took $DIFF_HUMAN seconds"
	else
		mv $inputfile.preprocessed $inputfile.nohost.fastq
		#echo "Host_reads: 0" >> $inputfile.reads_distribution			
		echo -e "The process for removing human-related reads has been skip."
		sleep 5
	fi
fi

seqtk seq -A $inputfile.nohost.fastq > $inputfile.nohost.fasta


######BLAST##############
if [ -f "$inputfile.nohost.megablast" ]
	then	
		echo -e "$(date)\t$0\t$inputfile.nohost.megablast has been existing. The process for alignment to 16s Refseq/Gold RDP nucletide database has been skip."
		sleep 5
	else
		echo -e "$(date)\t$0\tThe database are based from16s Refseq/Gold RDP nucletide database"
		START_FAST_NUCL=$(date +%s)
		echo -e "$(date)\t$0\t####BLAST to 16s Refseq/Gold RDP nucletide database####"
		/home/t630/Desktop/VIP_ongoing_development/cluster_test/BLAST/blastn -query $inputfile.nohost.fasta -db $BAC_16S_REF -outfmt "6 qseqid sseqid qlen length pident qcovs qcovhsp mismatch gapopen qstart qend sstart send evalue bitscore" -out $inputfile.nohost.megablast -num_alignments 10 -perc_identity 95 -qcov_hsp_perc 97 -num_threads $total_cores
		END_FAST_NUCL=$(date +%s)
		DIFF_FAST_NUCL=$(( $END_FAST_NUCL - $START_FAST_NUCL ))
		echo -e "$(date)\t$0\t####Alignment $inputfile.nohost.fastq to Refseq/Gold RDP nucletide database DONE. The process took $DIFF_FAST_NUCL seconds####"
	fi
	echo -e "$(date)\t$0\tExtract the best results from blast alignment according to the bitscore value"
	MIB_getBestAlignment.pl $inputfile.nohost.megablast
	#$inputfile.nohost.megablast.best
	echo -e "$(date)\t$0\tCount the Bacteria-related reads"
	Bac_16s_related_reads=`awk -F'\t' '{print$1}' $inputfile.nohost.megablast.best | uniq | wc -l | awk '{print$1}'`
	#Bac_16s_related_reads=`egrep -v "^@" $inputfile.nohost.fast_nucl.sam | awk '{if($3 != "*") print$1}' | uniq | wc -l | awk '{print$1}'`
	echo -e "16s_reads\t$Bac_16s_related_reads" >> $inputfile.reads_distribution

######add the original seqs##############

if [ -f "$inputfile.nohost.megablast.best" ] 
then
	echo -e "$(date)\t$0\t####Restore the full length of reads being soft-cut during local alignment####"
	MIB_reStoreLength.sh $inputfile.nohost.fastq $inputfile.nohost.megablast.best
else
	echo -e "$(date)\t$0\t####$inputfile.nohost.megablast.best MISS"
	echo -e "$(date)\t$0\t####exit"	
	exit
fi


######Taxonomy classfication############

if [ -f "$inputfile.nohost.megablast.best.addseq" ] 
then
	echo "$(date)\t$0\t####Taxnomoy Identification module for FAST mode result begins####"
	START_FAST_TAXI=$(date +%s)
	echo "$(date)\t$0\t####sh TaxI.sh $inputfile.nohost.fast_nucl.match.sam sam nucl $total_cores "$tax_DB"####"
	MIB_TanC.sh "$inputfile.nohost.megablast.best.addseq" $total_cores "$tax_DB"
	END_FAST_TAXI=$(date +%s)
	DIFF_FAST_TAXI=$(( $END_FAST_TAXI - $START_FAST_TAXI))
	echo -e "$(date)\t$0\t####Parsing fast mode result with TAXI DONE. The process took $DIFF_FAST_TAXI seconds####"
else 
	echo -e "$(date)\t$0\tFile missing: $inputfile.nohost.megablast.best.addseq"
fi


######Report generation#################

if [ -f "$inputfile.nohost.megablast.best.addseq.all.annotated" ] 
then
	MIB_report.sh $inputfile.nohost.megablast.best.addseq.all.annotated $inputfile $BAC_16S_FULL
	while read coverage_genus
	do
		cd temp.$coverage_genus.$inputfile
		cp *.png $curdir/$inputfile.report/
		cd $curdir
	done < temp.all.$inputfile.uniq.genus
	#top 15 modified 0.1.1
	#sort -t $'\t' -r -k6,6 -n ./$inputfile.report/temp.$inputfile.covreport > ./$inputfile.report/temp.best20.$inputfile.temp
	sort -t $'\t' -r -k6,6 -n ./$inputfile.report/temp.$inputfile.covreport | head -n 15 > ./$inputfile.report/temp.best20.$inputfile.temp
	echo -e "Species\tGenus\tGI\t%Coverage\tReads_hit\tReads_num\tAverage depth of coverage" > ./$inputfile.report/temp.best20.$inputfile.title
	cat ./$inputfile.report/temp.best20.$inputfile.title ./$inputfile.report/temp.best20.$inputfile.temp > ./$inputfile.report/taxi.$inputfile.table
	cd $curdir/$inputfile.report/
	END_MIB=$(date +%s)
	DIFF_MIB=$(($END_MIB-$BEGIN_MIB))
	echo -e "$(date)\t$0\tMIB took $DIFF_MIB seconds"
	###reads_distribution
	cd $curdir/
	MIB_distributionCalc.pl $inputfile.reads_distribution $inputfile reads
	MIB_distributionPlot.py $inputfile.reads_distribution $inputfile reads
	###reads_distribution.$inputfile.png
	cp reads_distribution.$inputfile.png $curdir/$inputfile.report/
	###familiy distribution top 5
	family_total=`wc -l $inputfile.nohost.megablast.best.addseq | awk '{print$1}'`
	echo -e "Total\t$family_total" > $inputfile.family.top5
	sort -r -n -k2,2 $inputfile.nohost.megablast.best.addseq.all.annotated.family.counttable | head -n 5 >> $inputfile.family.top5
	MIB_distributionCalc.pl $inputfile.family.top5 $inputfile reads
	MIB_distributionPlot.py $inputfile.family.top5 $inputfile family
	cp family_distribution.$inputfile.png $curdir/$inputfile.report/
	###Genus barchart top 15
	sort -r -n -k2,2 $inputfile.nohost.megablast.best.addseq.all.annotated.genus.counttable | head -n 15 > $inputfile.genus.top15
	MIB_distributionPlot.py $inputfile.genus.top15 $inputfile genus
	cp genus_distribution.$inputfile.png $curdir/$inputfile.report/
	cd $curdir/$inputfile.report/
	echo -e "htmlGen.pl taxi.$inputfile.table $inputfile $run_mode $DIFF_MIB $MIB_DIR"
	MIB_htmlGen.pl taxi.$inputfile.table $inputfile $run_mode $DIFF_MIB $MIB_DIR
fi

echo -e "Please check the MIB_report.html under the path: $curdir/$inputfile.report"


