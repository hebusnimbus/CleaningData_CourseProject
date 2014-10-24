## Raw data

Source:

* Jorge L. Reyes-Ortiz, Davide Anguita, Alessandro Ghio, Luca Oneto.
* Smartlab - Non Linear Complex Systems Laboratory
* DITEN - UniversitÃ  degli Studi di Genova, Genoa I-16145, Italy.
* activityrecognition '@' smartlab.ws
* www.smartlab.ws
* URL: http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones.

The survey is about data collected from the accelerometers from a Samsung Galaxy S smartphone.  The data was built from the recordings of 30 subjects (within an age bracket of 19-48 years) performing activities of daily living (walking, walking upstairs, walking downstairs, sitting, standing, laying), while carrying a waist-mounted smartphone with embedded inertial sensors.

Using the embedded accelerometer and gyroscope, 3-axial linear acceleration and 3-axial angular velocity measures were captured at a constant rate of 50 Hz.  The sensor signals were processed using different filtering techniques to extract additional information such as body acceleration and gravity, as well as Jerk signals and signals magnitude.  A FFT (or Fast Fourier Transform) was also applied to a subset of the time signals to convert them to frequency domain signals.

The feature vector contains the following signals:

* tBodyAcc-XYZ
* tGravityAcc-XYZ
* tBodyAccJerk-XYZ
* tBodyGyro-XYZ
* tBodyGyroJerk-XYZ
* tBodyAccMag
* tGravityAccMag
* tBodyAccJerkMag
* tBodyGyroMag
* tBodyGyroJerkMag
* fBodyAcc-XYZ
* fBodyAccJerk-XYZ
* fBodyGyro-XYZ
* fBodyAccMag
* fBodyAccJerkMag
* fBodyGyroMag
* fBodyGyroJerkMag

A set of variables was estimated from these signals:

* mean(): Mean value
* std(): Standard deviation
* mad(): Median absolute deviation
* max(): Largest value in array
* min(): Smallest value in array
* sma(): Signal magnitude area
* energy(): Energy measure. Sum of the squares divided by the number of values.
* iqr(): Interquartile range
* entropy(): Signal entropy
* arCoeff(): Autorregresion coefficients with Burg order equal to 4
* correlation(): correlation coefficient between two signals
* maxInds(): index of the frequency component with largest magnitude
* meanFreq(): Weighted average of the frequency components to obtain a mean frequency
* skewness(): skewness of the frequency domain signal
* kurtosis(): kurtosis of the frequency domain signal
* bandsEnergy(): Energy of a frequency interval within the 64 bins of the FFT of each window.
* angle(): Angle between to vectors.

This data set was also randomly partioned into two sets, where 70% of the volunteers was selected for generating the training data and 30% the test data.

For each record in the dataset it is provided:

* Triaxial acceleration from the accelerometer (total acceleration) and the estimated body acceleration.
* Triaxial Angular velocity from the gyroscope.
* A 561-feature vector with time and frequency domain variables.
* Its activity label.
* An identifier of the subject who carried out the experiment.


## Study Design

From this original data set, we have constructed a tidy data set focusing solely on the mean and standard deviation variables for each measurement.  The data has been reshaped to arrive at the average of each variable for each activity and each subject.


#### Step 1

The first step in the data transformation process consisted in loading the five different pieces separately: activities, features, subjects (test and train), measures (test and train) and labels (test and train), followed by a mergin step where test and train data sets where merged together.

```
Activities

ID               Name
 1            WALKING
 2   WALKING_UPSTAIRS
 3 WALKING_DOWNSTAIRS
 4            SITTING
 5           STANDING
 6             LAYING
```

```
Features

ID                  Name
1      tBodyAcc-mean()-X
2      tBodyAcc-mean()-Y
3      tBodyAcc-mean()-Z
...
559 angle(X,gravityMean)
560 angle(Y,gravityMean)
561 angle(Z,gravityMean)
```

```
Subjects

ID
 1
 1
 1
...
30
30
30
```

