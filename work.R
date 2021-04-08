
### Libraries


library(tidyverse)
library(vroom)
library(caret)
library(DataExplorer)

### Data
test <- vroom::vroom("./test.csv") %>% mutate(type = NA)
train <- vroom::vroom("./train.csv")
full <- rbind(test, train)

test.id <- test %>% pull(id)


nnProbs <- vroom::vroom("./nn_Probs_65acc.csv")
KNN <- vroom::vroom("./Probs_KNN.csv")
xgbTree <- vroom::vroom("./xgbTree_probs.csv")
gbm <- vroom::vroom("./probs_gbm.csv")
multilayer <- vroom::vroom("./multilayerperceptron.csv")
classific <- vroom::vroom("./classification_submission_rf.csv")
log <- vroom::vroom("./LogRegPreds.csv")


names(multilayer)[1] <- 'ID'
names(nnProbs)[4] <- 'ID'
names(test)[1] <- 'ID'
names(train)[1] <- 'ID'
names(log)[1] <- 'ID'




all <- left_join(by="ID", nnProbs, KNN) %>%
  left_join(., xgbTree, by = 'ID') %>%
  left_join(., gbm, by="ID") %>%
  left_join(., multilayer, by="ID") %>%
  left_join(., classific, by="ID")  %>%
  left_join(., log, by="ID") %>%
  left_join(., full, by ='ID')

all$ID <- as.factor(all$ID)
all$type <- as.factor(all$type)


pp <- preProcess(all, method= "pca")
all_pp <- predict(pp, all)

plot_missing(all_pp)

pp.model <- train(form=type ~ .,
                    data = all_pp %>% filter(Set == 2) %>% select(-ID, -color, -Set),
                    method="xgbTree",
                    tuneGrid = expand.grid(nrounds = 150,
                                           max_depth = 3,
                                           eta =  .5,
                                           gamma = .3,
                                           colsample_bytree = .6,
                                           min_child_weight = .6,
                                           subsample = 1),
                    trControl=trainControl(method='repeatedcv', number = 20, repeats = 2),
                    verboseIter= T)
preds <- predict(pp.model, all_pp %>% filter(Set == 1) %>% select(-ID, -color, -Set))
submission <- cbind(all_pp %>% filter(Set == 1) %>% select(ID), type = preds) %>% as.data.frame()

submission <- submission %>% mutate(id = ID) %>% select(-ID)
submission <- submission[c(2,1)]

write.csv(submission, "./submission.csv", row.names = FALSE)
