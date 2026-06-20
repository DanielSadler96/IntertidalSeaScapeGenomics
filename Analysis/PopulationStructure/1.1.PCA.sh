VCF=/users/d/s/dsadler1/Pi_shared/MultiSpeciesGO/Balanusglandula/VCFs/Balanus_glandula_filt3.vcf.gz

module load plink/1.9b7.7

plink --vcf $VCF --make-bed --allow-extra-chr --out Balanus_plink_filt3

###filter MAF 0.05 prune LD 0.8

plink --bfile Balanus_plink_filt3 \
  --indep-pairwise 50 5 0.2 \
  --allow-extra-chr \
  --out Balanus_plink_filt3_pruned


###generate pca
plink --bfile Balanus_plink_filt3 --mind --allow-extra-chr  --extract  Balanus_plink_filt3_pruned.prune.in --pca 10  --out Balanus_plink_filt3_PCA