```
Measures

  tBodyAcc-mean()-X tBodyAcc-mean()-Y ... angle(Y,gravityMean) angle(Z,gravityMean)
     2.5717778e-001   -2.3285230e-002 ...       2.7680104e-001      -5.7978304e-002
     2.8602671e-001   -1.3163359e-002 ...       2.8134292e-001      -8.3898014e-002
     2.7548482e-001   -2.6050420e-002 ...       2.8008303e-001      -7.9346197e-002
     ...
     2.7338737e-001   -1.7010616e-002 ...       2.4914484e-001       4.0811188e-002
     2.8965416e-001   -1.8843044e-002 ...       2.4643223e-001       2.5339478e-002
     3.5150347e-001   -1.2423118e-002 ...       2.4680852e-001       3.6694843e-002
```

```
Labels

ID
 5
 5
 5
 ...
 2
 2
 2
```


#### Step 2

In the next step, we filtered out all measure columns which were not means (denoted by "mean()") nor standard variations (denoted by "std()").  At the same time, activities and labels were merged on ID to create a new column _Activity_ in the measures data set, and the subject IDs were copied directly into it as a new column _Subject_.

```
Measures

  tBodyAcc-mean()-X tBodyAcc-mean()-Y ... fBodyBodyGyroJerkMag-mean() fBodyBodyGyroJerkMag-std()         Activity Subject
     2.5717778e-001   -2.3285230e-002 ...              -9.855619e-001             -9.858429e-001         STANDING       2
     2.8602671e-001   -1.3163359e-002 ...              -9.904980e-001             -9.905719e-001         STANDING       2
     2.7548482e-001   -2.6050420e-002 ...              -9.887326e-001             -9.898050e-001         STANDING       2
     ...
     2.7338737e-001   -1.7010616e-002 ...              -6.8585150-001             -7.2637180-001 WALKING_UPSTAIRS      30
     2.8965416e-001   -1.8843044e-002 ...              -7.1213070-001             -6.8942090-001 WALKING_UPSTAIRS      30
     3.5150347e-001   -1.2423118e-002 ...              -7.1558820-001             -7.4512040-001 WALKING_UPSTAIRS      30
```


#### Step 3

Next, variable names (i.e. column names) were renamed to provide more readability.  The replacement patterns used were as follow:

| pattern             | new value           |
|---------------------|---------------------|
| Acc                 | Acceleration        |
| Gyro                | Gyroscope           |
| Mag                 | Magnitude           |
| -mean()             | .Mean               |
| -std()              | .StandardDeviation  |
| -X                  | .X                  |
| -Y                  | .Y                  |
| -Z                  | .Z                  |
| Mean.X              | X.Mean              |
| Mean.Y              | Y.Mean              |
| Mean.Z              | Z.Mean              |
| StandardDeviation.X | X.StandardDeviation |
| StandardDeviation.Y | Y.StandardDeviation |
| StandardDeviation.Z | Z.StandardDeviation |
| ^t                  |                     |
| ^f(.\*)             | \\1.FFT             |
| BodyBody            | Body                |

Please see the `README.md` file for more details about the renaming patterns and the choices which were made during this process.  Here is a list of the final variable names (re-ordered for readibility):

