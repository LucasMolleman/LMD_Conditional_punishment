
This package contains data, analysis, and simulations files for the paper "Conditional punishment: Descriptive norms drive negative reciprocity" by Xueheng Li, Lucas Molleman and Dennie van Dolder. 

"ExperimentData_beforeClean.dta" stores the raw experimental data in the format of STATA .dta file.

"Clean_and_Regressions.do"  is a STATA do file to clean the experimental data and generate regression results in Table S1. The input of it is "ExperimentData_beforeClean.dta", and the outputs of it are "ExperimentData_afterClean_Short.dta" and "ExperimentData_afterClean_Long.dta".

"ExperimentData_afterClean_Short.dta" and "ExperimentData_afterClean_Long.dta" are experimental data after the cleaning, in the wide format and the long format, respectively.

"plots_experiment.Rmd" is a R Notebook which can be opened with RStudio; it loads "ExperimentData_afterClean_Short.dta" and "ExperimentData_afterClean_Long.dta" and  generates Figures 1 and 2 in the main text of the paper and Figures S1 to S7 in Supplementary Information.

"simulation_FourTypes.ipynb" is a Jupyter Notebook which contains the Python code to simulate the dynamic model in the paper; the model assumes four punishment types: non-punishers, independent punishers, norm enforcers, and conformist punishers. 

"simulation_FiveTypes.ipynb" conducts robust checks by adding "decreasing punishers"; it produces data to draw Fig. S11 in Supplementary Information. 

"plots_simulation.Rmd" draws figures based on the simulation data, including Figures 3 and 4 in the main text, and Figures 8 to 10 in Supplementary Information.


