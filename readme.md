# Contributors:
- Hofmann, Tobias: tobias.th.hofmann@tum.de
- Krug, Tobias: https://github.com/hashkode
- Messaoud, Rayene: https://github.com/rmessaou
- Schölles, Alexander: alexander.schoelles@tum.de

# **Top Level Folders**
- **00_Documentation**: Documentation of this project. Folder includes raw latex file, used literature and finalized pdf-document.
- **ExampleData**: Example Walking Data provided by Monty Matlab Team.
- **GUI**: Folder includes all necessary functions to create the GUI and all callbacks. For more detailed information view the comments in the respective files.
- **Models/70**: Pretrained models to choose in the GUI to classify data. Train/Test-split was chosen to 70/30.
- **Optimization**: Benchmark to determine the highest yielding model and the optimal hyperparameters. Final choice is saved in main directory as **model.mat**. For more information refer to readme in subfolder.
- **RawData**: Raw data files from all team members. In total over 275 walks were recorded.
- **TestData**: Test data directory with cutted data in desired format. Approximately 30% of raw data.
- **TrainData**: Training data directory with cutted data in desired format. Approximately 70% of raw data.

# **Top Level Functions** 
**For more information on functions, view comments in respective files.**
The symbol &#11177; indicates which functions are called in respective files.
## Data Preprocessing
- **cutData()**: Cut provided raw data such that data consists only of the actual walk by trimming front and end. 
&#11177; increaseFrequency()   
- **increaseFrequency()**: Increase frequency of collected data with sampling frequency below 50 Hz to 50 Hz by squeezing time vector.
- **preprocessRawData()**: Read, trim and split raw dataset according to train/test ratio, e.g. 70/30. 
&#11177; filterFileStruct()
&#11177; cutData() 

## Training- and Testdata Input
- **extractData()**: Extract samples and class labels from single .mat file. This function works for different target sampling rate in [Hz] and window length in [s].
- **getFeatures()**: Extract various features from given input data to use in SVM and RF.
- **zscoreNorm()**: Perform z-score normalization on given input data.

## Training Classifier Model
- **trainLSTM()**: Train a LSTM classifier using training data and labels.
&#11177; zscoreNorm()
- **trainRandomForest()**: Train a Random Forest classifier using training features and labels.
- **trainSvm()**: Train a SVM classifier using training features and labels.
- **trainSillyWalkClassifier()**: Train specified classifier model. In this project a Support Vector Machine, Random Forest and three LSTM Networks with different number of layers are trained for ensemble model. 
&#11177; getFeatures()
&#11177; trainSvm()
&#11177; trainRandomForest()
&#11177; trainLSTM()

## Testing Classifier Model
- **classifyWalk()**: This function classifies a given test dataset on a pretrained model and outputs the classified prediction labels.
&#11177; getFeatures()
&#11177; predictSvm()
&#11177; predictRandomForest()
&#11177; predictLSTM()
- **predictLSTM()**: Apply a LSTM model to test data to yield predictions.
&#11177; zscoreNorm()
- **predictRandomForest()**: Apply a Random Forest model to test data to yield predictions.
- **predictSvm()**: Apply a SVM model to test data to yield predictions.

## Unit Test
- **runExtractTrainClassify()**: This function serves as unit test replacement for GUI usage. This function extracts the training and test data, trains one/multiple classifier, predicts the test data and gives information about accuracy, balanced accuracy and the testdata split ratio of normal and silly walks.
&#11177; filterFileStruct()
&#11177; extractData()
&#11177; trainSillyWalkClassifier()
&#11177; getFeatures()
&#11177; predictSvm()
&#11177; predictRandomForest()
&#11177; predictLSTM()
&#11177; classifyWalk()
- **SillyWalkDetectionTest()**: Unit test provided by Monty Matlab Team. 

## Helperfunctions
- **filterFileStruct()**: Filter a struct of files with a filename mask to remove all non-matching elements located in given directory, e.g. to only have files of form "Group5_Walk001_N".
- **runUnitTests()**: Run unit test "SillyWalkDetectionTest.p" provided by Monty Matlab Team.
&#11177; SillyWalkDetectionTest()

# **Top Level Scripts**
- **buildBenchmarkStatisticsTable**: Evaluate trained models and print statistics table to compare accuracies.
- **buildModelPermutation**: Combine pretrained models to new models in order to find optimal combination for final model.
- **prepareEnv**: Prepare environment and set paths.
- **runGui**: Run GUI app. 
- **runModelsBenchmark**: Run the optimization process to find optimal model.
- **runRawDataPreprocessing**: Run raw data preprocessing.
- **runTrain**: Run training process of models.
- **updateModelStructProperties**: Update model properties manually, e.g. settings for feature extraction.