library(RPostgreSQL)
library(GenomicRanges)
library(dplyr)
#----------------------------------------------------------------------------------------------------
# Grab snapshots of the fimo database and bone_element_wellington_20 footprints
#
#----------------------------------------------------------------------------------------------------
# Function for grabbing X rows of the database and bone footprints and saving them as a snapshot
takeSnapshot <- function(chrom.num){

    # Make chromosome number into a chromosome
    chromosome <- paste0("chr",chrom.num)
    
    fimo <- dbConnect(PostgreSQL(),
                      user = "trena",
                      password = "trena",
                      host = "localhost",
                      dbname = "fimo")

    my.query <- sprintf("select * from fimo_hg38 where chrom = '%d'", chrom.num)
    tbl.fimo <- dbGetQuery(fimo, my.query)
    dbDisconnect(fimo)
    tbl.fp <- read.table("/scratch/data/footprints/ENCSR000EMH.bed",
                            sep="\t", as.is=TRUE)
    colnames(tbl.fp) <- c("chrom", "start", "end", "name", "score", "strand")

    # Filter the fp table
    tbl.fp <- filter(tbl.fp, chrom == "chr1")
    
    saveRDS(tbl.fimo, file = paste0("fimo_snapshot",chromosome,".RDS"))
    saveRDS(tbl.fp, file = paste0("bone_snapshot",chromosome,".RDS"))
    
} #createTwoSnapshots
#----------------------------------------------------------------------------------------------------
# Load 2 RDS files and profile the merge of them
profileDbMerge <- function(tbl.fimo, tbl.fp){

    # Start the profiler    
    Rprof(tmp <- tempfile())

    # Read the 2 RDS files

    sampleID <- "Test_sample"
    method <- "Test_method"

    min.pos <- min(tbl.fp$start)    
    max.pos <- max(tbl.fp$end)
                
    colnames(tbl.fimo) <- c("motif", "chrom", "motif.start", "motif.end", "motif.strand",                            
                            "fimo.score","fimo.pvalue", "empty", "motif.sequence")    
            
#    tbl.fimo <- tbl.fimo[, -grep("empty", colnames(tbl.fimo))]    
    tbl.fimo$chrom <- paste("chr", tbl.fimo$chrom, sep="")    
    
    # Converts the FIMO data into a GenomicRanges object, making the intersection with footprints fast    
    gr.fimo <- GRanges(seqnames=tbl.fimo$chrom, IRanges(start=tbl.fimo$motif.start, end=tbl.fimo$motif.end))
          
    # --- get some footprints    
    # Converts the footprints into GenomicRanges objects    
    gr.wellington <- GRanges(seqnames=tbl.fp$chrom, IRanges(start=tbl.fp$start, end=tbl.fp$end))
            
    # the "within" is conservative. I will run this with "any" to increase    
    #the number of motif interesects    

    tbl.overlaps <- findOverlaps(gr.fimo, gr.wellington, type="any")        
    tbl.overlaps <- as.data.frame(tbl.overlaps)
    tbl.fimo$loc <- paste0(tbl.fimo$chrom,":",tbl.fimo$motif.start,"-",tbl.fimo$motif.end)
#    tbl.fimo$loc <- sprintf("%s:%d-%d", tbl.fimo$chrom, tbl.fimo$motif.start, tbl.fimo$motif.end)
    tbl.fimo$method <- method    
    tbl.fimo$sample_id <- sampleID    
            
    tbl.regions <- tbl.fimo[tbl.overlaps$queryHits,]
    
    tbl.regions <- cbind(tbl.regions,                         
                         wellington.score=tbl.fp[tbl.overlaps$subjectHits, "score"],                         
                         fp.start=tbl.fp[tbl.overlaps$subjectHits, "start"],
                         fp.end=tbl.fp[tbl.overlaps$subjectHits, "end"])    

    # Finish the profiler and print the summary
    Rprof()
    test.sum <- summaryRprof(tmp)

    return(list(test.sum, tbl.regions))
}
#----------------------------------------------------------------------------------------------------
# Take in the FIMO table, add the loc column, then profile the same code as above,
# minus the loc addition

testLocRemoval <- function(tbl.fimo, tbl.fp){

    # Time the addition of the loc column
    colnames(tbl.fimo) <- c("motif", "chrom", "motif.start", "motif.end", "motif.strand",                            
                            "fimo.score","fimo.pvalue", "empty", "motif.sequence")
    Rprof(tmp1 <- tempfile())

    tbl.fimo$loc <- sprintf("%s:%d-%d", tbl.fimo$chrom, tbl.fimo$motif.start, tbl.fimo$motif.end)
    Rprof()
    summ.loc <- summaryRprof(tmp1)


    # Do the rest

    Rprof(tmp2 <- tempfile())
    
    sampleID <- "Test_sample"
    method <- "Test_method"

    min.pos <- min(tbl.fp$start)    
    max.pos <- max(tbl.fp$end)                    
            
    tbl.fimo <- tbl.fimo[, -grep("empty", colnames(tbl.fimo))]    
    tbl.fimo$chrom <- paste("chr", tbl.fimo$chrom, sep="")    
    
    # Converts the FIMO data into a GenomicRanges object, making the intersection with footprints fast    
    gr.fimo <- GRanges(seqnames=tbl.fimo$chrom, IRanges(start=tbl.fimo$motif.start, end=tbl.fimo$motif.end))
          
    # --- get some footprints    
    # Converts the footprints into GenomicRanges objects    
    gr.wellington <- GRanges(seqnames=tbl.fp$chrom, IRanges(start=tbl.fp$start, end=tbl.fp$end))
            
    # the "within" is conservative. I will run this with "any" to increase    
    #the number of motif interesects    

    tbl.overlaps <- findOverlaps(gr.fimo, gr.wellington, type="any")        
    tbl.overlaps <- as.data.frame(tbl.overlaps)

    tbl.fimo$method <- method    
    tbl.fimo$sample_id <- sampleID    
            
    tbl.regions <- tbl.fimo[tbl.overlaps$queryHits,]
    
    tbl.regions <- cbind(tbl.regions,                         
                         wellington.score=tbl.fp[tbl.overlaps$subjectHits, "score"],                         
                         fp.start=tbl.fp[tbl.overlaps$subjectHits, "start"],
                         fp.end=tbl.fp[tbl.overlaps$subjectHits, "end"])    

    # Finish the profiler and print the summary
    Rprof()
    test.sum <- summaryRprof(tmp2)

    return(list(test.sum, tbl.regions, summ.loc))
}
#----------------------------------------------------------------------------------------------------
