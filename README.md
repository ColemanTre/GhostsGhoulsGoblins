# GhostsGhoulsGoblins
a.	What is the overall purpose of this project?
To predict the type of monster based on rotting flesh, bone length, hair length, color, and if they have a soul.

b.	What do each file in your repository do?
work.R is where I made the stacked model using data from all the students.
DrHeatonVersion.R is the clean version of our original logistic regression modelling.
submission.csv is the output of Work.R

c.	What methods did you use to clean the data or do feature engineering?
The data was clean already. I didn't do any feature engineering. 

d.	What methods did you use to generate predictions?
We mostly used the caret library to perform modeling. Within the caret library, we did gradient boosting using the xgbTree option. We also did an ensemble of various model predictions, including gradient boosting, random forest, logistic regression, and neural networks.
