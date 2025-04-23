# UAS2CSV Package

## Description
Reads a zipped or tar folder that contains typed files of specific markers downloaded and extracted from the ForenSeq UAS software. 
This follows the script from P1 that extracted the information per marker. The function calls and merges all typed files, simultaneously widening the long data.

## Function
```
uas2csv(file = files, reference = TRUE, population = metadata)
```

## Parameters
@param *files* should be a zipped file containing the typed data with 3 columns: [1] Sample column, [2] markers column, and [3] alleles. See sample.zip that contains the files.

@param *reference* should be set to TRUE if population metadata is needed.

@param *population* is either an xlsx or csv file containing the metadata of the samples. A sample column similar to the *files* should be present. Column name should also be "Sample"

## Usage
```
uas2csv(file = "myzippedfiles.zip", reference = TRUE population = "metadata.xlsx")
uas2csv(file = "sample.zip", reference = FALSE)
```
