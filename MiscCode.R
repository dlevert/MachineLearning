# SETUP ===========================
require(knitr)
require(caret)
require(ggplot2)
training <- read.csv(
     "https://d396qusza40orc.cloudfront.net/predmachlearn/pml-training.csv")
testing <- read.csv(
     "https://d396qusza40orc.cloudfront.net/predmachlearn/pml-testing.csv")
trainSub <- training
trainSub <- trainSub[,-1]
trainSub <- trainSub[,-2:-6]
trainSub[trainSub == ""] <- NA
trainSub <- trainSub[, colSums(is.na(trainSub))==0]
trainSub[, 2:53] <- apply(trainSub[,2:53], 2, as.numeric)
trainSub$user_name <- as.factor(trainSub$user_name)
trainSub$classe <- as.factor(trainSub$classe)
testSub <- testing
testSub <- testSub[,-1]
testSub <- testSub[,-2:-6]
testSub[testSub == ""] <- NA
testSub <- testSub[, colSums(is.na(testSub))==0]
testSub[, 2:53] <- apply(testSub[,2:53], 2, as.numeric)
testSub <- testSub[,-54]
testSub$user_name <- as.factor(testSub$user_name)
rm(training); rm(testing)

# EXPLORATORY ANALYSIS =======================
set.seed(333)
modFit1 <- train(classe ~ ., data = trainSub, method="rf", ntree=100)
modFit2 <- train(classe ~ ., data = trainSub, method = "gbm", verbose = FALSE)
modFit3 <- train(classe ~ ., data = trainSub, method = "lda")
pdRF <- predict(modFit1, newdata = testSub)
pdGBM <- predict(modFit1, newdata = testSub)
pdLDA <- predict(modFit1, newdata = testSub)

# VARIABLES ================================
require(kableExtra)
modComp <- data.frame(pdRF, pdGBM, pdLDA)
impRF <- varImp(modFit1)
impRF <- data.frame(impRF$importance)
impRF$Variable <- rownames(impRF)
impRF <- impRF[order(impRF$Overall, decreasing = TRUE),]
impRF$Overall <- round(impRF$Overall,1)
impRF$Importance <- 1:dim(impRF)[1]
impRF[1:10,c(3,2,1)] %>% kbl(row.names = FALSE, 
                             align = c("c","l", "c")) %>%
     kable_classic_2(full_width = T)

#PREDICTION =================================
modComp <- data.frame(pdRF, pdGBM, pdLDA)
par(mfcol = c(1,3))
plot(modComp$pdRF, main = "Random Forest Prediction", col = "blue")
plot(modComp$pdGBM, main = "Boosted Regression Prediction", col = "green")
plot(modComp$pdLDA, main = "Linear Discriminant Predistion", col = "brown")
modComp <- data.frame(pdRF, pdGBM, pdLDA)
rownames(modComp) <- 1:20
t <- t(modComp)
t %>% kbl() %>% kable_classic_2(full_width = T)

# ACCURACY ==================================
print(paste("Random Forest Accuracy", 
            round(modFit1$results[2,2]*100,2), "%"))
print(paste("Boosted Regression Accuracy", 
            round(modFit2$results[9,5]*100,2), "%"))
print(paste("Linear Discriminant Accuracy", 
            round(modFit3$results[1,2]*100,2), "%"))

# PLOT =====================================
par(mfcol = c(1,1))
plot(modFit1$finalModel)
print(modFit1$finalModel$confusion)
