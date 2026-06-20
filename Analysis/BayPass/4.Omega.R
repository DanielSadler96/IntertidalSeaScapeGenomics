
library(corrplot)
library(ggplot2)
library(RColorBrewer)
library(ape)

setwd("/users/d/s/dsadler1/Pi_shared/MultiSpeciesGO/Conner/analyses/")

pops<-read.table("/users/d/s/dsadler1/Pi_shared/MultiSpeciesGO/Conner/analyses/FST/pop_prefixes.txt")

NC.omega <- as.matrix(read.table("CoreModelHali_2_mat_omega.out"))

output_dir="./Baypass_omega"
if (!dir.exists(output_dir)) {dir.create(output_dir)}

colnames(NC.omega) <- pops$BOD
rownames(NC.omega) <- pops$BOD

write.table(NC.omega, "output/tables/NC.omega.txt", sep='\t')

NC.omega_reorder <- as.matrix(read.table("popordered.txt"))

as.character(NC.omega_reorder)->ord

NC.omega <- NC.omega[ord, ord]


cor.mat <- cov2cor(NC.omega_reorder)

NC.omega <- NC.omega[ord, ord]

cor.mat <- cov2cor(NC.omega)

pdf("/gpfs2/scratch/pi/mpespeni/MultiSpeciesGO/Conner/analyses/BayPass/Baypass_omega/Baypass_omega_cor_matrix_title.pdf", width = 5, height = 5)
corrplot(cor.mat, method = "color", mar=c(2,1,2,2)+0.1, main=expression("Correlation map based on"~hat(Omega)))
dev.off()

NC.tree=as.phylo(hclust(as.dist(1-cor.mat**2)))

pdf("/gpfs2/scratch/pi/mpespeni/MultiSpeciesGO/Conner/analyses/BayPass/Baypass_omega/Baypass_hier_clustering_title.pdf", width = 5, height = 5)
plot(NC.tree,type="p",
     main=expression("Hier. clust. tree based on"~hat(Omega)~"("*d[ij]*"=1-"*rho[ij]*")"))
dev.off()


nb.cols <- 23
mycolors <- rev(colorRampPalette(brewer.pal(11, "RdBu"))(nb.cols))

# Graph tree (no title), color tips by N-S order
pdf("/gpfs2/scratch/pi/mpespeni/MultiSpeciesGO/Conner/analyses/BayPass/Baypass_omega/Baypass_hier_clustering_colors.pdf", width = 6.5, height = 9)
plot(NC.tree, type="p", label.offset = 0.02, cex = 1.8)
tiplabels(pch = 21, col="black", bg = mycolors, cex = 2)
dev.off()
