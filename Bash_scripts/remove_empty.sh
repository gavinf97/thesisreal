#!/bin/bash
#Gavin Farrell – 15/8/21 

#Use: 
#File management 

#Description: 
#Removes all empty size 0 files (useful for incomplete antismash runs; gbk/fasta files/etc... 
find ./ -size  0 -print -delete
