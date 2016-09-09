
#Import the .txt files associated with the training data into R using read.table:
  train_subjectIDs <- read.table("subject_train.txt", header=FALSE, sep="")

  train_activityIDs <- read.table("y_train.txt", header=FALSE, sep="", stringsAsFactors=FALSE)

  train_data <- read.table("X_train.txt", header=FALSE, sep="", stringsAsFactors=FALSE)


#Import the .txt files associated with the test data into R using read.table:
  test_subjectIDs <- read.table("subject_test.txt", header=FALSE, sep="")
  
  test_activityIDs <- read.table("y_test.txt", header=FALSE, sep="")
  
  test_data <- read.table("X_test.txt", header=FALSE, sep="", stringsAsFactors=FALSE)
  
  
#Import the .txt files containing features and activity labels into R using read.table:
  features <- read.table("features.txt", header=FALSE, sep="", stringsAsFactors=FALSE)
  
  activity_labels <- read.table("activity_labels.txt", header=FALSE, sep="", stringsAsFactors=TRUE)
  
  
#Assign the second column in 'features' containing metric descriptions as column headers in the 'train_data' and 'test_data' data frames:
  colnames(train_data) <- features[ ,2]
  
  colnames(test_data) <- features[ ,2]
    
  
#Assign consistent and descriptive column headers to train_subjectIDs, test_subjectIDs, train_activityIDs, and test_activityIDs:
  colnames(train_subjectIDs) <- "volunteerid"
    colnames(test_subjectIDs) <-  "volunteerid"
    
  colnames(train_activityIDs) <-  "activityid"
    colnames(test_activityIDs) <- "activityid"
        
        
#Assign descriptive column headers to the activity_labels file.  Name column 1 'activityid' to match the column name in train_activityIDs and test_activityIDs for merging:
  library(dplyr)
    activity_labels <- rename(activity_labels, activityid=V1, activity=V2)
      activity_labels$activity <- as.character(activity_labels$activity)
 
         
#Combine activity_labels with test_activityIDs and train_activityIDs so that each resultant activity file contains a descriptive 'activity' column.  Use left_join() in dplyr:
  library(dplyr)
    train_activitiesdf <- train_activityIDs %>% left_join(activity_labels)
      test_activitiesdf <- test_activityIDs %>% left_join(activity_labels)

      
#Create 1 training file that combines subject IDs, activity descriptions and the data:
  training <- cbind(train_subjectIDs, train_activitiesdf, train_data)
  
  
#Create 1 test file that combines subject IDs, activity descriptions and the data:
  test <- cbind(test_subjectIDs, test_activitiesdf, test_data)
  
  
#Combine the 'training' and 'test' files:
  train_test <- rbind(training, test)
  

#Get rid of duplicate columns.  They aren't needed for the analysis, and they cause problems with dplyr functions below:
  train_test_noDups <- train_test[ ,!duplicated(colnames(train_test))]
    
  
#Subset only the columns I need then combine the mean and stdev data frames into one data frame.
#I include all columns with any sort of mean in the heading, as they may include useful or desired mean calculations:
  train_test_vol <- select(train_test_noDups, contains("volunteer"))
    train_test_act <- select(train_test_noDups, contains("activity"))
      train_test_act <- select(train_test_act,-contains("activityid"))
  
  train_test_mean <- select(train_test_noDups, contains("mean"))
    train_test_mean <- select(train_test_mean, -contains("angle"))
      train_test_stdev <- select(train_test_noDups, contains("std"))
        
  train_test_clean <- cbind(train_test_vol, train_test_act, train_test_mean, train_test_stdev)
    
      
#Convert 'train_test_clean' to a 'tbl_df' so it prints nicely:
    train_test_clean <- tbl_df(train_test_clean)
    
    
#Create a new data frame that calculates the average of each mean() and std() variable by volunteerid and by activity:
  library(dplyr)
    train_test_summary <- train_test_clean %>% group_by(volunteerid, activity) %>% summarise_each(funs(mean(.,na.rm=TRUE)))
    
#Create a .txt file containing the output from train_test_summary:
  write.table(train_test_summary, file = "train_test_summary.txt", sep = "", row.names=FALSE)
  
    