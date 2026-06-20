cut -f1 Balanus_glandula.fna.fai > scaffolds.txt

wc -l scaffolds.txt

split -n l/20 scaffolds.txt scaffold_chunk_

ls scaffold_chunk_* > scaffold_lists.txt

head scaffold_lists.txt
head scaffold_chunk_aa
