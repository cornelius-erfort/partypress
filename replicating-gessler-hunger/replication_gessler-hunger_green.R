
library(dplyr)
library(haven)
library(stringr)
library(plyr)
library(gtrendsR)
library(lubridate)

setwd("replicating-gessler-hunger")


###############
# SALIENCE
###############



# partypress <- readRDS("publication/rds/partypress.rds")
monthly_agendas <- readRDS("../publication/rds/monthly_agendas.rds")

# # Load the press releases data
# load("data/salience/alldocs_lab_notxt.RData")
# alldocs <- alldocs_lab_notxt
# rm(alldocs_lab_notxt)
# 
# # Aggregate press releases monthly
# alldocs$month <- substr(alldocs$date, 1, 7)
# alldocs$n <- 1
# 
# # Create dataframe with monthly issue attention
# green_salience <- merge(aggregate(n ~ country + parlgov_id + month + issue_pred, alldocs, sum),
#                    aggregate(n ~ parlgov_id + month, alldocs, sum) %>% dplyr::rename(n_party = n),
#                    by = c("parlgov_id", "month"))
# 
# 
# green_salience$green_salience <- green_salience$n/green_salience$n_party * 100
# # green_salience <- green_salience %>% filter(country %in% c("germany", "austria"))
# green_salience$ym <- substr(green_salience$month, 3, 8)
# green_salience <- select(green_salience, -c(month))
# 
# # # Add category 9 where it is missing but other categories exist
# add_obs <- unique(select(green_salience, c(parlgov_id, country, ym)))
# add_obs$green_salience <- 0
# add_obs$issue_pred <- 9
# 
# existing_obs <- (green_salience %>% filter(issue_pred == 9) %>% select(parlgov_id, ym))
# 
# nrow(green_salience)
# green_salience <- rbind.fill(green_salience, add_obs[!(str_c(add_obs$parlgov_id, add_obs$ym) %in% str_c(existing_obs$parlgov_id, existing_obs$ym)), ])
# nrow(green_salience)

green_salience <- monthly_agendas %>% filter(issue %in% c(7))
green_salience <- dplyr::rename(green_salience, green_salience = share_multi)

green_salience$country <- green_salience$country_name %>% str_replace_all(c("austria" = "AT", 
                                                                        "ireland" = "IE",
                                                                        "sweden" = "SE",
                                                                        "netherlands" = "NL",
                                                                        "uk" = "UK",
                                                                        "denmark" = "DK",
                                                                        "germany" = "DE",
                                                                        "poland" = "PL",
                                                                        "spain" = "ES")) #%>% table(useNA = "always")
green_salience$ym <- str_c(substr(green_salience$month, 3, 4), "-", substr(green_salience$month, 5, 6))
green_salience[1:20, ]


###############
# POLLS
###############


# Load polls data and aggregate monthly
polls <- readRDS("data/polls/polls.RDS") %>% mutate(polling = percent) %>% 
  mutate(ym = substr(date, 3, 7)) %>% 
  aggregate(polling ~ country + parlgov_id + party_name + ym, ., function(x) mean(x, na.rm = T))

# Merge issue attention and polls
replication <- merge(green_salience, select(polls, -c(country, party_name)), all = T, by = c("parlgov_id", "ym"))

# save(replication, file = "data/replication.RData")

# table(green_salience$parlgov_id == 1644)

###############
# DEFINING RRP
###############

# Abou-Chadi, T., & Krause, W. (2020). The Causal Effect of Radical Right Success on Mainstream Parties’ Policy Positions: A Regression Discontinuity Approach. British Journal of Political Science, 50(3), 829-847. doi:10.1017/S0007123418000029

listparty <- unique(filter(replication, !is.na(polling) & !is.na(country)) %>% select(c(country, parlgov_id, party_name)))
listparty[order(listparty$country), ]


green_p <- c(1429, # AT: Grüne
         772, # DE: Grüne
         1644, # DK: SF  (2567 Alternativet, 306 Enhedslisten)
         # ES
         # PL:
         1573, # IE: Green
         756, # NL: GroenLinks
         1546, # SE: Miljöpartiet de Gröna
         1272 # UK: Greens
)


###############
# RRP SALIENCE
###############

replication <- green_salience %>% filter(parlgov_id %in% green_p) %>% mutate(green_p_salience = green_salience) %>% select(c(country, green_p_salience, ym)) %>% merge(replication, by = c("country", "ym"), all = T)


# save(replication, file = "data/replication.RData")


###############
# RRP POLLS
###############


replication <- polls %>% filter(parlgov_id %in% green_p) %>% mutate(green_polling = polling) %>% select(c(country, green_polling, ym)) %>% merge(replication, by = c("country", "ym"), all = T)


###############
# ASYLUM
###############

# For severity, we use the monthly number of asylum applications as research assumes that refugee arrival and the state's capacity to react determines the problematization of immigration in public discourse.

# asylum <- read.csv("data/asylum-eurostat/migr_asyappctzm__custom_627198_page_linear.csv") %>% 
#   mutate(ym = TIME_PERIOD %>% substr(3, 7),
#          country = geo,
#          asylum = OBS_VALUE) %>% 
#   select(country, ym, asylum)
# 
# replication <- asylum %>% merge(replication, by = c("country", "ym"), all = T)
# 
# replication$asylum_z <- scale(replication$asylum, center = TRUE, scale = TRUE) %>% as.numeric


###############
# PARLGOV
###############

