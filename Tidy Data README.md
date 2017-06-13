---
title: "Tidy Data ReadMe"
author: "Greg Small"
date: "June 12, 2017"
output: html_document
---

Focus of the assignment is to transform data from the Human Activity Recognition Using Smartphones project text files into a tidy dataset ready for analysis, via 5 particular steps defined in the assignment. 

This readme also explains the script file: run_analysis.R

## This readme has the following sections:
1. Source Materials
2. Tidy Data
3. Steps in the assignment
+ Merge Datasets
+ Extract Data
+ Activity Names
+ Variable Names
+ Create Tidy Dataset



## Section 1: Source Materials
Source Materials provided:  
General  
* 'README.txt': readme provided by the project about their data  
* 'features_info.txt': Descriptive, not data. Shows information about the variables used on the feature vector.  
* 'features.txt': the column titles are in features.txt with 561 labels for the columns  
* 'activity_labels.txt': lists the 6 labels for the activity types corresponding to numbers 1-6  

Training Data  
* 'train/X_train.txt': Training data set. Main data with 7352 observations of 561 variables, all numeric  
* 'train/y_train.txt': list of activities 1-6 performed in 7352 observations of 1 variable  
* 'train/subject_train.txt': numbers 1-30 represnting the 30 unique particpatnts with 7352 obs of 1 variable  

Test Data  
* 'test/X_test.txt': Test set. Main data with 2947 observations of 561 variables, all numeric  
* 'test/y_test.txt': list of activities 1-6 performed in 2947 observations of 1 variable  
* 'test/subject_test.txt': numbers 1-30 represnting the 30 unique participants with 2947 obs of 1 variable  

Unused (not relevant to this analysis):  
* 'train/Inertial Signals' : multiple files containing the original signal data  
* 'test/Inertial signals' : multiple files containing the original signal data  



## Section 2: Is the data produced by this script tidy?
From Hadley Wickham's Tidy Data paper (Wickham, 2014):  
In tidy data:  
1. Each variable forms a column.  
2. Each observation forms a row.  
3. Each type of observational unit forms a table.  

Does these core principles hold up for the dataset produced in this exercise?

**1) Each variable forms a column**
Each column contains a distinct measurement, with no overlap, duplication or introduction of NA columns into the representation. Each column stands alone as a particular type of variable observed over each combination of participant and activity (30 participats X 6 activities give 180 summary observations). 

This principle is upheld. 

**2) Each observation forms a row.**
This takes a little more effort to work out. With 79 variables in this wide format it seems logical that perhaps there are natural groups that should be further decomposed to make observations more atomic. However, examination of the logical possibilities indicates that further decomoposition will primarily serve to make the data logically more complex, make analysis more difficult, or introduce NA values. 

For example, many measurements could be grouped as X,Y,Z axis measurements of the same type. For example, "tBodyAcc" could be extracted from the name,  and the related mean()X, mean()Y and mean()Z plus std()X, std()Y and std()Z gropuped as variables of the "tBodyAcc"" observation for each participant/activity combination. 

The logical result of this would be 30 participants X 6 activities X (roughly) 15 new measurement groupings, resulting in a long dataset instead of a wide one. However, examination of the column names candidates indicate problems: not all of the variables have x,y,z components, so we need to add new columns for plain means and standard deviations, resulting in a lot of NA elements in the data. 

Conceptually also, this does not add logical clarity. For example to analyze the data in current form, it is trival to pull every "participant 1"/"walking" observation. So, if the analytical question, for example, is how the mean for "tBodyAcc_mean()X" differs from one activity to the next, or from one participant to the next, the answer requires relatively little manipulation to produce. On the other hand if we further logically decomposed the data, we would need to pull the rows for each participant, for the activity "walking", for the measurement "tBodyAcc", in the column mean of X. Complexity would be added without providing additional clarity, simplicity or insight. 

This principle is also upheld.

**3) Each type of observation forms a table**
There is no data unnecessary to the observations in the table that is candidate for removal. For example, there is no user identity data that needs to be pulled out. There are no attribute data for the tests that should be pulled out. Any data that would be removed or abstracted would result in a less meaningful data set. 

This principle is upheld.

To make sure the data is as tidy as we think, we should at least give brief consideration to the principles that define "messy" data to insure no hidden problems lurk. 

The five most common symptoms of messy data, also from Hadley Wickham's Tidy Data paper (Wickham, 2014):  
* Column headers are values, not variable names.   
* Multiple variables are stored in one column.   
* Variables are stored in both rows and columns.   
* Multiple types of observational units are stored in the same table.   
* A single observational unit is stored in multiple tables.  

**1) Column headers are values, not variable names.**  
Each colunm in our data set is a clearly defined measurement type, not a value of some measurement. 

**2) Multiple variables are stored in one column.**  
Column values are single measurements and may not be further decomposed. 

**3) Variables are stored in both rows and columns.**   
Rows are clearly articulated as participants X activities, and would not cast well as variables (would need to construct compound people-activity columns). Likewise the columns are clear measurement categories that correspond well to the people and activities in the rows. 

