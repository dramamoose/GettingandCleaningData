## Create one R script called run_analysis.R that does the following:
## 1. Merges the training and the test sets to create one data set.
## 2. Extracts only the measurements on the mean and standard deviation for each measurement.
## 3. Uses descriptive activity names to name the activities in the data set
## 4. Appropriately labels the data set with descriptive activity names.
## 5. Creates a second, independent tidy data set with the average of each variable for each activity and each subject.

#Load the libaries we need to work with our data
library("data.table")
library("reshape2")
        
#Load our list of activities 
activities <- read.table("./UCI HAR Dataset/activity_labels.txt")[,2]

#Grab our list of features
raw_features <- read.table("./UCI HAR Dataset/features.txt")[,2]

#Load into memory the sets we are combining
X_test <- read.table("./UCI HAR Dataset/test/X_test.txt")
names(X_test) = raw_features
y_test <- read.table("./UCI HAR Dataset/test/y_test.txt")
subject_test <- read.table("./UCI HAR Dataset/test/subject_test.txt")

X_train <- read.table("./UCI HAR Dataset/train/X_train.txt")
y_train <- read.table("./UCI HAR Dataset/train/y_train.txt")
subject_train <- read.table("./UCI HAR Dataset/train/subject_train.txt")
names(X_train) = raw_features

#Grab the important statistical data from the features, use this to get the right data sets
features <- grepl("mean|std", raw_features)
X_test = X_test[,features]
X_train = X_train[,features]

#Get our activity labels for both sets
y_test[,2] = activities[y_test[,1]]
names(y_test) = c("Activity_ID", "Activity_Label")
names(subject_test) = "subject"

y_train[,2] = activities[y_train[,1]]
names(y_train) = c("Activity_ID", "Activity_Label")
names(subject_train) = "subject"

#Two lines to bind them all
test_data <- cbind(as.data.table(subject_test), y_test, X_test)
train_data <- cbind(as.data.table(subject_train), y_train, X_train)

#And in the darkness, merge them

final = rbind(test_data, train_data)

id_labels   = c("subject", "Activity_ID", "Activity_Label")
final_labels = setdiff(colnames(data), id_labels)
melt_data      = melt(final, id = id_labels, measure.vars = final_labels)

final_data = dcast(melt_data, subject + Activity_Label ~ variable, mean)

write.table(final_data, file = "./final_data.txt", row.name=FALSE)

