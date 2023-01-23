# Final model
The final model for hand-in was chosen to be **36-true_213-true_378-true_t-210705-1848.mat** from the 10th optimization cycle.
Properties:
- SVM: 200 iterations with randomsearch, superextended features, sorted axes
- RF: type Tree, subtype Bag, 100 iterations, superextended features, sorted axes
- LSTM1: 36 hidden units, sorted axes
- LSTM2: 213 hidden units, sorted axes
- LSTM3: 378 hidden units, sorted axes

Performance:
~~~
final model: 10-cycle/36-true_213-true_378-true_t-210705-1848.mat
balanced accuracy (mean, train, test, validation)
   96.7322   99.9693   99.5196   90.7076

accuracy (mean, train, test, validation)
   96.3551   99.9647   99.5575   89.5431
~~~

# Optimization
This directory holds information about the performance of the trained models (234 different) and their individual performance figures. The performance is evaluated across settings:
- type of classification (1 stage or 2 stage stacking)
    - \_1stage\_ - all 5 classifiers being merged with equal weight
    - \_2stage\_ - a first stage, where the 3 LSTM networks are merged with equal weight and the output is merged with the SVM and RF output with equal weight
- considered models
    - \_?cycle\_ - analysis of a single cycle
    - \_?-cycle-to-?-cycle\_ - analysis of the mentioned range of cycles
    - \_all\_ - all trained models of all cycles, e.g. static and/or random (1: LSTM1 with 10-100, 2: LSTM2 with 100-250, 3: LSTM3 with 250-450) selection of the number of hidden units of one or many of the LSTM networks per cycle

## Files and variables
The herein located .mat files contain four variables:
- models: a cell array with the names of all rated cycles and models
- results: a cell array with numerical arrays with the accuracy and balanced accuracy of every rated model for test, train and validation data
- meanPerf: a cell array with numerical arrays with the mean (test, train, validation) accuracy and balanced accuracy of every rated model
- optimalModel: a struct that holds information about the name, row and column index (used for models, results and meanPerf cell arrays) and performance benchmark for mean and balanced accuracy (test, train, validation separately)

## Models
As the .mat files with the "model" variable are quite large - compressed more than 3GB - the models are archived on a file share instead of git. Please ask for access.

