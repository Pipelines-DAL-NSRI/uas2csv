# UAS2CSV Package

## Description
Reads a zipped or tar folder that contains typed files of specific markers downloaded and extracted from the ForenSeq UAS software. 
This follows the script from P1 that extracted the information per marker. The function calls and merges all typed files, simultaneously widening the long data.

## Parameters
Input: 
1. Zipped folder containing the typed files.
2. Metadata (optional)

## Usage
uas2csv(file = "myzippedfiles.zip", population = "metadata.xlsx", reference = TRUE)