| measure                       | axis | feature           | domain |
|-------------------------------|:----:|-------------------|:------:|
| BodyAcceleration              | X    | Mean              |        |
| BodyAcceleration              | X    | Mean              | FFT    |
| BodyAcceleration              | X    | StandardDeviation |        |
| BodyAcceleration              | X    | StandardDeviation | FFT    |
| BodyAcceleration              | Y    | Mean              |        |
| BodyAcceleration              | Y    | Mean              | FFT    |
| BodyAcceleration              | Y    | StandardDeviation |        |
| BodyAcceleration              | Y    | StandardDeviation | FFT    |
| BodyAcceleration              | Z    | Mean              |        |
| BodyAcceleration              | Z    | Mean              | FFT    |
| BodyAcceleration              | Z    | StandardDeviation |        |
| BodyAcceleration              | Z    | StandardDeviation | FFT    |
| BodyAccelerationJerk          | X    | Mean              |        |
| BodyAccelerationJerk          | X    | Mean              | FFT    |
| BodyAccelerationJerk          | X    | StandardDeviation |        |
| BodyAccelerationJerk          | X    | StandardDeviation | FFT    |
| BodyAccelerationJerk          | Y    | Mean              |        |
| BodyAccelerationJerk          | Y    | Mean              | FFT    |
| BodyAccelerationJerk          | Y    | StandardDeviation |        |
| BodyAccelerationJerk          | Y    | StandardDeviation | FFT    |
| BodyAccelerationJerk          | Z    | Mean              |        |
| BodyAccelerationJerk          | Z    | Mean              | FFT    |
| BodyAccelerationJerk          | Z    | StandardDeviation |        |
| BodyAccelerationJerk          | Z    | StandardDeviation | FFT    |
| BodyAccelerationJerkMagnitude |      | Mean              |        |
| BodyAccelerationJerkMagnitude |      | Mean              | FFT    |
| BodyAccelerationJerkMagnitude |      | StandardDeviation |        |
| BodyAccelerationJerkMagnitude |      | StandardDeviation | FFT    |
| BodyAccelerationMagnitude     |      | Mean              |        |
| BodyAccelerationMagnitude     |      | Mean              | FFT    |
| BodyAccelerationMagnitude     |      | StandardDeviation |        |
| BodyAccelerationMagnitude     |      | StandardDeviation | FFT    |
| BodyGyroscope                 | X    | Mean              |        |
| BodyGyroscope                 | X    | Mean              | FFT    |
| BodyGyroscope                 | X    | StandardDeviation |        |
| BodyGyroscope                 | X    | StandardDeviation | FFT    |
| BodyGyroscope                 | Y    | Mean              |        |
| BodyGyroscope                 | Y    | Mean              | FFT    |
| BodyGyroscope                 | Y    | StandardDeviation |        |
| BodyGyroscope                 | Y    | StandardDeviation | FFT    |
| BodyGyroscope                 | Z    | Mean              |        |
| BodyGyroscope                 | Z    | Mean              | FFT    |
| BodyGyroscope                 | Z    | StandardDeviation |        |
| BodyGyroscope                 | Z    | StandardDeviation | FFT    |
| BodyGyroscopeJerk             | X    | Mean              |        |
| BodyGyroscopeJerk             | X    | StandardDeviation |        |
| BodyGyroscopeJerk             | Y    | Mean              |        |
| BodyGyroscopeJerk             | Y    | StandardDeviation |        |
| BodyGyroscopeJerk             | Z    | Mean              |        |
| BodyGyroscopeJerk             | Z    | StandardDeviation |        |
| BodyGyroscopeJerkMagnitude    |      | Mean              |        |
| BodyGyroscopeJerkMagnitude    |      | Mean              | FFT    |
| BodyGyroscopeJerkMagnitude    |      | StandardDeviation |        |
| BodyGyroscopeJerkMagnitude    |      | StandardDeviation | FFT    |
| BodyGyroscopeMagnitude        |      | Mean              |        |
| BodyGyroscopeMagnitude        |      | Mean              | FFT    |
| BodyGyroscopeMagnitude        |      | StandardDeviation |        |
| BodyGyroscopeMagnitude        |      | StandardDeviation | FFT    |
| GravityAcceleration           | X    | Mean              |        |
| GravityAcceleration           | X    | StandardDeviation |        |
| GravityAcceleration           | Y    | Mean              |        |
| GravityAcceleration           | Y    | StandardDeviation |        |
| GravityAcceleration           | Z    | Mean              |        |
| GravityAcceleration           | Z    | StandardDeviation |        |
| GravityAccelerationMagnitude  |      | Mean              |        |
| GravityAccelerationMagnitude  |      | StandardDeviation |        |


#### Step 4

The final step consisted into reshaping the data into a tidy form, based on _Activity_ and _Subject_ as IDs and all other columns as values.  The data was also summarized by average of each measure.

```
            Activity Subject BodyAcceleration.X.Mean ... BodyGyroscopeJerkMagnitude.StandardDeviation.FFT
1             LAYING       1               0.2215982 ...                                       -0.9326607
2             LAYING       2               0.2813734 ...                                       -0.9894927
3             LAYING       3               0.2755169 ...                                       -0.9825682
...
178 WALKING_UPSTAIRS      28               0.2620058 ...                                       -0.7048528
179 WALKING_UPSTAIRS      29               0.2654231 ...                                       -0.7564642
180 WALKING_UPSTAIRS      30               0.2714156 ...                                       -0.7913494
```


## Notes

The features in the original data were normalized and bounded within [-1,1], which means the original units were lost in the process.  Therefore, the tidy data set does not have any units either.