## Methodology
The search for the optimal model was done in an iterative manner. The optimization target was chosen as the mean balanced accuracy of the model when applied on training, test and validation data.
1. This cycle was performed with random number of hidden units for all three lstm components with sorting enabled and SVM (randomsearch, 200) and RF (Bag, 100) configuration fixed to 'superextended' features, sorting enabled and parfor active.
2. This cycle was performed with fixed numbers of hidden units for all three lstm components (40, 100, 400) with sorting enabled and SVM (randomsearch, 200) and RF (Bag, 100) configuration fixed to 'superextended' features, sorting disabled and parfor active.
3. This cycle was performed with fixed numbers of hidden units for all three lstm components (40, 100, 400) with sorting enabled and SVM (randomsearch, 200) and RF (Bag, 100) configuration fixed to 'default' features, sorting disabled and parfor active.
4. This cycle was performed with fixed numbers of hidden units for all three lstm components (40, 100, 400) with sorting enabled SVM (randomsearch, 200) and RF (Bag, 100) configuration fixed to 'superextended' features, sorting enabled and parfor active.
5. This cycle was performed with random number of hidden units for all three lstm components with sorting enabled and SVM (randomsearch, 200) and RF (Bag, 100) configuration fixed to 'superextended' features, sorting enabled and parfor active. Afterwards, the optimal model from cycles 1-5 was determined. With 1-stage stacking this proved to be **5-cycle/26_106_395_t-210704-1636.mat** from cycle 5.
6. The entry point for this cycle was the optimal model from cycle 5. Herein, the optimal SVM configuration was determined. In total 8 different SVM configurations were tested, which result from the permutation of three variables. Namely, 'MaxObjectiveEvaluations' for 'randomsearch' (200/500), feature set (super: superextended, default: default) and sorting (sort: enabled, raw: disabled). The highest performing model with 1-stage stacking was determined to be **6SVM-cycle/SVM500-super-raw_t-210704-1843.mat**.
7. The entry point for this cycle was the model with the optimized SVM settings from cycle 6. In total 17 different SVM configurations were tested, which result from variation of three variables. Namely, subtype of the trainRandomForest function (AB: AdaBoostM1, Bag: Bag, RB: RobustBoost, TB: TotalBoost), feature set (super: superextended, default: default) and sorting (sort: enabled, raw: disabled). The highest performing model with both 1-stage and 2-stage stacking was determined to be **7RF-cycle/RB-default-sort_t-210704-1756.mat** with 2-stage stacking.
8. The entry point for this cycle was the model with the optimized RF settings from cycle 7. It was performed with a random number of hidden units for all three lstm components with random sorting setting per lstm component and SVM and RF configuration fixed to the base model. The highest performing model with both 1-stage and 2-stage stacking was determined to be **8-cycle/36-1_213-1_378-1_t-210704-2256.mat** with 1-stage stacking.
9. The entry point for this cycle was the model with the optimized lstm settings from cycle 8. It was performed across the permutation from the base model with the 3 lstm models and the 8 SVM models from cycle 6 and 12 RF (4 AdaBoostM1, 4 Bag, 4 RobustBoost) models from cycle 7. In total 96 models were evaluated. The highest performing models are presented in the next sub-chapter.
10. The entry point for this cycle was determined in a team meeting on 5th July 2021. The team chose 1-stage stacking with **9-cycle/mrgSVM200-super-sort_t-210704-1805+Bag-super-sort_t-210704-1758.mat** as the most promising approach, as it has a unique combination of good performance, fast classification (SVM and RF operate with the same feature settings, so we extract features only once) and short training time (SVM with 200 iterations). To check the validity of this pick, 20 models with static SVM, RF and LSTM settings (36, 213, 378; all sorted) were trained to exploit the nondeterministic nature of the MATLAB LSTM training procedure.
11. The entry point for this cycle was the same as to cycle 10, namely **9-cycle/mrgSVM200-super-sort_t-210704-1805+Bag-super-sort_t-210704-1758.mat**. To check the validity of the number of hidden units setting for the three LSTM networks for final hand-in of the project, a validation cycle with 20 models with static SVM, RF and LSTM settings (40, 100, 400; all sorted) were trained to exploit the nondeterministic nature of the MATLAB LSTM training procedure.

### Optimization results in cycle 8
#### For 1-stage stacking, benchmark yielded the following results:
~~~  
##> mean optimal model: 8-cycle/36-1_213-1_378-1_t-210704-2256.mat
balanced accuracy (mean, train, test, validation)
   96.9397   99.9279   98.7568   92.1344

accuracy (mean, train, test, validation)
   96.6974   99.9295   98.8938   91.2690

##> training optimal model: 8-cycle/90-0_158-0_384-0_t-210704-2333.mat
balanced accuracy (mean, train, test, validation)
   92.2229  100.0000   97.9201   78.7487

accuracy (mean, train, test, validation)
   91.4323  100.0000   98.0531   76.2437

##> testing optimal model: 8-cycle/99-0_224-1_435-1_t-210705-0031.mat
balanced accuracy (mean, train, test, validation)
   95.8902   99.9639   99.3111   88.3957

accuracy (mean, train, test, validation)
   95.4523   99.9647   99.3363   87.0558

##> validation optimal model: 8-cycle/36-1_213-1_378-1_t-210704-2256.mat
balanced accuracy (mean, train, test, validation)
   96.9397   99.9279   98.7568   92.1344

accuracy (mean, train, test, validation)
   96.6974   99.9295   98.8938   91.2690
~~~

