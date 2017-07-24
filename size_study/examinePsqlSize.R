#----------------------------------------------------------------------------------------------------
# Function to create random data of 10 columns and X rows
createFakeData <- function(X){

    # Create a bunch of different data structures
    rand.score <- 10*rnorm(X)
    rand.ints <- rpois(X, lambda = 20)
    rand.chrom <- paste0("chr", sample(1:22,X,replace=TRUE))
    rand.start <- 1:X
    rand.end <- 2:(X+1)
    rand.loc <- paste0(rand.chrom,":",rand.start,"-",rand.end)

    fake.data <- data.frame(loc = rand.loc,
                            chrom = rand.chrom,
                            start = rand.start,
                            endpos = rand.end,
                            score1 = rand.score,
                            score2 = rand.ints)
    fake.data
}
# createFakeData
#----------------------------------------------------------------------------------------------------
# Function to create the data I want and save to tsv files
writeFakeData <- function(){

    # Create 5 different data frames    
    data.1000 <- createFakeData(1000)
    data.10000 <- createFakeData(10000)
    data.100000 <- createFakeData(100000)
    data.1000000 <- createFakeData(1e6)
    data.10000000 <- createFakeData(1e7)

    # Write the 5 data frames to tsv files
    write.table(data.1000, file = "./data_1000", sep = "\t", col.names = FALSE, row.names = FALSE)
    write.table(data.10000, file = "./data_10000", sep = "\t", col.names = FALSE, row.names = FALSE)
    write.table(data.100000, file = "./data_100000", sep = "\t", col.names = FALSE, row.names = FALSE)
    write.table(data.1000000, file = "./data_1000000", sep = "\t", col.names = FALSE, row.names = FALSE)
    write.table(data.10000000, file = "./data_10000000", sep = "\t", col.names = FALSE, row.names = FALSE)    
}
#----------------------------------------------------------------------------------------------------

    


# Function to
buildGeneralDBs <- function(){

    # Create 5 different data frames
    data.1000 <- createFakeData(1000)
    data.10000 <- createFakeData(10000)
    data.100000 <- createFakeData(100000)
    data.1000000 <- createFakeData(1e6)
    data.10000000 <- createFakeData(1e7)

    # Create the general schema string
    schema.string <- paste("create table regions(loc varchar primary key,",
                           "chrom varchar,",
                           "start int,",
                           "endpos int,",
                           "score1 real,",
                           "score2 int);")


    # Open up a Postgres connection
    db <- dbConnect(PostgreSQL(),
                    user = "trena",
                    password = "trena",
                    host = "localhost",
                    dbname = "postgres")

    # Create the databases and disconnect
    dbSendQuery(db, "create database general_1000;")
    dbSendQuery(db, "create database general_10000;")
    dbSendQuery(db, "create database general_100000;")
    dbSendQuery(db, "create database general_1000000;")
    dbSendQuery(db, "create database general_10000000;")
    dbDisconnect(db)

    # Fill each database and create an index for each as well
    db <- dbConnect(PostgreSQL(),
                    user = "trena",
                    password = "trena",
                    host = "localhost",
                    dbname = "general_1000")
    dbSendQuery(db, schema.string)
    dbWriteTable(db, "regions", data.1000, row.names = FALSE)
                
    
}# buildGeneralDBs

    
