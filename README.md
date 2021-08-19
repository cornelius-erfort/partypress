# scripts-issue-agendas
Political parties emphasize different issues in their public communication efforts to address the topics of the day and to strengthen their policy profiles.

This repository contains the scripts for our textmodels. The underlying dataset of press releases is not published here.

## Classification methods

### Supervised learning aggregated

We calculate a Multinomial Naive Bayes text classification model and then aggregate the number of press releases per issue by quarter. In order to get a relative measure of issue attention for each party, we divide the number of issue-specific press releases by the total number of press releases by that party in each quarter. We define five folds for cross-validation. Our test dataset thus makes up 20% of documents.

### Readme2
Additionally, we use the package <a href = "https://github.com/iqss-research/readme-software">readme2</a> by Jerzak et al. (forthcoming) to estimate the proportion of press releases regarding each topic. We do so by defining five folds for cross-validation. Our test dataset thus makes up 20% of documents.

In a first step, we vectorize our courpus using a pre-trained word vector (embeddings trained on German Wikipedia, source: https://deepset.ai/german-word-embeddings). Second, we generate vector summaries for all documents. Third, we run the readme function to obtain predictions about the proportions in our test data.

(Jerzak, C. T., King, G., & Strezhnev, A. (forthcoming). An improved method of auto-mated nonparametric content analysis for social science. Political Analysis.)

## Results

### Comparison of classificitation methods

*Aggregated predictions across 17 categories*
<img src="https://github.com/cornelius-erfort/scripts-issue-agendas/raw/main/plots/agg_eval_compare_facet.png" width="80%">

*Issue attention over time of German parties to issue "7 - Environment and Energy" (Transformers GBERT)* 
<img src="https://github.com/cornelius-erfort/scripts-issue-agendas/raw/main/plots/7%20-%20Environment%20and%20Energy_all-parties_facet.png" width="80%">

*Issue attention over time of German parties to issue "9 - Immigration" (Transformers GBERT)*
<img src="https://github.com/cornelius-erfort/scripts-issue-agendas/raw/main/plots/9%20-%20Immigration_all-parties_facet.png" width="80%">

*Accuracy for different sizes of the training data for three different models*
<img src="https://github.com/cornelius-erfort/scripts-issue-agendas/blob/main/plots/training-size-simulation.png" width="80%">

For the multi-lingual model, the size refers to the number of documents in the language of the test sample. The training data contained labeled documents in other languages.