# parlgov <- read_csv("data/parlgov_view_party.csv") %>% dplyr::rename(parlgov_id = party_id, parlgov_party_name = party_name)
# 
# replication <- merge(green_salience_polls, parlgov, by = "parlgov_id", all.x = T)
# 
# not needed



###############
# LAGS
###############

# done in Stata




###############
# GOOGLE TRENDS (aka public salience)
###############

# Alternatively, we also consider that what mattered could be the perception of a crisis rather than the extent of refugee arrivals. Given the scarcity of opinion data over time, we rely on Google Search Trends to measure public attention to immigration. Specifically, we use the Google Knowledge Graph technology to track the frequency of a search query topic rather than individual search strings (Siliverstovs and Wochner, Reference Siliverstovs and Wochner2018). In line with advice from previous applications (Granka, Reference Granka2013; Mellon, Reference Mellon2013; Chykina and Crabtree, Reference Chykina and Crabtree2018), we compare different search trends with Eurobarometer results for immigration salience as the most important problem in a country and select the Google trend for “refugee” as closest correlate to the Eurobarometer in Germany and Austria. T

# replication$pub_salience_z <- scale(replication$pub_salience_z, center = TRUE, scale = TRUE)


# pub_salience <- gtrends("Flüchtling", geo = "DE", time = "2010-01-01 2020-12-31", onlyInterest = T)$interest_over_time
# 
# 
# # gtrends("Flüchtling", geo = "AT", time = "2010-01-01 2020-12-31", onlyInterest = T)
# 
# if(!("AT" %in% pub_salience$geo)) pub_salience <- gtrends("Flüchtling", geo = "AT", time = "2010-01-01 2020-12-31", onlyInterest = T)$interest_over_time %>% rbind.fill(pub_salience)
# 
# if(!("IE" %in% pub_salience$geo)) pub_salience <- gtrends("refugee", geo = "IE", time = "2010-01-01 2020-12-31", onlyInterest = T)$interest_over_time %>% rbind.fill(pub_salience)
# 
# if(!("GB" %in% pub_salience$geo)) pub_salience <- gtrends("refugee", geo = "GB", time = "2010-01-01 2020-12-31", onlyInterest = T)$interest_over_time %>% rbind.fill(pub_salience)
# 
# if(!("NL" %in% pub_salience$geo)) pub_salience <- gtrends("vluchteling", geo = "NL", time = "2010-01-01 2020-12-31", onlyInterest = T)$interest_over_time %>% rbind.fill(pub_salience)
# 
# if(!("PL" %in% pub_salience$geo)) pub_salience <- gtrends("uchodźca", geo = "PL", time = "2010-01-01 2020-12-31", onlyInterest = T)$interest_over_time %>% rbind.fill(pub_salience)
# 
# if(!("DK" %in% pub_salience$geo)) pub_salience <- gtrends("flygtning", geo = "DK", time = "2010-01-01 2020-12-31", onlyInterest = T)$interest_over_time %>% rbind.fill(pub_salience)
# 
# if(!("SE" %in% pub_salience$geo)) pub_salience <- gtrends("flykting", geo = "SE", time = "2010-01-01 2020-12-31", onlyInterest = T)$interest_over_time %>% rbind.fill(pub_salience)
# 
# if(!("ES" %in% pub_salience$geo)) pub_salience <- gtrends("refugiado", geo = "ES", time = "2010-01-01 2020-12-31", onlyInterest = T)$interest_over_time %>% rbind.fill(pub_salience)
# 
# pub_salience$geo %>% table
# 
# pub_salience <- pub_salience %>% mutate(pub_salience = hits %>% str_remove("<") %>% as.numeric, country = str_replace(geo, "GB", "UK"), ym = substr(date, 3, 7))
# 
# pub_salience$pub_salience_z <- scale(pub_salience$pub_salience, center = TRUE, scale = TRUE)  %>% as.numeric
# 
# replication <- pub_salience %>% select(country, ym, pub_salience, pub_salience_z) %>% merge(replication, by = c("country", "ym"), all = T)


# save(replication, file = "data/replication.RData")

###############
# DEFINING CR PARTIES
###############

# not needed


###############
# DEFINING TIMES OF CRISIS
###############

# To delimit the crisis period, we additionally calculate a binary measure based on this series. We determine as refugee crisis the period in which the searches for the refugee topic are above the country average. Thereby, we place the start of the crisis in July 2015 in Austria, and in August 2015 in Germany and Switzerland. This period of heightened attention ends in July 2016 in Austria, in November 2016 in Germany, and in February 2017 in Switzerland, the first month in which attention to the topic falls below the mean.

# not needed


###############
# RENAMING VARS TO FIT ORIGINAL DO FILE
###############


names(replication)


stata <- replication %>% dplyr::rename(sal = green_salience,
                                       sal_green_p = green_p_salience,
                                       # noref_z = asylum_z,
                                       polls_green = green_polling,
                                       # refugees_z = pub_salience_z
                                       ) %>% select(country, ym, sal, sal_green_p, polling, parlgov_id, party_name, polls_green) # , noref_z, polls_ppr, refugees_z, 


# Drop green parties
stata <- filter(stata, !(parlgov_id %in% green_p))

stata <- stata[stata$party_name != "Kukiz'15 (2015-2019)", ]
stata <- stata[!(stata$parlgov_id == 512 & stata$ym == "19-08"), ]

stata$sal <- stata$sal*100
stata$sal_green_p <- stata$sal_green_p*100


stata$date <- ym(stata$ym)
write_dta(stata, path = "stata-replication-green.dta")

