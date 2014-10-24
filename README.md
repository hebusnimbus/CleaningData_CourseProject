## 1. Goal

The goal of this project is to study data from the accelerometers from the Samsung Galaxy S smartphone, and to generate a more condense, and tidy version of the original (almost raw) data.

<BR/>


## 2. Files

The code for this project is split into two files:

* `utils.R`: a collection of utility functions collected throughout the life of this class
* `run_analysis.R`: main R file containing all the code to fulfill the project's goals

The functions of the utils.R file are as follow:

* `printf`: permits a more refine way of printing to the standard output (similar to C/C++)
* `install_package`: installs a package if it has not already been installed
* `create_dir`: recursively creates a directory if it does not already exist
* `download_file`: downloads a file from the Internet if it does not already exist on the local disk
* `unzip_file`: unzips a file if it has not already been extracted
* `unzip_all`: unzips all file(s) inside an archive file

These are functions typically used when setting up a project, and when downloading data from its original location.  Most of them (*install_package*, *create_dir*, *download_file* and *unzip_file*) are "re-entrant", in the sense that they only perform an operation if it has not already been done, so they can be called over and over again without performance impact (for example, calling *download_file* on the same url and file multiple times will only download it once).

<BR/>


## 3. Analysis

The analysis itself is separated into 5 different steps in the file `run_analysis.R`, as outlined in the instructions:

* __step 0__: download, extract and load data
* __step 1__: merge training and test sets
* __step 2__: extract mean and standard deviation measurements
* __step 3__: set descriptive activity names
* __step 4__: label data set with descriptive variable names
* __step 5__: create tidy data set

In the first section (`CONFIGURATION`), the project is configured and the necessary resources are prepared: additional R files are sourced, third-party libraries are installed and imported, and the data is downloaded.  All the downloaded and generated files are kept inside a folder called __data__ in the same directory where the main script resides.

<BR/>


#### 3.0 Extract and load data

The main section (`MAIN`) assumes that all the different pieces have been setup, and that the original data is available on the local disk as a zip file (downloaded in the previous section).  If any of the files needed to the analysis are missing, they are extracted from the zip file.

The activity names (_WALKING_, ..., _LAYING_) and the feature labels (_tBodyAcc-mean()-X_, ..., _angle(Z,gravityMean)_) are loaded in memory first, followed by the actual training and testing observations (__subjects__, __feature measures__ and __labels__).  These file all have a fixed length format, so it is just a matter of passing the right column widths when calling `read.fwf(...)`.

In the output, we can visually check the consistency of the data and confirm that all sets have the same size (2,947 test observations and 7,352 training observations):
```
# activities: 6
# measures  : 561
#
# test  subjects: 2947
# test  measures: 2947
# test  labels  : 2947
# train subjects: 7352
# train measures: 7352
# train labels  : 7352
```

<BR/>


#### 3.1 Merge training and test sets

For this exercise, the distinction between testing and training observations is not important, so both sets of data frames (__subjects__, __measures__ and __labels__) are merged together.

Again, a quick visual inspection confirms that no data was lost: the total number of observations (10,299) is indeed the sum of the test and training observations (2,947 + 7,352):

```
# subjects: 10299
# measures: 10299
# labels  : 10299

```

Because there are a lots of different measures (561), and quite a few observations (10,299), the whole data takes a lot of space in memory, so intermediary/unnecessary objects at this point are deleted from the global environment (only the merged results are kept).

Finally, meaningful names are assigned to the data.frames (rather than the default V1, ..., V561).  This will make the analysis downstream easier (columns can be referred to by their real name), and avoid potential errors/typos like counting errors (for example: was the mean column on body acceleration V50 or V51?):

* __activity names__, __feature labels__, __subjects__ and __labels__ get assigned arbitrary names (`ID` and `Name`)
* __measures__ get assigned the appropriate names from the feature labels data directly (they are supposed to be in the same order).

<BR/>


#### 3.2 Subset by mean and standard deviation measurements

The project calls for keeping only measurements on the mean and the standard deviation for each measurement.  A call to `grepl(...)` on the names of the features generates a list of the columns with either "-mean()" or "-std()" in their name, which is then used to subset the data down to only these columns.

```
# columns to extract : 66
```

The grep is made against the pattern "-mean()" rather than just "mean" for example, because we want to avoid columns such as "fBodyAcc-meanFreq()-X", which is a weighted average of the frequency components to obtain a mean frequency, and not a mean on a measurement.  Standard deviation columns do not have this problem, but the same pattern is applied to be consistent.

<BR/>


#### 3.3 Set descriptive activity names

For this exercise, an inner join on the two data frames `labels` and `activities` is performed, which generates a vector of activities with the right labels (_WALKING_, etc).  This vector is then added to the main data frame as the `Activity` column.

A similar operation is performed for the `subjects`, except that we do not have the actual names, so a simple vector of identifiers is added to the main data frame as the `Subject` column.

<BR/>


#### 3.4 Set descriptive variable names

