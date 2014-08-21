## Get the data zipfile from 
# https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip
# Downloaded and unzip to a folder in the working directory
# The directory was renamed to UCI_HAR_Dataset for convenience

## Merge the training and the test sets to create one data set.
path <- 'UCI_HAR_Dataset'
if (!file.exists(path)) 
    stop("Error: The dataset folder, UCI_HAR_Dataset, does not exist in the working directory!")

fx <- paste(path, 'test/X_test.txt', sep='/')
fy <- paste(path, 'test/y_test.txt', sep='/')
fs <- paste(path, 'test/subject_test.txt', sep='/')
if (!file.exists(fx) || !file.exists(fy) || !file.exists(fs) ) 
    stop("Error: One or more of the input data files is missing for the test dataset!")

xtest <- read.table(fx)
ytest <- read.table(fy)
stest <- read.table(fs)

fx <- paste(path, 'train/X_train.txt', sep='/')
fy <- paste(path, 'train/y_train.txt', sep='/')
fs <- paste(path, 'train/subject_train.txt', sep='/')
if (!file.exists(fx) || !file.exists(fy) || !file.exists(fs) ) 
    stop("Error: One or more of the input data files is missing for the training dataset!")

xtrain <- read.table(fx)
ytrain <- read.table(fy)
strain <- read.table(fs)

y <- rbind(ytrain, ytest)
x <- rbind(xtrain, xtest)
s <- rbind(strain, stest)

## Appropriately labels the data set with descriptive variable names. 
colnames(y)[colnames(y)=="V1"] <- 'Activity'
colnames(s)[colnames(s)=="V1"] <- 'Subject'

ff <- paste(path, 'features.txt', sep='/')
if (!file.exists(ff)) 
    stop("Error: The features label file is missing!")

xlabels <- read.table(ff)

# Clean up some of the labels to make them easier to work with
xlabels$V2 <- gsub("\\(", "", xlabels$V2)
xlabels$V2 <- gsub("\\)", "", xlabels$V2)
xlabels$V2 <- gsub(",", "_", xlabels$V2)
xlabels$V2 <- gsub("-", "_", xlabels$V2)
xlabels$V2 <- gsub("meanFreq", "MeanFreq", xlabels$V2)
xlabels$V2 <- gsub("mean_X", "X_mean", xlabels$V2)
xlabels$V2 <- gsub("mean_Y", "Y_mean", xlabels$V2)
xlabels$V2 <- gsub("mean_Z", "Z_mean", xlabels$V2)
xlabels$V2 <- gsub("std_X", "X_std", xlabels$V2)
xlabels$V2 <- gsub("std_Y", "Y_std", xlabels$V2)
xlabels$V2 <- gsub("std_Z", "Z_std", xlabels$V2)

colnames(x) <- xlabels$V2

## Use descriptive activity names to name the activities in the data set
act <- c('WALKING','WALKING_UPSTAIRS','WALKING_DOWNSTAIRS', 'SITTING', 'STANDING', 'LAYING')
y$Activity <- factor(y$Activity, levels=1:6, labels=act)

## Add the Activity and Subject columns to x
x$Activity <- y$Activity
x$Subject <- s$Subject

## Extract only the measurements on the mean and standard deviation 
## for each measurement.

# Get all the mean and std labels to use in the extract
mlabels<-xlabels[grep('mean', xlabels$V2), ]
slabels<-xlabels[grep('std', xlabels$V2), ]
cols <- rbind(mlabels, slabels)
cols$V2 <- sort(as.character(cols$V2))

# Create the data extract with the selected columns
dataExtract <- x[,c(cols$V2, 'Activity', 'Subject')]

## Create a second, independent tidy data set with the average of each 
## variable for each activity and each subject. 
library(reshape2)
tmp <- melt(dataExtract, id=c("Subject","Activity"), measure.vars=cols$V2)
tmp <- with(tmp, tapply(value, list(Activity, Subject, variable), mean))
dataSummary <- as.data.frame.table(tmp, responseName = "value") 
colnames(dataSummary) <- c('Activity', 'Subject', 'Feature', 'Mean')
dataSummary$Subject <- as.numeric(as.character(dataSummary$Subject))

## Save the two datasets to files
write.table(dataExtract, file='UCI_HAR_DataExtract.txt', row.name=FALSE)
write.table(dataSummary, file='UCI_HAR_DataSummary.txt', row.name=FALSE)