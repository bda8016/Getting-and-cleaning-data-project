# Getting-and-cleaning-data-project

#Below I import the .txt files associated with the training data into R using read.table:
  train_subjectIDs <- read.table("subject_train.txt", header=FALSE, sep="")

  train_activityIDs <- read.table("y_train.txt", header=FALSE, sep="", stringsAsFactors=FALSE)

  train_data <- read.table("X_train.txt", header=FALSE, sep="", stringsAsFactors=FALSE)


#Below I import the .txt files associated with the test data into R using read.table:
  test_subjectIDs <- read.table("subject_test.txt", header=FALSE, sep="")
  
  test_activityIDs <- read.table("y_test.txt", header=FALSE, sep="")
  
  test_data <- read.table("X_test.txt", header=FALSE, sep="", stringsAsFactors=FALSE)
  
  
#Below I import the .txt files containing features and activity labels into R using read.table:
  features <- read.table("features.txt", header=FALSE, sep="", stringsAsFactors=FALSE)
  
  activity_labels <- read.table("activity_labels.txt", header=FALSE, sep="", stringsAsFactors=TRUE)
  
  
#Below I use colnames() to assign the second column in 'features' as column headers in the 'train_data' and 'test_data' data frames.  #This gives descriptive variable names for the measurements in the 'training' and 'test' data frames:
  colnames(train_data) <- features[ ,2]
  
  colnames(test_data) <- features[ ,2]
    
  
#Below I again use colnames() to assign consistent and descriptive column headers to train_subjectIDs, test_subjectIDs, #train_activityIDs, and test_activityIDs:
  colnames(train_subjectIDs) <- "volunteerid"
    colnames(test_subjectIDs) <-  "volunteerid"

  colnames(train_activityIDs) <-  "activityid"
    colnames(test_activityIDs) <- "activityid"
  
 
#Below I assign descriptive column headers to the activity_labels file.  I name column 1 'activityid' to match the corresponding #column name in train_activityIDs and test_activityIDs for merging:
  library(dplyr)
    activity_labels <- rename(activity_labels, activityid=V1, activity=V2)
      activity_labels$activity <- as.character(activity_labels$activity)
 

#Below I use left_join() from dplyr to combine activity_labels with test_activityIDs and train_activityIDs so that each resultant #activity file contains a descriptive 'activity' column:
  library(dplyr)
    train_activitiesdf <- train_activityIDs %>% left_join(activity_labels)
      test_activitiesdf <- test_activityIDs %>% left_join(activity_labels)

 
#Below I use cbind() to create 1 training file that combines subject IDs, activity descriptions and the data:
  training <- cbind(train_subjectIDs, train_activitiesdf, train_data)
  
  
#Below I use cbind() to create 1 test file that combines subject IDs, activity descriptions and the data:
  test <- cbind(test_subjectIDs, test_activitiesdf, test_data)
  
  
#Below I use rbind() to combine the 'training' and 'test' files:
  train_test <- rbind(training, test)
  

#Below I use duplicated() to get rid of duplicate columns.  They aren't needed for the analysis, and they cause problems with dplyr #functions used later:
  train_test_noDups <- train_test[ ,!duplicated(colnames(train_test))]
    
  
#Below I subset only the columns I need and then combine them into one data frame called train_test_clean.
#I include both mean() and meanFreq() variables, as they both may include useful or desired data:
  train_test_vol <- select(train_test_noDups, contains("volunteer"))
    train_test_act <- select(train_test_noDups, contains("activity"))
      train_test_act <- select(train_test_act,-contains("activityid"))
  
  train_test_mean <- select(train_test_noDups, contains("mean"))
    train_test_mean <- select(train_test_mean, -contains("angle"))
      train_test_stdev <- select(train_test_noDups, contains("std"))
        
  train_test_clean <- cbind(train_test_vol, train_test_act, train_test_mean, train_test_stdev)
 
  
#Below I convert 'train_test_clean' to a 'tbl_df' so it prints nicely:
    train_test_clean <- tbl_df(train_test_clean)
    
 
#Below I use group_by() and summarise_each() to create a new data frame that calculates the average of each mean() and std() variable #by volunteerid and by activity:
  library(dplyr)
    train_test_summary <- train_test_clean %>% group_by(volunteerid, activity) %>% summarise_each(funs(mean(.,na.rm=TRUE)))
    
#Below I use write.table() to create a .txt file containing the output from train_test_summary.  The .txt file is stored in my
#working directory:
  write.table(train_test_summary, file = "train_test_summary.txt", sep = "", row.names=FALSE)
