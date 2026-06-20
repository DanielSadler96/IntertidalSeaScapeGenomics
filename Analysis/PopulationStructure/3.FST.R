library(SeqArray)
library(SeqVarTools)
library(reshape2)
library(ggplot2)
library(SNPRelate)
library(tidyr)
library(ggplot2)

#if (!requireNamespace("BiocManager", quietly=TRUE))
#    install.packages("BiocManager")
#BiocManager::install("SeqVarTools")

setwd("/gpfs2/scratch/pi/mpespeni/MultiSpeciesGO/Balanusglandula/analyses")

gds.fn <- "Balanus_glandula_filtered.gds"
genofile <- seqOpen(gds.fn)

sample_ids <- seqGetData(genofile, "sample.id")
head(sample_ids)
table(seqGetData(genofile, "chromosome"))

popmap <- read.table("FST/popmap.txt", header = FALSE, stringsAsFactors = FALSE)
colnames(popmap) <- c("sample.id", "pop")


popmap <- data.frame(
  sample.id = as.character(sample_ids),
  pop = sub("^([A-Za-z]+).*", "\\1", sample_ids)
)

popmap

pop <- popmap$pop[match(sample_ids, popmap$sample.id)]


pop <- factor(pop)
pops <- levels(pop)

pairs <- combn(pops, 2, simplify = FALSE)

fst_list <- list()


for (pair in pairs) {
  pop1 <- pair[1]
  pop2 <- pair[2]
  
  cat("Processing:", pop1, "vs", pop2, "\n")
  
  samples_keep <- sample_ids[pop %in% c(pop1, pop2)]
  
  sub_pop <- pop[match(samples_keep, sample_ids)]
  sub_pop <- droplevels(factor(sub_pop))
  fst <- snpgdsFst(
    genofile,
    sample.id = samples_keep,
    population = sub_pop,
    method = "W&C84",
    autosome.only = FALSE
  )
  
  fst_list[[paste(pop1, pop2, sep = "_vs_")]] <- fst$Fst
}

pairwise_fst <- data.frame(
  comparison = names(fst_list),
  fst = unlist(fst_list)
)

head(pairwise_fst)

seqClose(genofile)


fst_wide <- pairwise_fst %>%
  separate(comparison, into = c("pop1", "pop2"), sep = "_vs_") %>%
  pivot_wider(names_from = pop2, values_from = fst)

fst_long <- pairwise_fst %>%
  separate(comparison, into = c("pop1", "pop2"), sep = "_vs_")

p1<-ggplot(fst_long, aes(x = pop1, y = pop2, fill = fst)) +
  geom_tile(color = "white") +
  geom_text(aes(label = round(fst, 3)), size = 3) +
  scale_fill_gradient2(
    low = "cadetblue",
    mid = "white",
    high = "salmon3",
    midpoint = median(fst_long$fst, na.rm = TRUE)
  ) +
  theme_minimal() +
  theme(
    axis.text = element_text(angle = 45, hjust = 1, colour = "black"),,
    panel.grid = element_blank()
  ) +
  labs(
    x = "",
    y = "",
    fill = "FST",
  )

ggsave(p1, file = "BalanusFST.png")