import sys,os,re,commands
from random import random
from operator import add

from pyspark import SparkContext


if len(sys.argv)!=5:
	print '\033[1;31;40m',
	print "Usage: *.py [ bin.txt ] [ bam ] [ output ] [ length cutoff 600 ]",
	print '\033[0m',
	sys.exit(0)


status_time,output_time1=commands.getstatusoutput("date")
print "************************1 time :"+output_time1

tab1 = sys.argv[2]
database = sys.argv[1]
output_file=sys.argv[3]
lengthcutoff=float(sys.argv[4])*0.8*1000

os.system("samtools view -F 4 "+tab1+" | awk '{print $1\"\t\"$2\"\t\"$3\"\t\"$4\"\t\"$5\"\t\"$6}' >"+tab1+".txt")

sc = SparkContext(appName="Pythontest")
file_name="file://"+database
lines=sc.textFile(file_name)

status_time,output_time1=commands.getstatusoutput("date")
print "************************2 time :"+output_time1

chrom_num=lines.map(lambda line:(re.split("\t",line)[0],1)).collectAsMap()

status_time,output_time1=commands.getstatusoutput("date")
print "************************3 time :"+output_time1

#chrom_region_num=lines.map(lambda line:(re.split("\t",line)[1],1)).collectAsMap()

status_time,output_time1=commands.getstatusoutput("date")
print "************************4 time :"+output_time1

#dict2=lines.map(lambda line:(re.split("\t",line)[0]+" "+re.split("\t",line)[1],int (re.split("\t",line)[4]))).reduceByKey(lambda a,b:a+b).collectAsMap()
#print dict2
'''
dict1=(lines.map(lambda line:(re.split("\t",line)[0]+" "+re.split("\t",line)[1],(re.split("\t",line)[2],re.split("\t",line)[3])))
			.reduceByKey(lambda a,b:a+b)
			.filter(lambda kv:int(dict2[kv[0]])> int(lengthcutoff))
			.collectAsMap())
max_num=(lines.map(lambda line:(re.split("\t",line)[0]+" "+re.split("\t",line)[1],(int(re.split("\t",line)[2]),int(re.split("\t",line)[3]))))
		.reduceByKey(lambda a,b:a+b)
		.filter(lambda kv:int(dict2[kv[0]])> int(lengthcutoff)).map(lambda  kv:(kv[0],max(kv[1])))
		.collectAsMap())

min_num=(lines.map(lambda line:(re.split("\t",line)[0]+" "+re.split("\t",line)[1],(int(re.split("\t",line)[2]),int(re.split("\t",line)[3]))))
		.reduceByKey(lambda a,b:a+b)
		.filter(lambda kv:int(dict2[kv[0]])> int(lengthcutoff)).map(lambda  kv:(kv[0],min(kv[1])))
		.collectAsMap())
'''
#####################################################################
def f(qline):
	print "*######################"
	print qline
	#count1_new={}
	a=qline.split("\t")
	#print "*######################"
	#print a
	dis_length=0
	pipei=re.compile("\d+M|\d+D")
	list_num=pipei.findall(a[5])
	for one in list_num:
		one_new=re.sub("D|M","",one)
		dis_length+=int(one_new)
	END=int(a[3])+dis_length
	for key2 in chrom_region_num.keys():
		if dict1.has_key(a[2]+" "+key2):
			if (int(a[3])>=int(min_num[a[2]+" "+key2])-200) and (END<=int(max_num[a[2]+" "+key2])+200):
				#list_pos=re.split(" ",dict1[a[2]+" "+key2])
				num_lishi=1
				for pos_lishi in dict1[a[2]+" "+key2]:
					if num_lishi%2==0:
						if (int(pos_lishi)-int(a[3])>=25 and int(pos_lishi)<=END) or (END>=tmp_lishi+25 and END<=int(pos_lishi)):
							return (a[2]+" "+key2,1)
							break
					else:
						tmp_lishi=int(pos_lishi)
					num_lishi+=1
#####################################################################

tab1_txt="file://"+sys.argv[1]
print "*******************************5\n"
count1=(sc.textFile(tab1_txt).filter(lambda line:int(re.split("\t",line)[4])>=5)
		.filter(lambda line:not re.search("chrM|\*",re.split("\t",line)[2]))
		.collect())
print "*******************************6\n"
print count1
file_write=open(output_file,"w")
file_wirte.write(count1)
'''
for key1 in sorted(chrom_num.keys()):
	for key2 in sorted(chrom_region_num.keys()):
		if count1.has_key(key1+" "+key2):
			file_write.write(key1+"\t"+min_num[key1+" "+key2]+"\t"+max_num[key1+" "+key2]+"\t"+str(count1[key1+" "+key2])+"\t"+key2+"\n")
'''
file_write.close()