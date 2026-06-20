library(tidyverse)

setwd("/users/d/s/dsadler1/Pi_shared/MultiSpeciesGO/Balanusglandula/BayPass")

# Set the directory containing your .frq.count files
allele_dir <- "/users/d/s/dsadler1/Pi_shared/MultiSpeciesGO/Balanusglandula/AC/filt4"

# Get all files ending with .frq.count
files <- list.files(allele_dir, pattern = "\\.frq\\.count$", full.names = TRUE)

# Function to extract allele counts from a file

process_file <- function(file) {
  df <- read.delim(file, header = FALSE, fill = TRUE, stringsAsFactors = FALSE)
  
  # Remove continuation rows (where CHROM is missing)
  df <- df[!is.na(df$V1), ]
  
  colnames(df)[1:4] <- c("CHROM", "POS", "N_ALLELES", "N_CHR")
  
  # Keep only biallelic sites
  df <- df[df$N_ALLELES == 2, ]
  
  # Keep only first two allele columns (ignore extras)
  allele_counts <- df[, 5:6]
  
  counts <- as.data.frame(lapply(allele_counts, function(x) {
    as.integer(sub(".*:", "", x))
  }))
  
  return(counts)
}


# Apply processing to each file
all_counts <- lapply(files, process_file)

# Confirm all have the same number of rows (i.e., SNPs)
stopifnot(length(unique(sapply(all_counts, nrow))) == 1)

# Combine counts: one row per SNP, two columns per population (Ref and Alt)
baypass_matrix <- do.call(cbind, all_counts)
baypass_matrix[is.na(baypass_matrix)] <- 0
dim(baypass_matrix)
# Write to file with no row/column names or quotes
write.table(baypass_matrix, file = "baypass_input_Balanus_filt4.txt", 
            quote = FALSE, row.names = FALSE, col.names = FALSE, sep = " ")