**4) Multiple types of observational units are stored in the same table.**  
No extraneous data that does not relate directly to the observation is included in this data. There is no extra user data, data about the analytics, or data relating to the activities that should be abstracted out. 

**5) A single observational unit is stored in multiple tables.**  
Does not apply, only one table is produced in this assignment. 

Conclusion is that this data is, in fact, tidy. 


## Section 3: Steps in the script

### - Merge Datasets
Instructions: Merges the training and the test sets to create one data set.

The data provided consists of one initial data set that has been broken into 2 sets to facilitate system training, and then system testing. The training data has about 2/3 of the initial data with 7352 observations. The test data has the remaining 1/3 with 2947 observations. For this exercise we are putting the test and training data sets back together into a single large dataset with 10299 observations. 

Process requires merging 3 sets of data each for both the training and test set. This was done in the following order:  

1) Merge all three training data sets based on the row_index we created to insure no sorting/ordering issues creep into the merge process.  

2) Repeat the process above for the test data set.  

3) Create a master merge of the training and test data sets using rbind to add the rows of test to the bottom of the training dataset, and produce df "master".  

4) Str(master) validates that process yields 10299 observations of 564 variables (561 variables, our row index, participants and activities).  

5) Clean up data that we will not need further. We can remove all the imported data that has now been successfully merged into our master df. 




### - Extract Data
Instructions: Extracts only the measurements on the mean and standard deviation for each measurement.

The master dataset created above has 561 measurement Variables (plus index, participants and activities). Out of these variable, for this assignment, we are only interested in variables that have "mean" or "std" (in other words, mean calculations or standard deviation calculations) in the description. 

Theoretically, we could go ahead and label the columns, and then do a select on the columns we want directly. However, the column names caused significant issues in further processing, and we decided to defer column naming until we had shaped the final dataset (and, practically speaking, it is called for below in step 4).

In order to identify the columns we needed, we used the dataset we created called "features" and pulled from it the INDEX of every column that had "mean" or "std" in it. 

Because our merged df master has additional columns in the front which are not listed in df features (participant and activity), we need to add 2 to each index value in order to pull the correct columns from df master.

Apply the index created from df features to df master, and pull the columns into new df master.

While we are creating indexes, we will also in this step create a list of the names of all of these columns that we will use in step 4 to name the variables. To be clear, the first index was truly a list of index numbers to identify columns to pull. The second was an index of names to apply to these columns later. 


### - Activity Names
Instructions: Uses descriptive activity names to name the activities in the data set

The documentation provides the following values for the activities represented in the data currently only as the numbers 1-6 in the column for activities (still known as Index3) at this point. 
1 WALKING
2 WALKING_UPSTAIRS
3 WALKING_DOWNSTAIRS
4 SITTING
5 STANDING
6 LAYING

This step requires two steps for df master: 

1) The column is currently numeric and we're going to be swapping in text, so convert the column to char.  

2) for each value replace the existing number with its friendlier label.


### - Variable Names
Instructions: Appropriately labels the data set with descriptive variable names.

There are 79 unique variables which had "mean" or "std" in their name. We have created in a step above a list of the names of each of these 79 columns which is ready to be used called col_name_list. We will, at the same time, label the participant and activity variables as well. 

1) Name the columns using setnames with our labels plus the col_name_list as inputs.

2) Since all of our observations will be summary data of the original observations, we need to add "mean_of_" to the front of each column name except participants and activities. (We haven't done the summarizing yet, but we will in the next step)  

3) To validate, View(master) to confirm that all the columns are correctly labelled.

4) Also can str(master) to validate that we have 10299 observations of 81 variables (our 79 column names plus participants and activities).



### - Create Tidy Dataset
Instructions: From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.

At this point, with 10299 observations, we have multiple observations for each combination of participant (1-30) and activity (1-6). Our goal is to reduce this to 180 observations (30 X 6) so that we have one mean calculation for each unique participant-activity. 

Use the following steps:  
1) Use group_by to create 180 separate groups within the data, grouping by both Particpant and Activity.

2) Summarize each group using summarize_each to calculate the mean for each group and collapse the group to a single observation per group. 

3) str(master_summary) shows 180 observations (1 for each 30 participants X 6 activities) and 81 variables (79 columns of data plus participant and activity)  

4) Use write.table to output the data into tidy_data_assign.txt. 

At this point the assignment is complete. To access the data from your working directory and view the file:


tidy_data <- fread(file.path("tidy_data_assign.txt"), na.strings="NA" )  
View(tidy_data)

Citations:  
_______________
WICKHAM, Hadley . Tidy Data. Journal of Statistical Software, [S.l.], v. 59, Issue 10, p. 1 - 23, sep. 2014. ISSN 1548-7660. Available at: <https://www.jstatsoft.org/v059/i10>. Date accessed: 13 june 2017. doi:http://dx.doi.org/10.18637/jss.v059.i10.

