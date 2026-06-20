library(ggplot2)
library(data.table)
library(RColorBrewer)
library(tidyverse)
library(broom)

###check this works, might have to move to your own directory
#source("/gpfs1/home/d/s/dsadler1/scratch/SeaUrchinEnvPop/GDS/BayPass/localscore/scorelocalfunctions.R")
source("/gpfs1/home/d/s/dsadler1/scratch/SeaUrchinEnvPop/AllProjects/BayPass/localscore/scorelocalfunctions.R")

###read in your XtX file
###XtX is the equivalent of FST but instead corrects for population
###log10 p value is if there is significant divergence across the population, this is done per SNP
#list.files(pattern = "contrast")

xtx<-read.table("CoreModelBalanus_summary_pi_xtx.out" , header=T)
###Read in your list of chr's and pos'
###use bcftools query -f '%CHROM\t%POS\n' input.vcf.gz > chr_pos.txt

snps<-read.table("/gpfs2/scratch/pi/mpespeni/MultiSpeciesGO/Balanusglandula/chr_pos.txt", header=T)

####combine the files toghether, the baypass file will be in the same order as snps file
xtx_pos_dt<-cbind(snps,xtx)

#### convert to data table object, local score is encoded using data table so we have switched
#### from tidyverse, it is essentially a memory efficient way of wrangling data
xtx_pos_dt<- as.data.table(xtx_pos_dt)

#### setkey reorders data, here it is ordered by chromosome, NOTE YOU MAY HAVE TO NUMERICALLY DO THIS
setkey(xtx_pos_dt, chr)

####replace zero values with 1e-16 
####NOTE pval might be a different name, you can change the name with names() or use the original
xtx_pos_dt$log10.1.pval.[xtx_pos_dt$log10.1.pval.==0]=1e-16

####counts number of chromosome, check this is correct for your species
Nchr=length(xtx_pos_dt[,unique(chr)])

####computes chromosome information, length + autocorrelation
####SNPs are not independent due to linkage THIS IS WHY WE USE LINDLEY
####this is calculating a correction based on chromsome length (L) and the autocorrelation of the pval
chrInfo=xtx_pos_dt[,.(L=.N,cor=autocor(log10.1.pval.)),chr]

###allows joining of snp table by chr
setkey(chrInfo,chr)

###creates genome wide cumulative chr start points
### L = SNP count per chr, cumsum creates starting index for each chromsome - so you know where each chr starts and ends
data.table(chr=chrInfo[,unique(chr),], S=cumsum(c(0,chrInfo$L[-Nchr])))

### Choice of $\xi$ (1,2,3 or 4)
# The score mean must be negative, ksi must be chosen between mean and max of -log10(p-value)
xi=1
##compute snp scores correcting for xi 
xtx_pos_dt[,score:= log10.1.pval.-xi]

##compute lindley scores -> Li=max(0,Li−1+scorei)
xtx_pos_dt[,lindley:=lindley(score),chr]

###check that this negative
mean(xtx_pos_dt$score)

###check xi is in between mean and max 
mean(xtx_pos_dt$log10.1.pval.);max(xtx_pos_dt$log10.1.pval.)

#hist(mydata$score)
###maximum observed score - largest peak
max(xtx_pos_dt$lindley)

# Compute significance threshold for each chromosome
## Uniform distribution of p-values
chrInfo[,th:=thresUnif(L, cor, xi),chr]

##joins thresholds to snp table
(xtx_pos_dt=xtx_pos_dt[chrInfo])

####detects significant zones - where Lindley > threshold (th)
(sigZones=xtx_pos_dt[chrInfo,sig_sl(lindley, pos, unique(th)),chr])
###save
save(xtx_pos_dt, file="xtx_pos_dt_F16_SS2.RData")

###identify list of outliers based on max threshold and print
outlierslindxi2<-xtx_pos_dt %>% 
  filter(lindley > max(th))
dim(outlierslindxi2)

###make sure its arranged by chr and pos -> Note we switch to tidyverse here, I hate datatable, but has to be used for localscore
xtx_pos_dt <- xtx_pos_dt %>%
  arrange(chr, pos)

### calculates chromsome length (max pos) and created cumulative offsets for each, so for example:
### chr 1 0-50000 (max pos), yjem creayes a lag, starts next chr, 50000-100000 (max pos)
chromosome_offsets <- xtx_pos_dt %>%
  group_by(chr) %>%
  summarize(chr_len = max(pos)) %>%
  mutate(offset = lag(cumsum(chr_len), default = 0)) 

####joins the new chr offset values to the dataframe creating new pos of pos_cum rather than raw positions
xtx_pos_dt <- xtx_pos_dt %>%
  left_join(chromosome_offsets, by = "chr") %>%
  mutate(pos_cum = pos + offset)

#### creates labels for the chromosomes, positioming them in the centre of each chr
chr_labels <- xtx_pos_dt %>%
  group_by(chr) %>%
  summarize(center = mean(pos_cum))

####generates manhattan plot - if you have any questions about what each function within ggplot does give me a message or check with ?

colourline = c( "black","salmon1", "salmon3",  "seagreen3", "seagreen","navy", "cadetblue")

p1 <- ggplot(xtx_pos_dt, aes(x = pos_cum, y = lindley, colour = as.factor(chr))) +
  geom_point(size = 1, alpha = 0.7) +
  geom_hline(yintercept = max(xtx_pos_dt$th), linetype = "solid", color = "red", linewidth = 0.8) +
  scale_x_continuous(label = chr_labels$chr, breaks = chr_labels$center) +  # Chromosome labels
  scale_color_manual(values = rep(c("black", "salmon1"), length(unique(xtx_pos_dt$chr)))) +  # Alternate colors
  theme_classic(base_size = 14) +
  theme(
    panel.grid.major.y = element_line(color = "grey90", linetype = "dotted"),
    axis.text.x = element_text(size = 14, colour = "black"),
    axis.text.y = element_text(size = 14, colour = "black"),
    axis.title = element_text(size = 16, colour = "black", face = "bold")
    legend.position = "none"
  ) +
  labs(x = "Chromosome", y = "Lindley Score")+
  ggtitle("F16 SS2")

output_dir <- "/scratch/project_2003522/WGS_2022/FST/linerepBay/plots"

if (!dir.exists(output_dir)) {
  dir.create(output_dir)
}

ggsave(
  filename = file.path(output_dir, "pvalue_xi2_SS2_F16_man.png"),  # Full path
  plot = p1,
  dpi = 300,
  width = 14,   
  height = 8,   
  units = "in"  
)
