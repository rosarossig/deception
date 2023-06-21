# deception

Raw choice data is contained in deception_dat.mat – columns are as follows:
Column 2: Subject ID
Column 3: Choice (1, 2, 3, 4)
Column 4: Context (0 = give; 1 = recieve) 
Column 5: Ambiguity value 
Column 6: Total number of trials 
Column 7: Confidence
Column 8: Version (comp versus control)
Column 9: LPA group

Aggregated behavioral data (including scales, parameter values, and LPA groups) are contained in behavioral_data_06_02_2023.csv

Simulated model parameters for parameter recovery is contained in sim_params_06_02_2023.csv

Scripts for model likelihood calculation are in the model_fitting folder – the winning model is M5.csv
Model fitting scripts were adapated from code from Sam Gershman's mfit package (https://github.com/sjgershm/mfit)


