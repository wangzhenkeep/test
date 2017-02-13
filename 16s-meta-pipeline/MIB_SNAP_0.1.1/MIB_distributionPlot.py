#!/usr/bin/python
#
#	distributionPlot.py
#
#	This program will generate the distribution map.
#	
#	distributionPlot.py <distribution_file> <NGS> <reads or virus>
#
### Authors : Yang Li <liyang@ivdc.chinacdc.cn>
### License : GPL 3 <http://www.gnu.org/licenses/gpl.html>
### Update  : 2015-08-05
### Copyright (C) 2015 Yang Liz` - All Rights Reserved
import matplotlib
#import matplotlib.numerix as nx
matplotlib.use('Agg')
from pylab import *
from pylab import figure, show, legend
import matplotlib.pyplot as plt
#import numpy as np
import pandas as pd
import sys, os
import matplotlib as mtl

mtl.rcParams['font.size'] = 8.0

if len(sys.argv) < 3:
	print "usage: distributionPlot.py <distribution_file> <NGS> <reads or virus>"
	sys.exit(-1)

dataFile = sys.argv[1]
#report = sys.argv[2]
#title = sys.argv[3]
ngs = sys.argv[2]
file_type = str(sys.argv[3])
#outputFile = "covplot."+title+"."+ngs+".png"
if file_type == 'reads':
	outputFile = "reads_distribution"+"."+ngs+".png"
	ngs_title = "Reads Distribution"
	data = pd.read_table(dataFile,names=['X', 'Y'], header=None, skiprows=1)
	fig=plt.figure(figsize=[5,3.75])
	fig=plt.pie(data['Y'], labels=data['X'], autopct='%1.1f%%')
	title(ngs_title)
	#fig.
	plt.show()
	savefig(outputFile)
elif file_type == 'family':
	outputFile = "family_distribution"+"."+ngs+".png"
	ngs_title = "Family Distribution"
	data = pd.read_table(dataFile,names=['X', 'Y'], header=None, skiprows=1)
	fig=plt.figure(figsize=[5,3.75])
	fig=plt.pie(data['Y'], labels=data['X'], autopct='%1.1f%%')
	title(ngs_title)
	#fig.
	plt.show()
	savefig(outputFile)
elif file_type == 'genus':
	outputFile = "genus_distribution"+"."+ngs+".png"
	data = sys.argv[1]
	data = pd.read_table(dataFile,names=['X', 'Depth'], header=None, skiprows=0)
	#print data['Depth']
	fig=plt.figure(figsize=[10,3.75])
	ax = fig.add_subplot(111)
	#fig = plt.bar(left=1, height=data['Depth'], width=0.4)
	#data['Depth'].plot(kind='bar', width=0.4, color='red', ax=ax, position=1,legend=True)
	#width=0.4
	data['Depth'].plot(kind='bar', color='red')
	#print data
	ax.set_ylabel('Depth')
	title="Top 15 genus distribution"
	ax.set_title(title)
	ax.set_xticklabels(data['X'], rotation=10)
	#data['Y'].plot(kind='bar', width=0.3, color='red', position=1,legend=True)
	#plt.xticks(data['X'])	
	#data.plot(kind='bar')
		
	#genus=pd.DataFrame(data['Y'], columns=data['X'])
	#print genus
	#print data['Y']
	#genus.plot(kind='bar')
	#ax.legend(loc=2)
	
	#plt.xlabel(u'Genus')
	#plt.ylabel(u'Depth')
	#fig=plt.bar(data['X'], data['Y'])
	plt.show()
	savefig(outputFile)
#data = pd.read_table(dataFile,names=['X', 'Y'], header=None, skiprows=1)
#fig=plt.figure(figsize=[5,3.75])
#fig=plt.pie(data['Y'], labels=data['X'], autopct='%1.1f%%')
#title(ngs_title)
#patches, texts, autotexts = fig
#texts.set_fontsize(9)
#plt.show()
#data.plot(kind='pie', figsize=(6, 6))
#savefig(outputFile)