This is probably the most controversial section of the project, as everybody will have their own subjective ways of naming variables.

The guidelines from the course suggest the following:

* all lower case when possible
* descriptive (no abbreviation)
* no duplicates
* avoid punctuation characters like underscores, dots or white spaces

Here, the variables end up having very long names in order to be descriptive.  It became hard to read, so we opted for a Camel case approach instead of all lower case (for example, consider _bodybodygyroscopejerkmagnitude_ vs _BodyBodyGyroscopeJerkMagnitude_).

The guidelines also recommend to avoid punctuation characters, but here again we felt that the '.' made it easier to read and recognize variables belonging to the same family of measure (equivalent to a namespace if you will).  For example, consider _bodyaccelerationx_, _bodyaccelerationy_ and _bodyaccelerationz_ versus _BodyAcceleration.X_, _BodyAcceleration.Y_ and _BodyAcceleration.Z_: in the latter example, it becomes more obvious that the three components X, Y and Z belong to the same measure _BodyAcceleration_.

Following the same idea, we have added _.Mean_ or _.StandardDeviation_ at the end of the variable name, to help separate all the different logical groups: __[measure name].[axial component].[feature name]__, for example: _BodyAcceleration.X.Mean_.

And finally, to distinguish between domain signals (time versus frequency), we have adopted the following convention: unless explicitely specified, the domain signal is time, and we use FFT (or Fast Fourier Transform) for frequency signals.  In the end, the final naming convention is as follow: `measure name`[.`axial component`].`feature name`[.`domain signal`], where the second and fourth groups are optional.  With that convention, it becomes more evident when two columns are related to each other (for example _BodyAcceleration.X.Mean_ and _BodyAcceleration.X.Mean.FFT_, where the second one is the first one "augmented" with a FFT).

Here is the list of final column names in the data:

| measure                       | axis | feature           | domain |
|-------------------------------|:----:|-------------------|:------:|
| BodyAcceleration              | X    | Mean              |        |
| BodyAcceleration              | Y    | Mean              |        |
| BodyAcceleration              | Z    | Mean              |        |
| BodyAcceleration              | X    | Mean              | FFT    |
| BodyAcceleration              | Y    | Mean              | FFT    |
| BodyAcceleration              | Z    | Mean              | FFT    |
| BodyAcceleration              | X    | StandardDeviation |        |
| BodyAcceleration              | Y    | StandardDeviation |        |
| BodyAcceleration              | Z    | StandardDeviation |        |
| BodyAcceleration              | X    | StandardDeviation | FFT    |
| BodyAcceleration              | Y    | StandardDeviation | FFT    |
| BodyAcceleration              | Z    | StandardDeviation | FFT    |
| GravityAcceleration           | X    | Mean              |        |
| GravityAcceleration           | Y    | Mean              |        |
| GravityAcceleration           | Z    | Mean              |        |
| GravityAcceleration           | X    | StandardDeviation |        |
| GravityAcceleration           | Y    | StandardDeviation |        |
| GravityAcceleration           | Z    | StandardDeviation |        |
| BodyAccelerationJerk          | X    | Mean              |        |
| BodyAccelerationJerk          | Y    | Mean              |        |
| BodyAccelerationJerk          | Z    | Mean              |        |
| BodyAccelerationJerk          | X    | Mean              | FFT    |
| BodyAccelerationJerk          | Y    | Mean              | FFT    |
| BodyAccelerationJerk          | Z    | Mean              | FFT    |
| BodyAccelerationJerk          | X    | StandardDeviation |        |
| BodyAccelerationJerk          | Y    | StandardDeviation |        |
| BodyAccelerationJerk          | Z    | StandardDeviation |        |
| BodyAccelerationJerk          | X    | StandardDeviation | FFT    |
| BodyAccelerationJerk          | Y    | StandardDeviation | FFT    |
| BodyAccelerationJerk          | Z    | StandardDeviation | FFT    |
| BodyGyroscope                 | X    | Mean              |        |
| BodyGyroscope                 | Y    | Mean              |        |
| BodyGyroscope                 | Z    | Mean              |        |
| BodyGyroscope                 | X    | Mean              | FFT    |
| BodyGyroscope                 | Y    | Mean              | FFT    |
| BodyGyroscope                 | Z    | Mean              | FFT    |
| BodyGyroscope                 | X    | StandardDeviation |        |
| BodyGyroscope                 | Y    | StandardDeviation |        |
| BodyGyroscope                 | Z    | StandardDeviation |        |
| BodyGyroscope                 | X    | StandardDeviation | FFT    |
| BodyGyroscope                 | Y    | StandardDeviation | FFT    |
| BodyGyroscope                 | Z    | StandardDeviation | FFT    |
| BodyGyroscopeJerk             | X    | Mean              |        |
| BodyGyroscopeJerk             | Y    | Mean              |        |
| BodyGyroscopeJerk             | Z    | Mean              |        |
| BodyGyroscopeJerk             | X    | StandardDeviation |        |
| BodyGyroscopeJerk             | Y    | StandardDeviation |        |
| BodyGyroscopeJerk             | Z    | StandardDeviation |        |
| BodyAccelerationMagnitude     |      | Mean              |        |
| BodyAccelerationMagnitude     |      | Mean              | FFT    |
| BodyAccelerationMagnitude     |      | StandardDeviation |        |
| BodyAccelerationMagnitude     |      | StandardDeviation | FFT    |
| GravityAccelerationMagnitude  |      | Mean              |        |
| GravityAccelerationMagnitude  |      | StandardDeviation |        |
| BodyAccelerationJerkMagnitude |      | Mean              |        |
| BodyAccelerationJerkMagnitude |      | StandardDeviation |        |
| BodyGyroscopeMagnitude        |      | Mean              |        |
| BodyGyroscopeMagnitude        |      | StandardDeviation |        |
| BodyGyroscopeJerkMagnitude    |      | Mean              |        |
| BodyGyroscopeJerkMagnitude    |      | StandardDeviation |        |
|                               |      |                   |        |
| BodyBodyGyroscopeMagnitude        |  | Mean              | FFT    |
| BodyBodyGyroscopeMagnitude        |  | StandardDeviation | FFT    |
| BodyBodyAccelerationJerkMagnitude |  | Mean              | FFT    |
| BodyBodyAccelerationJerkMagnitude |  | StandardDeviation | FFT    |
| BodyBodyGyroscopeJerkMagnitude    |  | Mean              | FFT    |
| BodyBodyGyroscopeJerkMagnitude    |  | StandardDeviation | FFT    |

