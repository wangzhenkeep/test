import sys,os,re,commands
from random import random
from operator import add

from pyspark import SparkContext


if len(sys.argv)!=2:
	print '\033[1;31;40m',
	print "Usage: *.py [ shell.sh ]",
	print '\033[0m',
	sys.exit(0)
basename_sh=os.path.basename(sys.argv[1])
sc = SparkContext(appName="PGS_spark "+basename_sh)
file_name=sys.argv[1]

sc.parallelize(["1"]).map(lambda line:os.system("sh "+file_name+" 1 >"+file_name+".o 2>"+file_name+".e")).collect()
