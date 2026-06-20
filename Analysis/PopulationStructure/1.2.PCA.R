library(tidyverse)

###tutorial at https://speciationgenomics.github.io/pca/

pca <- read_table2("Haliotis_pca_3_0.2.eigenvec", col_names = FALSE)
eigenval <- scan("Haliotis_pca_3_0.2.eigenval")

pca <- pca[,-2]
# set names
names(pca)[1] <- "Population"
names(pca)[2:ncol(pca)] <- paste0("PC", 1:(ncol(pca)-1))

pca %>% mutate(POP=str_extract(as.character(Population), "[A-Za-z]+"),REP=str_extract(as.character(Population), "[0-9]+"))->pca

pve <- data.frame(PC = 1:10, pve = eigenval/sum(eigenval)*100)

a <- ggplot(pve, aes(PC, pve)) + geom_bar(stat = "identity")
a + ylab("Percentage variance explained") 
ggsave(a, file = "variance.png")


cumsum(pve$pve)

b <- ggplot(pca, aes(PC1, PC2, Fill = POP)) + 
  geom_point(aes(fill=POP), size = 3, colour = "black", shape = 21, stroke =1, alpha = 0.5)+
  coord_equal() + 
  theme_light()+
  scale_fill_brewer(palette = "Set3")+ 
  xlab(paste0("PC1 (", signif(pve$pve[1], 3), "%)")) + ylab(paste0("PC2 (", signif(pve$pve[2], 3), "%)"))+
  ggtitle("H. rufescens")+
  xlim(-0.05, 0.05)+
  ylim(-0.05, 0.05)


ggsave(b, file = "filt3_pca.png")