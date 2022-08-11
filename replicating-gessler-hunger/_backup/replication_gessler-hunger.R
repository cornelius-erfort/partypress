library(dplyr)
library(haven)
library(stringr)
library(plyr)

# Load the press releases data
load("data/alldocs_lab_notxt.RData")
alldocs <- alldocs_lab_notxt
rm(alldocs_lab_notxt)

# Aggregate press releases monthly
alldocs$month <- substr(alldocs$date, 1, 7)
alldocs$n <- 1

# Create dataframe with monthly issue attention
issue_att <- merge(aggregate(n ~ country + parlgov_id + month + issue_pred, alldocs, sum),
                         aggregate(n ~ parlgov_id + month, alldocs, sum) %>% dplyr::rename(n_party = n),
                         by = c("parlgov_id", "month"))
issue_att$issue_att <- issue_att$n/issue_att$n_party * 100
issue_att <- issue_att %>% filter(country %in% c("germany", "austria"))
issue_att$ym <- substr(issue_att$month, 3, 8)


# Add category 9 where it is missing but other categories exist
add_obs <- unique(select(issue_att, c(parlgov_id, ym)))
add_obs$issue_att <- 0
add_obs$issue_pred <- 9

existing_obs <- (issue_att %>% filter(issue_pred == 9) %>% select(parlgov_id, ym))

issue_att <- rbind.fill(issue_att, add_obs[!(str_c(add_obs$parlgov_id, add_obs$ym) %in% str_c(existing_obs$parlgov_id, existing_obs$ym)), ])



# Make ready for merging with Gessler/Hunger
issue_att <- issue_att %>% filter(issue_pred == 9)


gessler <- read_dta("data/gessler-hunger_stata_data.dta")


# Add parlgov_id
parties <- data.frame(party = unique(gessler$party[gessler$country != "Switzerland"]) %>% sort, 
           parlgov_id = c(1727, NA, 543, 1429, 772, 791, 2255, 1013, 558, 973))


replication <- merge(gessler, parties, by = "party", all.x = T)

replication <- merge(replication, issue_att %>% select(-c(country)), by = c("parlgov_id", "ym"), all.x = T)

cor(replication[, c("sal", "issue_att")] %>% filter(!is.na(sal) & !is.na(issue_att)))

replication$sal_repl <- replication$issue_att

unique(gessler$party[gessler$country != "Switzerland"]) %>% sort

# Add rrp salience
rrp <- issue_att %>% filter(issue_pred == 9 & parlgov_id %in% c(2253, 50)) %>% select(c(country, issue_att, ym)) %>% dplyr::rename(sal_rrp_repl = issue_att) %>% mutate(country = str_to_title(country))


replication <- merge(replication, rrp, by = c("country", "ym"), all.x = T)


replication$sal[!is.na(replication$sal_repl)] %>% summary
replication$sal_repl[!is.na(replication$sal)] %>% summary

write_dta(replication, path = "replication.dta")
