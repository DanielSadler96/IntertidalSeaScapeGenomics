##list2 = samplenames ploidy usually = 2 for our case as we are dealing with diploid species 

awk '{print $0 "\t2"}' list2.txt > ploidymap.txt

head ploidymap.txt