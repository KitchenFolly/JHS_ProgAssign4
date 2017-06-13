
#libraries needed to complete this:
library(data.table)
library(dplyr)
library(readr)

# Step 1: Merge the training and the test sets to create one data set.

# Instructions: unzip the UCI HAR Dataset into your working directory
# DO NOT pull the files out of the folders they unzip into 
# (or, if you do, remove the "train" and "test" file folder designations below)

# read in training files and create a row index in each for merging
subject_train <- fread(file.path("train", "subject_train.txt"), na.strings="NA" )
subject_train$row_index <- as.numeric(rownames(subject_train))

X_train <- fread(file.path("train", "X_train.txt"), na.strings="NA" )
X_train$row_index <- as.numeric(rownames(X_train))

y_train <- fread(file.path("train", "y_train.txt"), na.strings="NA" )
y_train$row_index <- as.numeric(rownames(y_train))

# read in test files and create a row index in each for merging
subject_test <- fread(file.path("test", "subject_test.txt"), na.strings="NA" )
subject_test$row_index <- as.numeric(rownames(subject_test))

X_test <- fread(file.path("test", "X_test.txt"), na.strings="NA" )
X_test$row_index <- as.numeric(rownames(X_test))

y_test <- fread(file.path("test", "y_test.txt"), na.strings="NA" )
y_test$row_index <- as.numeric(rownames(y_test))

# create a features df we can use later for column names
features <- fread(file.path("features.txt"), na.strings="NA" )

# merge the 3 training data files into one
train_merge <- merge(merge(subject_train, y_train, by = "row_index", all = TRUE), X_train, by = "row_index", all = TRUE)

# merge the 3 test data files into one
test_merge <- merge(merge(subject_test, y_test, by = "row_index", all = TRUE),X_test, by = "row_index", all = TRUE)

# merge test and train df into one df
# master should yield 2947 + 7352 = 10299 observations of 564 variables 
#(561 cols, our row index, participants and activities)
master <- rbind(train_merge, test_merge)
master$row_index <- NULL # remove the indexing col as we're done with it

#clean up the data elements we're done with
rm(subject_train, X_train, y_train, subject_test, X_test, y_test, test_merge, train_merge)


# Step 2: extract only the measurements on the mean and standard deviation for each measurement.

# create an index that identifies every column with "mean" or "std" anywhere in the name
create_index <- lapply(features, grep, pattern = "mean|std")
create_index <- create_index$V2 + 2 # add 2 to each index to account for cols V1 and V2

# build a column name index to use in step 4 
col_name_list <- lapply(features, grep, pattern = "mean|std", value = TRUE)
rm(features) #clean up features

# using the index created above, pull the columns with "mean" and "std" into df master
master <- select(master, index = c(1:2, create_index))
rm(create_index) # clean up create_index

# Step 3: Rename the activities using descriptive activity names 
# 1 WALKING, 2 WALKING_UPSTAIRS, 3 WALKING_DOWNSTAIRS, 4 SITTING, 5 STANDING, 6 LAYING

# change column from numeric to character to make substitution possible
# make the substitutions
master$index2[master$index2 == "6"] <- "laying"
master$index2[master$index2 == "5"] <- "standing"
master$index2[master$index2 == "4"] <- "sitting"
master$index2[master$index2 == "3"] <- "walking_downstairs"
master$index2[master$index2 == "2"] <- "walking_upstairs"
master$index2[master$index2 == "1"] <- "walking"


# Step 4: appropriately label the data set with descriptive variable names.

# apply all the column labels from the column name list we created earlier
master <- setnames(master, c("Participant", "Activity", col_name_list$V2))
rm(col_name_list) # clean up col_name_list
# add "mean of" to every column name from 3 to 81 to reflect that this is summary data
colnames(master)[3:81] <- paste("mean_of", colnames(master)[3:81], sep = "_")


# Step 5: From the data set in step 4, create a second, independent tidy data set with the average 
# of each variable for each activity and each subject.
master <- master %>%
        group_by(Participant, Activity) %>%
        summarize_each(funs(mean(., na.rm=TRUE))) 


# write out the file to your working directory
write.table(master, "tidy_data_assign.txt", row.names = FALSE)

# finally, test the import of the file
# change the file path to the directory where the file is located 
tidy_data <- fread(file.path("tidy_data_assign.txt"), na.strings="NA" )

View(tidy_data)


