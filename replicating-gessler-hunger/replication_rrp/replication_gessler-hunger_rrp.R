library(dplyr)
library(haven)
library(stringr)
library(plyr)
library(gtrendsR)
library(lubridate)


###############
# SALIENCE
###############

# Load PARTYPRESS monthly agendas (monthly issue attention)
monthly_agendas <- readRDS("datasets/rds/monthly_agendas.rds")


imm_salience <- monthly_agendas %>% filter(issue == 9)
imm_salience <- dplyr::rename(imm_salience, imm_salience = share_multi)

imm_salience$country <- imm_salience$country_name %>% str_replace_all(c("austria" = "AT", 
                                        "ireland" = "IE",
                                        "sweden" = "SE",
                                        "netherlands" = "NL",
                                        "uk" = "UK",
                                        "denmark" = "DK",
                                        "germany" = "DE",
                                        "poland" = "PL",
                                        "spain" = "ES")) #%>% table(useNA = "always")
imm_salience$ym <- str_c(substr(imm_salience$month, 3, 4), "-", substr(imm_salience$month, 5, 6))
imm_salience[1:20, ]


###############
# POLLS
###############


# Load polls data and aggregate monthly
polls <- readRDS("polls/polls.RDS") %>% mutate(polling = percent) %>% 
  mutate(ym = substr(date, 3, 7)) %>% 
  aggregate(polling ~ country + parlgov_id + party_name + ym, ., function(x) mean(x, na.rm = T))

# Merge issue attention and polls
replication <- merge(imm_salience, select(polls, -c(country, party_name)), all = T, by = c("parlgov_id", "ym"))



###############
# DEFINING RRP
###############

# Abou-Chadi, T., & Krause, W. (2020). The Causal Effect of Radical Right Success on Mainstream Parties’ Policy Positions: A Regression Discontinuity Approach. British Journal of Political Science, 50(3), 829-847. doi:10.1017/S0007123418000029

listparty <- unique(filter(replication, !is.na(polling) & !is.na(country)) %>% select(c(country, parlgov_id, party_name)))
listparty[order(listparty$country), ]

# Define RRPs by ParlGov ID
rrp <- c(50, # AT: FPÖ
         2253, # DE: AfD
         1418, # DK: DF
         # ES
         528, # PL: PiS
         # IE
         990, # NL: PvdV
         1546, # SE: SD
         1272 # UK: UKIP
         )


###############
# RRP SALIENCE
###############

# Add data about RRP salience
replication <- imm_salience %>% 
  filter(parlgov_id %in% rrp) %>% 
  mutate(rrp_salience = imm_salience) %>% 
  select(c(country, rrp_salience, ym)) %>% 
  merge(replication, by = c("country", "ym"), all = T)



###############
# RRP POLLS
###############

# Add polling data
replication <- polls %>% 
  filter(parlgov_id %in% rrp) %>% 
  mutate(rrp_polling = polling) %>% 
  select(c(country, rrp_polling, ym)) %>% 
  merge(replication, by = c("country", "ym"), all = T)


###############
# ASYLUM
###############

# "For severity, we use the monthly number of asylum applications as research assumes that refugee arrival and the state's capacity to react determines the problematization of immigration in public discourse." (Gessler & Hunger, 2022)

# Add monthly asylum data
asylum <- read.csv("asylum-eurostat/migr_asyappctzm__custom_627198_page_linear.csv") %>% 
  mutate(ym = TIME_PERIOD %>% substr(3, 7),
         country = geo,
         asylum = OBS_VALUE) %>% 
  select(country, ym, asylum)

replication <- asylum %>% merge(replication, by = c("country", "ym"), all = T)

# Transform
replication$asylum_z <- scale(replication$asylum, center = TRUE, scale = TRUE) %>% as.numeric



###############
# LAGS
###############

# done in Stata


###############
# GOOGLE TRENDS (aka public salience)
###############

# replication$pub_salience_z <- scale(replication$pub_salience_z, center = TRUE, scale = TRUE)


pub_salience <- gtrends("Flüchtling", geo = "DE", time = "2010-01-01 2020-12-31", onlyInterest = T)$interest_over_time


# gtrends("Flüchtling", geo = "AT", time = "2010-01-01 2020-12-31", onlyInterest = T)

if(!("AT" %in% pub_salience$geo)) pub_salience <- gtrends("Flüchtling", geo = "AT", time = "2010-01-01 2020-12-31", onlyInterest = T)$interest_over_time %>% rbind.fill(pub_salience)

if(!("IE" %in% pub_salience$geo)) pub_salience <- gtrends("refugee", geo = "IE", time = "2010-01-01 2020-12-31", onlyInterest = T)$interest_over_time %>% rbind.fill(pub_salience)

if(!("GB" %in% pub_salience$geo)) pub_salience <- gtrends("refugee", geo = "GB", time = "2010-01-01 2020-12-31", onlyInterest = T)$interest_over_time %>% rbind.fill(pub_salience)

if(!("NL" %in% pub_salience$geo)) pub_salience <- gtrends("vluchteling", geo = "NL", time = "2010-01-01 2020-12-31", onlyInterest = T)$interest_over_time %>% rbind.fill(pub_salience)

# if(!("PL" %in% pub_salience$geo)) pub_salience <- gtrends("uchodźca", geo = "PL", time = "2010-01-01 2020-12-31", onlyInterest = T)$interest_over_time %>% rbind.fill(pub_salience)

if(!("DK" %in% pub_salience$geo)) pub_salience <- gtrends("flygtning", geo = "DK", time = "2010-01-01 2020-12-31", onlyInterest = T)$interest_over_time %>% rbind.fill(pub_salience)

if(!("SE" %in% pub_salience$geo)) pub_salience <- gtrends("flykting", geo = "SE", time = "2010-01-01 2020-12-31", onlyInterest = T)$interest_over_time %>% rbind.fill(pub_salience)

if(!("ES" %in% pub_salience$geo)) pub_salience <- gtrends("refugiado", geo = "ES", time = "2010-01-01 2020-12-31", onlyInterest = T)$interest_over_time %>% rbind.fill(pub_salience)

pub_salience$geo %>% table

pub_salience <- pub_salience %>% mutate(pub_salience = hits %>% str_remove("<") %>% as.numeric, country = str_replace(geo, "GB", "UK"), ym = substr(date, 3, 7))

pub_salience$pub_salience_z <- scale(pub_salience$pub_salience, center = TRUE, scale = TRUE)  %>% as.numeric

replication <- pub_salience %>% select(country, ym, pub_salience, pub_salience_z) %>% merge(replication, by = c("country", "ym"), all = T)


save(replication, file = "replication_rrp.RData")


###############
# RENAMING VARS TO FIT ORIGINAL DO FILE
###############


names(replication)


stata <- replication %>% dplyr::rename(sal = imm_salience,
                                       sal_rrp = rrp_salience,
                                       noref_z = asylum_z,
                                       polls_ppr = rrp_polling,
                                       refugees_z = pub_salience_z) %>% select(country, ym, sal, sal_rrp, noref_z, polls_ppr, refugees_z, polling, parlgov_id, party_name)


# Drop rrp parties
stata <- filter(stata, !(parlgov_id %in% rrp))

stata <- stata[stata$party_name != "Kukiz'15 (2015-2019)", ]
stata <- stata[!(stata$parlgov_id == 512 & stata$ym == "19-08"), ]

stata$sal <- stata$sal*100
stata$sal_rrp <- stata$sal_rrp*100


stata$date <- ym(stata$ym)

# Write to DTA
write_dta(stata, path = "stata-replication_rrp.dta")

