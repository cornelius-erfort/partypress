# scripts-issue-agendas
Political parties emphasize different issues in their public communication efforts to address the topics of the day and to strengthen their policy profiles.

This repository contains the scripts for our textmodels. The underlying dataset of press releases is not published here.

### Supervised learning aggregated

We calculate a Multinomial Naive Bayes text classification model and then aggregate the number of press releases per issue by quarter. In order to get a relative measure of issue attention for each party, we divide the number of issue-specific press releases by the total number of press releases by that party in each quarter.

*Issue attention of party CDU/CSU (Germany) to issue "9 - Immigration"*
<img src="https://github.com/cornelius-erfort/scripts-issue-agendas/blob/main/plots/9 - Immigration_union_fraktion.png" width="60%">

*Comparison of classificitation methods across 17 categories*
<img src="https://github.com/cornelius-erfort/scripts-issue-agendas/blob/main/plots/agg_eval_compare.png" width="60%">

