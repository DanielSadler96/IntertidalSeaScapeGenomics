
###first col all SRR etc , secon col = BOD1 etc (Real sample name)
###dos2unix renamemeta.txt if done on excel to check 

while read -r old new; do
  for f in ${old}*; do
    newname="${f/$old/$new}"
    mv -- "$f" "$newname"
  done
done < renamemeta.txt


while read new old; do
    mv "$old" "$new"
done < rename.txt