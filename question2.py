# Name: Jospin Al Deek 
# Broken String Biosciences test Feb/23
# python version: 3.8.8 on MacOS Ventura 13.2
# pandas version: 1.2.4
# numpy version: 1.20.1
# matplotlib version: 3.3.4

# packages
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt

#Variables
normalized_counts=[]
samples=16

for i in range(1,samples+1):
    #2)a) reading bed file containing AsiSI breaks 
    final_AsiSI_bed=pd.read_table("./results/final/Sample"+str(i)+"_AsiSI_breaks.bed", names=["chr", "start", "end", "count"])
    #checking whether the file is empty and appointing 0 normalized AsiSI breaks if it is
    if len(final_AsiSI_bed)!=0:
        #2)b) summing the number of AsiSI breaks per sample
        AsiSI_count=final_AsiSI_bed["count"].sum()
        #2)c) normalising the number of AsiSI breaks
        bed=pd.read_table("./results/bed/Sample"+str(i)+"_aln.bed", header=None)
        bed_count=len(bed)
        normalized_count=AsiSI_count/(bed_count/1000)
        normalized_counts.append(normalized_count)
    else:
        normalized_counts.append(0)

#2)d) plotting
sample_pos=np.arange(1,17,1)
plt.figure(figsize=(10, 6), dpi=100)
plt.scatter(range(1,samples+1),normalized_counts, cmap='viridis')
plt.title("Scatter plot of normalized AsiSI breaks number per sample", pad=20, fontweight="bold")
plt.xlabel("Samples")
plt.xticks(sample_pos, sample_pos)
plt.ylabel("Number of normalized AsiSI breaks")
plt.grid(alpha=0.3)
#plt.show()
plt.savefig('./results/AsiSI_normalised_counts.png')