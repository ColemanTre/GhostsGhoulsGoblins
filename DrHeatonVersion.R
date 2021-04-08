## Libraries
library(tidyverse)
library(vroom)
library(caret)
library(DataExplorer)

## Read in the data
train <- vroom("../train.csv")
test <- vroom("../test.csv")
ghost <- bind_rows(train,test)

## Set as factors
ghost$type <- as.factor(ghost$type)
ghost$color <- as.factor(ghost$color)

## Set up indicators
ghost <- ghost %>%
  mutate(isGhost=ifelse(type=="Ghost", "Yes", "No") %>% as.factor(),
         isGhoul=ifelse(type=="Ghoul", "Yes", "No") %>% as.factor())

## First Layer Logistic Regression (Ghost vs. Not Ghost)
ghost.logreg <- glm(isGhost~bone_length+rotting_flesh+hair_length+
                      has_soul+color,
                    data=ghost,
                    family=binomial)

## Second Layer Logistic Regression (Ghoul vs. Goblin)
ghoul.logreg <- glm(isGhoul~bone_length+rotting_flesh+hair_length+
                      has_soul+color,
                    data=ghost %>% filter(isGhost=="No"),
                    family=binomial)

## Get Predicted Probabilities for all data
predProbs <- data.frame(id=ghost$id,
                        ghostProb_LR=predict(ghost.logreg,
                                             newdata=ghost,
                                             type="response"),
                        ghoulProb_LR=(1-predict(ghost.logreg,
                                                newdata=ghost,
                                                type="response"))*
                          predict(ghoul.logreg, newdata=ghost,
                                  type="response"))
predProbs <- predProbs %>%
  mutate(goblinProb_LR=1-ghostProb_LR-ghoulProb_LR)

## Get Predicted Classes
predClasses <- data.frame(id=predProbs$id,
                          type=apply(predProbs[,-1], 1, function(x){
                            c("Ghost","Ghoul","Goblin")[which.max(x)]
                          }))
kaggleSubmission <- predClasses[-(1:nrow(train)),]
write.csv(x=kaggleSubmission, file="./kaggleSubmission.csv",
          row.names=FALSE)
