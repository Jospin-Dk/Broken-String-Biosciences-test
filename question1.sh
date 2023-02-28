#!/usr/bin/bash
# Name: Jospin Al Deek 
# Broken String Biosciences test Feb/23
# Bash version: 3.2.57(1)-release on MacOS Ventura 13.2
# bwa version: 0.7.17-r1188
# samtools version: 1.17 (using htslib 1.17)
# bedtools version: 2.30.0

#directories
#assuming that the user has already navigated to the "broken_string_bio_test" directory and is running this pipeline from there
ref="./data/chr21/chr21.fasta"
reads="./data/fastqs/"
alignment="./results/alignment/"
bed="./results/bed/"
bed_edited="./results/bed_edited/"
final="./results/final/"

#variables
num_samples=$(ls ${reads} | wc -l)

# 1)a)
#indexing the reference genome (chromosome 21)
echo "========================="
echo "Indexing reference genome"
echo "========================="
bwa index ${ref}

#looping
for sample in $(seq 1 $num_samples)
do 

#Aligning the reads using bwa -mem
echo "========================"
echo "Aligning read number:${sample}"
echo "========================"
bwa mem \
-R "@RG\tID:H32L2BGXT\tSM:$sample\tPL:illumina" \
${ref} \
${reads}"Sample"$sample".fastq.gz" \
> ${alignment}"Sample"$sample"_aln.sam"

# convert sam to bam files
echo "====================="
echo "Converting Sam to Bam"
echo "====================="
samtools view -S -b ${alignment}"Sample"$sample"_aln.sam" > ${alignment}"Sample"$sample"_aln.bam"

# 1)b)
# convert bam to bed file
echo "====================="
echo "Converting Bam to Bed"
echo "====================="
bedtools bamtobed -i ${alignment}"Sample"$sample"_aln.bam" > ${bed}"Sample"$sample"_aln.bed"

# 1)c)
#processing the bed files adjusting the coordinates to only include the break sites
echo "========================================"
echo "Adjusting start and end positions in Bed"
echo "========================================"
awk '{
    if ($6 == "+")
    {
        $3=$2+1
        print $0
    }
    else
    {
        $2=$3-1
        print $0
    }
}' ${bed}"Sample"$sample"_aln.bed" > ${bed_edited}"Sample"$sample"_aln_edited.bed"

#1)d)
#Intersect the breaks encoded in the bed file with predicted AsiSI sites
echo "======================================================================="
echo "Intersect the breaks encoded in Bed with predicted AsiSI sites"
echo "======================================================================="
awk 'NR == FNR {x[NR]=$2; next;} { for (i in x) {if (x[i] >= $2 && x[i] < $3) {print $1, $2, $3; } } }' \
${bed_edited}"Sample"$sample"_aln_edited.bed" ./data/chr21_AsiSI_sites.t2t.bed \
> ${bed_edited}"Sample"$sample"_AsiSI_intersection.bed"


uniq -c ${bed_edited}"Sample"$sample"_AsiSI_intersection.bed" | awk 'BEGIN { OFS = "\t"} {print $2,$3,$4,$1}' \
> ${final}"Sample"$sample"_AsiSI_breaks.bed"
done