From that list, and thanks to the naming convention adopted, the last 6 names stand out, as they are most likely misspelled (the token "Body"" is duplicated in the name).  Assuming this is the case (and if we remove the extra token), we can also see very quickly which measures are missing/have not had a FFT applied to them: _GravityAcceleration_, _BodyGyroscopeJerk_ and _GravityAccelerationMagnitude_.

All and all, we have found out that, as long as the naming __convention is consistent__ over all the variables, it does not matter too much what the convention actually is, as long as it __makes sense and variables are easily readable__.

<BR/>


#### 3.5 Create tidy data set

Creating a tidy data set is performed in two steps:

* First the data is "melted" according to the two variables of interest (_Activity_ and _Subject_), meaning all the feature columns are aggregated into one column (or rather two, _variable_ and _value_): this is done with a call to `melt(..)` and generates a long and skinny data set.

```
               Activity Subject                variable                                   value
1              STANDING       2 BodyAcceleration.X.Mean                               0.2571778
2              STANDING       2 BodyAcceleration.X.Mean                               0.2860267
3              STANDING       2 BodyAcceleration.X.Mean                               0.2754848
4              STANDING       2 BodyAcceleration.X.Mean                               0.2702982
5              STANDING       2 BodyAcceleration.X.Mean                               0.2748330
6              STANDING       2 BodyAcceleration.X.Mean                               0.2792199
...
679729 WALKING_UPSTAIRS      30 BodyBodyGyroscopeJerkMagnitude.StandardDeviation.FFT -0.7547290
679730 WALKING_UPSTAIRS      30 BodyBodyGyroscopeJerkMagnitude.StandardDeviation.FFT -0.7239514
679731 WALKING_UPSTAIRS      30 BodyBodyGyroscopeJerkMagnitude.StandardDeviation.FFT -0.7711831
679732 WALKING_UPSTAIRS      30 BodyBodyGyroscopeJerkMagnitude.StandardDeviation.FFT -0.7263718
679733 WALKING_UPSTAIRS      30 BodyBodyGyroscopeJerkMagnitude.StandardDeviation.FFT -0.6894209
679734 WALKING_UPSTAIRS      30 BodyBodyGyroscopeJerkMagnitude.StandardDeviation.FFT -0.7451204
```

A quick visual inspection confirms that the numbers in the long data set are correct and as expected:

* the number of observations (679,734 = 66 * 10,299) is the product of the number of features (66), and the number of measures in the merged data set (10,299).
* the number of columns is 4: the two id columns (_Activity_ and _Subject_) and the two variable columns (_variable_ and _value_).


```
# 'long' observations : 679734
# 'long' columns      : 4
```

<BR/>

* Second, the long data set generated above is reshaped (or re-casted) into a different form using the function `dcast(...)`.  The data is summarized using the `mean` function (rather than the default function `length`) to generate the average for each variable for each activity and each subject.  This becomes the tidy data set.

A quick visual inspection once again confirms that the numbers in the tidy data set are correct and as expected:

* the number of observations (180 = 6 * 30) is the product of the number of activities (6), and the number of (unique) subjects (30).
* the number of columns is 68: the 66 features, and the two additional columns _Activity_ and _Subject_.

```
# 'tidy' observations : 180
# 'tidy' columns      : 68
```

Finally, the tidy data set is exported to a file on the local disk with a call to `write.table(...)`.