#### For 2-stage stacking, benchmark yielded the following results:
~~~
##> mean optimal model: 8-cycle/36-1_213-1_378-1_t-210704-2256.mat
balanced accuracy (mean, train, test, validation)
   96.6036   99.9793   97.1230   92.7085

accuracy (mean, train, test, validation)
   96.3555   99.9824   97.2566   91.8274

##> training optimal model: 8-cycle/19-0_248-1_383-1_t-210704-2151.mat
balanced accuracy (mean, train, test, validation)
   96.0460  100.0000   97.1151   91.0229

accuracy (mean, train, test, validation)
   95.7036  100.0000   97.2124   89.8985

##> testing optimal model: 8-cycle/98-1_130-1_409-0_t-210705-0009.mat
balanced accuracy (mean, train, test, validation)
   96.5275   99.9432   97.4451   92.1941

accuracy (mean, train, test, validation)
   96.2292   99.9471   97.5221   91.2183

##> validation optimal model: 8-cycle/36-1_213-1_378-1_t-210704-2256.mat
balanced accuracy (mean, train, test, validation)
   96.6036   99.9793   97.1230   92.7085

accuracy (mean, train, test, validation)
   96.3555   99.9824   97.2566   91.8274
~~~

### Optimization results in cycle 9
#### For 1-stage stacking, benchmark yielded the following results:
~~~
##> mean optimal model: 9-cycle/mrgSVM500-super-raw_t-210704-1843+Bag-default-sort_t-210704-1758.mat
balanced accuracy (mean, train, test, validation)
   96.9931   99.9486   98.9284   92.1025

accuracy (mean, train, test, validation)
   96.7306   99.9471   99.0265   91.2183

##> training optimal model: 9-cycle/mrgSVM200-default-sort_t-210704-1809+Bag-default-raw_t-210704-1757.mat
balanced accuracy (mean, train, test, validation)
   96.8408   99.9486   98.6063   91.9673

accuracy (mean, train, test, validation)
   96.5914   99.9471   98.7611   91.0660

##> testing optimal model: 9-cycle/mrgSVM200-super-sort_t-210704-1805+Bag-super-sort_t-210704-1758.mat
balanced accuracy (mean, train, test, validation)
   96.8729   99.9486   99.0181   91.6520

accuracy (mean, train, test, validation)
   96.5909   99.9471   99.1150   90.7107

##> validation optimal model: 9-cycle/mrgSVM200-super-raw_t-210704-1800+AB-super-raw_t-210704-1749.mat
balanced accuracy (mean, train, test, validation)
   96.8877   99.8449   98.3873   92.4309

accuracy (mean, train, test, validation)
   96.6575   99.8590   98.5398   91.5736
~~~

#### For 2-stage stacking, benchmark yielded the following results:
~~~
##> mean optimal model: 9-cycle/mrgSVM500-super-raw_t-210704-1843+RB-default-sort_t-210704-1756.mat
balanced accuracy (mean, train, test, validation)
   96.6036   99.9793   97.1230   92.7085

accuracy (mean, train, test, validation)
   96.3555   99.9824   97.2566   91.8274

##> training optimal model: 9-cycle/mrgSVM200-default-sort_t-210704-1809+Bag-default-raw_t-210704-1757.mat
balanced accuracy (mean, train, test, validation)
   95.8541  100.0000   96.7007   90.8616

accuracy (mean, train, test, validation)
   95.5496  100.0000   96.9027   89.7462

##> testing optimal model: 9-cycle/mrgSVM200-super-sort_t-210704-1805+AB-default-sort_t-210704-1750.mat
balanced accuracy (mean, train, test, validation)
   96.0856   99.9585   97.6694   90.6291

accuracy (mean, train, test, validation)
   95.7799   99.9647   97.8319   89.5431

##> validation optimal model: 9-cycle/mrgSVM200-super-raw_t-210704-1800+RB-super-sort_t-210704-1755.mat
balanced accuracy (mean, train, test, validation)
   96.1602   99.1567   96.1200   93.2040

