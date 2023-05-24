
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


# Load PARTYPRESS monthly agendas (monthly issue attention)
monthly_agendas <- readRDS("datasets/rds/monthly_agendas.rds")


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
polls <- readRDS("polls/polls.RDS") %>% mutate(polling = percent) %>% 
  mutate(ym = substr(date, 3, 7)) %>% 
  aggregate(polling ~ country + parlgov_id + party_name + ym, ., function(x) mean(x, na.rm = T))

# Merge issue attention and polls
replication <- merge(imm_salience, select(polls, -c(country, party_name)), all = T, by = c("parlgov_id", "ym"))



###############
# DEFINING GREEN PARTIES
###############

# Abou-Chadi, T., & Krause, W. (2020). The Causal Effect of Radical Right Success on Mainstream Parties’ Policy Positions: A Regression Discontinuity Approach. British Journal of Political Science, 50(3), 829-847. doi:10.1017/S0007123418000029

listparty <- unique(filter(replication, !is.na(polling) & !is.na(country)) %>% 
                      select(c(country, parlgov_id, party_name)))

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

# Add data about Green party salience

replication <- green_salience %>% 
  filter(parlgov_id %in% green_p) %>% 
  mutate(green_p_salience = green_salience) %>% 
  select(c(country, green_p_salience, ym)) %>% 
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
# LAGS
###############

# done in Stata


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

# Write to DTA
write_dta(stata, path = "stata-replication_green.dta")

