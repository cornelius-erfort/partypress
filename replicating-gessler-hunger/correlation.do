cd "C:\Users\scripts\Desktop\SCRIPTS\GitHub\scripts-issue-agendas\replicating-gessler-hunger\"


use "gessler-hunger.dta" , clear
* use "stata-replication.dta" , clear

replace parlgov_id = 1727 if party == "cdu"
replace parlgov_id = 543 if party == "fdp"
replace parlgov_id = 1429 if party == "gr_at"
replace parlgov_id = 772 if party == "gr_de"
replace parlgov_id = 791 if party == "linke"
replace parlgov_id = 2255 if party == "neos"
replace parlgov_id = 1013 if party == "ovp"
replace parlgov_id = 558 if party == "spd"
replace parlgov_id = 973 if party == "spo"

drop if parlgov_id == .


merge 1:1  parlgov_id ym using "stata-replication.dta"

cor sal sal_repl // 0.7263

reg sal sal_repl