accuracy (mean, train, test, validation)
   95.9998   99.2419   96.3717   92.3858
~~~

### Optimization results for cycles 1 to 9
#### For 1-stage stacking, benchmark yielded the following results:
~~~
##> mean optimal model: 9-cycle/mrgSVM500-super-raw_t-210704-1843+Bag-default-sort_t-210704-1758.mat
balanced accuracy (mean, train, test, validation)
   96.9931   99.9486   98.9284   92.1025

accuracy (mean, train, test, validation)
   96.7306   99.9471   99.0265   91.2183

##> training optimal model: 1-cycle/68_222_265_t-210703-2200.mat
balanced accuracy (mean, train, test, validation)
   96.3132  100.0000   98.8175   90.1220

accuracy (mean, train, test, validation)
   95.9404  100.0000   98.9381   88.8832

##> testing optimal model: 1-cycle/97_239_371_t-210703-2250.mat
balanced accuracy (mean, train, test, validation)
   96.4803  100.0000   99.4483   89.9927

accuracy (mean, train, test, validation)
   96.0983  100.0000   99.5133   88.7817

##> validation optimal model: 9-cycle/mrgSVM200-super-raw_t-210704-1800+AB-super-raw_t-210704-1749.mat
balanced accuracy (mean, train, test, validation)
   96.8877   99.8449   98.3873   92.4309

accuracy (mean, train, test, validation)
   96.6575   99.8590   98.5398   91.5736
~~~

#### For 2-stage stacking, benchmark yielded the following results:
~~~
##> mean optimal model: 8-cycle/36-1_213-1_378-1_t-210704-2256.mat
balanced accuracy (mean, train, test, validation)
   96.6036   99.9793   97.1230   92.7085

accuracy (mean, train, test, validation)
   96.3555   99.9824   97.2566   91.8274

##> training optimal model: 1-cycle/100_171_424_t-210703-2236.mat
balanced accuracy (mean, train, test, validation)
   95.2331  100.0000   96.9172   88.7822

accuracy (mean, train, test, validation)
   94.8177  100.0000   96.9912   87.4619

##> testing optimal model: 9-cycle/mrgSVM200-super-sort_t-210704-1805+AB-default-sort_t-210704-1750.mat
balanced accuracy (mean, train, test, validation)
   96.0856   99.9585   97.6694   90.6291

accuracy (mean, train, test, validation)
   95.7799   99.9647   97.8319   89.5431

##> validation optimal model: 9-cycle/mrgSVM200-super-raw_t-210704-1800+RB-super-sort_t-210704-1755.mat
balanced accuracy (mean, train, test, validation)
   96.1602   99.1567   96.1200   93.2040

accuracy (mean, train, test, validation)
   95.9998   99.2419   96.3717   92.3858
~~~

### Optimization results for cycle 10
#### For 1-stage stacking, benchmark yielded the following results:
##### base model
~~~
##> base model: 9-cycle/mrgSVM200-super-sort_t-210704-1805+Bag-super-sort_t-210704-1758.mat
balanced accuracy (mean, train, test, validation)
   96.8729   99.9486   99.0181   91.6520

accuracy (mean, train, test, validation)
   96.5909   99.9471   99.1150   90.7107
~~~

##### 20 new models from cycle
~~~
##> mean optimal model: 10-cycle/36-true_213-true_378-true_t-210705-1848.mat
balanced accuracy (mean, train, test, validation)
   96.7322   99.9693   99.5196   90.7076

accuracy (mean, train, test, validation)
   96.3551   99.9647   99.5575   89.5431

##> training optimal model: 10-cycle/36-true_213-true_378-true_t-210705-1754.mat
balanced accuracy (mean, train, test, validation)
   96.1431  100.0000   99.0181   89.4113

accuracy (mean, train, test, validation)
   95.7964  100.0000   99.1150   88.2741

