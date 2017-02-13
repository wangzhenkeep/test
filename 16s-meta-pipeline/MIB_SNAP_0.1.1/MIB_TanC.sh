#!/bin/bash
#
#
#	MIB_TanC.sh
#
#	Quick guide:
#	The scientific information will be appending at the end of each record.
#
#		MIB_TanC.sh <BLAST.best.addseq> <cores> <tax_dir>
#

### Authors : Yang Li <liyang@ivdc.chinacdc.cn>
### License : GPL 3 <http://www.gnu.org/licenses/gpl.html>
### Update  : 2015-07-05
#
scriptname=${0##*/}
if [ $# -lt 3 ]
then
	echo "Usage: $scriptname <BLAST.best.addseq> <cores> <tax_dir>"
	exit 65
fi

########
result=$1
total_cores=$2
tax_dir=$3
########

sed -i '/^#/d' $result
echo -e "$(date)\tParsing $result"
echo -e "perl taxonomy_lookup.pl $result sam nucl $total_cores $tax_dir"
#perl taxonomy_lookup.pl $result blast prot $total_cores $tax_dir
MIB_taxonomy_lookup.pl $result sam nucl $total_cores $tax_dir
MIB_table_generator.sh $result.all.annotated sam


