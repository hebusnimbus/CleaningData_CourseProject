# ===============================================================================
# CONFIGURATION
# ===============================================================================

# ----------  Source utils script  ----------

script.dir <- dirname(sys.frame(1)$ofile)

source(file.path(script.dir, 'utils.R'))


# ----------  Libraries  ----------

install_package("dplyr");    library(dplyr)
install_package("reshape2"); library(reshape2)


# ----------  Constants & variables  ----------

data.url <- 'https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip'

dir.data <- create_dir(file.path(script.dir, 'data'))
dir.work <- file.path(dir.data, 'UCI HAR Dataset')

file.zip <- download_file(data.url, dir.data)


file.activities     <- file.path(dir.work, 'activity_labels.txt')
file.features       <- file.path(dir.work, 'features.txt')

file.test.subjects  <- file.path(dir.work, 'test',  'subject_test.txt')
file.test.measures  <- file.path(dir.work, 'test',  'X_test.txt')
file.test.labels    <- file.path(dir.work, 'test',  'y_test.txt')

file.train.subjects <- file.path(dir.work, 'train', 'subject_train.txt')
file.train.measures <- file.path(dir.work, 'train', 'X_train.txt')
file.train.labels   <- file.path(dir.work, 'train', 'y_train.txt')

file.output.txt     <- file.path(script.dir, 'tidy_data.txt')


# ===============================================================================
# MAIN
# ===============================================================================

# ----------  Extract data  ----------

if (
    (! file.exists(dir.work))            ||
    (! file.exists(file.activities))     ||
    (! file.exists(file.features))       ||
    (! file.exists(file.train.subjects)) ||
    (! file.exists(file.train.measures)) ||
    (! file.exists(file.train.labels))   ||
    (! file.exists(file.test.subjects))  ||
    (! file.exists(file.test.measures))  ||
    (! file.exists(file.test.labels))
) {
    unzip_all(file.zip, dir.data)
}


# ----------  Load data  ----------

activities     <- read.csv(file.activities, sep=' ', header=FALSE)
features       <- read.csv(file.features,   sep=' ', header=FALSE)

features.width <- rep.int(c(-1, 15), dim(features)[1]) # each measure is 15 bytes long, separated by a space

subjects.test  <- read.fwf(file.test.subjects,  c(2))
subjects.train <- read.fwf(file.train.subjects, c(2))
measures.test  <- read.fwf(file.test.measures,  features.width)
measures.train <- read.fwf(file.train.measures, features.width)
labels.test    <- read.fwf(file.test.labels,    c(1))
labels.train   <- read.fwf(file.train.labels,   c(1))

printf("\n")

printf("# activities: %d\n", dim(activities)[1])
printf("# features  : %d\n", dim(features)[1])

printf("\n")

printf("# test  subjects: %d\n", dim(subjects.test)[1])
printf("# test  measures: %d\n", dim(measures.test)[1])
printf("# test  labels  : %d\n", dim(labels.test)[1])

printf("# train subjects: %d\n", dim(subjects.train)[1])
printf("# train measures: %d\n", dim(measures.train)[1])
printf("# train labels  : %d\n", dim(labels.train)[1])

printf("\n")


# ----------  Merge data  ----------

# Merge test and train datasets
subjects <- rbind(subjects.test, subjects.train)
measures <- rbind(measures.test, measures.train)
labels   <- rbind(labels.test,   labels.train)

# Free some memory
rm(
    subjects.test,
    subjects.train,
    measures.test,
    measures.train,
    labels.test,
    labels.train
)

# Set column names
names(activities) <- c('ID', 'Name')
names(features)   <- c('ID', 'Name')

names(subjects) <- c('ID')
names(measures) <- features$Name
names(labels)   <- c('ID')

# Summary
printf("# subjects: %d\n", dim(subjects)[1])
printf("# measures: %d\n", dim(measures)[1])
printf("# labels  : %d\n", dim(labels)[1])
printf("\n")


# ----------  Subset data  ----------

# Keep only columns which contain either of the strings "-mean()" or "-std()"
columnNames <- as.character(features[with(features, grepl("-mean\\(\\)|-std\\(\\)", Name)),]$Name)

printf("# columns to extract : %d\n", length(columnNames))
printf("\n")

# Subset the data based on the mean/std columns
data <- measures[columnNames]


# ----------  Add columns Activity & Subject  ----------

# This does not preserve the order !!!
# data$Activity <- arrange(merge(labels, activities, by.x="ID", by.y="ID", all=FALSE)$Name, ID)

data$Activity <- inner_join(labels, activities, c("ID" = "ID"))$Name
data$Subject  <- subjects$ID


# ----------  Make meaningful variable names  ----------

names <- names(data)
names <- gsub("Acc",                 "Acceleration",        names) # Full name for Acceleration
names <- gsub("Gyro",                "Gyroscope",           names) # Full name for Gyroscope
names <- gsub("Mag",                 "Magnitude",           names) # Full name for Magnitude
names <- gsub("-mean\\(\\)",         ".Mean",               names) # Remove "punctuation" characters like '-', '(' or ')'
names <- gsub("-std\\(\\)",          ".StandardDeviation",  names) # Full name for StandardDeviation + remove "punctuation" characters like '-', '(' or ')'
names <- gsub("-X",                  ".X",                  names) # Remove "punctuation" characters like '-'
names <- gsub("-Y",                  ".Y",                  names) # Remove "punctuation" characters like '-'
names <- gsub("-Z",                  ".Z",                  names) # Remove "punctuation" characters like '-'
names <- gsub("Mean.X",              "X.Mean",              names) # Reverse order of function and axis
names <- gsub("Mean.Y",              "Y.Mean",              names) # Reverse order of function and axis
names <- gsub("Mean.Z",              "Z.Mean",              names) # Reverse order of function and axis
names <- gsub("StandardDeviation.X", "X.StandardDeviation", names) # Reverse order of function and axis
names <- gsub("StandardDeviation.Y", "Y.StandardDeviation", names) # Reverse order of function and axis
names <- gsub("StandardDeviation.Z", "Z.StandardDeviation", names) # Reverse order of function and axis
names <- gsub("^t",                  "",                    names) # Remove prefix 't' (time signal)
names <- gsub("^f(.*)",              "\\1.FFT",             names) # Replace prefix 'f' (frequency signal) by suffix FFT (Fast Fourier Transform)
names <- gsub("BodyBody",            "Body",                names) # Fix spelling errors (duplicated Body)

names(data) <- names


# ----------  Create tidy data  ----------

data.long <- melt(data, id.vars=c("Activity", "Subject"))
data.tidy <- dcast(data.long, Activity + Subject ~ variable, mean)

printf("# 'long' observations : %d\n", dim(data.long)[1])
printf("# 'long' columns      : %d\n", dim(data.long)[2])
printf("\n")

printf("# 'tidy' observations : %d\n", dim(data.tidy)[1])
printf("# 'tidy' columns      : %d\n", dim(data.tidy)[2])
printf("\n")


# ----------  Output tidy data  ----------

write.table(x = data.tidy, file = file.output.txt, row.names = FALSE)


# ===============================================================================
