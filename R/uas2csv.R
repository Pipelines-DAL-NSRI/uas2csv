#' Merge and widen files generated from ForenSeq UAS and export as a single CSV file
#' 
#' @param files is a zipped or tar file containing all individual/group reports for a specific type of marker in an excel file. See the sample zipped file.
#' @param population is a csv or excel file containing the metadata. It should have a "Sample" header.
#' @param reference indicates if there is a "population" input. Should be set to TRUE if metadata is uploaded. Default is FALSE.
#' @examples
#' uas2csv(file = "files.zip", population = "metadata.xlsx", reference = TRUE)
#' @example uas2csv(files = "mydata.tar")
#' @import pacman
#' @import tools
#' @import utils
#' @import readxl
#' @import stats
#' @import dplyr
#' @import purrr
#' @import tidyr
#' @import readr
#' @export

uas2csv <- function(files = files, population = pop_file, reference = FALSE){
   
   if(!require("pacman")) {
      install.packages("pacman")
   }
   
   pacman::p_load(tools, utils, readxl, stats, dplyr, purrr, tidyr, readr, install = TRUE)
   
   if(!file.exists(files)){
      stop("File does not exist in the working directory")
   } else {
   
   if(tools::file_ext(files) == "zip"){
      utils::unzip(files, 
                   files = NULL, 
                   list = FALSE, 
                   overwrite = TRUE, 
                   exdir = "UAS_genotypes")
      
      MainDir <- getwd()
      setwd("./UAS_genotypes")
      data.files <- list.files()
      data.list <- list.files(pattern = ".xlsx")
      all.list <- list()
      
      for (i in data.list) {
         all.list[[i]] = readxl::read_excel(i, sheet = 1, col_names = TRUE, row.names(data.files))}
      
      # correct names of dataframes
      new_colnames <- c("Sample", "ID", "Allele")
      dflist_new <- lapply(all.list, setNames, new_colnames)
      
      dflist_corrected <- lapply(
         dflist_new, 
         function(x){ 
            stats::aggregate(Allele ~ Sample + ID, x, paste, collapse = "/")
         })
      
      # pivot wider
      df_list <- purrr::map(dflist_corrected, ~(tidyr::pivot_wider(.x, names_from= Sample, values_from = Allele)))
      
      library(dplyr) # usually needs to be specified
      library(purrr)
      
      merged <- df_list %>% purrr::reduce(full_join, by= "ID")
      id <- merged$ID 
      
      #transpose
      correct_alleles <- merged
      correct_alleles <- data.frame(t(correct_alleles))
      names(correct_alleles) <- correct_alleles[1,] 
      correct_alleles <- correct_alleles[-1,] 
      
      samples <- data.frame(colnames(merged[,-1]))
      corrected <- correct_alleles
      
      Samples <- rownames(corrected)
      corrected <- data.frame(Samples, corrected)
      
      
} else if(tools::file_ext(files) == "tar"){ 
      MainDir <- getwd()
      
      utils::untar(files, files = NULL, list = FALSE, exdir = "UAS_genotypes")
      new <- list.files(path = "./UAS_genotypes", recursive = TRUE, full.names = T)
      
      file.copy(from = new, to = "./UAS_genotypes", overwrite = T)
      
      setwd("./UAS_genotypes")
      data.files <- list.files()
      data.list <- list.files(pattern = ".xlsx")
      all.list <- list()
      
      for (i in data.list) {
         all.list[[i]] = readxl::read_excel(i, sheet = 1, col_names = TRUE, row.names(data.files))}
      
      # correct names of dataframes
      new_colnames <- c("Sample", "ID", "Allele")
      dflist_new <- lapply(all.list, setNames, new_colnames)
      
      dflist_corrected <- lapply(
         dflist_new, 
         function(x){ 
            stats::aggregate(Allele ~ Sample + ID, x, paste, collapse = "/")
         })
      
      # pivot wider
      df_list <- purrr::map(dflist_corrected, ~(tidyr::pivot_wider(.x, names_from= Sample, values_from = Allele)))
      
      library(dplyr) # usually needs to be specified
      library(purrr)
      
      merged <- df_list %>% purrr::reduce(full_join, by= "ID")
      id <- merged$ID 
      
      #transpose
      correct_alleles <- merged
      correct_alleles <- data.frame(t(correct_alleles))
      names(correct_alleles) <- correct_alleles[1,] # removes letters are columns, but duplicates ID row+column
      correct_alleles <- correct_alleles[-1,] #will remove the duplicate ID row
      
      samples <- data.frame(colnames(merged[,-1]))
      corrected <- correct_alleles
      
      Samples <- rownames(corrected)
      corrected <- data.frame(Samples, corrected)
      
   } else {
      stop("Not a zipped file. Accepted are zipped and tar files")
   }
      
      if(reference == FALSE){
         readr::write_csv(corrected, file = "01_merged_typed_data.csv")
      } else {
         
         if(tools::file_ext(population) == "csv"){
            pop_data <- readr::read_csv(population)
         } else if(tools::file_ext(population) == "xlsx"){
            pop_data <- readxl::read_excel(population)
         } else {
            stop("File is not a csv or xlsx file")
         }
         
         matched <- corrected %>% dplyr::left_join(pop_data, by = "Sample")
         data_length <- as.integer(ncol(corrected) - 1) # count the number of markers
         data_matched <- matched[,2:data_length] # subset the markers
         meta_begin <- as.integer(ncol(corrected) + 1) # estimate the beginning of the metadata
         meta <- matched[,meta_begin:ncol(matched)] # subset the metadata 
         
         final_df <- dplyr::bind_cols(matched$Sample, meta, data_matched)
         names(final_df)[names(final_df) == "matched$Sample"] <- "Sample"
         
         readr::write_csv(final_df, file = "01_merged_typed_data.csv")
      }
   }
} 
