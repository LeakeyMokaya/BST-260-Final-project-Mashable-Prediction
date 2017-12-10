# BST-260-Final-project-Mashable-Prediction

P.S. : All codes in Project Code.Rmd / Project Code.html.
P.S. : "Mashable_shares_prediction" is the Shiny folder.

#### Quick Links ####

[Google Drive Folder containing the data](https://drive.google.com/drive/folders/1wnwedxkSo_hoscvWFohUuApDrIH4CaOQ?usp=sharing)

[Shiny Dashboard](https://abhijith-asok.shinyapps.io/mashable_shares_prediction/)   
(In case you are not able to access the dashboard, kindly shoot an email to aasok@hsph.harvard.edu or chilger@hsph.harvard.edu and we'll restart the dashboard. RStudio's Shiny Server only allows a maximum of 1 hour of idle time before sending the dashboard to sleep)

[Summary video](https://www.youtube.com/watch?v=kBSfymZATfw&feature=youtu.be)

[GitHub Repo](https://github.com/abhijith-asok/BST-260-Final-project-Mashable-Prediction)


# Description

## Overview and Motivation

Media companies like Mashable produce tens of thousands of articles per year, all with varying degrees of virality. The virality of the content produced is key to a media company’s profitability. An accurate model that could predict parameters that increase the virality of an article, specifically, the number of social shares it receives, would be extremely valuable. 

This is of personal interest to us, since one of us comes from a marketing and product management background, while the other has had a respectable amount of experience in predictive model building.  We both had a desire to incorporate regression and machine learning techniques in this project. A short video summarising our approach and findings can be found [here](https://www.youtube.com/watch?v=kBSfymZATfw&feature=youtu.be).

## Related Work

This project allowed us to incorporate many techniques taught in the BST 260 class such as regression, decision trees and random forests, variable importance, data visualization with Shiny. Many of the prediction methods are time intensive, so we also applied knowledge from our BST 262 - Computing for Big Data course to track the processing times for each method and implement multicore parallel processing to speed up implementations.

## Initial Questions

The scientific goal is to develop a predictive model that can be used to determine the virality, number of shares generated, of a given piece of content. Authors at Mashable or a similar media company could then take findings from the model and further optimize the virality of the content.  These parameters could be simple things like word count of the title or paragraph or more complex changes, such as overall sentiment of the piece. 

Through developing more viral content, media companies will increase ad revenues and overall profitability. We primarily looked at this project through the eye of predictive modelling based on quantifiable article parameters like counts of words, pictures, videos etc. 

This objective evolved over the course of the project. Since the data was rather noisy, it was difficult to make a robust model that was generalizable enough. Specifically, the overall MAE (mean absolute error) was well into the 2000s [Range 1- ~ 150,000], so we switched our focus to finding a good balance between gains in MAE, computation time required for each analysis, and most important set of predictor variables.

## The Data

We started with a base dataset containing meta-data of nearly 40,000 unique Mashable blog articles over the past 5 years. The meta-data includes 61 different attributes ranging from metrics like word counts to sentiment analysis. This dataset is hosted on the Machine Learning Repository from the Center for Machine Learning and Intelligent Systems at the University of California Irvine. 

In addition to the meta-data, we were also interested in the actual article data, so we used a webscraper (using ‘rvest’) to collect the actual article titles, date published, author and article content. We joined these values into the base dataset.

## Dashboard

We created an interactive dashboard to further visualize the results.

[Dashboard](https://abhijith-asok.shinyapps.io/mashable_shares_prediction/) 

## Data Cleaning and Exploratory Data Analysis

To better understand our data, we first wanted to see how the number of shares varied for the articles in our data set. Looking at the summary information, we can see that the average article received about 3,400 shares.  Additionally, we see that the average shares per month varies, but does not show a general upward or downward trend. However, looking at a box and whisker plot, we see that there are many outliers that fell well above the mean.

While we didn’t want to eliminate all outliers from our dataset, we did eliminate them based on Cook’s distance and business logic. This analysis indicated  that anything roughly over 150,000 shares would be flagged as an outlier, the thinking being that our model should be representative of the typical Mashable article. If it happens to underestimate the actual result, due to an extremely rare, and viral article, that is acceptable from our perspective, since the blog will simply have more virality than expected.

Additionally, there are 1,992 total authors of which, 1,328 of them only produced one article, as seen in the table below. We decided to also eliminate articles produced by authors who only published 1 article. This is because we want our model to be representative for staff authors, not simply guest contributors.

Looking at the predictors, there were several with descriptions in the data dictionary were not clear enough to understand, so we eliminated them. 

These included things that we believe were related to variables such as, kw_min_min, kw_max_min, kw_avg_min, kw_min_max, kw_max_max, kw_avg_max, kw_min_avg, kw_max_avg, kw_avg_avg. 

Additionally, there were predictors related to Latent Dirichlet Allocation (LDA). Specifically, there were five topics that were defined, namely, LDA_00, LDA_01, LDA_02, LDA_03, and LDA_04. 

However, the data dictionary did not contain the semantic meaning of these topics, or details of whether they were developed using the article titles, bodies, or both. Hence, we eliminated these as well. Instead, we conducted our own topic modeling, and developed 8 topics of our own.  These topics were developed using just the content in the article titles, not the article bodies. We did not have enough computational power to conduct an analysis on the body.

It is a bit challenging to apply a semantic understanding to each of these, but if we had to categorize them, we’d do so in the following way:

Topic 1: Need to know tech information
Topic 2: Large tech company new product announcement
Topic 3: Social media/app information
Topic 4: Video tech news
Topic 5: World news
Topic 6: Need to know world tech news
Topic 7: App and gaming news
Topic 8: World tech news

## Methods Considered

To achieve our goal of reducing Mean Absolute Error(MAE), we conducted the following tasks and analyses.

**Random Sampling** - In order to establish a train and test set of data, we conducted random sampling. Our train set contained a random sample of 90% of our data and our test set contained the remaining 10% of our data.  This split was chosen since we wanted to get the most out of our data and we were less concerned with overfitting since we incorporated Tree based models for our sophisticated analysis.

**Mean Measure of Central Tendency** - To get a baseline MAE which we could compare all future analyses to, we used the mean number of shares across the whole dataset for each prediction. We used this as a method to evaluate all subsequent analyses. If a particular subsequent analysis failed to improve beyond the baseline MAE, we did not move forward with further optimizing that method.

**Author Effect** - We succespeted that on average some authors might outperform others. Therefore, we calculated the mean number of shares that each author received, and then used this in addition to the baseline mean prediction.  However, this actually worsened our MAE relative to the baseline MAE, so we did not incorporate it for future models.

**Top Words Effect** - We succespeted that on average some words in article titles might lead to a greater number of shares on average. Specifically, our hunch was if the articles contained words like “iPhone” or “App”, this might lead to a larger number of shares since these were two very popular topics during the time the articles were published. We used the tm package in R to conduct the text processing.  

We first extracted all article titles and created a corpus. Then, we conducted various data manipulation, such as making all words lowercase, removing any non-english words, removing stop words, and stemming the corpus.  Then we converted the corpus to a term-document matrix, and determined the most frequent terms at a specific frequency cutoff.  From this list of frequent terms, we used our intuitive business sense to select which words we thought would lead to more more shares. We chose words like, “Appl”, “Googl”, “App” (Note, the word is “Appl” not “Apple” due to stemming). We placed these words in our “Top Word” list.

To produce the model, we calculated the mean shares of articles that contained words in our train set. Then we evaluated articles in our test set, if they contained top words, we applied the mean value for top word articles, if not we applied the mean value for non-top word articles.

Unfortunately, the top-word effect actually worsened our MAE relative to the baseline MAE, so we did not incorporate it for future models.

**Correlations** - When conducting regressions with multiple predictors, it is important to exclude variables that are strongly correlated with each other.  Additionally, viewing the correlations of predictors can help us understand which of the predictors are most strongly correlated with shares.  You can see the correlation plot below. From this correlation analysis, we decided to remove the variables from our regression models listed in the table below, as these were highly correlated with another variable.

**Linear regression** - We started with a linear regression model of our data, as this is very simple  to implement and interpret.  

**Stepwise forward regression** - Given that we had many predictors, this method allowed us to incrementally incorporate the predictors which resulted in the lowest MAE. This allowed us to improve our MAE relative to the Base Linear Regression Model. (package - olsrr)

**Decision Trees** - Tree models are robust, meaning they are not impacted by correlations remaining in dataset.  This was advantageous to us given the large number of predictors we have. We developed a Decision Tree model to arrive at an MAE and also used it to create a    Variable Importance table (see below). (package - rpart)

**Random Forests** - Decision Trees are subject to overfitting whereas Random Forests are less so. Random Forests allowed us to lower our MAE further, and also gain exposure to Ensemble models. (package - caret, randomForest)

**Gradient Boosted Trees** - Gradient Boosted Trees are a deeper implementation of Random Forests. We suspected that they would further improve our MAE, since they incorporate incremental improvement in prediction within the Ensemble. Also, they are simply fascinating to use and used by most Kaggle Grandmasters. (package - caret, xgboost)

**Repeated Cross-Validation** - This method was used with Random Forests and Gradient Boosted Trees to further raise generalizability. (package - caret)

**Variable Importance** - This method allowed us to see which variables were most important in determining the number of shares.  By having a reduced number of predictors, we could conduct future analyses that required less computation time while still achieving close to the same MAE. Additionally, Variable Importance could allow for authors to better understand of which predictors are most important when creating content. Below we have shown a table listing the the most important variables, what each variable means, and a Pareto diagram indicating the relative importance of each variable. (package - rpart) 

**Computation Time** - As we implemented more sophisticated models, they required more computation power and time. In an effort to a model that was scalable in the real world without the need for expensive hardware, we evaluated several of the major models developed on an MAE/computation time basis. The plots below show this relationship for our models.

## Final Results

While we expected our task of predicting the number of shares for an article to be challenging, we now realize it is even more challenging than initially thought. For example, here are two articles, that are rather similar. Both discuss very popular tech products, Xbox and iPhone and have similar values for key metrics identified in the Variable Importance table above.  However, they have drastically different number of shares, 900 vs 197,000.

(Here are the links to the articles [Apple](http://mashable.com/2013/10/23/apple-new-ipads-brief/#W6ivLH0neiqu) and [Xbox](http://mashable.com/2013/12/25/xbox-one-getting-started/#BhHkViduzuqB))

That said, we learned that it is possible to create a good model that utilizes a number of predictors to determine the number of shares a given article. Additionally, we found that through implementing more sophisticated methods like Random Forests and Gradient Boosted Trees, we could further reduce our MAE by over 130 points over the prediction using share mean. 

**The final boosted model had an MAE of 2724.32. On average, our model is able to predict the shares of mashable articles with a maximum positive/negative difference of just over 2,700 shares.**

Additionally, from our Variable Importance table, we can say that authors at Mashable should focus on creating content that include, links to other Mashable articles that received a large number of shares, many images and videos, many links. Additionally, the article should focus on topics other than those that would be classified as “world”.

In the event that an author at Mashable does not have access to the computing power or knowledge required to run the more sophisticated models, he/she could simply conduct a regression using the variables listed in the Variable Importance table above, and still obtain useful results in a fraction of the time.

Last, we created a Shiny Dashboard to better visualize the major data used in our analysis.

[Interactive Dashboard](https://abhijith-asok.shinyapps.io/mashable_shares_prediction/) 

## Improvements

If were were to complete this project again, the following, if possible, would be helpful:

- **Having more data**: We had ~40,000 articles which is on the small side for having so many predictors. To put this in perspective, the Netflix Prize utilized over 100MM ratings, and had 4 predictors..  More data certainly would have helped us to create better models and therefore better predictions.

- **Better clarity regarding what each variable meant in the UCIrvine dataset**: As cited above, many variables were not properly defined in the data dictionary, so we had no choice but to throw them out from our analysis.

- **More computational power and time**: We could have applied NLP to the article content itself, rather than just the titles. From this, we could have generated potentially a better model, than what we were able to derive from just the titles. Additionally, we incorporated preliminary neural networks and deep learning implementations using H2O, but did not include them in our final analysis. They required significant time and computation power, to properly tune and execute the analysis, which were not at our disposal. Last, we could have applied more trees to our Gradient Boosted Tree analysis.