##> testing optimal model: 10-cycle/36-true_213-true_378-true_t-210705-1848.mat
balanced accuracy (mean, train, test, validation)
   96.7322   99.9693   99.5196   90.7076

accuracy (mean, train, test, validation)
   96.3551   99.9647   99.5575   89.5431

##> validation optimal model: 10-cycle/36-true_213-true_378-true_t-210705-1848.mat
balanced accuracy (mean, train, test, validation)
   96.7322   99.9693   99.5196   90.7076

accuracy (mean, train, test, validation)
   96.3551   99.9647   99.5575   89.5431
~~~

##### key figures of randomness of training
The following table summarizes the statistical results from the 20 different trained models.

|Metric | Max  | Min | Mean | Std |
|:--- | :--- | :--- | :--- | :--- |
|mean mean accuracy |96.3551 |94.6781 |95.6199 |0.36103 |
|mean mean balanced accuracy |96.7322 |95.2294 |96.0223 |0.32548 |
|training accuracy |100 |99.9118 |99.9498 |0.034451 |
|training balanced accuracy |100 |99.9234 |99.956 |0.030144 |
|testing accuracy |99.5575 |97.9204 |98.9049 |0.39338 |
|testing balanced accuracy |99.5196 |97.8542 |98.8232 |0.40776 |
|validation accuracy |89.5431 |85.0254 |88.0051 |1.035 |
|validation balanced accuracy |90.7076 |86.7117 |89.2878 |0.92733 |

### Optimization results for cycle 11
#### For 1-stage stacking, benchmark yielded the following results:
##### base model
~~~
##> base model: 9-cycle/mrgSVM200-super-sort_t-210704-1805+Bag-super-sort_t-210704-1758.mat
balanced accuracy (mean, train, test, validation)
   96.8729   99.9486   99.0181   91.6520

accuracy (mean, train, test, validation)
   96.5909   99.9471   99.1150   90.7107
~~~

##### 20 new models from cycle
~~~
##> mean optimal model: 11-cycle/40-true_100-true_400-true_t-210705-2126.mat
balanced accuracy (mean, train, test, validation)
   96.5525   99.9179   98.9680   90.7715

accuracy (mean, train, test, validation)
   96.2091   99.9118   99.0708   89.6447

##> training optimal model: 11-cycle/40-true_100-true_400-true_t-210705-2026.mat
balanced accuracy (mean, train, test, validation)
   96.0711  100.0000   99.1290   89.0844

accuracy (mean, train, test, validation)
   95.6736  100.0000   99.2035   87.8173

##> testing optimal model: 11-cycle/40-true_100-true_400-true_t-210705-2119.mat
balanced accuracy (mean, train, test, validation)
   95.9638   99.9333   99.2398   88.7183

accuracy (mean, train, test, validation)
   95.5273   99.9295   99.2920   87.3604

##> validation optimal model: 11-cycle/40-true_100-true_400-true_t-210705-2231.mat
balanced accuracy (mean, train, test, validation)
   96.3920   99.8196   98.3160   91.0402

accuracy (mean, train, test, validation)
   96.1233   99.8237   98.4956   90.0508
~~~
##### key figures of randomness of training
The following table summarizes the statistical results from the 20 different trained models.

|Metric | Max  | Min | Mean | Std |
|:--- | :--- | :--- | :--- | :--- |
|mean mean accuracy |96.2318 |94.8713 |95.6779 |0.34971 |
|mean mean balanced accuracy |96.5525 |95.3777 |96.0621 |0.28773 |
|training accuracy |100 |99.8237 |99.9171 |0.0436 |
|training balanced accuracy |100 |99.8196 |99.9209 |0.044621 |
|testing accuracy |99.292 |98.4071 |98.8628 |0.25604 |
|testing balanced accuracy |99.2398 |98.1946 |98.7713 |0.29812 |
|validation accuracy |90.0508 |86.0914 |88.2538 |1.1138 |
|validation balanced accuracy |91.0402 |87.5791 |89.4941 |0.96314 |
