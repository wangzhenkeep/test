import sys,os,re,commands
from random import random
from operator import add

from pyspark import SparkContext

if __name__ == "__main__":
	if len(sys.argv)!=4:
		print '\033[1;31;40m',
		print "Usage: *.py [ shell.sh ] [temp] [result_dir]",
		print '\033[0m',
		sys.exit(0)
	basename_sh=os.path.basename(sys.argv[1])
	sc = SparkContext(appName="PGS_spark "+basename_sh)
	file_name=sys.argv[1]
	temp=sys.argv[2]
	result_dir=sys.argv[3]


	def f(line):
		os.system("mkdir -p "+result_dir)
		os.system("rm -rf "+file_name)
		os.system("rm -rf "+result_dir+"/"+temp)
		os.system("scp root@master:"+file_name+" "+result_dir+"/")
		os.system("sh "+line+" 1 >"+line+".o 2>"+line+".e")
 
	sc.parallelize([file_name]).map(f).collect()